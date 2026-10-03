using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace TripWay.Customer
{
    public partial class ProfilePage : Helper.ListPageBase
    {
        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);
            if (!IsPostBack) LoadProfile();

            /* On a postback the panel is re-declared hidden, so a ticked "Remove current
               photo" would silently vanish when something else fails validation and the save
               is abandoned. Checkboxes do round-trip, so trust that instead. */
            if (IsPostBack && chkRemovePhoto.Checked) pnlRemovePhoto.Visible = true;

        }

        private void LoadProfile()
        {
            DataRow r = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, Email, PhoneNumber, Gender, DefaultAddress, ProfilePhotoUrl, CreatedAt FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerId)).Rows[0];

            lblName.InnerText = r["FullName"].ToString();
            lblEmail.InnerText = r["Email"].ToString();
            txtFullName.Text = r["FullName"].ToString();
            txtEmail.Text = r["Email"].ToString();
            txtPhone.Text = r["PhoneNumber"].ToString();
            ddlGender.SelectedValue = r["Gender"] == DBNull.Value ? "" : r["Gender"].ToString();
            txtDefaultAddress.Text = r["DefaultAddress"] == DBNull.Value ? "" : r["DefaultAddress"].ToString();
            lblJoined.InnerText = r["CreatedAt"] == DBNull.Value ? "" : "Joined " + FormatTime(r["CreatedAt"], "dd MMM yyyy");

            string photoPath = r["ProfilePhotoUrl"] == DBNull.Value ? "" : r["ProfilePhotoUrl"].ToString();
            if (!string.IsNullOrEmpty(photoPath))
            {
                imgProfilePhoto.ImageUrl = "~/" + photoPath;
                imgProfilePhoto.Visible = true;
                imgDefaultPhoto.Visible = false;
            }
            else
            {
                imgProfilePhoto.Visible = false;
                imgDefaultPhoto.Visible = true;
            }

            // Nothing to remove until something has been stored.
            pnlRemovePhoto.Visible = photoPath.Length > 0;

            var master = (SiteMaster)Master;
            master.RefreshUserInfo();
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (string.IsNullOrEmpty(email))
            {
                ShowProfileMessage("Email cannot be empty.", true);
                return;
            }

            DataTable dup = Helper.DBHelper.ExecuteQuery(
                "SELECT CustomerID FROM Customers WHERE Email = @Email AND CustomerID <> @Id",
                new SqlParameter("@Email", email),
                new SqlParameter("@Id", CustomerId));
            if (dup.Rows.Count > 0)
            {
                ShowProfileMessage("That email is already in use by another account.", true);
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Customers SET Email = @Email WHERE CustomerID = @Id",
                new SqlParameter("@Email", email),
                new SqlParameter("@Id", CustomerId));
            Helper.AuthHelper.Login(CustomerId, email, Helper.AuthHelper.GetRole());
            lblEmail.InnerText = email;

            string name = txtFullName.Text.Trim();
            if (string.IsNullOrEmpty(name))
            {
                ShowProfileMessage("Full name is required.", true);
                return;
            }
            lblName.InnerText = name;

            object phone = string.IsNullOrEmpty(txtPhone.Text.Trim()) ? (object)"" : txtPhone.Text.Trim();
            object gender = string.IsNullOrEmpty(ddlGender.SelectedValue) ? (object)DBNull.Value : ddlGender.SelectedValue;
            object address = string.IsNullOrEmpty(txtDefaultAddress.Text.Trim()) ? (object)DBNull.Value : txtDefaultAddress.Text.Trim();

            object stored = Helper.DBHelper.ExecuteScalar(
                "SELECT ProfilePhotoUrl FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerId));
            string current = Helper.TripHelper.CustomerPhotoUrl(stored);

            /* Removing is recorded here but not carried out. The file stays on disk until the
               row has stopped pointing at it, so a refused upload cannot take away a photo the
               customer still has. */
            bool removed = chkRemovePhoto.Checked && current.Length > 0;

            string fresh = null;
            if (fuProfilePhoto.HasFile)
            {
                fresh = SavePhoto(fuProfilePhoto);
                if (fresh == null)
                {
                    ShowProfileMessage("Profile photo must be a JPG, JPEG or PNG image.", true);
                    return;
                }
            }

            // Decided in one place, spelled out: a new file wins, an explicit remove clears the
            // column, and doing neither leaves the stored value exactly as it was.
            object photoValue;
            if (fresh != null) photoValue = fresh;
            else if (removed) photoValue = null;
            else photoValue = stored;

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Customers SET FullName=@n, PhoneNumber=@p, Gender=@g, DefaultAddress=@a, ProfilePhotoUrl=@ph, Email=@e WHERE CustomerID=@id",
                new SqlParameter("@n", name),
                new SqlParameter("@p", phone),
                new SqlParameter("@g", gender),
                new SqlParameter("@a", address),
                new SqlParameter("@ph", photoValue ?? DBNull.Value),
                new SqlParameter("@e", email),
                new SqlParameter("@id", CustomerId));

            /* The row no longer refers to the old file, whether it was replaced or removed, so
               this is the first moment at which dropping it cannot leave a photo missing. */
            if (current.Length > 0 && (removed || fresh != null))
                Helper.TripHelper.DeleteStoredPhoto(current, Helper.TripHelper.CustomerPhotoFolder);

            if (fresh != null)
            {
                imgProfilePhoto.ImageUrl = "~/" + fresh;
                imgProfilePhoto.Visible = true;
                imgDefaultPhoto.Visible = false;
            }
            else if (removed)
            {
                imgProfilePhoto.Visible = false;
                imgDefaultPhoto.Visible = true;
            }

            chkRemovePhoto.Checked = false;
            pnlRemovePhoto.Visible = !(removed || fresh != null);

            RefreshMasterUserInfo();

            ShowProfileMessage("Profile updated successfully.", false);
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            string current = txtCurrentPassword.Text;
            if (current.Length == 0 || txtNewPassword.Text.Length == 0 || txtConfirmPassword.Text.Length == 0)
            {
                ShowPasswordMessage("Please fill in all password fields.", true);
                return;
            }

            object hash = Helper.DBHelper.ExecuteScalar(
                "SELECT PasswordHash FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerId));
            if (hash == null || !Helper.AuthHelper.VerifyPassword(current, hash.ToString()))
            {
                ShowPasswordMessage("Current password is incorrect.", true);
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Customers SET PasswordHash=@h WHERE CustomerID=@id",
                new SqlParameter("@h", Helper.AuthHelper.HashPassword(txtNewPassword.Text)),
                new SqlParameter("@id", CustomerId));

            txtCurrentPassword.Text = "";
            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";
            ShowPasswordMessage("Password updated successfully.", false);
        }

        private string SavePhoto(FileUpload fu)
        {
            string ext = Path.GetExtension(fu.FileName).ToLowerInvariant();
            if (string.IsNullOrEmpty(ext) || (ext != ".jpg" && ext != ".jpeg" && ext != ".png"))
                return null;

            // Capped like every other upload on the site, so one account cannot fill the
            // disk with an unbounded photo.
            if (fu.PostedFile.ContentLength <= 0
                || fu.PostedFile.ContentLength > Helper.TripHelper.MaxImageBytes) return null;

            string dir = Server.MapPath("~/Uploads/ProfilePhotos");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string name = "Profile_" + CustomerId + "_" + DateTime.Now.Ticks + ext;
            fu.PostedFile.SaveAs(Path.Combine(dir, name));
            return "Uploads/ProfilePhotos/" + name;
        }

        private void RefreshMasterUserInfo()
        {
            SiteMaster master = this.Master as SiteMaster;
            if (master != null) master.RefreshUserInfo();
        }

        private void ShowProfileMessage(string msg, bool isError)
        {
            pnlProfileMsg.Visible = true;
            lblProfileMsg.Text = msg;
            pnlProfileMsg.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }

        private void ShowPasswordMessage(string msg, bool isError)
        {
            pnlPwdMsg.Visible = true;
            lblPwdMsg.Text = msg;
            pnlPwdMsg.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}