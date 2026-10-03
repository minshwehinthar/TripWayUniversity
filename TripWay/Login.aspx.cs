using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace TripWay
{
    public partial class LoginPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["action"] == "logout")
            {
                Helper.AuthHelper.Logout();
                Response.Redirect("~/Login.aspx");
                return;
            }

            if (Request.QueryString["registered"] == "1")
            {
                ShowMessage("Registration successful! Please log in.", false);
            }

            if (!IsPostBack && Request.Cookies["tw_email"] != null)
            {
                txtEmail.Text = System.Net.WebUtility.HtmlDecode(Request.Cookies["tw_email"].Value);
            }

            if (Helper.AuthHelper.IsLoggedIn())
            {
                Helper.AuthHelper.RedirectByRole(this);
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();

            // Look up the account across the three role tables (email + password only).
            DataTable customer = Helper.DBHelper.ExecuteQuery(
                "SELECT CustomerID AS Id, Email, PasswordHash, 'Customer' AS Role, Status FROM Customers WHERE Email = @Email",
                new SqlParameter("@Email", email));
            DataTable driver = Helper.DBHelper.ExecuteQuery(
                "SELECT DriverID AS Id, Email, PasswordHash, 'Driver' AS Role, KYCStatus AS Status FROM Drivers WHERE Email = @Email",
                new SqlParameter("@Email", email));
            DataTable admin = Helper.DBHelper.ExecuteQuery(
                "SELECT AdminID AS Id, Email, PasswordHash, 'Admin' AS Role, 'Active' AS Status FROM Admins WHERE Email = @Email",
                new SqlParameter("@Email", email));

            DataRow row = null;
            if (customer.Rows.Count > 0) row = customer.Rows[0];
            else if (driver.Rows.Count > 0) row = driver.Rows[0];
            else if (admin.Rows.Count > 0) row = admin.Rows[0];

            if (row == null)
            {
                ShowMessage("Invalid email or password.", true);
                return;
            }

            string role = row["Role"].ToString();
            string status = row["Status"].ToString();

            if (!Helper.AuthHelper.VerifyPassword(password, row["PasswordHash"].ToString()))
            {
                ShowMessage("Invalid email or password.", true);
                return;
            }

            /* These three states are set by an admin from the management pages, so they are
               checked for every role and not only for drivers. Suspending is about money and
               conduct; pending and rejected are about the account never having cleared review.
               Anything not named here is allowed through, so 'Active' and 'Approved' both work. */
            if (status == "Pending")
            {
                ShowMessage(role == "Driver"
                    ? "Your driver account is pending KYC approval by an admin."
                    : "Your account is pending approval by an admin.", true);
                return;
            }
            if (status == "Rejected")
            {
                ShowMessage(role == "Driver"
                    ? "Your driver KYC was rejected. Please contact support."
                    : "Your account was rejected. Please contact support.", true);
                return;
            }
            if (status == "Suspended")
            {
                ShowMessage("Your account has been suspended. Please contact support.", true);
                return;
            }

            int accountId = Convert.ToInt32(row["Id"]);
            Helper.AuthHelper.Login(accountId, email, role);

            if (chkRemember.Checked)
            {
                HttpCookie remember = new HttpCookie("tw_email", System.Net.WebUtility.HtmlEncode(email))
                {
                    Expires = DateTime.Now.AddDays(30)
                };
                Response.Cookies.Add(remember);
            }
            else
            {
                if (Request.Cookies["tw_email"] != null)
                {
                    Response.Cookies["tw_email"].Expires = DateTime.Now.AddDays(-1);
                }
            }

            Helper.AuthHelper.RedirectByRole(this);
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