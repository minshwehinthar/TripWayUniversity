using System;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;

namespace TripWay.Admin
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        private string _driversOnlineJson;

        /// <summary>Share of the fleet currently on the road, drawn as the ring on the page.</summary>
        public string DriversOnlineJson
        {
            get { return _driversOnlineJson ?? string.Empty; }
        }

        // +6:30, the same offset the counters above use, so the ring and the tiles agree about
        // which day "now" falls on.
        private const int LocalOffsetMinutes = 390;

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (IsPostBack) return;

            lblToday.Text = Helper.TripHelper.FormatMyanmarTime(DateTime.UtcNow, "dd MMM yyyy");

            lblCustomers.Text = Helper.DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Customers").ToString();
            lblDrivers.Text = Helper.DBHelper.ExecuteScalar("SELECT COUNT(*) FROM Drivers").ToString();
            lblTripsToday.Text = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips WHERE CAST(DATEADD(MINUTE, 390, RequestedAt) AS DATE) = CAST(DATEADD(MINUTE, 390, SYSUTCDATETIME()) AS DATE)").ToString();
            lblRevenueToday.Text = "MMK " + string.Format("{0:N0}",
                Helper.DBHelper.ExecuteScalar(
                    "SELECT ISNULL(SUM(Fare),0) FROM Trips WHERE CAST(DATEADD(MINUTE, 390, RequestedAt) AS DATE) = CAST(DATEADD(MINUTE, 390, SYSUTCDATETIME()) AS DATE) AND Status <> 'Cancelled'"));

            LoadDriversOnline();
        }

        /// <summary>
        /// How much of the fleet is available right now, which is what the ring shows, plus the
        /// list of who is online so an admin can still open a driver.
        ///
        /// Offline counts every driver who is not currently on the road, including any still
        /// waiting on KYC. That keeps the two slices adding up to the whole fleet, which is the
        /// whole point of a ring: "2 of 4 online" has to mean four drivers exist, not that two
        /// of them are hiding somewhere unaccounted for.
        ///
        /// The payload is built here in Page_Load rather than from a property getter. A getter
        /// would first run from the &lt;%= %&gt; in the markup during Render, once the response has
        /// started flushing, and a query fault at that point truncates the page so the script
        /// carrying the data never arrives and the card sits blank with nothing logged.
        /// </summary>
        private void LoadDriversOnline()
        {
            DataTable fleet = Helper.DBHelper.ExecuteQuery(
                "SELECT COUNT(*) AS Total, " +
                "SUM(CASE WHEN IsOnline = 1 AND KYCStatus = 'Approved' THEN 1 ELSE 0 END) AS OnlineCount " +
                "FROM Drivers");

            int total = Convert.ToInt32(fleet.Rows[0]["Total"]);
            int online = fleet.Rows[0]["OnlineCount"] == DBNull.Value
                ? 0
                : Convert.ToInt32(fleet.Rows[0]["OnlineCount"]);

            _driversOnlineJson = new JavaScriptSerializer().Serialize(new
            {
                online = online,
                offline = total - online,
                total = total,
                date = LocalToday().ToString("ddd dd MMM yyyy", CultureInfo.CurrentCulture)
            });

            /* The badge is written from the same figures the ring plots, so it states the truth
               even with scripting off or Chart.js missing, and the script cannot contradict it
               because it reads the same payload. */
            lblOnlineCount.Text = online + " of " + total + " online";

            DataTable rows = Helper.DBHelper.ExecuteQuery(
                @"SELECT d.DriverID, d.FullName, v.Name AS VehicleTypeName
                  FROM Drivers d INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  WHERE d.IsOnline = 1 AND d.KYCStatus = 'Approved'");

            rptOnline.DataSource = rows;
            rptOnline.DataBind();
            pnlNoOnline.Visible = rows.Rows.Count == 0;
            rptOnline.Visible = rows.Rows.Count > 0;
        }

        /// <summary>Today's date in the same local time the counters above group by.</summary>
        private static DateTime LocalToday()
        {
            return DateTime.UtcNow.AddMinutes(LocalOffsetMinutes).Date;
        }

        protected void rptOnline_ItemCommand(object sender, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "view") return;
            int driverId = Convert.ToInt32(e.CommandArgument);
            OpenAppModal(Helper.TripHelper.BuildDriverModalHtml(driverId, "DriverDetail.aspx?id=" + driverId));
        }
    }
}