using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Driver
{
    /// <summary>
    /// Full detail of one open (Requested, unassigned) trip request for a driver, with the
    /// arrival-ETA box used to claim the job. Requests are not owned by a driver yet, so this
    /// page is separate from TripDetail.aspx, which only serves the driver's own trips.
    /// </summary>
    public partial class RequestDetailPage : Helper.ListPageBase
    {
        public string PathJson { get; private set; } = "{\"pickup\":null,\"drop\":null,\"stops\":[]}";
        public string MeJson { get; private set; } = "null";

        private int TripId
        {
            get { return ViewState["TripID"] != null ? Convert.ToInt32(ViewState["TripID"]) : 0; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            Helper.TripHelper.EnsureEtaColumns();

            if (!Page.IsPostBack)
            {
                int id;
                if (!int.TryParse(Request.QueryString["id"], out id) || id <= 0)
                {
                    Response.Redirect("TripRequests.aspx");
                    return;
                }
                ViewState["TripID"] = id;
            }

            Bind();
        }

        protected void btnEtaUp_Click(object sender, EventArgs e)
        {
            txtEta.Text = ClampEta(ParseEta(txtEta.Text) + 5).ToString();
        }

        protected void btnEtaDown_Click(object sender, EventArgs e)
        {
            txtEta.Text = ClampEta(ParseEta(txtEta.Text) - 5).ToString();
        }

        protected void btnAccept_Click(object sender, EventArgs e)
        {
            int eta = ParseEta(txtEta.Text);
            if (!Helper.TripHelper.IsValidEtaMinutes(eta))
            {
                ShowError("Enter how many minutes you need to reach the pickup point (1-" +
                    Helper.TripHelper.MaxEtaMinutes + ").");
                Bind();
                return;
            }

            string error;
            if (!Helper.TripHelper.TryAcceptTrip(Helper.AuthHelper.GetAccountId(), TripId, eta, out error))
            {
                ShowError(error);
                Bind();
                return;
            }

            Response.Redirect("ActiveTrip.aspx?trip=" + TripId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void Bind()
        {
            pnlError.Visible = false;
            pnlTaken.Visible = false;
            pnlContent.Visible = false;

            if (!Helper.TripHelper.IsDriverApproved(Helper.AuthHelper.GetAccountId()))
            {
                ShowError("Your KYC is not approved yet, so you cannot accept this request.");
                return;
            }

            int myVehicle = Helper.TripHelper.GetDriverVehicleTypeId(Helper.AuthHelper.GetAccountId());
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT t.*, s.Name AS ServiceName, v.Name AS VehicleName, p.Name AS PackageName,
                         c.FullName AS CustomerName, c.PhoneNumber AS CustomerPhone, c.Gender AS CustomerGender,
                         c.ProfilePhotoUrl AS CustomerPhoto, c.CreatedAt AS CustomerSince
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Packages p ON t.PackageID = p.PackageID
                  WHERE t.TripID = @id",
                new SqlParameter("@id", TripId));

            if (t.Rows.Count == 0)
            {
                pnlTaken.Visible = true;
                return;
            }

            DataRow r = t.Rows[0];
            lblCrumbName.Text = r["ServiceName"].ToString();
            lblRequested.Text = Helper.TripHelper.FormatMyanmarTime(r["RequestedAt"], "dd MMM yyyy, HH:mm");
            lblAgo.Text = AgoText(r["RequestedAt"]);

            if (r["Status"].ToString() != "Requested" || r["DriverID"] != DBNull.Value)
            {
                pnlTaken.Visible = true;
                return;
            }
            if (Convert.ToInt32(r["VehicleTypeID"]) != myVehicle)
            {
                ShowError("This request needs a different vehicle type than the one on your account.");
                return;
            }

            pnlContent.Visible = true;
            litRoute.Text = Helper.TripHelper.RouteListHtml(TripId, r);

            lblService.Text = r["ServiceName"].ToString();
            lblVehicle.Text = r["VehicleName"].ToString();
            lblPackage.Text = r["PackageName"] == DBNull.Value || string.IsNullOrWhiteSpace(r["PackageName"].ToString())
                ? "—" : r["PackageName"].ToString();
            lblPaymentMethod.Text = r["PaymentMethod"] == DBNull.Value || string.IsNullOrWhiteSpace(r["PaymentMethod"].ToString())
                ? "Cash on arrival" : r["PaymentMethod"].ToString();
            ShowPaymentIcon(imgPaymentIcon, r["PaymentMethod"]);
            lblTripDistance.Text = Helper.TripHelper.FormatKm(r["EstimatedKm"] == DBNull.Value ? (decimal?)null : Convert.ToDecimal(r["EstimatedKm"]));
            lblStatus.Text = r["Status"].ToString();
            spnStatusPill.Attributes["class"] = "inline-flex px-2 py-1 rounded-full text-xs font-semibold mt-1 " + GetStatusCss(r["Status"].ToString());
            lblFare.Text = "MMK " + string.Format("{0:N0}", r["Fare"]);

            var stops = Helper.TripHelper.GetOrderedStops(TripId, r);
            lblStops.Text = stops.Count <= 2
                ? "Pickup → destination"
                : (stops.Count - 2) + " stop(s) between pickup and destination";

            string customerName = r["CustomerName"].ToString();
            lblCustomerName.Text = customerName;
            string phone = r["CustomerPhone"] == DBNull.Value ? "" : r["CustomerPhone"].ToString();
            lblCustomerPhone.Text = string.IsNullOrWhiteSpace(phone) ? "No phone on file" : phone;
            if (!string.IsNullOrWhiteSpace(phone))
            {
                lnkCallCustomer.Visible = true;
                lnkCallCustomer.NavigateUrl = "tel:" + phone;
            }
            lblCustomerMeta.Text = r["CustomerGender"] == DBNull.Value || string.IsNullOrWhiteSpace(r["CustomerGender"].ToString())
                ? "—" : r["CustomerGender"].ToString();
            lblCustomerSince.Text = Helper.TripHelper.FormatMyanmarTime(r["CustomerSince"], "dd MMM yyyy");
            ShowPhoto(r["CustomerPhoto"]);

            double?[] me = Helper.TripHelper.GetDriverLocation(Helper.AuthHelper.GetAccountId());
            int suggested = Helper.TripHelper.MaxEtaMinutes;
            if (me != null)
            {
                MeJson = "[" + me[0].Value.ToString(System.Globalization.CultureInfo.InvariantCulture) + ", "
                               + me[1].Value.ToString(System.Globalization.CultureInfo.InvariantCulture) + "]";
                double straightKm = (double)Helper.TripHelper.HaversineKm(me[0].Value, me[1].Value,
                    Convert.ToDouble(r["PickupLat"]), Convert.ToDouble(r["PickupLng"]));
                decimal roadKm = Helper.TripHelper.RoadDistanceKm(straightKm);
                suggested = Helper.TripHelper.DriveMinutesForRoadKm((double)roadKm);
                lblDistanceAway.Text = roadKm.ToString("0.0") + " km";
                lblDriveTime.Text = Helper.TripHelper.FormatDriveTime(suggested);
                lblPickupDistance.Text = "(" + straightKm.ToString("0.0") + " km as the crow flies)";
            }
            else
            {
                lblDistanceAway.Text = "--";
                lblDriveTime.Text = "--";
                lblPickupDistance.Text = "Waiting for your GPS location";
            }
            lblSuggestedEta.Text = me != null ? suggested + " min" : "--";

            if (string.IsNullOrWhiteSpace(txtEta.Text) || !Page.IsPostBack)
                txtEta.Text = me != null ? suggested.ToString() : "10";

            PathJson = Helper.TripHelper.BuildDetailPathJson(TripId, r);
        }

        private void ShowPhoto(object storedPath)
        {
            string path = storedPath == null || storedPath == DBNull.Value ? "" : storedPath.ToString().Trim();
            if (path.Length == 0) { pnlPhoto.Visible = false; pnlInitial.Visible = true; return; }

            if (path.StartsWith("http://") || path.StartsWith("https://") || path.StartsWith("/"))
                imgCustomerPhoto.ImageUrl = path;
            else if (path.StartsWith("~/"))
                imgCustomerPhoto.ImageUrl = ResolveUrl(path);
            else
                imgCustomerPhoto.ImageUrl = ResolveUrl("~/" + path);

            pnlPhoto.Visible = true;
            pnlInitial.Visible = false;
        }

        private void ShowError(string message)
        {
            lblError.Text = message;
            pnlError.Visible = !string.IsNullOrEmpty(message);
        }

        private static int ParseEta(string text)
        {
            int value;
            return int.TryParse(text, out value) ? value : 0;
        }

        private static int ClampEta(int value)
        {
            if (value < Helper.TripHelper.MinEtaMinutes) return Helper.TripHelper.MinEtaMinutes;
            if (value > Helper.TripHelper.MaxEtaMinutes) return Helper.TripHelper.MaxEtaMinutes;
            return value;
        }

        private string AgoText(object utcValue)
        {
            if (utcValue == null || utcValue == DBNull.Value) return "";
            double minutes = (DateTime.UtcNow - Helper.TripHelper.AsUtcDateTime(utcValue)).TotalMinutes;
            if (minutes < 1) return "just now";
            if (minutes < 60) return ((int)minutes) + " min ago";
            if (minutes < 1440) return ((int)(minutes / 60)) + " h ago";
            return ((int)(minutes / 1440)) + " days ago";
        }

        /// <summary>
        /// Shows the brand icon for the stored payment method. Keys off the raw column value,
        /// not the "Cash on arrival" fallback text, and stays hidden for the in-app wallet
        /// which has no brand image.
        /// </summary>
    }
}
