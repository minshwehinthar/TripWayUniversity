using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    public partial class TripDetailPage : Helper.ListPageBase
    {
        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";
        private int tripId;

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!int.TryParse(Request.QueryString["id"], out tripId))
            {
                Response.Redirect("TripManagement.aspx");
                return;
            }
            if (!IsPostBack) LoadTrip();
        }

        private void LoadTrip()
        {
            // DriverPhotoUrl is selected below, so make sure the column exists first.
            Helper.TripHelper.EnsureDriverProfilePhoto();

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT t.*, s.Name AS ServiceName, v.Name AS VehicleName, pk.Name AS PackageName,
                         c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone,
                         c.ProfilePhotoUrl AS CustomerPhoto, c.CreatedAt AS CustomerSince,
                         d.FullName AS DriverName, d.PhoneNumber AS DriverPhone,
                         d.VehiclePlateNumber AS PlateNumber, d.AverageRating AS DriverRating,
                         d.ProfilePhotoUrl AS DriverPhotoUrl,
                         rt.Score AS RatingScore, rt.Comment AS RatingComment,
                         pay.Amount AS PayAmount, pay.Method AS PayMethod, pay.PaidAt AS PayPaidAt
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Packages pk ON t.PackageID = pk.PackageID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID
                  LEFT JOIN Ratings rt ON rt.TripID = t.TripID
                  LEFT JOIN Payments pay ON pay.TripID = t.TripID
                  WHERE t.TripID = @id",
                new SqlParameter("@id", tripId));

            if (t.Rows.Count == 0)
            {
                pnlNoTrip.Visible = true;
                pnlTrip.Visible = false;
                return;
            }

            DataRow r = t.Rows[0];
            pnlNoTrip.Visible = false;
            pnlTrip.Visible = true;

            string status = r["Status"].ToString();
            spnStatus.InnerHtml = "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold "
                + GetStatusCss(status) + "\">" + Server.HtmlEncode(status) + "</span>";
            // Static chip: an admin is reading the record, so there is no countdown to tick.
            spnEta.InnerHtml = r["EtaMinutes"] == DBNull.Value
                ? ""
                : Helper.TripHelper.EtaHistoryChipHtml(Convert.ToInt32(r["EtaMinutes"]), r["EtaSetAt"]);

            litSubtitle.Text = "requested "
                + Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
            litRoute.Text = Helper.TripHelper.RouteListHtml(Convert.ToInt32(r["TripID"]), r);

            lblService.Text = r["ServiceName"].ToString();
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPlate.Text = r["PlateNumber"] == DBNull.Value ? "—" : r["PlateNumber"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value ? "—" : r["PackageName"].ToString();
            lblTripDistance.Text = Helper.TripHelper.FormatKm(r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            spnEtaSummary.InnerHtml = Helper.TripHelper.EtaFactBlockHtml(r);
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);
            lblPayment.Text = (string.IsNullOrEmpty(r["PaymentMethod"] == DBNull.Value
                        ? "" : r["PaymentMethod"].ToString())
                    ? "Cash on arrival"
                    : r["PaymentMethod"].ToString()) + " · " + r["PaymentStatus"];
            ShowPaymentIcon(imgPaymentIcon, r["PaymentMethod"]);
            litPaymentInfo.Text = PaymentRecordHtml(r);

            lblTRequested.Text = FormatTime(r["RequestedAt"]);
            lblTAccepted.Text = FormatTime(r["AcceptedAt"]);
            lblTArrived.Text = FormatTime(r["ArrivedAt"]);
            lblTStarted.Text = FormatTime(r["StartedAt"]);
            lblTCompleted.Text = FormatTime(r["CompletedAt"]);

            string name = r["CustomerName"] == DBNull.Value ? "" : r["CustomerName"].ToString();
            string phone = r["CustomerPhone"] == DBNull.Value ? "" : r["CustomerPhone"].ToString();
            lblCustName.Text = string.IsNullOrWhiteSpace(name) ? "Customer" : name;
            lblCustInitial.Text = GetInitial(name);
            lblCustPhone.Text = phone;
            lblCustPhoneText.Text = string.IsNullOrWhiteSpace(phone) ? "No phone on file" : phone;
            lblCustSince.Text = r["CustomerSince"] == DBNull.Value
                ? "—"
                : Helper.TripHelper.FormatMyanmarTime(r["CustomerSince"], "MMM yyyy");
            lblCustRating.Text = RatingText(r["RatingScore"]);
            ShowPhoto(r["CustomerPhoto"], pnlPhoto, imgCustomerPhoto, pnlInitial);

            if (r["DriverName"] == DBNull.Value)
            {
                lblDriverName.Text = "Not assigned";
                lblDriverPhone.Text = "";
                lblDriverPhoneText.Text = "—";
                lblDriverPlate.Text = "—";
                lblDriverRating.Text = "—";
                lblDriverInitial.Text = "?";
                lnkDriverProfile.Visible = false;
                pnlDriverPhotoPanel.Visible = false;
                pnlDriverInitialPanel.Visible = true;
            }
            else
            {
                string dName = r["DriverName"].ToString();
                string dPhone = r["DriverPhone"] == DBNull.Value ? "" : r["DriverPhone"].ToString();
                lblDriverName.Text = dName;
                lblDriverInitial.Text = GetInitial(dName);
                lblDriverPhone.Text = dPhone;
                lblDriverPhoneText.Text = string.IsNullOrWhiteSpace(dPhone) ? "No phone on file" : dPhone;
                lblDriverPlate.Text = r["PlateNumber"] == DBNull.Value ? "—" : r["PlateNumber"].ToString();
                lblDriverRating.Text = RatingText(r["DriverRating"]);
                lnkDriverProfile.Visible = true;
                lnkDriverProfile.NavigateUrl = "DriverDetail.aspx?id=" + r["DriverID"];

                string photo = Helper.TripHelper.DriverPhotoUrl(r["DriverPhotoUrl"]);
                pnlDriverPhotoPanel.Visible = photo.Length > 0;
                pnlDriverInitialPanel.Visible = photo.Length == 0;
                if (photo.Length > 0) imgDriverPhoto.ImageUrl = ResolveUrl("~/" + photo);
            }

            if (r["RatingScore"] != DBNull.Value)
            {
                pnlRating.Visible = true;
                lblStars.Text = Helper.TripHelper.StarsHtml(Convert.ToInt32(r["RatingScore"]));
                lblRatingComment.Text = r["RatingComment"] == DBNull.Value ? "No comment left." : r["RatingComment"].ToString();
            }

            PathJson = Helper.TripHelper.BuildDetailPathJson(Convert.ToInt32(r["TripID"]), r);
        }

        private static string RatingText(object score)
        {
            return score == null || score == DBNull.Value
                ? "Not rated yet"
                : Convert.ToDecimal(score).ToString("0.0") + " / 5";
        }

        private string FormatTime(object val)
        {
            return val == null || val == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(val, "dd MMM HH:mm");
        }
    }
}