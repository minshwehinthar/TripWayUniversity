using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Customer
{
    /// <summary>
    /// A customer has at most one trip in progress, so this page shows that single trip in
    /// full - map, route, timeline, summary and driver - instead of a list to filter and page.
    /// TripHistory.aspx covers the finished ones, TripDetail.aspx the archived record.
    /// </summary>
    public partial class ActiveTripPage : Helper.ListPageBase
    {
        private static readonly string ActiveStatusList = "'Requested','Accepted','Arrived','Started'";

        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        /// <summary>Map geometry for the client script: pickup, drop, ordered stops, GPS trail.</summary>
        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";

        /// <summary>Last known driver position as [lat, lng], or null when unknown.</summary>
        public string DriverJson { get; private set; } = "null";

        // Read by the chat panel markup, which is compiled into a separate page class.
        public int LoadedTripId { get; private set; }
        public string ChatTripId { get { return LoadedTripId > 0 ? LoadedTripId.ToString() : "0"; } }
        public string ChatApiUrl { get { return ResolveUrl("~/Handlers/TripApi.ashx"); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);
            // A cancel is a postback, so the trip has to be re-read after every action.
            Bind();
        }

        private void Bind()
        {
            ShowMessage("", false);
            LoadedTripId = 0;
            PathJson = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";
            DriverJson = "null";

            // ProfilePhotoUrl is selected below, so make sure the column exists first.
            Helper.TripHelper.EnsureDriverProfilePhoto();

            // BookTrip.aspx redirects here with ?trip= so the ride just booked is the one shown.
            // Ownership and status are still enforced, so the param can only narrow the choice.
            int wanted;
            bool haveWanted = int.TryParse(Request.QueryString["trip"], out wanted) && wanted > 0;

            DataTable t = Helper.DBHelper.ExecuteQuery(
                "SELECT TOP 1 t.*, s.Name AS ServiceName, v.Name AS VehicleName, p.Name AS PackageName, " +
                "d.FullName AS DriverName, d.VehiclePlateNumber, d.AverageRating, " +
                "d.ProfilePhotoUrl AS DriverPhotoUrl, d.PhoneNumber AS DriverPhone, " +
                "d.PaymentAccount AS DriverPaymentAccount, d.Email AS DriverEmail " +
                "FROM Trips t " +
                "INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID " +
                "LEFT JOIN Packages p ON t.PackageID = p.PackageID " +
                "LEFT JOIN Drivers d ON t.DriverID = d.DriverID " +
                "WHERE t.CustomerID = @c AND t.Status IN (" + ActiveStatusList + ")" +
                (haveWanted ? " AND t.TripID = @w" : "") +
                " ORDER BY t.TripID DESC",
                haveWanted
                    ? new SqlParameter[] { new SqlParameter("@c", CustomerId), new SqlParameter("@w", wanted) }
                    : new SqlParameter[] { new SqlParameter("@c", CustomerId) });

            if (t.Rows.Count == 0)
            {
            pnlTrip.Visible = false;
            pnlNoTrip.Visible = true;
            pnlWaiting.Visible = false;
            pnlActions.Visible = false;
                spnStatus.InnerHtml = "";
                spnEta.InnerHtml = "";
                spnEtaSummary.InnerHtml = "";

                litSubtitle.Text = "You have no ride in progress right now.";
                return;
            }

            DataRow r = t.Rows[0];
            int tripId = Convert.ToInt32(r["TripID"]);
            LoadedTripId = tripId;
            pnlTrip.Visible = true;
            pnlNoTrip.Visible = false;
            pnlChat.Visible = r["DriverID"] != DBNull.Value;

            string status = r["Status"].ToString();
            spnStatus.InnerHtml = "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold "
                + GetStatusCss(status) + "\">" + Server.HtmlEncode(status) + "</span>";
            spnEta.InnerHtml = EtaChip(r["EtaMinutes"], r["EtaSetAt"], status);
            spnEtaSummary.InnerHtml = EtaSummary(r["EtaMinutes"], r["EtaSetAt"], status);
            litSubtitle.Text = r["ServiceName"] + " · requested "
                + Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");

            lblTRequested.Text = Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
            lblTAccepted.Text = FormatTime(r["AcceptedAt"]);
            lblTArrived.Text = FormatTime(r["ArrivedAt"]);
            lblTStarted.Text = FormatTime(r["StartedAt"]);
            lblTCompleted.Text = FormatTime(r["CompletedAt"]);

            litRoute.Text = Helper.TripHelper.RouteListHtml(tripId, r);
            PathJson = Helper.TripHelper.BuildDetailPathJson(tripId, r);

            lblService.Text = r["ServiceName"].ToString();
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value ? "—" : r["PackageName"].ToString();
            lblKm.Text = Helper.TripHelper.FormatKm(r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);
            lblPayment.Text = (r["PaymentMethod"] == DBNull.Value ? "—" : r["PaymentMethod"].ToString()) + " · " + r["PaymentStatus"];

            BindDriver(r);
            ShowDriverPosition(r);

            // Only a request that nobody has taken yet can be called off.
            bool unclaimed = status == "Requested" && r["DriverID"] == DBNull.Value;
            pnlWaiting.Visible = unclaimed;
            pnlActions.Visible = unclaimed;
        }

        private void BindDriver(DataRow r)
        {
            if (r["DriverID"] == DBNull.Value)
            {
                pnlDriver.Visible = false;
                return;
            }

            pnlDriver.Visible = true;
            pnlDriverContacts.Visible = true;

            string driverName = r["DriverName"].ToString();
            lblDriverName.Text = driverName;
            lblDriverPlate.Text = r["VehiclePlateNumber"] == DBNull.Value ? "" : r["VehiclePlateNumber"].ToString();
            lblDriverRating.Text = r["AverageRating"] == DBNull.Value
                ? "New driver"
                : Helper.TripHelper.StarSvg(true, "size-3.5") + " " + Convert.ToDecimal(r["AverageRating"]).ToString("0.0");

            string photo = Helper.TripHelper.DriverPhotoUrl(r["DriverPhotoUrl"]);
            if (photo.Length > 0)
            {
                imgDriverPhoto.ImageUrl = ResolveUrl("~/" + photo);
                pnlDriverPhoto.Visible = true;
                pnlDriverAvatar.Visible = false;
            }
            else
            {
                pnlDriverPhoto.Visible = false;
                pnlDriverAvatar.Visible = true;
            }

            // Contact details are optional in the schema, so only link what actually has a value.
            string phone = Text(r["DriverPhone"]);
            if (phone.Length > 0)
            {
                lblDriverPhone.Text = phone;
                lblDriverPhoneText.Text = phone;
                lnkDriverPhone.NavigateUrl = "tel:" + phone.Replace(" ", "");
                lnkCallDriver.NavigateUrl = lnkDriverPhone.NavigateUrl;
                lnkDriverPhone.Visible = true;
                lnkCallDriver.Visible = true;
                divDriverPhoneText.Visible = false;
            }
            else
            {
                lblDriverPhoneText.Text = "Not provided";
                lnkDriverPhone.Visible = false;
                lnkCallDriver.Visible = false;
                divDriverPhoneText.Visible = true;
            }

            string payAccount = Text(r["DriverPaymentAccount"]);
            lblDriverPaymentAccount.Text = payAccount.Length > 0 ? payAccount : "Not provided";

            string email = Text(r["DriverEmail"]);
            if (email.Length > 0)
            {
                lblDriverEmail.Text = email;
                lblDriverEmailText.Text = email;
                lnkDriverEmail.NavigateUrl = "mailto:" + email;
                lnkDriverEmail.Visible = true;
                divDriverEmailText.Visible = false;
            }
            else
            {
                lblDriverEmailText.Text = "Not provided";
                lnkDriverEmail.Visible = false;
                divDriverEmailText.Visible = true;
            }
        }

        /// <summary>
        /// Pins the driver's last reported GPS position on the map. Drivers.CurrentLat/Lng is
        /// the same source the driver dashboard writes to, so it needs no extra plumbing.
        /// </summary>
        private void ShowDriverPosition(DataRow r)
        {
            spnDriverPin.InnerHtml = "";
            if (r["DriverID"] == DBNull.Value) return;

            double?[] loc = Helper.TripHelper.GetDriverLocation(Convert.ToInt32(r["DriverID"]));
            if (loc == null)
            {
                spnDriverPin.InnerHtml = "<span class=\"text-gray-300\">Driver location not shared yet</span>";
                return;
            }

            DriverJson = "[" + loc[0].Value.ToString(System.Globalization.CultureInfo.InvariantCulture)
                + ", " + loc[1].Value.ToString(System.Globalization.CultureInfo.InvariantCulture) + "]";
            spnDriverPin.InnerHtml = "<span class=\"flex items-center gap-1.5\"><span class=\"size-2 rounded-full bg-gray-900\"></span>Driver location updated</span>";
        }

        protected void lbtnCancel_Click(object sender, EventArgs e)
        {
            if (LoadedTripId <= 0) return;

            int rows = Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Trips SET Status='Cancelled' WHERE TripID=@t AND CustomerID=@c AND Status='Requested' AND DriverID IS NULL",
                new SqlParameter("@t", LoadedTripId), new SqlParameter("@c", CustomerId));
            if (rows == 0)
            {
                ShowMessage("This trip can no longer be cancelled. It must be requested and not yet assigned to a driver.", true);
            }
            else
            {
                Helper.TripHelper.LogActivity("Cancelled", LoadedTripId, "Customer " + CustomerId + " cancelled trip " + LoadedTripId + ".");
                ShowMessage("Trip cancelled.", false);
            }

            Bind();
        }

        /// <summary>
        /// Live arrival chip: a ticking "Arriving in x min" while the driver is on the way,
        /// "Arrived" once the pickup happened, nothing when no estimate was given.
        /// </summary>
        private string EtaChip(object minutes, object setAt, string status)
        {
            if (minutes == null || minutes == DBNull.Value || Convert.ToInt32(minutes) <= 0) return "";
            if (status == "Arrived" || status == "Started")
                return "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-600\">Arrived</span>";
            return Helper.TripHelper.EtaLiveChipHtml(Convert.ToInt32(minutes), setAt);
        }

        /// <summary>
        /// Arrival block for the Summary card: the promised clock time beside the live
        /// countdown, which Site.Master flips to "Arriving now" once the moment passes.
        /// Unlike the header chip this always renders something, so the customer is never
        /// left wondering whether an estimate exists.
        /// </summary>
        private string EtaSummary(object minutes, object setAt, string status)
        {
            int mins = minutes == null || minutes == DBNull.Value ? 0 : Convert.ToInt32(minutes);
            return Helper.TripHelper.EtaSummaryHtml(mins, setAt, status);
        }

        private static string FormatTime(object val)
        {
            return val == null || val == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(val, "dd MMM yyyy, HH:mm");
        }

        /// <summary>Nullable column as trimmed text, "" for NULL.</summary>
        private static string Text(object val)
        {
            return val == null || val == DBNull.Value ? "" : val.ToString().Trim();
        }

        private void ShowMessage(string msg, bool isError)
        {
            if (string.IsNullOrEmpty(msg))
            {
                pnlMessage.Visible = false;
                return;
            }
            pnlMessage.Visible = true;
            lblMessage.Text = msg;
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}
