using System;
using System.Data.SqlClient;
using System.IO;
using System.Web;

namespace TripWay.Admin
{
    /// <summary>
    /// Create-only form for a hotel. Editing lives on HotelEdit.aspx and read-only
    /// viewing on HotelDetail.aspx, so there is no ?id= here.
    /// </summary>
    public partial class HotelCreatePage : Helper.ListPageBase
    {
        private const int MaxImageBytes = 4 * 1024 * 1024;

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            Helper.TripHelper.EnsureHotels();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
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

            // Duplicate name check: the management list would otherwise show two hotels
            // that customers cannot tell apart on the booking page.
            if (Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                    "SELECT COUNT(*) FROM Hotels WHERE Name = @n",
                    new SqlParameter("@n", name))) > 0)
            {
                ShowMessage("A hotel with this name already exists.");
                return;
            }

            int hotelId = Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                @"INSERT INTO Hotels (Name, Address, Phone, Email, Lat, Lng, IsActive)
                  VALUES (@n, @a, @ph, @em, @la, @ln, @act); SELECT SCOPE_IDENTITY();",
                new SqlParameter("@n", name),
                new SqlParameter("@a", NullIfBlank(txtAddress.Text)),
                new SqlParameter("@ph", NullIfBlank(txtPhone.Text)),
                new SqlParameter("@em", NullIfBlank(txtEmail.Text)),
                new SqlParameter("@la", lat),
                new SqlParameter("@ln", lng),
                new SqlParameter("@act", chkActive.Checked)));

            Helper.TripHelper.LogActivity("HotelCreated", null, "Admin created hotel " + hotelId + ".");

            // The file name is prefixed with the id, so the logo can only be stored
            // once the row exists.
            if (fuLogo.HasFile) SaveLogo(hotelId);

            Response.Redirect("HotelManagement.aspx");
        }

        private void SaveLogo(int hotelId)
        {
            string saved = StoreImage(fuLogo.PostedFile, "Hotel_" + hotelId);
            if (saved == null) return;
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
