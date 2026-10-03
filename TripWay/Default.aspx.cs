using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

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
                @"SELECT TOP 4 p.PackageID, p.Name AS PackageName, p.FixedPrice AS BaseFare, " +
                "ISNULL(STUFF((SELECT ', ' + pp.PlaceName FROM PackagePlaces pp " +
                "WHERE pp.PackageID = p.PackageID ORDER BY pp.OrderIndex FOR XML PATH('')), 1, 2, ''), '') AS Description, " +
                "(SELECT COUNT(*) FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID) AS PlaceCount " +
                "FROM Packages p WHERE p.IsActive = 1 ORDER BY p.PackageID");
            rptHeroPackages.DataSource = hero;
            rptHeroPackages.DataBind();
            pnlHeroEmpty.Visible = hero.Rows.Count == 0;

            DataTable dt = Helper.DBHelper.ExecuteQuery(
                @"SELECT TOP 6 p.PackageID, p.Name AS PackageName, p.FixedPrice AS BaseFare, " +
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

        protected void rptHeroPackages_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            StampPackageBookUrl(e, "lnkHeroPackage");
        }

        protected void rptPackages_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            StampPackageBookUrl(e, "lnkPackageBook");
        }

        // Eval() is only legal inside a <%# %> expression on a databound control, and a bare
        // html <a> is not one, so the card link is stamped here per row instead. The markup
        // href is the Register fallback, which also covers a row we fail to read.
        private void StampPackageBookUrl(RepeaterItemEventArgs e, string linkId)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var link = e.Item.FindControl(linkId) as System.Web.UI.HtmlControls.HtmlAnchor;
            if (link == null) return;

            var package = e.Item.DataItem as DataRowView;
            if (package == null) return;

            link.HRef = PackageBookUrl(package["PackageID"]);
        }

        /// <summary>
        /// Where a package card should send the visitor. A signed-in Customer goes straight
        /// to BookTrip with that package already chosen.
        /// Anyone else goes to the login page, because BookTrip calls RequireCustomer and would
        /// bounce a Driver or Admin straight back out to their own dashboard. Signing in from
        /// there lands on the dashboard without the package picked, so the card is a plain
        /// entry point rather than a reservation for anyone not already a Customer.
        /// </summary>
        private string PackageBookUrl(object packageId)
        {
            if (!Helper.AuthHelper.IsLoggedIn() || Helper.AuthHelper.GetRole() != "Customer")
                return ResolveUrl("~/Login.aspx");

            int id;
            if (!int.TryParse(Convert.ToString(packageId), out id) || id <= 0)
                return ResolveUrl("~/Customer/BookTrip.aspx");

            // Plain integer, so nothing needs escaping; BookTrip still checks it against the
            // active package list before trusting it.
            return ResolveUrl("~/Customer/BookTrip.aspx") + "?package=" + id;
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