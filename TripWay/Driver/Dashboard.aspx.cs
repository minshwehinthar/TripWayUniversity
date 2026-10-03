using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Driver
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private int DriverId { get { return Helper.AuthHelper.GetAccountId(); } }

        /// <summary>
        /// Rendered state of the online switch. The checkbox posts back through
        /// lnkToggleOnline, and every path that ends in a redraw has to refresh this
        /// so the knob never drifts away from the value in the database.
        /// </summary>
        public bool IsOnlineNow { get; private set; }

        /// <summary>
        /// Columns the Recent Trips header may sort by. These values are the only thing
        /// that reaches SQL, and BuildOrderBy drops anything missing from here.
        /// </summary>
        private static readonly Dictionary<string, string> RecentSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "date",     "t.RequestedAt" },
                { "service",  "s.Name" },
                { "stops",    "StopsCount" },
                { "customer", "CustomerName" },
                { "fare",     "t.Fare" },
                { "status",   "t.Status" },
                { "payment",  "t.PaymentStatus" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            if (IsPostBack) return;

            LoadData();
        }

        private void LoadData()
        {
            DataTable me = Helper.DBHelper.ExecuteQuery(
                "SELECT d.FullName, d.KYCStatus, d.IsOnline, v.Name AS VehicleName " +
                "FROM Drivers d INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID " +
                "WHERE d.DriverID=@id",
                new SqlParameter("@id", DriverId));
            if (me.Rows.Count == 0)
            {
                Helper.AuthHelper.Logout();
                Response.Redirect("~/Login.aspx");
                return;
            }

            DataRow r = me.Rows[0];
            lblName.Text = r["FullName"].ToString();
            lblSub.Text = "Driving a " + r["VehicleName"] + " · " + r["KYCStatus"].ToString() + " KYC";

            bool approved = r["KYCStatus"].ToString() == "Approved";
            IsOnlineNow = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            lblOnlineText.Text = IsOnlineNow ? "Online" : "Offline";

            if (!approved)
            {
                pnlKycBanner.Visible = true;
                lblKycState.Text = r["KYCStatus"].ToString();
            }

            DataTable active = Helper.DBHelper.ExecuteQuery(
                "SELECT TOP 1 t.Status, s.Name AS ServiceName " +
                "FROM Trips t INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "WHERE t.DriverID=@id AND t.Status IN ('Accepted','Arrived','Started') ORDER BY t.TripID DESC",
                new SqlParameter("@id", DriverId));
            if (active.Rows.Count > 0)
            {
                pnlActiveBanner.Visible = true;
                lblActiveService.Text = active.Rows[0]["ServiceName"].ToString();
                lblActiveStatus.Text = active.Rows[0]["Status"].ToString();
            }

            lblTodayEarnings.Text = ScalarInt(
                "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE DriverID=@id AND Status='Completed' AND PaymentStatus='Paid' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), DAY(DATEADD(MINUTE, 390, SYSUTCDATETIME())))").ToString("N0");
            lblTodayTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE DriverID=@id AND Status='Completed' AND DATEADD(MINUTE, 390, RequestedAt) >= DATEFROMPARTS(YEAR(DATEADD(MINUTE, 390, SYSUTCDATETIME())), MONTH(DATEADD(MINUTE, 390, SYSUTCDATETIME())), DAY(DATEADD(MINUTE, 390, SYSUTCDATETIME())))").ToString("N0");
            lblTotalTrips.Text = ScalarInt(
                "SELECT COUNT(*) FROM Trips WHERE DriverID=@id AND Status='Completed'").ToString("N0");

            object rating = Helper.DBHelper.ExecuteScalar(
                "SELECT AverageRating FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId));
            lblRating.Text = rating == null || rating == DBNull.Value ? "New" : Convert.ToDecimal(rating).ToString("0.0") + " " + Helper.TripHelper.StarSvg(true, "size-4");

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, RecentSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY t.TripID DESC";

            rptRecent.DataSource = Helper.DBHelper.ExecuteQuery(
                @"SELECT t.TripID, t.RequestedAt, t.Fare, t.Status, t.PaymentStatus,
                         s.Name AS ServiceName, ISNULL(c.FullName, '—') AS CustomerName,
                         (SELECT COUNT(*) FROM TripStops ts WHERE ts.TripID=t.TripID) AS StopsCount
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID=s.ServiceTypeID
                  INNER JOIN Customers c ON t.CustomerID=c.CustomerID
                  WHERE t.DriverID=@id" + orderBy,
                new SqlParameter("@id", DriverId));
            rptRecent.DataBind();
            rptRecent.Visible = true;
            SetNoDataRow(rptRecent, rptRecent.Items.Count == 0);
            SetActiveSortArrow(rptRecent, SortKey, SortDir);
        }

        /// <summary>SetSort calls this, so a header click reloads the recent trips table.</summary>
        protected override void OnPageIndexNavigated()
        {
            LoadData();
        }

        protected void lnkToggleOnline_Click(object sender, EventArgs e)
        {
            DataRow r = Helper.DBHelper.ExecuteQuery(
                "SELECT KYCStatus, IsOnline FROM Drivers WHERE DriverID=@id",
                new SqlParameter("@id", DriverId)).Rows[0];

            bool currentlyOnline = r["IsOnline"] != DBNull.Value && Convert.ToBoolean(r["IsOnline"]);
            bool nowOnline = !currentlyOnline;

            if (r["KYCStatus"].ToString() != "Approved")
            {
                // The checkbox already moved client side, so redraw from the database to
                // snap it back to the stored value rather than leaving it lying.
                LoadData();
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET IsOnline=@o WHERE DriverID=@id",
                new SqlParameter("@o", nowOnline),
                new SqlParameter("@id", DriverId));

            Helper.TripHelper.LogActivity(nowOnline ? "DriverOnline" : "DriverOffline", null,
                "Driver " + DriverId + " went " + (nowOnline ? "online" : "offline") + ".");

            LoadData();
        }

        private int ScalarInt(string sql)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql, new SqlParameter("@id", DriverId));
            return o == null || o == DBNull.Value ? 0 : Convert.ToInt32(o);
        }

        protected void rptRecent_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "view") return;
            int tripId = Convert.ToInt32(e.CommandArgument);
            OpenAppModal(Helper.TripHelper.BuildTripModalHtml(tripId, "TripDetail.aspx?id=" + tripId));
        }
    }
}