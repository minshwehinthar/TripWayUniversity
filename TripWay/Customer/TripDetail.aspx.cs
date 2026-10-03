using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Customer
{
    public partial class TripDetailPage : Helper.ListPageBase
    {
        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";

        // Read by the chat panel markup, which is compiled into a separate page class.
        public int LoadedTripId { get; private set; }
        public string ChatTripId { get { return LoadedTripId > 0 ? LoadedTripId.ToString() : "0"; } }
        public string ChatApiUrl { get { return ResolveUrl("~/Handlers/TripApi.ashx"); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);

            int id;
            if (!int.TryParse(Request.QueryString["id"], out id))
            {
                Response.Redirect("TripHistory.aspx");
                return;
            }

            // DriverPhotoUrl is selected below, so make sure the column exists first.
            Helper.TripHelper.EnsureDriverProfilePhoto();

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT t.*, s.Name AS ServiceName, v.Name AS VehicleName, p.Name AS PackageName,
                         d.FullName AS DriverName, d.VehiclePlateNumber, d.AverageRating,
                         d.ProfilePhotoUrl AS DriverPhotoUrl, d.PhoneNumber AS DriverPhone,
                         d.PaymentAccount AS DriverPaymentAccount, d.Email AS DriverEmail,
                         r.Score, r.Comment AS RatingComment,
                         pay.PaidAt AS PayPaidAt
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  LEFT JOIN Packages p ON t.PackageID = p.PackageID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID
                  LEFT JOIN Ratings r ON r.TripID = t.TripID
                  LEFT JOIN Payments pay ON pay.TripID = t.TripID
                  WHERE t.TripID = @id AND t.CustomerID = @customer",
                new SqlParameter("@id", id),
                new SqlParameter("@customer", Helper.AuthHelper.GetAccountId()));

            if (t.Rows.Count == 0)
            {
                pnlNoTrip.Visible = true;
                lblCrumbName.Text = "Trip not found";
                return;
            }

            DataRow r = t.Rows[0];
            string status = r["Status"].ToString();
            bool isActive = status == "Requested" || status == "Accepted" || status == "Arrived" || status == "Started";
            string service = r["ServiceName"].ToString();

            lblCrumbName.Text = service;
            litSubtitle.Text = "Requested " + Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm")
                + " &middot; " + service;

            LoadedTripId = id;
            pnlTrip.Visible = true;
            pnlChat.Visible = true;

            // Status pill and the arrival chip share the heading, the same as the driver pages.
            spnStatus.InnerHtml = "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold "
                + GetStatusCss(status) + "\">" + Server.HtmlEncode(status) + "</span>";

            int eta = r["EtaMinutes"] == DBNull.Value ? 0 : Convert.ToInt32(r["EtaMinutes"]);
            if (eta > 0)
                spnEta.InnerHtml = Helper.TripHelper.EtaStatusChipHtml(eta, r["EtaSetAt"], status);

            // A settled trip gets the static record of the promise; only a trip that is still
            // running is allowed to carry the countdown.
            spnEtaSummary.InnerHtml = isActive
                ? Helper.TripHelper.EtaSummaryHtml(eta, r["EtaSetAt"], status)
                : Helper.TripHelper.EtaFactBlockHtml(r);

            litRoute.Text = Helper.TripHelper.RouteListHtml(Convert.ToInt32(r["TripID"]), r);

            lblService.Text = service;
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPlate.Text = r["VehiclePlateNumber"] == DBNull.Value || r["DriverID"] == DBNull.Value
                ? "" : r["VehiclePlateNumber"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value ? "—" : r["PackageName"].ToString();
            lblTripDistance.Text = Helper.TripHelper.FormatKm(r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);
            lblPayment.Text = (r["PaymentMethod"] == DBNull.Value ? "—" : r["PaymentMethod"].ToString()) + " · " + r["PaymentStatus"];
            ShowPaymentIcon(imgPaymentIcon, r["PaymentMethod"]);
            litPaymentInfo.Text = PaymentRecordHtml(r);

            lblTRequested.Text = Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
            lblTAccepted.Text = FormatTime(r["AcceptedAt"]);
            lblTArrived.Text = FormatTime(r["ArrivedAt"]);
            lblTStarted.Text = FormatTime(r["StartedAt"]);
            lblTCompleted.Text = FormatTime(r["CompletedAt"]);

            if (r["DriverID"] != DBNull.Value)
            {
                pnlDriver.Visible = true;
                string driverName = r["DriverName"].ToString();
                lblDriverName.Text = driverName;
                lblDriverInitial.Text = GetInitial(driverName);
                lblDriverRatingInline.Text = r["AverageRating"] == DBNull.Value
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

                // Contact details are optional in the schema, so each row is only linked when
                // it actually holds something usable.
                string phone = Text(r["DriverPhone"]);
                if (phone.Length > 0)
                {
                    lblDriverPhone.Text = phone;
                    lblDriverPhoneText.Text = phone;
                    lnkDriverPhone.NavigateUrl = "tel:" + phone.Replace(" ", "");
                    lnkCallDriver.NavigateUrl = lnkDriverPhone.NavigateUrl;
                    lnkCallDriver.Visible = true;
                    lnkDriverPhone.Visible = true;
                    divDriverPhoneText.Visible = false;
                }
                else
                {
                    lblDriverPhoneText.Text = "Not provided";
                    lnkDriverPhone.Visible = false;
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

            if (r["Score"] != DBNull.Value)
            {
                pnlRating.Visible = true;
                lblStars.Text = Helper.TripHelper.StarsHtml(Convert.ToInt32(r["Score"]));
                lblRatingComment.Text = r["RatingComment"] == DBNull.Value ? "No comment left." : r["RatingComment"].ToString();
            }

            object active = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@c AND TripID<>@t AND Status IN ('Requested','Accepted','Arrived','Started')",
                new SqlParameter("@c", Helper.AuthHelper.GetAccountId()),
                new SqlParameter("@t", id));
            lnkActive.Visible = Convert.ToInt32(active) > 0;
            lnkActive.NavigateUrl = "ActiveTrip.aspx";

            // Trips reached from ActiveTrip.aspx go back there; finished ones go to TripHistory.aspx.
            string listUrl = isActive ? "ActiveTrip.aspx" : "TripHistory.aspx";
            string listName = isActive ? "Active Trip" : "Trip History";
            lnkBack.NavigateUrl = listUrl;
            lnkBack.Text = isActive ? "Back to Active Trip" : "Back to History";
            lnkCrumbList.NavigateUrl = listUrl;
            lnkCrumbList.Text = listName;
            if (isActive) lnkActive.Visible = false;

            PathJson = Helper.TripHelper.BuildDetailPathJson(Convert.ToInt32(r["TripID"]), r);
        }

        private string FormatTime(object val)
        {
            return val == null || val == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(val, "dd MMM yyyy, HH:mm");
        }

        /// <summary>Nullable column as trimmed text, "" for NULL.</summary>
        private static string Text(object val)
        {
            return val == null || val == DBNull.Value ? "" : val.ToString().Trim();
        }
    }
}
