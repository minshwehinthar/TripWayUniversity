using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Driver
{
    public partial class TripDetailPage : Helper.ListPageBase
    {
        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[],\"path\":[]}";

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);

            int id;
            if (!int.TryParse(Request.QueryString["id"], out id))
            {
                Response.Redirect("TripHistory.aspx");
                return;
            }
            // The crumb leaf is filled in once the row is read, below.

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT t.*, s.Name AS ServiceName, v.Name AS VehicleName,
                         c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone,
                         c.ProfilePhotoUrl AS CustomerPhoto, c.CreatedAt AS CustomerSince,
                         d.VehiclePlateNumber AS PlateNumber, pk.Name AS PackageName,
                         rt.Score AS RatingScore, rt.Comment AS RatingComment,
                         pay.Amount AS PayAmount, pay.Method AS PayMethod, pay.PaidAt AS PayPaidAt
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  INNER JOIN Drivers d ON t.DriverID = d.DriverID
                  LEFT JOIN Packages pk ON t.PackageID = pk.PackageID
                  LEFT JOIN Ratings rt ON rt.TripID = t.TripID
                  LEFT JOIN Payments pay ON pay.TripID = t.TripID
                  WHERE t.TripID = @id AND t.DriverID = @driver",
                new SqlParameter("@id", id),
                new SqlParameter("@driver", Helper.AuthHelper.GetAccountId()));

            if (t.Rows.Count == 0)
            {
                pnlNoTrip.Visible = true;
                pnlTrip.Visible = false;
                lblCrumbName.Text = "Trip not found";
                return;
            }

            DataRow r = t.Rows[0];
            pnlNoTrip.Visible = false;
            pnlTrip.Visible = true;

            string status = r["Status"].ToString();
            spnStatus.InnerHtml = "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold "
                + GetStatusCss(status) + "\">" + Server.HtmlEncode(status) + "</span>";

            // A closed trip gets the static history chip, never the live countdown the
            // active page ticks, which would count down to a moment already past.
            spnEta.InnerHtml = r["EtaMinutes"] == DBNull.Value
                ? ""
                : Helper.TripHelper.EtaHistoryChipHtml(Convert.ToInt32(r["EtaMinutes"]), r["EtaSetAt"]);

            litSubtitle.Text = "requested "
                + Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
            litRoute.Text = Helper.TripHelper.RouteListHtml(Convert.ToInt32(r["TripID"]), r);

            lblService.Text = r["ServiceName"].ToString();
            lblCrumbName.Text = r["ServiceName"].ToString();
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPlate.Text = r["PlateNumber"] == DBNull.Value ? "—" : r["PlateNumber"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value ? "—" : r["PackageName"].ToString();
            lblTripDistance.Text = Helper.TripHelper.FormatKm(r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            spnEtaSummary.InnerHtml = Helper.TripHelper.DriverEtaHistoryBlockHtml(r);
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);
            lblPayment.Text = (string.IsNullOrEmpty(r["PaymentMethod"] == DBNull.Value
                        ? "" : r["PaymentMethod"].ToString())
                    ? "Cash on arrival"
                    : r["PaymentMethod"].ToString()) + " · " + r["PaymentStatus"];
            ShowPaymentIcon(imgPaymentIcon, r["PaymentMethod"]);
            litPaymentInfo.Text = PaymentRecordHtml(r);

            lblTRequested.Text = Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
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
            lblRating.Text = r["RatingScore"] == DBNull.Value || r["RatingScore"] == null
                ? "No ratings yet"
                : Convert.ToDecimal(r["RatingScore"]).ToString("0.0") + " / 5";
            ShowPhoto(r["CustomerPhoto"], pnlPhoto, imgCustomerPhoto, pnlInitial);

            if (r["RatingScore"] != DBNull.Value)
            {
                pnlRating.Visible = true;
                lblStars.Text = Helper.TripHelper.StarsHtml(Convert.ToInt32(r["RatingScore"]));
                lblRatingComment.Text = r["RatingComment"] == DBNull.Value ? "No comment left." : r["RatingComment"].ToString();
            }

            PathJson = Helper.TripHelper.BuildDetailPathJson(Convert.ToInt32(r["TripID"]), r);
        }

        private string FormatTime(object val)
        {
            return val == null || val == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(val, "dd MMM yyyy, HH:mm");
        }

    }
}