using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    public partial class CreateCustomerPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (EmailExists(email))
            {
                ShowMessage("This email is already registered.", true);
                return;
            }

            string photoUrl = null;
            if (fuProfilePhoto.HasFile)
            {
                photoUrl = Helper.TripHelper.StoreImage(fuProfilePhoto.PostedFile,
                    Helper.TripHelper.CustomerPhotoFolder, "Profile");
                if (photoUrl == null)
                {
                    ShowMessage("That photo was not accepted. Use a JPG or PNG under "
                        + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.", true);
                    return;
                }
            }

            Helper.DBHelper.ExecuteNonQuery(
                "INSERT INTO Customers (FullName, Email, PasswordHash, PhoneNumber, ProfilePhotoUrl, Gender, DefaultAddress, Status) " +
                "VALUES (@Name, @Email, @Hash, @Phone, @Photo, @Gender, @Address, 'Active')",
                new SqlParameter("@Name", txtFullName.Text.Trim()),
                new SqlParameter("@Email", email),
                new SqlParameter("@Hash", Helper.AuthHelper.HashPassword(txtPassword.Text)),
                new SqlParameter("@Phone", txtPhone.Text.Trim()),
                new SqlParameter("@Photo", string.IsNullOrEmpty(photoUrl) ? (object)DBNull.Value : photoUrl),
                new SqlParameter("@Gender", (object)ddlGender.SelectedValue ?? DBNull.Value),
                new SqlParameter("@Address", (object)txtDefaultAddress.Text.Trim() ?? DBNull.Value));

            Helper.TripHelper.LogActivity("CustomerCreated", null,
                "Admin created customer account: " + email);
            Response.Redirect("~/Admin/CustomerManagement.aspx");
        }

        private bool EmailExists(string email)
        {
            int count = 0;
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Customers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Admins WHERE Email = @e", new SqlParameter("@e", email)));
            return count > 0;
        }

        private void ShowMessage(string msg, bool isError)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = msg;
            pnlMessage.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}