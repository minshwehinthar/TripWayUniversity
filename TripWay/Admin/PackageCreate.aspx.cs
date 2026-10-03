using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    /// <summary>
    /// Create-only form for a package. Editing lives on PackageEdit.aspx and read-only
    /// viewing (with delete) on PackageDetail.aspx, so there is no ?id= here.
    /// </summary>
    public partial class PackageCreatePage : Helper.ListPageBase
    {
        /// <summary>Stops shown before the admin asks for more. Two is enough to draw a route.</summary>
        private const int InitialPlaceRows = 2;

        /// <summary>
        /// Ceiling on stops. Every row renders a set of server controls whose textboxes travel
        /// in the form, so this is also the practical limit on how large the form can get.
        /// </summary>
        private const int MaxPlaceRows = 12;

        private const int MaxImageBytes = 4 * 1024 * 1024;

        /// <summary>
        /// Renders the empty rows the script starts from. Their values live in the hidden field
        /// rather than in server controls, so there is nothing to repopulate here: after a
        /// postback the script rebuilds the typed stops from that field.
        /// </summary>
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Helper.TripHelper.EnsurePackagePhotos();
            Helper.TripHelper.EnsurePackageActive();

            var blank = new List<PlaceRow>();
            for (int i = 0; i < InitialPlaceRows; i++) blank.Add(new PlaceRow { Index = i + 1 });
            rptPlaces.DataSource = blank;
            rptPlaces.DataBind();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;
            if (!ValidateUploads()) return;

            int packageId = Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                @"INSERT INTO Packages (Name, DurationDays, FixedPrice, IsActive)
                  VALUES (@n, @d, @f, @act); SELECT SCOPE_IDENTITY();",
                new SqlParameter("@n", txtName.Text.Trim()),
                new SqlParameter("@d", Convert.ToInt32(txtDurationDays.Text)),
                new SqlParameter("@f", Convert.ToDecimal(txtFixedPrice.Text)),
                new SqlParameter("@act", chkActive.Checked)));
            Helper.TripHelper.LogActivity("PackageCreated", null, "Admin created package " + packageId + ".");

            SaveCoverPhoto(packageId);

            /* A finished save lands on the list, which is where the admin goes next anyway.
               The other branch is not a finished save: a stop that was named but never given
               coordinates is dropped rather than written with zeroes, which would put the package
               in the Gulf of Guinea. Sending them to the list there would hide a half-built
               package with no hint that anything was missing, so they go back to the form to
               finish it. */
            if (SavePlaces(packageId))
                Response.Redirect("PackageManagement.aspx");
            else
                Response.Redirect("PackageEdit.aspx?id=" + packageId);
        }

        private void SaveCoverPhoto(int packageId)
        {
            if (!fuCover.HasFile) return;
            string saved = StoreImage(fuCover.PostedFile, "Cover_" + packageId);
            if (saved == null) return;
            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Packages SET CoverPhotoUrl=@p WHERE PackageID=@id",
                new SqlParameter("@p", saved), new SqlParameter("@id", packageId));
        }

        /// <summary>
        /// Writes the tour stops. Returns true when every named stop was stored, false when
        /// one still needs coordinates, in which case the caller sends the admin to Edit.
        /// Whatever was completed before the incomplete stop is still written, so nothing
        /// already typed is lost.
        /// </summary>
        private bool SavePlaces(int packageId)
        {
            var placePars = new List<SqlParameter>();
            // Declared once, before the loop. Added per stop it repeated the same name, and
            // SQL Server rejects a batch that declares one name twice - so any package with
            // more than one stop failed to save at all.
            placePars.Add(new SqlParameter("@pkg", packageId));
            var valRows = new List<string>();
            int order = 0;
            bool complete = true;

            foreach (PlaceRow stop in ReadStops())
            {
                // A stop that was named but never given coordinates is dropped rather than
                // written with zeroes, which would put the package in the Gulf of Guinea.
                decimal lat, lng;
                // Both are read before either result is tested: && would skip the second
                // call, leaving lng unassigned when it is used further down.
                bool latOk = Helper.TripHelper.TryReadCoordinate(stop.Lat, out lat, 90m);
                bool lngOk = Helper.TripHelper.TryReadCoordinate(stop.Lng, out lng, 180m);
                if (!latOk || !lngOk)
                {
                    complete = false;
                    continue;
                }

                valRows.Add("(@pkg, @n" + order + ", @la" + order + ", @ln" + order + ", @o" + order + ")");
                placePars.Add(new SqlParameter("@n" + order, stop.PlaceName.Trim()));
                placePars.Add(new SqlParameter("@la" + order, lat));
                placePars.Add(new SqlParameter("@ln" + order, lng));
                placePars.Add(new SqlParameter("@o" + order, order));
                order++;
            }

            if (valRows.Count > 0)
                Helper.DBHelper.ExecuteNonQuery(
                    "INSERT INTO PackagePlaces (PackageID, PlaceName, Lat, Lng, OrderIndex) VALUES " + string.Join(", ", valRows),
                    placePars.ToArray());
            return complete;
        }

        /// <summary>
        /// The stops to write, newest page state first.
        ///
        /// Add and Remove no longer post back, because posting back replaced the whole document
        /// and the admin lost their place on a long form. The stops therefore travel in a single
        /// hidden field, one record per stop: the three values are URL-encoded (so a name may
        /// contain any punctuation at all) and joined with "|", and the records are joined with
        /// "~". Both separators are escaped by the client, so a stop name cannot forge a record.
        ///
        /// The repeater is still read when the field is empty, which is what happens if
        /// scripting is unavailable, so the form can still be submitted without it.
        /// </summary>
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

            // The row limit is enforced here as well as in script. A hidden field is just
            // text in a request, so the client-side cap proves nothing on its own.
            while (stops.Count > MaxPlaceRows) stops.RemoveAt(stops.Count - 1);

            // Blank stops are not written, and a stop 1 that was left empty must not leave a
            // route that starts somewhere the admin never chose.
            return stops.FindAll(delegate (PlaceRow s) { return !string.IsNullOrWhiteSpace(s.PlaceName); });
        }

        /// <summary>
        /// One stop as the script sent it. Index is display only and is set from the row order.
        /// </summary>
        [Serializable]
        private class PlaceRow
        {
            public int Index { get; set; }
            public string PlaceName { get; set; }
            public string Lat { get; set; }
            public string Lng { get; set; }
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
        /// Rejects unusable uploads before anything is written, so a bad file cannot leave the
        /// package half-saved.
        /// </summary>
        private bool ValidateUploads()
        {
            if (fuCover.HasFile && !IsAcceptedImage(fuCover.PostedFile))
            {
                ShowMessage("Cover photo must be a JPG or PNG image under 4 MB.");
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

        private void ShowMessage(string text)
        {
            lblMessage.Text = text;
            pnlMessage.Visible = true;
        }
    }
}
