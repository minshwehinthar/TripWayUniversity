using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Customer
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);
            if (IsPostBack) return;

            LoadData();
        }

        private void LoadData()
        {
            DataRow me = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, ProfilePhotoUrl FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerId)).Rows[0];
            lblName.Text = me["FullName"].ToString();
            ShowPhoto(me["ProfilePhotoUrl"]);

            DataTable active = Helper.DBHelper.ExecuteQuery(
                "SELECT TOP 1 t.Status, s.Name AS ServiceName, d.FullName AS DriverName " +
                "FROM Trips t " +
                "INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "LEFT JOIN Drivers d ON t.DriverID = d.DriverID " +
                "WHERE t.CustomerID=@id AND t.Status IN ('Requested','Accepted','Arrived','Started') ORDER BY t.TripID DESC",
                new SqlParameter("@id", CustomerId));
            if (active.Rows.Count > 0)
            {
                pnlActiveBanner.Visible = true;
                lblActiveService.Text = active.Rows[0]["ServiceName"].ToString();
                lblActiveStatus.Text = "You have an " + active.Rows[0]["Status"] + " trip in progress.";
                lblActiveDriver.Text = active.Rows[0]["DriverName"] == DBNull.Value
                    ? "Waiting for driver match…"
                    : "Driver: " + active.Rows[0]["DriverName"].ToString();
            }

            lblTotalTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@id",
                CustomerId).ToString("N0");
            lblMonthTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE CustomerID=@id AND Status='Completed' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), 1)",
                CustomerId).ToString("N0");
            lblTotalSpent.Text = ScalarInt(
                "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE CustomerID=@id AND PaymentStatus='Paid'",
                CustomerId).ToString("N0");

            object fav = Helper.DBHelper.ExecuteScalar(
                "SELECT TOP 1 v.Name FROM Trips t INNER JOIN VehicleTypes v ON t.VehicleTypeID=v.VehicleTypeID " +
                "WHERE t.CustomerID=@id GROUP BY v.Name ORDER BY COUNT(*) DESC",
                new SqlParameter("@id", CustomerId));
            lblFavoriteVehicle.Text = fav == null ? "--" : fav.ToString();
        }

        /// <summary>
        /// Swaps the default avatar for the uploaded profile photo. ProfilePhotoUrl is NULL
        /// until the customer uploads one on Profile.aspx, so the avatar stays as the fallback.
        /// </summary>
        private void ShowPhoto(object storedPath)
        {
            string path = storedPath == null || storedPath == DBNull.Value ? "" : storedPath.ToString().Trim();
            if (path.Length == 0)
            {
                pnlPhoto.Visible = false;
                pnlAvatar.Visible = true;
                return;
            }

            if (path.StartsWith("http://") || path.StartsWith("https://") || path.StartsWith("/"))
                imgProfilePhoto.ImageUrl = path;
            else if (path.StartsWith("~/"))
                imgProfilePhoto.ImageUrl = ResolveUrl(path);
            else
                imgProfilePhoto.ImageUrl = ResolveUrl("~/" + path);

            pnlPhoto.Visible = true;
            pnlAvatar.Visible = false;
        }

        private int ScalarInt(string sql, int customerId)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql, new SqlParameter("@id", customerId));
            return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o);
        }
    }
}