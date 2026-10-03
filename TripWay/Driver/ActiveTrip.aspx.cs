using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Driver
{
    public partial class ActiveTripPage : Helper.ListPageBase
    {
        private int TripId { get { return ViewState["TripID"] != null ? Convert.ToInt32(ViewState["TripID"]) : 0; } }

        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";
        public string MeJson { get; private set; } = "null";

        // Read by the chat panel markup. The page directive compiles into a separate class,
        // so the chat config has to be exposed publicly rather than reusing private TripId.
        public string ChatTripId { get { return TripId > 0 ? TripId.ToString() : "0"; } }
        public string ChatApiUrl { get { return ResolveUrl("~/Handlers/TripApi.ashx"); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            Helper.TripHelper.EnsureTripStops();
            Helper.TripHelper.EnsureEtaColumns();
            Bind();
        }

        /// <summary>
        /// The single action on the page. Its label is rebuilt in BindTrip to match the step
        /// the trip is waiting on, and the step itself is decided from a fresh status read
        /// rather than from ViewState, so a double click or a stale form cannot skip a stage.
        /// </summary>
        protected void btnNext_Click(object sender, EventArgs e)
        {
            if (TripId <= 0) return;

            string status = CurrentStatus();
            if (status == "Accepted")
            {
                ApplyStatus("Status='Arrived', ArrivedAt=SYSUTCDATETIME()", "Status='Accepted'", "Arrived");
            }
            else if (status == "Arrived")
            {
                ApplyStatus("Status='Started', StartedAt=SYSUTCDATETIME(), PaymentStatus='Unpaid'", "Status='Arrived'", "Started");
            }
            else if (status == "Started")
            {
                if (!IsPaid())
                {
                    if (SetPaymentStatus("Paid", "Collected the fare from the customer."))
                        ShowMessage("Fare collected. Finish the trip once you drop the customer off.", true);
                }
                else if (ApplyStatus("Status='Completed', CompletedAt=SYSUTCDATETIME()", "Status='Started'", "Completed"))
                {
                    ShowMessage("Trip completed and moved to Trip History.", true);
                }
            }
            else
            {
                ShowError("This trip is not waiting on you any more.");
            }

            // Page_Load runs before this handler, so the page on screen was bound with the
            // status this click has just changed. Rebinding here is what makes the button
            // advance straight away instead of only after a manual refresh.
            Bind();
        }

        protected void btnMarkUnpaid_Click(object sender, EventArgs e)
        {
            if (TripId <= 0) return;
            SetPaymentStatus("Unpaid", "Marked the fare as still unpaid.");
            Bind();
        }

        /// <summary>
        /// Drops the trip from the active list at whatever stage it has reached. A driver can
        /// need to back out at any point, so this is offered on every step rather than only at
        /// the start. The guard lists the three active statuses together, which is what stops a
        /// double click or a stale form cancelling a trip that already finished or was cancelled.
        /// The status comes from a fresh read rather than ViewState for the same reason.
        /// </summary>
        protected void btnCancel_Click(object sender, EventArgs e)
        {
            if (TripId <= 0) return;

            string status = CurrentStatus();
            if (status != "Accepted" && status != "Arrived" && status != "Started")
            {
                ShowError("This trip is not active any more, so it cannot be cancelled.");
                Bind();
                return;
            }

            // The fare can only have been collected at the last step, and it has to be released
            // while the trip is still Started: SetPaymentStatus refuses to touch a payment once
            // the trip is not Started, and a trip cancelled with a Paid fare would otherwise sit
            // in history claiming the driver was paid for a ride they never finished.
            if (status == "Started" && IsPaid())
                SetPaymentStatus("Unpaid", "Released the fare because the trip was cancelled.");

            // CompletedAt is deliberately left alone: the customer and API cancel paths do the same, and
            // a cancelled trip never completed, so the detail page must not show a completed
            // timestamp for it.
            if (!ApplyStatus("Status='Cancelled'",
                             "Status IN ('Accepted','Arrived','Started')", "Cancelled",
                             "Driver " + Helper.AuthHelper.GetAccountId() + " cancelled trip "
                               + TripId + " while it was " + status.ToLowerInvariant() + "."))
            {
                Bind();
                return;
            }

            // The trip has left the active list, so this confirmation is the only thing left on
            // screen that still tells the driver what happened.
            ShowMessage("Trip cancelled and moved to Trip History.", true);
            Bind();
        }

        /// <summary>Status read straight from the row, so the next step is never guessed from stale markup.</summary>
        private string CurrentStatus()
        {
            object o = Helper.DBHelper.ExecuteScalar(
                "SELECT Status FROM Trips WHERE TripID=@t AND DriverID=@d",
                new SqlParameter("@t", TripId), new SqlParameter("@d", Helper.AuthHelper.GetAccountId()));
            return o != null && o != DBNull.Value ? o.ToString() : "";
        }

        private bool IsPaid()
        {
            object o = Helper.DBHelper.ExecuteScalar(
                "SELECT PaymentStatus FROM Trips WHERE TripID=@t AND DriverID=@d",
                new SqlParameter("@t", TripId), new SqlParameter("@d", Helper.AuthHelper.GetAccountId()));
            return o != null && o != DBNull.Value && o.ToString() == "Paid";
        }

        /// <summary>
        /// Flips the fare between Paid and Unpaid, but only while the trip is actually under
        /// way. The Payments row is upserted in the same statement because nothing creates it
        /// at booking time, so a bare UPDATE would mark the trip Paid while recording nothing.
        /// </summary>
        private bool SetPaymentStatus(string status, string logMessage)
        {
            int driverId = Helper.AuthHelper.GetAccountId();
            string method = CurrentPaymentMethod();
            int done;
            using (SqlConnection cn = Helper.DBHelper.GetConnection())
            {
                cn.Open();
                using (SqlCommand cmd = new SqlCommand(
                    @"DECLARE @done INT = 0;
                      IF EXISTS (SELECT 1 FROM Trips
                                  WHERE TripID=@t AND DriverID=@d AND Status='Started')
                      BEGIN
                        UPDATE Trips SET PaymentStatus=@p, PaymentMethod=ISNULL(NULLIF(@m,''),PaymentMethod)
                         WHERE TripID=@t AND DriverID=@d AND Status='Started';
                        -- Same upsert reason as the rest of this flow: nothing creates a
                        -- Payments row at booking time, so a bare UPDATE would mark the
                        -- trip Paid while recording nothing.
                        IF @p='Paid'
                        BEGIN
                            IF EXISTS (SELECT 1 FROM Payments WHERE TripID=@t)
                                UPDATE Payments SET Amount=(SELECT Fare FROM Trips WHERE TripID=@t),
                                                   Method=ISNULL(NULLIF(@m,''),Method),
                                                   Status='Paid', PaidAt=SYSUTCDATETIME()
                                 WHERE TripID=@t;
                            ELSE
                                INSERT INTO Payments (TripID, Amount, Method, Status, PaidAt)
                                SELECT @t, Fare, ISNULL(NULLIF(@m,''), ISNULL(PaymentMethod,'Cash')),
                                       'Paid', SYSUTCDATETIME()
                                  FROM Trips WHERE TripID=@t;
                        END
                        ELSE
                            UPDATE Payments SET Status='Pending', PaidAt=NULL WHERE TripID=@t;
                        SET @done = 1;
                      END
                      SELECT @done;", cn))
                {
                    cmd.Parameters.AddWithValue("@t", TripId);
                    cmd.Parameters.AddWithValue("@d", driverId);
                    cmd.Parameters.AddWithValue("@p", status);
                    cmd.Parameters.AddWithValue("@m", method);
                    done = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }

            if (done == 0)
            {
                ShowError("You can only change the payment status once the trip has started.");
                return false;
            }
            Helper.TripHelper.LogActivity("Payment", TripId,
                "Driver " + driverId + " set payment to " + status + ". " + logMessage);
            ShowError("");
            return true;
        }

        private string CurrentPaymentMethod()
        {
            object o = Helper.DBHelper.ExecuteScalar(
                "SELECT ISNULL(PaymentMethod,'') FROM Trips WHERE TripID=@t",
                new SqlParameter("@t", TripId));
            return o != null && o != DBNull.Value ? o.ToString() : "";
        }

        /// <summary>
        /// Every status button funnels through here so the guard lives in one place: the
        /// UPDATE only lands when the trip is still in the state that button belongs to,
        /// which is what stops a double-click moving a trip two steps at once. The log line
        /// is passed in rather than built here because advancing forward and backing out of
        /// a trip are not the same event and should not read the same way in the history.
        /// </summary>
        private bool ApplyStatus(string set, string guard, string label, string logDetails)
        {
            int driverId = Helper.AuthHelper.GetAccountId();
            int rows = Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Trips SET " + set + " WHERE TripID=@t AND DriverID=@d AND " + guard,
                new SqlParameter("@t", TripId), new SqlParameter("@d", driverId));

            if (rows == 0)
            {
                ShowError("Trip is not in the correct state for this action.");
                return false;
            }
            ShowError("");
            Helper.TripHelper.LogActivity(label, TripId, logDetails);
            return true;
        }

        /// <summary>Advance-onwards variant, which is the only event that reads as progress.</summary>
        private bool ApplyStatus(string set, string guard, string label)
        {
            return ApplyStatus(set, guard, label,
                "Driver " + Helper.AuthHelper.GetAccountId() + " advanced trip to " + label + ".");
        }

        private void ShowError(string message)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = !string.IsNullOrEmpty(message);
            pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200";
        }

        private void ShowMessage(string message, bool ok)
        {
            if (string.IsNullOrEmpty(message))
            {
                pnlMessage.Visible = false;
                return;
            }
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = ok
                ? "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200"
                : "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200";
        }

        private void Bind()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT TOP 1 t.*, s.Name AS ServiceName, v.Name AS VehicleName, p.Name AS PackageName,
                         ISNULL(c.FullName, '—') AS CustomerName, c.PhoneNumber AS CustomerPhone,
                         c.Gender AS CustomerGender, c.ProfilePhotoUrl AS CustomerPhoto,
                         c.CreatedAt AS CustomerSince, d.VehiclePlateNumber AS PlateNumber,
                         d.FullName AS DriverName,
                         rt.Score AS RatingScore, rt.Comment AS RatingComment,
                         pay.Amount AS PaidAmount, pay.PaidAt AS PaidAt,
                         (SELECT COUNT(*) FROM TripStops ts WHERE ts.TripID=t.TripID) AS StopsCount
                   FROM Trips t
                   INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                   INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                   INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                   INNER JOIN Drivers d ON t.DriverID = d.DriverID
                   LEFT JOIN Packages p ON t.PackageID = p.PackageID
                   LEFT JOIN Ratings rt ON rt.TripID = t.TripID
                   LEFT JOIN Payments pay ON pay.TripID = t.TripID
                   WHERE t.DriverID=@id AND t.Status IN ('Accepted','Arrived','Started')
                   ORDER BY t.TripID DESC",
                new SqlParameter("@id", Helper.AuthHelper.GetAccountId()));

            if (t.Rows.Count == 0)
            {
                pnlNoTrip.Visible = true;
                pnlTrip.Visible = false;
                // Nothing is in progress, so there is no step left to offer, nothing to back
                // out of, and the status the header was showing no longer belongs to anything.
                pnlNextAction.Visible = false;
                btnCancel.Visible = false;
                pnlStatusRow.Visible = false;
                pnlSubtitle.Visible = false;
                return;
            }

            BindTrip(t.Rows[0]);
        }

        /// <summary>
        /// Clears the Done/Upcoming markers so the checklist can be rebuilt from scratch for
        /// the stage the trip is actually on.
        /// </summary>
        private void ResetStageMarkers()
        {
            litEtaNote.Text = "";
            litAccept.Text = "";
            litArrived.Text = "";
            litStarted.Text = "";
            litCompleted.Text = "";
            litCompletedNote.Text = "";
        }

        private void BindTrip(DataRow r)
        {
            int tripId = Convert.ToInt32(r["TripID"]);
            ViewState["TripID"] = tripId;
            string status = r["Status"].ToString();

            pnlNoTrip.Visible = false;
            pnlTrip.Visible = true;
            pnlStatusRow.Visible = true;
            pnlSubtitle.Visible = true;

            spnStatus.InnerHtml = "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold "
                + GetStatusCss(status) + "\">" + Server.HtmlEncode(status) + "</span>";
            spnEta.InnerHtml = DriverEtaChip(r["EtaMinutes"], r["EtaSetAt"], status);
            litSubtitle.Text = r["ServiceName"] + " · claimed " + FormatTime(r["AcceptedAt"]);

            litRoute.Text = Helper.TripHelper.RouteListHtml(tripId, r);
            PathJson = Helper.TripHelper.BuildDetailPathJson(tripId, r);

            double?[] loc = Helper.TripHelper.GetDriverLocation(Helper.AuthHelper.GetAccountId());
            MeJson = loc != null && loc[0].HasValue && loc[1].HasValue
                ? "[" + loc[0].Value.ToString(CultureInfo.InvariantCulture) + ", "
                  + loc[1].Value.ToString(CultureInfo.InvariantCulture) + "]"
                : "null";
            spnMePin.InnerHtml = MeJson != "null"
                ? "<span class=\"flex items-center gap-1.5\"><span class=\"size-2 rounded-full bg-gray-900\"></span>Sharing your location</span>"
                : "<span class=\"flex items-center gap-1.5\"><span class=\"size-2 rounded-full bg-gray-300\"></span>Location not shared</span>";

            lblTRequested.Text = FormatTime(r["RequestedAt"]);
            lblTAccepted.Text = FormatTime(r["AcceptedAt"]);
            lblTArrived.Text = FormatTime(r["ArrivedAt"]);
            lblTStarted.Text = FormatTime(r["StartedAt"]);
            lblTCompleted.Text = FormatTime(r["CompletedAt"]);

            spnEtaSummary.InnerHtml = Helper.TripHelper.DriverEtaSummaryHtml(r);
            lblService.Text = r["ServiceName"].ToString();
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPlate.Text = r["PlateNumber"] == DBNull.Value ? "—" : r["PlateNumber"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value ? "—" : r["PackageName"].ToString();
            lblTripDistance.Text = Helper.TripHelper.FormatKm(
                r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);
            lblPayment.Text = (string.IsNullOrEmpty(r["PaymentMethod"] == DBNull.Value
                        ? "" : r["PaymentMethod"].ToString())
                    ? "Cash on arrival"
                    : r["PaymentMethod"].ToString()) + " · " + r["PaymentStatus"];
            ShowPaymentIcon(imgPaymentIcon, r["PaymentMethod"]);
            litPaymentInfo.Text = PaymentRecordHtml(r);
            litEtaPromise.Text = EtaPromiseHtml(r);

            string name = r["CustomerName"] == DBNull.Value ? "" : r["CustomerName"].ToString();
            string phone = string.IsNullOrWhiteSpace(r["CustomerPhone"] == DBNull.Value
                ? "" : r["CustomerPhone"].ToString()) ? "" : r["CustomerPhone"].ToString();
            lblCustName.Text = string.IsNullOrWhiteSpace(name) ? "Customer" : name;
            lblCustPhone.Text = phone;
            lblCustPhoneText.Text = string.IsNullOrWhiteSpace(phone) ? "No phone on file" : phone;
            lblCustInitial.Text = GetInitial(name);
            lblCustSince.Text = r["CustomerSince"] == DBNull.Value
                ? "—"
                : Helper.TripHelper.FormatMyanmarTime(r["CustomerSince"], "MMM yyyy");
            lblRating.Text = r["RatingScore"] == DBNull.Value || r["RatingScore"] == null
                ? "No ratings yet"
                : Convert.ToDecimal(r["RatingScore"]).ToString("0.0") + " / 5";
            lnkCallCustomer.Visible = !string.IsNullOrWhiteSpace(phone);
            if (lnkCallCustomer.Visible) lnkCallCustomer.NavigateUrl = "tel:" + phone;
            ShowPhoto(r["CustomerPhoto"], pnlPhoto, imgCustomerPhoto, pnlInitial);

            ResetStageMarkers();
            int order = StageOrder(status);
            litAccept.Text = StageGlyph(order, 1);
            litArrived.Text = StageGlyph(order, 2);
            litStarted.Text = StageGlyph(order, 3);
            litCompleted.Text = StageGlyph(order, 4);
            litEtaNote.Text = EtaNoteHtml(r);

            pnlActions.Visible = true;
            btnMarkUnpaid.Visible = false;

            // Cancel sits beside the next-step button and is offered at every stage, because a
            // driver may need to back out after setting off as well as before. The confirm text
            // names the stage the trip is actually on so nobody cancels by accident.
            btnCancel.Visible = true;
            btnCancel.OnClientClick = "return confirm('"
                + (status == "Accepted"
                    ? "Cancel this trip? The customer has not been picked up yet."
                    : status == "Arrived"
                        ? "Cancel this trip? You are already at the pickup point."
                        : "Cancel this trip? The ride is under way and the fare will be released.")
                + "');";

            // One button, top right, labelled with the step the trip is waiting on. Each
            // click advances exactly one stage, so the label is rebuilt here on every
            // postback from the row that was just read.
            pnlNextAction.Visible = true;
            btnNext.Attributes.Remove("onclick");
            if (status == "Accepted")
            {
                btnNext.Text = "I've Arrived";
                btnNext.OnClientClick = "return confirm('Confirm you have reached the pickup point?');";
                litCompletedNote.Text = "Collect the fare, then complete the trip to move it to Trip History.";
            }
            else if (status == "Arrived")
            {
                btnNext.Text = "Start Trip";
                btnNext.OnClientClick = "return confirm('Start the trip now that the customer is onboard?');";
                litCompletedNote.Text = "Collect the fare, then complete the trip to move it to Trip History.";
            }
            else
            {
                bool paid = IsPaid();
                btnNext.Text = paid ? "Completed" : "Paid";
                btnNext.OnClientClick = paid
                    ? "return confirm('Finish this trip and send it to Trip History?');"
                    : "return confirm('Confirm you collected the fare from the customer?');";
                litCompletedNote.Text = paid
                    ? "Fare collected. Complete the trip to move it to Trip History."
                    : "Collect the fare first. Marking it paid does not finish the trip.";
                btnMarkUnpaid.Visible = paid;
            }
        }

        /// <summary>
        /// Arrival block for the driver's trip panel. The driver is the one who made the
        /// promise, so the wording is about keeping it: the clock time it lands on, the live
        /// countdown, and once the moment passes a "running late" line with the drift so the
        /// driver can see how far behind they are.
        /// </summary>
        private static string EtaPromiseHtml(DataRow r)
        {
            if (r["EtaMinutes"] == DBNull.Value) return "";
            int minutes = Convert.ToInt32(r["EtaMinutes"]);
            if (minutes <= 0) return "";
            string when = Helper.TripHelper.EtaArrivalMyanmarText(r["EtaSetAt"], minutes, "dd MMM yyyy, HH:mm");
            string given = Helper.TripHelper.FormatMyanmarTime(r["EtaSetAt"], "dd MMM yyyy, HH:mm");
            return " <span class=\"text-gray-500\">You promised <strong>" + minutes + " min</strong>"
                 + (string.IsNullOrEmpty(when) ? "." : " (arrival about " + HttpUtility.HtmlEncode(when) + ")")
                 + (string.IsNullOrEmpty(given) ? "" : ", set at " + HttpUtility.HtmlEncode(given))
                 + ".</span>";
        }

        /// <summary>
        /// Reminds the driver of the arrival time they promised the customer on accept, and
        /// once they have arrived, how that compared with the promise.
        /// </summary>
        private static string EtaNoteHtml(DataRow r)
        {
            if (r["EtaMinutes"] == DBNull.Value) return "";
            int minutes = Convert.ToInt32(r["EtaMinutes"]);
            if (minutes <= 0) return "";
            string when = Helper.TripHelper.FormatMyanmarTime(r["EtaSetAt"], "dd MMM, HH:mm");
            string text = " Customer expects arrival in " + minutes + " min"
                + (string.IsNullOrEmpty(when) ? "." : " (about " + when + ").");

            if (r["ArrivedAt"] != DBNull.Value && r["EtaSetAt"] != DBNull.Value)
            {
                int drift = Convert.ToInt32(Math.Round(
                    (Helper.TripHelper.AsUtcDateTime(r["ArrivedAt"]) - Helper.TripHelper.AsUtcDateTime(r["EtaSetAt"])).TotalMinutes));
                string verdict = drift <= -2 ? "You arrived early." : (drift >= 2 ? "You arrived late." : "You arrived on time.");
                text += " " + verdict + " (" + (drift >= 0 ? "+" : "") + drift + " min).";
            }
            return " <span class=\"font-semibold text-gray-600\">" + HttpUtility.HtmlEncode(text) + "</span>";
        }

        private static int StageOrder(string status)
        {
            switch (status)
            {
                case "Accepted": return 1;
                case "Arrived": return 2;
                case "Started": return 3;
                case "Completed": return 4;
                default: return -1;
            }
        }

        private static string StageGlyph(int order, int stage)
        {
            if (order > 0 && stage < order)
                return "<span class=\"inline-flex items-center gap-1.5 text-xs font-semibold text-emerald-600\"><svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"2.5\" stroke=\"currentColor\" class=\"size-4 inline-block align-middle\"><path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"m4.5 12.75 6 6 9-13.5\"/></svg>Done</span>";
            if (order > 0 && stage > order)
                return "<span class=\"text-xs text-gray-300\">Upcoming</span>";
            return "";
        }

        /// <summary>
        /// Shows the brand icon for the stored payment method. Keys off the raw column value,
        /// not the "Cash on arrival" fallback text, and stays hidden for the in-app wallet
        /// which has no brand image.
        /// </summary>
    }
}
