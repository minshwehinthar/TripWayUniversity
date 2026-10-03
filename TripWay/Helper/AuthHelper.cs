using System;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;

namespace TripWay.Helper
{
    public static class AuthHelper
    {
        public static void Login(int accountId, string email, string role)
        {
            HttpContext.Current.Session["AccountId"] = accountId;
            HttpContext.Current.Session["Email"] = email;
            HttpContext.Current.Session["Role"] = role;
            HttpContext.Current.Session["IsLoggedIn"] = true;
        }

        public static void Logout()
        {
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session.Abandon();
        }

        public static bool IsLoggedIn()
        {
            return HttpContext.Current.Session["IsLoggedIn"] != null
                && (bool)HttpContext.Current.Session["IsLoggedIn"];
        }

        public static string GetRole()
        {
            return HttpContext.Current.Session["Role"]?.ToString() ?? "";
        }

        public static int GetAccountId()
        {
            if (HttpContext.Current.Session["AccountId"] != null)
                return Convert.ToInt32(HttpContext.Current.Session["AccountId"]);
            return 0;
        }

        public static string GetEmail()
        {
            return HttpContext.Current.Session["Email"]?.ToString() ?? "";
        }

        // Salted SHA-256: stored as "SALT$HASH" (fits NVARCHAR(256)).
        public static string HashPassword(string rawData)
        {
            byte[] saltBytes = new byte[16];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(saltBytes);
            }
            string salt = ToHex(saltBytes);
            return salt + "$" + Sha256Hex(salt + rawData);
        }

        public static bool VerifyPassword(string rawData, string stored)
        {
            if (string.IsNullOrEmpty(stored)) return false;
            int idx = stored.IndexOf('$');
            if (idx <= 0) return false;
            string salt = stored.Substring(0, idx);
            string expected = stored.Substring(idx + 1);
            return string.Equals(Sha256Hex(salt + rawData), expected, StringComparison.OrdinalIgnoreCase);
        }

        private static string Sha256Hex(string input)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(input));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                    builder.Append(bytes[i].ToString("x2"));
                return builder.ToString();
            }
        }

        private static string ToHex(byte[] bytes)
        {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < bytes.Length; i++) sb.Append(bytes[i].ToString("x2"));
            return sb.ToString();
        }

        public static void RequireLogin(Page page)
        {
            if (!IsLoggedIn())
            {
                page.Response.Redirect("~/Login.aspx");
            }
        }

        public static void RequireRole(Page page, string role)
        {
            RequireLogin(page);
            if (GetRole() != role)
            {
                page.Response.Redirect("~/Login.aspx");
            }
        }

        public static void RequireAdmin(Page page) { RequireRole(page, "Admin"); }
        public static void RequireCustomer(Page page) { RequireRole(page, "Customer"); }
        public static void RequireDriver(Page page) { RequireRole(page, "Driver"); }

        public static void RedirectByRole(Page page)
        {
            switch (GetRole())
            {
                case "Admin":
                    page.Response.Redirect("~/Admin/Dashboard.aspx");
                    break;
                case "Driver":
                    page.Response.Redirect("~/Driver/Dashboard.aspx");
                    break;
                case "Customer":
                    page.Response.Redirect("~/Customer/Dashboard.aspx");
                    break;
                default:
                    page.Response.Redirect("~/Default.aspx");
                    break;
            }
        }
    }
}
