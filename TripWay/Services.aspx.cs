using System;
using System.Data;

namespace TripWay
{
    public partial class ServicesPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool loggedIn = Helper.AuthHelper.IsLoggedIn();
            pnlCtaGuest.Visible = !loggedIn;
            pnlCtaUser.Visible = loggedIn;
            pnlCtaGuestBtn.Visible = !loggedIn;
            pnlCtaUserBtn.Visible = loggedIn;
            if (loggedIn)
            {
                string dash = DashboardUrl();
                lnkCtaDashboard.NavigateUrl = dash;
                lnkCtaBook.NavigateUrl = "~/Customer/BookTrip.aspx";
                lnkCtaBook.Visible = Helper.AuthHelper.GetRole() == "Customer";
            }

            if (IsPostBack) return;

            // A vehicle has one rate row holding both figures, so there is nothing to group and no
            // service to join: the per-km rate it charges for point-to-point and the per-hour rate
            // it charges for hourly hire both come off the same row. A rate that is NULL is a
            // service that vehicle does not offer, and the table prints a dash for it.
            DataTable dt = Helper.DBHelper.ExecuteQuery(
                "SELECT v.Name AS VehicleTypeName, fr.PerKmRate AS PtpPerKm, fr.HourlyRate AS HlyPerHour " +
                "FROM FareRates fr " +
                "INNER JOIN VehicleTypes v ON v.VehicleTypeID = fr.VehicleTypeID " +
                "WHERE fr.PerKmRate IS NOT NULL OR fr.HourlyRate IS NOT NULL " +
                "ORDER BY v.VehicleTypeID");

            rptFares.DataSource = dt;
            rptFares.DataBind();

            // A Repeater prints nothing at all for an empty DataSource, so the grid would just
            // be a blank strip of page with no explanation.
            Helper.EmptyState.Block(pnlNoFares, dt.Rows.Count == 0,
                "No fare rates have been set yet. An admin has to set a rate for a vehicle before it can be booked.");
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

        protected string FmtN(object v)
        {
            if (v == null || v == DBNull.Value) return "\u2014";
            return "MMK " + string.Format("{0:N0}", Convert.ToDecimal(v));
        }
    }
}
