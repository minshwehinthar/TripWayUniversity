using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay
{
    public partial class DefaultPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool loggedIn = Helper.AuthHelper.IsLoggedIn();
            pnlHeroGuest.Visible = !loggedIn;
            pnlHeroUser.Visible = loggedIn;
            pnlCtaGuest.Visible = !loggedIn;
            pnlCtaUser.Visible = loggedIn;
            if (loggedIn)
            {
                string dash = DashboardUrl();
                lnkHeroDashboard.NavigateUrl = dash;
                lnkCtaDashboard.NavigateUrl = dash;
            }

            if (IsPostBack) return;

            // The published-package queries below filter on IsActive, so the column has to
            // exist before they run, whether or not the upgrade script has been applied yet.
            Helper.TripHelper.EnsurePackageActive();

            lblDrivers.Text = CountOf("SELECT COUNT(*) FROM Drivers WHERE KYCStatus = 'Approved'").ToString("N0");
            lblTrips.Text = CountOf("SELECT COUNT(*) FROM Trips WHERE Status = 'Completed'").ToString("N0");
            lblPassengers.Text = CountOf("SELECT COUNT(*) FROM Customers WHERE Status = 'Active'").ToString("N0");

            DataTable hero = Helper.DBHelper.ExecuteQuery(
                @"SELECT TOP 4 p.Name AS PackageName, p.FixedPrice AS BaseFare, " +
                "ISNULL(STUFF((SELECT ', ' + pp.PlaceName FROM PackagePlaces pp " +
                "WHERE pp.PackageID = p.PackageID ORDER BY pp.OrderIndex FOR XML PATH('')), 1, 2, ''), '') AS Description, " +
                "(SELECT COUNT(*) FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID) AS PlaceCount " +
                "FROM Packages p WHERE p.IsActive = 1 ORDER BY p.PackageID");
            rptHeroPackages.DataSource = hero;
            rptHeroPackages.DataBind();
            pnlHeroEmpty.Visible = hero.Rows.Count == 0;

            DataTable dt = Helper.DBHelper.ExecuteQuery(
                @"SELECT TOP 6 p.Name AS PackageName, p.FixedPrice AS BaseFare, " +
                "CAST(p.DurationDays AS NVARCHAR(10)) + ' day tour' AS DurationLabel, " +
                "ISNULL(STUFF((SELECT ', ' + pp.PlaceName FROM PackagePlaces pp " +
                "WHERE pp.PackageID = p.PackageID ORDER BY pp.OrderIndex FOR XML PATH('')), 1, 2, ''), '') AS Description, " +
                "(SELECT COUNT(*) FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID) AS PlaceCount " +
                "FROM Packages p WHERE p.IsActive = 1 ORDER BY p.PackageID");
            rptPackages.DataSource = dt;
            rptPackages.DataBind();
            Helper.EmptyState.Block(pnlNoPackages, dt.Rows.Count == 0,
                "No day tour packages have been published yet.");
        }

        private string DashboardUrl()
        {
            switch (Helper.AuthHelper.GetRole())
            {
                case "Admin": return "~/Admin/Dashboard.aspx";
                case "Driver": return "~/Driver/Dashboard.aspx";
                case "Customer": return "~/Customer/Dashboard.aspx";
                default: return "~/Default.aspx";
            }
        }

        private int CountOf(string sql)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql);
            if (o == null || o == DBNull.Value) return 0;
            return Convert.ToInt32(o);
        }
    }
}