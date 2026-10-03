using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;

namespace TripWay.Admin
{
    public partial class DashboardPage : Helper.ListPageBase
    {
        public string DriversJson { get; private set; }

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

            int onlineCount = 0;
            DataTable online = Helper.DBHelper.ExecuteQuery(
                @"SELECT d.DriverID, d.FullName, v.Name AS VehicleTypeName
                  FROM Drivers d INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  WHERE d.IsOnline = 1 AND d.KYCStatus = 'Approved'");
            onlineCount = online.Rows.Count;

            rptOnline.DataSource = online;
            rptOnline.DataBind();
            pnlNoOnline.Visible = online.Rows.Count == 0;
            rptOnline.Visible = online.Rows.Count > 0;
            lblOnlineCount.Text = onlineCount + " online";

            BuildDriversJson(onlineCount);

            DataTable act = Helper.DBHelper.ExecuteQuery(
                @"SELECT TOP 10 t.TripID, t.Status, t.Fare, t.RequestedAt,
                         s.Name AS ServiceName, ISNULL(c.FullName,'—') AS CustomerName,
                         ISNULL(ISNULL(d.FullName,'Pending'),'—') AS DriverName,
                         (SELECT COUNT(*) FROM TripStops ts WHERE ts.TripID=t.TripID) AS StopsCount
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID
                  ORDER BY t.TripID DESC");
            rptActivity.DataSource = act;
            rptActivity.DataBind();
            rptActivity.Visible = true;
            SetNoDataRow(rptActivity, rptActivity.Items.Count == 0);
        }

        private void BuildDriversJson(int onlineCount)
        {
            StringBuilder sb = new StringBuilder("[");
            bool first = true;
            foreach (DataRow dr in Helper.DBHelper.ExecuteQuery(
                @"SELECT d.DriverID, d.FullName, v.Name AS VehicleTypeName,
                         g.Lat, g.Lng
                  FROM Drivers d
                  INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID
                  OUTER APPLY (
                      SELECT TOP 1 g.Lat, g.Lng
                      FROM Trips t INNER JOIN TripGPSLogs g ON g.TripID = t.TripID
                      WHERE t.DriverID = d.DriverID
                      ORDER BY g.LogID DESC
                  ) g
                  WHERE d.IsOnline = 1 AND d.KYCStatus = 'Approved'").Rows)
            {
                if (!first) sb.Append(",");
                first = false;
                sb.Append("{ \"name\": \"").Append(HttpUtilityEscape(dr["FullName"].ToString()))
                  .Append("\", \"vehicle\": \"").Append(HttpUtilityEscape(dr["VehicleTypeName"].ToString())).Append("\"");
                if (dr["Lat"] != DBNull.Value)
                    sb.Append(", \"lat\": ").Append(dr["Lat"]).Append(", \"lng\": ").Append(dr["Lng"]);
                sb.Append(" }");
            }
            sb.Append("]");
            DriversJson = sb.ToString();
        }

        private static string HttpUtilityEscape(string s)
        {
            return System.Web.HttpUtility.JavaScriptStringEncode(s ?? "");
        }

        protected void rptActivity_ItemCommand(object sender, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "view") return;
            int tripId = Convert.ToInt32(e.CommandArgument);
            OpenAppModal(Helper.TripHelper.BuildTripModalHtml(tripId, "TripDetail.aspx?id=" + tripId));
        }

        protected void rptOnline_ItemCommand(object sender, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "view") return;
            int driverId = Convert.ToInt32(e.CommandArgument);
            OpenAppModal(Helper.TripHelper.BuildDriverModalHtml(driverId, "DriverDetail.aspx?id=" + driverId));
        }
    }
}