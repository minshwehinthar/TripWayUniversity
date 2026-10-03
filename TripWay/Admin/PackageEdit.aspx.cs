using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    /// <summary>
    /// Edit-only form for a package. Creating lives on PackageCreate.aspx and read-only
    /// viewing (with delete) on PackageDetail.aspx, so ?id= is mandatory here.
    /// </summary>
    public partial class PackageEditPage : Helper.ListPageBase
    {
        /// <summary>Stops shown when a package has none yet. Two is enough to draw a route.</summary>
        private const int InitialPlaceRows = 2;

        /// <summary>Ceiling on stops, matching MaxPlaceRows in PackageCreate.aspx.cs.</summary>
        private const int MaxPlaceRows = 12;

        private const int MaxImageBytes = 4 * 1024 * 1024;

        public int PackageIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        private int PackageId { get { return PackageIdParam; } }

        /// <summary>
        /// Rows have to exist before WebForms applies posted values, or a postback cannot land
        /// anything in them. The saved stops are bound here on a fresh request; on a postback the
        /// script rebuilds them from hfStops, so these are empty skeletons.
        /// </summary>
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Helper.TripHelper.EnsurePackagePhotos();
            Helper.TripHelper.EnsurePackageActive();
            /* Spelled out rather than as "IsPostBack ? PlaceRowCount : (DataTable)null". An int
               and a DataTable have no conversion in either direction, so no C# version can type
               that conditional: the compiler reports it as a target-typed conditional expression
               failing to convert to DataTable. Passing the row count as its own parameter says
               what is meant and compiles everywhere. */
            if (IsPostBack)
            {
                BindPlaces(null, PlaceRowCount);
            }
            else
            {
                BindPlaces(null, InitialPlaceRows);
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);

            if (PackageId == 0)
            {
                Response.Redirect("PackageManagement.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadPackage();
                BindPlaces(Helper.DBHelper.ExecuteQuery(
                    "SELECT PlaceName, Lat, Lng FROM PackagePlaces WHERE PackageID=@id ORDER BY OrderIndex, PackagePlaceID",
                    new SqlParameter("@id", PackageId)), InitialPlaceRows);
            }
        }

        /// <summary>
        /// How many rows the last render produced, so a postback can rebuild that many.
        /// <para>
        /// This is only the no-scripting path. With scripting on, the client sends the stops in
        /// hfStops and the count is irrelevant. Without it, Add and Remove cannot work at all, so
        /// the form has to fall back to exactly the rows it rendered last time: fewer rows than
        /// that would silently discard the later stops of a long package, and more would make
        /// WebForms reject the form as having controls it did not render.
        /// </para>
        /// </summary>
        private int PlaceRowCount
        {
            get
            {
                object v = ViewState["PlaceRowCount"];
                return v == null ? InitialPlaceRows : (int)v;
            }
            set { ViewState["PlaceRowCount"] = value; }
        }

        private void LoadPackage()
        {
            DataTable r = Helper.DBHelper.ExecuteQuery(
                "SELECT * FROM Packages WHERE PackageID=@id",
                new SqlParameter("@id", PackageId));
            if (r.Rows.Count == 0)
            {
                Response.Redirect("PackageManagement.aspx");
                return;
            }
            DataRow row = r.Rows[0];
            txtName.Text = row["Name"].ToString();
            txtDurationDays.Text = row["DurationDays"].ToString();
            txtFixedPrice.Text = row["FixedPrice"].ToString();
            if (row.Table.Columns.Contains("IsActive")) chkActive.Checked = Convert.ToBoolean(row["IsActive"]);

            string cover = Helper.TripHelper.PackagePhotoUrl(row["CoverPhotoUrl"]);
            pnlCover.Visible = cover.Length > 0;
            pnlCoverNone.Visible = cover.Length == 0;
            if (cover.Length > 0) imgCover.ImageUrl = ResolveUrl("~/" + cover);
        }

        /// <summary>
        /// Renders the stops, padding to the minimum so the script always has a template to
        /// clone from and a row to add to.
        /// <para>
        /// minRows is the floor, not the answer. On a postback it is how many rows the previous
        /// render produced, which is what the form must reproduce or the posted values for the
        /// later stops have nowhere to land.
        /// </para>
        /// </summary>
        private void BindPlaces(DataTable existing, int minRows)
        {
            var rows = new List<PlaceRow>();
            DataTable src = existing ?? new DataTable();
            int count = Math.Max(minRows, src.Rows.Count);
            PlaceRowCount = count;
            for (int i = 0; i < count; i++)
            {
                object placeName = null, lat = null, lng = null;
                if (i < src.Rows.Count)
                {
                    placeName = src.Rows[i]["PlaceName"];
                    lat = src.Rows[i]["Lat"];
                    lng = src.Rows[i]["Lng"];
                }
                rows.Add(new PlaceRow
                {
                    Index = i + 1,
                    PlaceName = placeName == null || placeName == DBNull.Value ? "" : placeName.ToString(),
                    Lat = lat == null || lat == DBNull.Value ? "" : Convert.ToDecimal(lat).ToString("0.000000"),
                    Lng = lng == null || lng == DBNull.Value ? "" : Convert.ToDecimal(lng).ToString("0.000000")
                });
            }
            rptPlaces.DataSource = rows;
            rptPlaces.DataBind();
        }

        private class PlaceRow
        {
            public int Index { get; set; }
            public string PlaceName { get; set; }
            public string Lat { get; set; }
            public string Lng { get; set; }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!ValidateUploads()) return;

            /* The stops are read and checked before the package row is touched, so a save that
               cannot finish changes nothing at all. Validating afterwards left the package
               carrying the new name and price with none of its stops, and the redirect then
               discarded the message explaining which stop was the problem. */
            List<PlaceRow> stops = ReadStops();
            string stopError = ValidateStops(stops);
            if (stopError != null)
            {
                ShowMessage(stopError, true);
                return;
            }

            int packageId = PackageId;

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Packages SET Name=@n, DurationDays=@d, FixedPrice=@f, IsActive=@act WHERE PackageID=@id",
                new SqlParameter("@n", txtName.Text.Trim()),
                new SqlParameter("@d", Convert.ToInt32(txtDurationDays.Text)),
                new SqlParameter("@f", Convert.ToDecimal(txtFixedPrice.Text)),
                new SqlParameter("@act", chkActive.Checked),
                new SqlParameter("@id", packageId));
            Helper.TripHelper.LogActivity("PackageUpdated", null, "Admin updated package " + packageId + ".");

            SaveCoverPhoto(packageId);
            SavePlaces(packageId, stops);

            Response.Redirect("PackageManagement.aspx");
        }

        private void SaveCoverPhoto(int packageId)
        {
            string current = Helper.TripHelper.PackagePhotoUrl(Helper.DBHelper.ExecuteScalar(
                "SELECT CoverPhotoUrl FROM Packages WHERE PackageID=@id",
                new SqlParameter("@id", packageId)));

            if (chkRemoveCover.Checked)
            {
                DeleteStoredPhoto(current);
                Helper.DBHelper.ExecuteNonQuery(
                    "UPDATE Packages SET CoverPhotoUrl=NULL WHERE PackageID=@id",
                    new SqlParameter("@id", packageId));
                if (fuCover.HasFile)
                {
                    string fresh = StoreImage(fuCover.PostedFile, "Cover_" + packageId);
                    if (fresh != null)
                        Helper.DBHelper.ExecuteNonQuery(
                            "UPDATE Packages SET CoverPhotoUrl=@p WHERE PackageID=@id",
                            new SqlParameter("@p", fresh), new SqlParameter("@id", packageId));
                }
                return;
            }

            if (!fuCover.HasFile) return;
            string saved = StoreImage(fuCover.PostedFile, "Cover_" + packageId);
            if (saved == null) return;
            DeleteStoredPhoto(current);
            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Packages SET CoverPhotoUrl=@p WHERE PackageID=@id",
                new SqlParameter("@p", saved), new SqlParameter("@id", packageId));
        }

        /// <summary>
        /// Writes the tour stops, oldest page state first.
        ///
        /// Add and Remove do not post back, so the stops travel in a single hidden field rather
        /// than as a set of server controls per row: the three values are URL-encoded and joined
        /// with "|", and the records are joined with "~". Both separators are escaped by the
        /// client, so a stop name cannot forge a record. This mirrors ReadStops on the create
        /// page, and the repeater is still read when the field is empty, which is what happens
        /// if scripting is unavailable.
        /// </summary>
        /// <summary>
        /// Checks every stop before anything is written, and names the first bad one.
        /// <para>
        /// This used to happen inline in SavePlaces, after it had already deleted the package's
        /// existing stops. A stop with bad coordinates therefore left the package with no stops at
        /// all, and because the caller redirected straight afterwards, the message naming the bad
        /// stop was thrown away unread. Validating up front means a rejected save writes nothing:
        /// not the stops, and not the package fields either.
        /// </para>
        /// </summary>
        /// <returns>null when every stop is usable, otherwise the message to show.</returns>
        private static string ValidateStops(List<PlaceRow> stops)
        {
            foreach (PlaceRow stop in stops)
            {
                decimal lat, lng;
                // Both coordinates are read before either result is tested: && would skip the
                // second call, leaving lng unassigned when it is used further down.
                bool latOk = Helper.TripHelper.TryReadCoordinate(stop.Lat, out lat, 90m);
                bool lngOk = Helper.TripHelper.TryReadCoordinate(stop.Lng, out lng, 180m);
                if (!latOk || !lngOk)
                {
                    return "Stop \"" + stop.PlaceName.Trim()
                        + "\" needs valid coordinates — click it, then click the map.";
                }
            }
            return null;
        }

        /// <summary>
        /// Replaces the package's stops with the given ones. Only called once they are known to
        /// be valid, so the delete and the insert cannot leave the package with no stops.
        /// </summary>
        private void SavePlaces(int packageId, List<PlaceRow> stops)
        {
            Helper.DBHelper.ExecuteNonQuery("DELETE FROM PackagePlaces WHERE PackageID=@id",
                new SqlParameter("@id", packageId));

            int order = 0;
            var placePars = new List<SqlParameter>();
            // Declared once, before the loop. Added per stop it repeated the same name, and
            // SQL Server rejects a batch that declares one name twice - so any package with
            // more than one stop failed to save at all.
            placePars.Add(new SqlParameter("@pkg", packageId));
            var valRows = new List<string>();
            foreach (PlaceRow stop in stops)
            {
                decimal lat, lng;
                Helper.TripHelper.TryReadCoordinate(stop.Lat, out lat, 90m);
                Helper.TripHelper.TryReadCoordinate(stop.Lng, out lng, 180m);

                valRows.Add("(@pkg, @n" + order + ", @la" + order + ", @ln" + order + ", @o" + order + ")");
                placePars.Add(new SqlParameter("@n" + order, stop.PlaceName.Trim()));
                placePars.Add(new SqlParameter("@la" + order, lat));
                placePars.Add(new SqlParameter("@ln" + order, lng));
                placePars.Add(new SqlParameter("@o" + order, order));
                order++;
            }

            if (valRows.Count > 0)
            {
                Helper.DBHelper.ExecuteNonQuery(
                    "INSERT INTO PackagePlaces (PackageID, PlaceName, Lat, Lng, OrderIndex) VALUES " + string.Join(", ", valRows),
                    placePars.ToArray());
            }
        }

        private List<PlaceRow> ReadStops()
        {
            var stops = new List<PlaceRow>();
            string payload = (hfStops.Value ?? "").Trim();

            if (payload.Length > 0)
            {
                string[] records = payload.Split('~');
                foreach (string record in records)
                {
                    if (record.Length == 0) continue;
                    string[] parts = record.Split('|');
                    stops.Add(new PlaceRow
                    {
                        PlaceName = Decode(parts, 0),
                        Lat = Decode(parts, 1),
                        Lng = Decode(parts, 2)
                    });
                }
            }
            else
            {
                foreach (RepeaterItem item in rptPlaces.Items)
                {
                    var tName = item.FindControl("txtPlaceName") as TextBox;
                    var tLat = item.FindControl("txtLat") as TextBox;
                    var tLng = item.FindControl("txtLng") as TextBox;
                    stops.Add(new PlaceRow
                    {
                        PlaceName = tName == null ? "" : tName.Text,
                        Lat = tLat == null ? "" : tLat.Text,
                        Lng = tLng == null ? "" : tLng.Text
                    });
                }
            }

            // The row limit is enforced here as well as in script. A hidden field is just text
            // in a request, so the client-side cap proves nothing on its own.
            while (stops.Count > MaxPlaceRows) stops.RemoveAt(stops.Count - 1);

            // Blank stops are not written, and a stop 1 that was left empty must not leave a
            // route that starts somewhere the admin never chose.
            return stops.FindAll(delegate (PlaceRow s) { return !string.IsNullOrWhiteSpace(s.PlaceName); });
        }

        /// <summary>
        /// URL-decodes one field of a record, or returns "" when the client sent a shorter one.
        /// A blank name never throws: HttpUtility.UrlDecode(null) would.
        /// </summary>
        private static string Decode(string[] parts, int index)
        {
            if (parts.Length <= index) return "";
            string raw = parts[index];
            return string.IsNullOrEmpty(raw) ? "" : HttpUtility.UrlDecode(raw);
        }

        /// <summary>
        /// Rejects an unusable upload before anything is written, so a bad file cannot leave the
        /// package half-saved.
        /// </summary>
        private bool ValidateUploads()
        {
            if (fuCover.HasFile && !IsAcceptedImage(fuCover.PostedFile))
            {
                ShowMessage("Cover photo must be a JPG or PNG image under 4 MB.", true);
                return false;
            }
            return true;
        }

        private static bool IsAcceptedImage(HttpPostedFile file)
        {
            if (file == null || file.ContentLength <= 0 || file.ContentLength > MaxImageBytes) return false;
            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png";
        }

        /// <summary>
        /// Stores one already-validated image and returns its page-relative path
        /// (Uploads/PackagePhotos/...).
        /// </summary>
        private string StoreImage(HttpPostedFile file, string prefix)
        {
            if (!IsAcceptedImage(file)) return null;

            string dir = Server.MapPath("~/" + Helper.TripHelper.PackagePhotoFolder);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            string name = prefix + "_" + DateTime.Now.Ticks + ext;
            file.SaveAs(Path.Combine(dir, name));
            return Helper.TripHelper.PackagePhotoFolder + "/" + name;
        }

        private void DeleteStoredPhoto(string relativeUrl)
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return;
            try
            {
                string full = Server.MapPath("~/" + relativeUrl);
                string root = Server.MapPath("~/" + Helper.TripHelper.PackagePhotoFolder);
                if (!string.IsNullOrEmpty(full) && !string.IsNullOrEmpty(root)
                    && full.StartsWith(root, StringComparison.OrdinalIgnoreCase) && File.Exists(full))
                    File.Delete(full);
            }
            catch { }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMessage.Text = text;
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
            pnlMessage.Visible = true;
        }
    }
}