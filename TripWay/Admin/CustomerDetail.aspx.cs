using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;

namespace TripWay.Admin
{
    /// <summary>
    /// Read-only detail view of one customer account: contact details, status and trip
    /// history totals. Kept separate from CustomerEdit so browsing never risks a save.
    /// </summary>
    public partial class CustomerDetailPage : Helper.ListPageBase
    {
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
            if (!IsPostBack) Bind();
        }

        private void Bind()
        {
            int id = CustomerIdParam;
            if (id == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT c.CustomerID, c.FullName, c.Email, c.PhoneNumber, c.Gender,
                         c.DefaultAddress, c.ProfilePhotoUrl, c.Status, c.CreatedAt,
                         (SELECT COUNT(*) FROM Trips tr WHERE tr.CustomerID = c.CustomerID) AS TripCount,
                         (SELECT COUNT(*) FROM Trips tr WHERE tr.CustomerID = c.CustomerID AND tr.Status = 'Completed') AS CompletedCount,
                         (SELECT COUNT(*) FROM Trips tr WHERE tr.CustomerID = c.CustomerID AND tr.Status = 'Cancelled') AS CancelledCount,
                         (SELECT ISNULL(SUM(tr.Fare),0) FROM Trips tr WHERE tr.CustomerID = c.CustomerID AND tr.Status <> 'Cancelled') AS TotalSpent,
                         (SELECT TOP 1 tr.RequestedAt FROM Trips tr WHERE tr.CustomerID = c.CustomerID ORDER BY tr.TripID DESC) AS LastTripAt
                  FROM Customers c WHERE c.CustomerID=@id",
                new SqlParameter("@id", id));

            if (t.Rows.Count == 0)
            {
                pnlMissing.Visible = true;
                return;
            }

            DataRow r = t.Rows[0];
            pnlCustomer.Visible = true;

            string name = r["FullName"].ToString();
            lblName.Text = Server.HtmlEncode(name);
            lblNameField.Text = Server.HtmlEncode(name);
            lblJoined.Text = r["CreatedAt"] == DBNull.Value ? "" : "Joined " + FormatTime(r["CreatedAt"], "dd MMM yyyy");

            lblEmail.Text = Server.HtmlEncode(r["Email"].ToString());
            lblEmailField.Text = Server.HtmlEncode(r["Email"].ToString());
            lblPhone.Text = Server.HtmlEncode(r["PhoneNumber"].ToString());
            lblGender.Text = OrDash(r["Gender"]);
            lblAddress.Text = OrDash(r["DefaultAddress"]);

            string status = r["Status"] == DBNull.Value ? "" : r["Status"].ToString();
            bool suspended = string.Equals(status, "Suspended", StringComparison.OrdinalIgnoreCase);
            lblStatus.Text = suspended ? "Suspended" : "Active";
            lblStatus.CssClass = PillBase + (suspended ? "bg-red-100 text-red-700" : "bg-emerald-100 text-emerald-700");

            lblTrips.Text = r["TripCount"].ToString();
            lblCompleted.Text = r["CompletedCount"].ToString();
            lblCancelled.Text = r["CancelledCount"].ToString();
            lblSpent.Text = "MMK " + string.Format("{0:N0}", Convert.ToDecimal(r["TotalSpent"]));
            lblLastTrip.Text = r["LastTripAt"] == DBNull.Value
                ? "None yet"
                : FormatTime(r["LastTripAt"], "dd MMM yyyy");

            string photo = Helper.TripHelper.CustomerPhotoUrl(r["ProfilePhotoUrl"]);
            if (photo.Length > 0)
            {
                imgProfilePhoto.ImageUrl = ResolveUrl("~/" + photo);
                imgProfilePhoto.Visible = true;
                imgDefaultPhoto.Visible = false;
            }
        }

        private static string OrDash(object value)
        {
            if (value == null || value == DBNull.Value) return "—";
            string text = value.ToString().Trim();
            return text.Length == 0 ? "—" : HttpUtility.HtmlEncode(text);
        }
    }
}
