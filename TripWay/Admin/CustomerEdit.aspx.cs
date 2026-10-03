using System;
using System.Data;
using System.Data.SqlClient;

namespace TripWay.Admin
{
    /// <summary>
    /// Edit-only form for a customer account. Creating lives on CreateCustomer.aspx and
    /// read-only viewing (with delete) on CustomerDetail.aspx, so ?id= is mandatory here.
    /// The password is not on this form: it is hashed at creation and never stored in the
    /// clear, so changing it is a separate action.
    /// </summary>
    public partial class CustomerEditPage : Helper.ListPageBase
    {
        private const int MaxImageBytes = 4 * 1024 * 1024;
        private const string PhotoFolder = Helper.TripHelper.CustomerPhotoFolder;

        public int CustomerIdParam
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) && id > 0 ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);

            if (CustomerIdParam == 0)
            {
                Response.Redirect("CustomerManagement.aspx");
                return;
            }

            if (!IsPostBack) LoadCustomer();
        }

        private void LoadCustomer()
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                "SELECT FullName, Email, PhoneNumber, Gender, DefaultAddress, ProfilePhotoUrl, Status, CreatedAt FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerIdParam));
            if (t.Rows.Count == 0)
            {
                Response.Redirect("CustomerManagement.aspx");
                return;
            }

            DataRow r = t.Rows[0];
            txtFullName.Text = r["FullName"].ToString();
            txtEmail.Text = r["Email"].ToString();
            txtPhone.Text = r["PhoneNumber"].ToString();
            txtDefaultAddress.Text = r["DefaultAddress"] == DBNull.Value ? "" : r["DefaultAddress"].ToString();

            // The identity card previews the saved record; the fields below are the edit form.
            lblHeadName.Text = Server.HtmlEncode(txtFullName.Text);
            lblHeadEmail.Text = Server.HtmlEncode(txtEmail.Text);
            lblHeadJoined.Text = r["CreatedAt"] == DBNull.Value ? "" : "Joined " + FormatTime(r["CreatedAt"], "dd MMM yyyy");

            string gender = r["Gender"] == DBNull.Value ? "" : r["Gender"].ToString();
            if (ddlGender.Items.FindByValue(gender) != null) ddlGender.SelectedValue = gender;

            string status = r["Status"] == DBNull.Value ? "Active" : r["Status"].ToString();
            if (ddlStatus.Items.FindByValue(status) != null) ddlStatus.SelectedValue = status;

            bool suspended = string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase);
            lblHeadStatus.Text = suspended ? "Suspended" : "Active";
            lblHeadStatus.CssClass = PillBase + (suspended ? "bg-red-100 text-red-700" : "bg-emerald-100 text-emerald-700");

            string photo = Helper.TripHelper.CustomerPhotoUrl(r["ProfilePhotoUrl"]);
            if (photo.Length > 0)
            {
                imgProfilePhoto.ImageUrl = ResolveUrl("~/" + photo);
                imgProfilePhoto.Visible = true;
                imgDefaultPhoto.Visible = false;
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            string email = txtEmail.Text.Trim();
            if (EmailTakenByOther(email, CustomerIdParam))
            {
                ShowMessage("Another account already uses this email address.", true);
                return;
            }

            string name = txtFullName.Text.Trim();
            if (name.Length == 0)
            {
                ShowMessage("Full name is required.", true);
                return;
            }

            // A picked file wins over the remove checkbox, otherwise choosing a replacement
            // would clear it again. An untouched form keeps whatever is already stored.
            string oldPhoto = Helper.TripHelper.CustomerPhotoUrl(Helper.DBHelper.ExecuteScalar(
                "SELECT ProfilePhotoUrl FROM Customers WHERE CustomerID=@id",
                new SqlParameter("@id", CustomerIdParam)));

            object photo;
            if (fuProfilePhoto.HasFile)
            {
                string savedPhoto = Helper.TripHelper.StoreImage(fuProfilePhoto.PostedFile,
                    PhotoFolder, "Profile_" + CustomerIdParam);
                if (savedPhoto == null)
                {
                    ShowMessage("The profile photo must be a JPG or PNG image under "
                        + (Helper.TripHelper.MaxImageBytes / (1024 * 1024)) + " MB.", true);
                    return;
                }
                photo = savedPhoto;
            }
            else
            {
                photo = chkRemovePhoto.Checked ? (object)DBNull.Value : (object)oldPhoto;
            }

            // One statement, so the photo can no longer be left behind by a later failure:
            // the old flow updated the row first and wrote the photo in a second round-trip.
            Helper.DBHelper.ExecuteNonQuery(
                @"UPDATE Customers SET FullName=@n, Email=@e, PhoneNumber=@p, Gender=@g,
                          DefaultAddress=@a, Status=@st, ProfilePhotoUrl=@ph
                    WHERE CustomerID=@id",
                new SqlParameter("@n", name),
                new SqlParameter("@e", email),
                new SqlParameter("@p", txtPhone.Text.Trim()),
                new SqlParameter("@g", BlankAsDbNull(ddlGender.SelectedValue)),
                new SqlParameter("@a", BlankAsDbNull(txtDefaultAddress.Text)),
                new SqlParameter("@st", ddlStatus.SelectedValue),
                new SqlParameter("@ph", photo),
                new SqlParameter("@id", CustomerIdParam));

            Helper.TripHelper.LogActivity("CustomerUpdated", null, "Admin updated customer " + CustomerIdParam + ".");

            // Only now that the row points at the new file is the previous one dropped, so a
            // failed save never leaves the customer without a photo.
            if (!string.Equals(Convert.ToString(photo), oldPhoto, StringComparison.OrdinalIgnoreCase))
                Helper.TripHelper.DeleteStoredPhoto(oldPhoto.TrimStart('~', '/'), PhotoFolder);

            Response.Redirect("CustomerDetail.aspx?id=" + CustomerIdParam);
        }

        /// <summary>
        /// Gender and the address are both optional, and a whitespace-only address would
        /// otherwise be stored as a blank string rather than as no address at all.
        /// </summary>
        private static object BlankAsDbNull(string value)
        {
            string text = (value ?? "").Trim();
            return text.Length == 0 ? (object)DBNull.Value : text;
        }

        /// <summary>
        /// Email is unique per table, but the same address could exist as a driver or an
        /// admin, which would break sign-in, so all three are checked.
        /// </summary>
        private static bool EmailTakenByOther(string email, int customerId)
        {
            int count = Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Customers WHERE Email = @e AND CustomerID <> @id",
                new SqlParameter("@e", email), new SqlParameter("@id", customerId)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers WHERE Email = @e", new SqlParameter("@e", email)));
            count += Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Admins WHERE Email = @e", new SqlParameter("@e", email)));
            return count > 0;
        }

        /// <summary>
        /// The panel ships with no colours so it can render both outcomes; the variant is
        /// chosen here, the same way Customer/Profile.aspx does it.
        /// </summary>
        private void ShowMessage(string text, bool isError)
        {
            lblMessage.Text = text;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isError
                ? "mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}
