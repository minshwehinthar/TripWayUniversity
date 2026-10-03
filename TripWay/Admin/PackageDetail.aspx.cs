using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;

namespace TripWay.Admin
{
    /// <summary>
    /// Read-only detail view of one package: cover photo, tour route on a map and the stops that
    /// make it up. Kept separate from PackageEdit so browsing never risks a save.
    /// </summary>
    public partial class PackageDetailPage : Helper.ListPageBase
    {
        public int PackageIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        public string PlacesJson { get; private set; } = "[]";

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            Helper.TripHelper.EnsurePackagePhotos();
            Helper.TripHelper.EnsurePackageActive();
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            int id = PackageIdParam;
            if (id == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT p.PackageID, p.Name, p.DurationDays, p.FixedPrice, p.CoverPhotoUrl, p.CreatedAt,
                         ISNULL(p.IsActive, 1) AS IsActive,
                         ISNULL(d.FullName,'Created by admin') AS CreatedByName,
                         (SELECT COUNT(*) FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID) AS PlacesCount,
                         (SELECT COUNT(*) FROM Trips tr WHERE tr.PackageID = p.PackageID) AS BookingsCount
                   FROM Packages p
                   LEFT JOIN Drivers d ON p.CreatedByDriverID = d.DriverID
                   WHERE p.PackageID=@id",
                new SqlParameter("@id", id));

            if (t.Rows.Count == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataRow r = t.Rows[0];
            pnlPackage.Visible = true;

            lblName.Text = r["Name"].ToString();
            lblPackageId.Text = id.ToString();
            lblSource.Text = r["CreatedByName"].ToString();
            lblCreated.Text = FormatTime(r["CreatedAt"]);
            lblDuration.Text = r["DurationDays"].ToString() + " day(s)";
            lblPlacesCount.Text = r["PlacesCount"].ToString();
            lblBookings.Text = Convert.ToInt32(r["BookingsCount"]) == 0
                ? "None yet"
                : Convert.ToInt32(r["BookingsCount"]) + " trip(s)";
            lblPrice.Text = "MMK " + string.Format("{0:N0}", Convert.ToDecimal(r["FixedPrice"]));

            bool isActive = Convert.ToBoolean(r["IsActive"]);
            lblActive.Text = isActive ? "Active" : "Hidden";
            lblActive.CssClass = "inline-flex px-2 py-1 rounded-full text-xs font-semibold "
                + (isActive ? "bg-green-100 text-green-700" : "bg-gray-100 text-gray-500");

            string cover = Helper.TripHelper.PackagePhotoUrl(r["CoverPhotoUrl"]);
            pnlCover.Visible = cover.Length > 0;
            if (cover.Length > 0) imgCover.ImageUrl = ResolveUrl("~/" + cover);

            DataTable places = Helper.DBHelper.ExecuteQuery(
                "SELECT PlaceName, Lat, Lng FROM PackagePlaces WHERE PackageID=@id ORDER BY OrderIndex, PackagePlaceID",
                new SqlParameter("@id", id));
            pnlNoPlaces.Visible = places.Rows.Count == 0;
            litPlaces.Text = PlacesListHtml(places);
            PlacesJson = BuildPlacesJson(places);
        }

        /// <summary>
        /// Place names in itinerary order. The coordinates stay on the map and in the edit
        /// form: showing "(16.881391, 97.626258)" under every name is noise in a read-only view.
        /// </summary>
        private static string PlacesListHtml(DataTable places)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < places.Rows.Count; i++)
            {
                string color = i == 0 ? "bg-emerald-500" : (i == places.Rows.Count - 1 ? "bg-rose-500" : "bg-blue-500");
                string name = places.Rows[i]["PlaceName"].ToString().Trim();
                if (name.Length == 0) name = "Place " + (i + 1);
                sb.Append("<div class=\"flex items-start gap-2 py-1\">")
                  .Append("<span class=\"flex items-center justify-center size-5 rounded-full ").Append(color)
                  .Append(" text-white text-[10px] font-bold shrink-0 mt-0.5\">").Append(i + 1).Append("</span>")
                  .Append("<span class=\"text-sm text-gray-600\">").Append(HttpUtility.HtmlEncode(name))
                  .Append("</span></div>");
            }
            return sb.ToString();
        }

        /// <summary>
        /// Map points as [htmlEncodedName, lat, lng] for the Leaflet script block.
        /// </summary>
        private static string BuildPlacesJson(DataTable places)
        {
            var sb = new StringBuilder("[");
            for (int i = 0; i < places.Rows.Count; i++)
            {
                if (i > 0) sb.Append(", ");
                sb.Append("[\"")
                  .Append(HttpUtility.HtmlEncode(places.Rows[i]["PlaceName"].ToString()))
                  .Append("\", ")
                  .Append(Convert.ToDouble(places.Rows[i]["Lat"])).Append(", ")
                  .Append(Convert.ToDouble(places.Rows[i]["Lng"])).Append("]");
            }
            return sb.Append("]").ToString();
        }
    }
}
