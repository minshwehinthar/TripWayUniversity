using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace TripWay.Admin
{
    /// <summary>
    /// Edit-only form for a hotel. Creating lives on HotelCreate.aspx and read-only
    /// viewing on HotelDetail.aspx, so ?id= is mandatory here.
    /// </summary>
    public partial class HotelEditPage : Helper.ListPageBase
    {
        private const int MaxImageBytes = 4 * 1024 * 1024;

        public int HotelIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Helper.TripHelper.EnsureHotels();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);

            if (HotelIdParam == 0)
            {
                Response.Redirect("HotelManagement.aspx");
                return;
            }

            if (!IsPostBack) LoadHotel();
        }

        private void LoadHotel()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                "SELECT Name, Address, Phone, Email, LogoPhotoUrl, Lat, Lng, IsActive FROM Hotels WHERE HotelID=@id",
                new SqlParameter("@id", HotelIdParam));
            if (t.Rows.Count == 0)
            {
                Response.Redirect("HotelManagement.aspx");
                return;
            }

            DataRow r = t.Rows[0];
            txtName.Text = r["Name"].ToString();
            txtAddress.Text = r["Address"] == DBNull.Value ? "" : r["Address"].ToString();
            txtPhone.Text = r["Phone"] == DBNull.Value ? "" : r["Phone"].ToString();
            txtEmail.Text = r["Email"] == DBNull.Value ? "" : r["Email"].ToString();
            txtLat.Text = r["Lat"].ToString();
            txtLng.Text = r["Lng"].ToString();
            chkActive.Checked = Convert.ToBoolean(r["IsActive"]);

            // The logo tile shows the stored logo or a placeholder, never both. These two are
            // direct IMG/SPAN children of [data-tw-cover] on purpose: the shared upload script
            // walks that cover's children to hide whichever one is up while a new file previews.
            string logo = Helper.TripHelper.HotelPhotoUrl(r["LogoPhotoUrl"]);
            bool hasLogo = logo.Length > 0;
            imgLogo.Visible = hasLogo;
            imgDefaultLogo.Visible = !hasLogo;
            if (hasLogo) imgLogo.ImageUrl = ResolveUrl("~/" + logo);
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            if (fuLogo.HasFile && !IsAcceptedImage(fuLogo.PostedFile))
            {
                ShowMessage("The logo must be a JPG or PNG image under 4 MB.");
                return;
            }

            double lat, lng;
            if (!double.TryParse(txtLat.Text.Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lat)
                || !double.TryParse(txtLng.Text.Trim(), System.Globalization.NumberStyles.Any, System.Globalization.CultureInfo.InvariantCulture, out lng))
            {
                ShowMessage("Enter valid latitude and longitude coordinates.");
                return;
            }
            if (lat < -90 || lat > 90 || lng < -180 || lng > 180)
            {
                ShowMessage("Latitude must be between -90 and 90, longitude between -180 and 180.");
                return;
            }

            string name = txtName.Text.Trim();
            if (name.Length == 0)
            {
                ShowMessage("Name is required.");
                return;
            }

            if (Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM Hotels WHERE Name = @n AND HotelID <> @id",
                    new SqlParameter("@n", name), new SqlParameter("@id", HotelIdParam))) > 0)
            {
                ShowMessage("Another hotel already uses this name.");
                return;
            }

            int hotelId = HotelIdParam;

            Helper.DBHelper.ExecuteNonQuery(
                @"UPDATE Hotels SET Name=@n, Address=@a, Phone=@ph, Email=@em,
                          Lat=@la, Lng=@ln, IsActive=@act
                    WHERE HotelID=@id",
                new SqlParameter("@n", name),
                new SqlParameter("@a", NullIfBlank(txtAddress.Text)),
                new SqlParameter("@ph", NullIfBlank(txtPhone.Text)),
                new SqlParameter("@em", NullIfBlank(txtEmail.Text)),
                new SqlParameter("@la", lat),
                new SqlParameter("@ln", lng),
                new SqlParameter("@act", chkActive.Checked),
                new SqlParameter("@id", hotelId));

            Helper.TripHelper.LogActivity("HotelUpdated", null, "Admin updated hotel " + hotelId + ".");
            SaveLogo(hotelId);

            Response.Redirect("HotelManagement.aspx");
        }

        private void SaveLogo(int hotelId)
        {
            string current = Helper.TripHelper.HotelPhotoUrl(Helper.DBHelper.ExecuteScalar(
                "SELECT LogoPhotoUrl FROM Hotels WHERE HotelID=@id",
                new SqlParameter("@id", hotelId)));

            if (chkRemoveLogo.Checked)
            {
                DeleteStoredPhoto(current);
                Helper.DBHelper.ExecuteNonQuery(
                    "UPDATE Hotels SET LogoPhotoUrl=NULL WHERE HotelID=@id",
                    new SqlParameter("@id", hotelId));
                current = "";
            }

            if (!fuLogo.HasFile) return;

            string saved = StoreImage(fuLogo.PostedFile, "Hotel_" + hotelId);
            if (saved == null) return;

            // Replacing the logo leaves the previous file on disk, so clear it.
            if (current.Length > 0) DeleteStoredPhoto(current);
            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Hotels SET LogoPhotoUrl=@p WHERE HotelID=@id",
                new SqlParameter("@p", saved), new SqlParameter("@id", hotelId));
        }

        /// <summary>
        /// Stores one already-validated image and returns its page-relative path
        /// (Uploads/HotelPhotos/...).
        /// </summary>
        private string StoreImage(HttpPostedFile file, string prefix)
        {
            if (!IsAcceptedImage(file)) return null;

            string dir = Server.MapPath("~/" + Helper.TripHelper.HotelPhotoFolder);
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            string name = prefix + "_" + DateTime.Now.Ticks + ext;
            file.SaveAs(Path.Combine(dir, name));
            return Helper.TripHelper.HotelPhotoFolder + "/" + name;
        }

        private static bool IsAcceptedImage(HttpPostedFile file)
        {
            if (file == null || file.ContentLength <= 0 || file.ContentLength > MaxImageBytes) return false;
            string ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            return ext == ".jpg" || ext == ".jpeg" || ext == ".png";
        }

        private void DeleteStoredPhoto(string relativeUrl)
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return;
            try
            {
                string full = Server.MapPath("~/" + relativeUrl);
                string root = Server.MapPath("~/" + Helper.TripHelper.HotelPhotoFolder);
                if (!string.IsNullOrEmpty(full) && !string.IsNullOrEmpty(root)
                    && full.StartsWith(root, StringComparison.OrdinalIgnoreCase) && File.Exists(full))
                    File.Delete(full);
            }
            catch { }
        }

        private static string NullIfBlank(string value)
        {
            string text = (value ?? "").Trim();
            return text.Length == 0 ? null : text;
        }

        private void ShowMessage(string text)
        {
            lblMessage.Text = text;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200";
        }
    }
}
