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
            catch (System.Data.SqlClient.SqlException)
            {
                /* The column genuinely does not exist yet, so fall back to the column-less
                   query and let the cards show initials. Narrow on purpose: a bare catch here
                   used to swallow anything at all and drop ProfilePhotoUrl from the result,
                   which made every driver lose their photo with nothing to show for it. */
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
        }


        /// <summary>
        /// Pulls a photo column out of the bound row and returns the display path, or "" when
        /// there is nothing to show. Takes the column name because the driver fallback query
        /// deliberately omits ProfilePhotoUrl, and indexing a column that is not in the table
        /// throws rather than returning null.
        /// </summary>
        protected string AboutPhotoUrl(object dataItem, string column)
        {
            string url = StoredPhotoOf(dataItem, column);
            return url.Length == 0 ? "" : ResolveUrl("~/" + url);
        }

        /// <summary>
        /// Whether the card has a photo to overlay. Bound to the image's Visible, so the
        /// initials underneath are always rendered and the photo is only ever drawn on top.
        /// </summary>
        protected bool HasAboutPhoto(object dataItem, string column)
        {
            return StoredPhotoOf(dataItem, column).Length > 0;
        }

        private static string StoredPhotoOf(object dataItem, string column)
        {
            var row = dataItem as DataRowView;
            if (row == null || !row.Row.Table.Columns.Contains(column)) return "";
            return Helper.TripHelper.HotelPhotoUrl(row[column]);
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