using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    public partial class ProfilePage : Helper.ListPageBase
    {
        private int AdminId { get { return Helper.AuthHelper.GetAccountId(); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            // The photo column was added after the Admins table shipped, so a database that
            // predates it is healed before anything reads or writes it.
            Helper.TripHelper.EnsureAdminProfilePhoto();
            if (!IsPostBack) LoadAdmin();
        }

        private void LoadAdmin()
        {
            DataRow r = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, Email, CreatedAt, ProfilePhotoUrl FROM Admins WHERE AdminID=@id",
                new SqlParameter("@id", AdminId)).Rows[0];

            lblName.InnerText = r["FullName"].ToString();
            lblEmail.InnerText = r["Email"].ToString();
            lblJoined.InnerText = r["CreatedAt"] == DBNull.Value ? "" : "Joined " + FormatTime(r["CreatedAt"], "dd MMM yyyy");
            txtFullName.Text = r["FullName"].ToString();
            txtEmail.Text = r["Email"].ToString();
            ShowPhoto(r["ProfilePhotoUrl"]);

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
                "SELECT AdminID FROM Admins WHERE Email = @Email AND AdminID <> @Id",
                new SqlParameter("@Email", email),
                new SqlParameter("@Id", AdminId));
            if (dup.Rows.Count > 0)
            {
                ShowProfileMessage("That email is already in use by another account.", true);
                return;
            }

            string name = txtFullName.Text.Trim();
            if (string.IsNullOrEmpty(name))
            {
                ShowProfileMessage("Full name is required.", true);
                return;
            }

            /* The photo is saved first, and only replaces the stored one once a new file has
               actually landed. A rejected upload, or a disk that refused the write, must leave
               the admin with the picture they already had rather than clearing it. */
            object stored = Helper.DBHelper.ExecuteScalar(
                "SELECT ProfilePhotoUrl FROM Admins WHERE AdminID=@id",
                new SqlParameter("@id", AdminId));
            string current = Helper.TripHelper.AdminPhotoUrl(stored);

            /* Removing is recorded here but not carried out. The file is left on disk until the
               row has stopped pointing at it, so a refused upload or a failed update cannot take
               a photo the admin still has. */
            bool removed = chkRemovePhoto.Checked && current.Length > 0;

            string fresh = null;
            if (fuProfilePhoto.HasFile)
            {
                string saved = Helper.TripHelper.StoreImage(fuProfilePhoto.PostedFile,
                    Helper.TripHelper.AdminPhotoFolder, "Admin_" + AdminId);
                if (string.IsNullOrEmpty(saved))
                {
                    // Explain the refusal rather than reporting a save that quietly did nothing.
                    ShowProfileMessage("That photo could not be saved. Use a JPG or PNG under 4 MB.", true);
                    return;
                }
                fresh = saved;
            }

            // Decided in one place, spelled out: a new file wins, an explicit remove clears the
            // column, and doing neither leaves the stored value exactly as it was.
            object photoValue;
            if (fresh != null) photoValue = fresh;
            else if (removed) photoValue = null;
            else photoValue = stored;

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Admins SET FullName=@n, Email=@e, ProfilePhotoUrl=@ph WHERE AdminID=@id",
                new SqlParameter("@n", name),
                new SqlParameter("@e", email),
                new SqlParameter("@ph", photoValue ?? DBNull.Value),
                new SqlParameter("@id", AdminId));

            /* The row no longer refers to the old file, whether it was replaced or removed, so
               this is the first moment at which dropping it cannot leave a photo missing. */
            if (current.Length > 0 && (removed || fresh != null))
                Helper.TripHelper.DeleteStoredPhoto(current, Helper.TripHelper.AdminPhotoFolder);

            if (fresh != null) ShowPhoto(fresh);
            else if (removed) ShowPhoto(null);

            Helper.AuthHelper.Login(AdminId, email, Helper.AuthHelper.GetRole());

            lblName.InnerText = name;
            lblEmail.InnerText = email;
            chkRemovePhoto.Checked = false;

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
                "SELECT PasswordHash FROM Admins WHERE AdminID=@id",
                new SqlParameter("@id", AdminId));
            if (hash == null || !Helper.AuthHelper.VerifyPassword(current, hash.ToString()))
            {
                ShowPasswordMessage("Current password is incorrect.", true);
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Admins SET PasswordHash=@h WHERE AdminID=@id",
                new SqlParameter("@h", Helper.AuthHelper.HashPassword(txtNewPassword.Text)),
                new SqlParameter("@id", AdminId));

            txtCurrentPassword.Text = "";
            txtNewPassword.Text = "";
            txtConfirmPassword.Text = "";
            ShowPasswordMessage("Password updated successfully.", false);
        }

        /// <summary>
        /// Draws the stored photo over the placeholder, or puts the placeholder back. One place,
        /// so loading, uploading and removing cannot each end up showing a different state.
        /// </summary>
        private void ShowPhoto(object storedPath)
        {
            string path = Helper.TripHelper.AdminPhotoUrl(storedPath);
            if (path.Length == 0)
            {
                imgProfilePhoto.Visible = false;
                imgProfilePhoto.ImageUrl = "";
                imgDefaultPhoto.Visible = true;
                pnlRemovePhoto.Visible = false;
                return;
            }

            imgProfilePhoto.ImageUrl = "~/" + path;
            imgProfilePhoto.Visible = true;
            imgDefaultPhoto.Visible = false;
            // Nothing to remove until something has been stored.
            pnlRemovePhoto.Visible = true;
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