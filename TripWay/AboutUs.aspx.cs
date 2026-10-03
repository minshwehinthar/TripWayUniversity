using System;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay
{
    public partial class AboutUsPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            lblDrivers.Text = CountOf("SELECT COUNT(*) FROM Drivers WHERE KYCStatus = 'Approved'").ToString("N0");
            lblPassengers.Text = CountOf("SELECT COUNT(*) FROM Customers WHERE Status = 'Active'").ToString("N0");
            lblTrips.Text = CountOf("SELECT COUNT(*) FROM Trips WHERE Status = 'Completed'").ToString("N0");

            BindHotels();
            BindDrivers();
        }

        private int CountOf(string sql)
        {
            object o = Helper.DBHelper.ExecuteScalar(sql);
            if (o == null || o == DBNull.Value) return 0;
            return Convert.ToInt32(o);
        }

        /// <summary>
        /// Partner hotels come from the same Hotels table the admin manages and BookTrip reads,
        /// so a hotel added in the admin console shows up here on the next page load.
        /// </summary>
        private void BindHotels()
        {
            // Self-heals the table if the upgrade has not run yet, so this public page
            // cannot be the thing that throws a 500.
            Helper.TripHelper.EnsureHotels();
            DataTable dt = Helper.TripHelper.GetActiveHotels();

            rptAboutHotels.DataSource = dt;
            rptAboutHotels.DataBind();
            pnlAboutHotels.Visible = dt.Rows.Count > 0;
            pnlAboutHotelsEmpty.Visible = dt.Rows.Count == 0;

            // Decide logo-vs-initials per card once the items exist, not from inside
            // the data-binding expression, where rptAboutHotels.Items is still empty.
            foreach (RepeaterItem item in rptAboutHotels.Items)
            {
                var holder = item.FindControl("pnlAboutPhotoUrl") as Panel;
                var initials = item.FindControl("pnlAboutHotelInitials") as Panel;
                if (holder == null || initials == null) continue;

                bool hasLogo = HotelLogoOf(item.DataItem).Length > 0;
                holder.Visible = hasLogo;
                initials.Visible = !hasLogo;
            }
        }

        /// <summary>
        /// HotelPhotoUrl takes the stored path value, not the row, so pull the column out first.
        /// </summary>
        private static string HotelLogoOf(object dataItem)
        {
            var row = dataItem as DataRowView;
            if (row == null) return "";
            return Helper.TripHelper.HotelPhotoUrl(row["LogoPhotoUrl"]);
        }

        /// <summary>
        /// Approved drivers only. Phone number, NRC, licence and vehicle registration photos
        /// are deliberately never published here; the avatar comes from ProfilePhotoUrl, the
        /// dedicated column that is separate from the KYC document photos.
        /// </summary>
        private void BindDrivers()
        {
            // Self-heals the column if Upgrade 6 has not run, so this public page
            // cannot be the thing that throws a 500.
            Helper.TripHelper.EnsureDriverProfilePhoto();

            DataTable dt;
            try
            {
                dt = Helper.DBHelper.ExecuteQuery(
                    "SELECT TOP 8 d.FullName, d.ProfilePhotoUrl, vt.Name AS VehicleName, d.AverageRating, " +
                    "(SELECT COUNT(*) FROM Trips t WHERE t.DriverID = d.DriverID AND t.Status = 'Completed') AS CompletedTrips " +
                    "FROM Drivers d JOIN VehicleTypes vt ON vt.VehicleTypeID = d.VehicleTypeID " +
                    "WHERE d.KYCStatus = 'Approved' " +
                    "ORDER BY d.AverageRating DESC, d.DriverID");
            }
            catch
            {
                // Fall back to the column-less query so the section still renders.
                dt = Helper.DBHelper.ExecuteQuery(
                    "SELECT TOP 8 d.FullName, vt.Name AS VehicleName, d.AverageRating, " +
                    "(SELECT COUNT(*) FROM Trips t WHERE t.DriverID = d.DriverID AND t.Status = 'Completed') AS CompletedTrips " +
                    "FROM Drivers d JOIN VehicleTypes vt ON vt.VehicleTypeID = d.VehicleTypeID " +
                    "WHERE d.KYCStatus = 'Approved' " +
                    "ORDER BY d.AverageRating DESC, d.DriverID");
            }

            rptAboutDrivers.DataSource = dt;
            rptAboutDrivers.DataBind();
            pnlAboutDrivers.Visible = dt.Rows.Count > 0;
            pnlAboutDriversEmpty.Visible = dt.Rows.Count == 0;

            // Same rule as the hotel cards: photo when there is one, initials otherwise.
            foreach (RepeaterItem item in rptAboutDrivers.Items)
            {
                var photo = item.FindControl("pnlAboutDriverPhoto") as Panel;
                var initials = item.FindControl("pnlAboutDriverInitials") as Panel;
                if (photo == null || initials == null) continue;

                var row = item.DataItem as DataRowView;
                // The fallback query has no ProfilePhotoUrl column, so check before indexing.
                bool hasPhoto = row != null
                    && row.Row.Table.Columns.Contains("ProfilePhotoUrl")
                    && Helper.TripHelper.DriverPhotoUrl(row["ProfilePhotoUrl"]).Length > 0;
                photo.Visible = hasPhoto;
                initials.Visible = !hasPhoto;
            }
        }

        /// <summary>Hotels have a logo; drivers do not, so both fall back to initials.</summary>
        protected string AboutInitials(object value)
        {
            string text = Raw(value);
            if (text.Length == 0) return "?";

            var words = text.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 1) return Safe(words[0].Substring(0, 1).ToUpperInvariant());
            return Safe((words[0].Substring(0, 1) + words[words.Length - 1].Substring(0, 1)).ToUpperInvariant());
        }

        /// <summary>
        /// Resolves a stored photo path for display. Empty when there is no photo, in which
        /// case the caller shows the initials tile instead. Shared by hotels and drivers.
        /// </summary>
        protected string AboutPhotoUrl(object storedPath)
        {
            string url = Helper.TripHelper.HotelPhotoUrl(storedPath);
            return url.Length == 0 ? "" : ResolveUrl("~/" + url);
        }

        protected string AboutText(object value)
        {
            string text = Raw(value);
            return text.Length == 0 ? "&#8212;" : HttpUtility.HtmlEncode(text);
        }

        protected string AboutPhone(object value)
        {
            string text = Raw(value);
            return text.Length == 0 ? "" : HttpUtility.HtmlEncode(text);
        }

        protected string AboutRating(object value)
        {
            if (value == null || value == DBNull.Value) return "New";
            double rating = Convert.ToDouble(value);
            return rating > 0 ? rating.ToString("0.0") : "New";
        }

        protected string AboutTrips(object value)
        {
            if (value == null || value == DBNull.Value) return "0";
            return Convert.ToInt32(value).ToString("N0");
        }

        private static string Raw(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            string text = value.ToString().Trim();
            // An em dash placeholder is never a real value; treat it as missing.
            return text == "—" || text == "-" ? "" : text;
        }

        private static string Safe(string text)
        {
            return HttpUtility.HtmlEncode(text);
        }
    }
}