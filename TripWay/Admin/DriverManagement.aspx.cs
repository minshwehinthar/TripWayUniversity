using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class DriverManagementPage : Helper.ListPageBase
    {
        private const int DefaultPageSize = 5;

        private int CurrentPageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        private static readonly Dictionary<string, string> AllowedSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "name", "d.FullName" },
                { "vehicle", "v.Name" },
                { "trips", "tripCount" },
                { "kyc", "d.KYCStatus" },
                { "rating", "ratingValue" },
                { "online", "d.IsOnline" }
            };

        /// <summary>
        /// The review outcomes an admin may record for a driver. KYCStatus is the only status
        /// field a driver has, so this list is also the set of values /Login accepts from it.
        /// The posted value is checked against this before it reaches the database, because a
        /// dropdown is a suggestion, not a guarantee: the value arrives from the client and can
        /// be anything.
        /// </summary>
        private static readonly string[] AllowedKycStates =
            { "Pending", "Approved", "Rejected" };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                string kycFilter = Request.QueryString["kyc"] ?? "";
                if (ddlKyc.Items.FindByValue(kycFilter) != null) ddlKyc.SelectedValue = kycFilter;
                Bind();
            }
        }

        protected void ddlKyc_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            Bind();
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            Bind();
        }

        protected void ddlPerPage_SelectedIndexChanged(object sender, EventArgs e)
        {
            HandlePerPageChanged(ddlPerPage, DefaultPageSize);
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            CurrentPageIndex = Math.Max(0, CurrentPageIndex - 1);
            Bind();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPageIndex++;
            Bind();
        }


        protected override void OnPageIndexNavigated()
        {
            Bind();
        }

        /// <summary>
        /// Answers the two things a row can ask for: recording a review outcome, and deleting a
        /// driver. They are kept in one handler because both arrive as a command on the same
        /// repeater, and splitting them would mean two methods bound to one event.
        /// </summary>
        protected void rptDrivers_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
if (e.CommandName != "delete") return;

            int id = Convert.ToInt32(e.CommandArgument);

            try
            {
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Drivers WHERE DriverID=@id", new SqlParameter("@id", id));
                Helper.TripHelper.LogActivity("Admin", null, "Deleted driver #" + id + ".");
                Bind();
            }
            catch
            {
                ClientScript.RegisterStartupScript(GetType(), "delblocked",
                    "TwToast.error('Cannot delete this driver — they have trips or other activity on record.');", true);
            }
        }

        /// <summary>Template helper: resolved profile photo, or "" when there is none.</summary>
        /// <summary>
        /// Puts the stored review state into the row's drop-down, so the list shows what is
        /// actually saved rather than whatever the first item happens to be. A value that is not
        /// in the list is added rather than dropped: the point of the row is to show the real
        /// state, and silently falling back to the first entry would misreport it.
        /// </summary>
        protected void rptDrivers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var ddl = (DropDownList)e.Item.FindControl("ddlRowKyc");
            if (ddl == null) return;

            var row = e.Item.DataItem as DataRowView;
            if (row == null) return;

            /* The id rides along on the control rather than being read back out of the markup,
               which is what lets the handler know which row was changed. */
            ddl.Attributes["data-driverid"] = Convert.ToString(row["DriverID"]);

            string current = Convert.ToString(row["KYCStatus"]);
            if (ddl.Items.FindByValue(current) == null)
            {
                ddl.Items.Add(new ListItem(
                    string.IsNullOrEmpty(current) ? "(blank)" : current, current));
            }
            ddl.SelectedValue = current;
        }

        protected void ddlRowKyc_SelectedIndexChanged(object sender, EventArgs e)
        {
            var ddl = (DropDownList)sender;
            /* The list is fixed in the markup, so anything arriving here that is not in it came
               from a crafted post. The allowlist below is the only thing that matters. */
            string next = ddl.SelectedValue;

            int driverId;
            if (!int.TryParse(ddl.Attributes["data-driverid"], out driverId))
            {
                Toast("That row could not be identified.", true);
                Bind();
                return;
            }

            if (Array.IndexOf(AllowedKycStates, next) < 0)
            {
                Toast("That is not a review outcome a driver can be given.", true);
                Bind();
                return;
            }

            object before = Helper.DBHelper.ExecuteScalar(
                "SELECT KYCStatus FROM Drivers WHERE DriverID = @id", new SqlParameter("@id", driverId));
            if (before == null || before == DBNull.Value)
            {
                Toast("That driver no longer exists.");
                Bind();
                return;
            }

            string was = before.ToString();
            if (was == next)
            {
                // Nothing changed. Rebinding puts the row back as it was rather than leaving the
                // list claiming a state the database never accepted.
                Toast(was + " — no change.");
                Bind();
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET KYCStatus = @st WHERE DriverID = @id",
                new SqlParameter("@st", next),
                new SqlParameter("@id", driverId));

            Helper.TripHelper.LogActivity("DriverKycChanged", null,
                "Admin changed driver " + driverId + " from " + was + " to " + next + ".");

            Toast("Driver review state is now " + next + ".");
            Bind();
        }

        private void Bind()
        {
            Helper.TripHelper.EnsureDriverProfilePhoto();

            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            var where = new List<string>();
            var pars = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(ddlKyc.SelectedValue))
            {
                where.Add("d.KYCStatus = @kyc");
                pars.Add(new SqlParameter("@kyc", ddlKyc.SelectedValue));
            }

            string search = (txtSearch.Text ?? "").Trim();
            if (search.Length > 0)
            {
                where.Add("(ISNULL(d.FullName,'') LIKE @spat OR ISNULL(d.PhoneNumber,'') LIKE @spat OR ISNULL(d.Email,'') LIKE @spat)");
                pars.Add(new SqlParameter("@spat", "%" + search + "%"));
            }

            string whereSql = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";

            object totalObj = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Drivers d" + whereSql, pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY d.DriverID DESC";

            string sql =
                @"SELECT d.DriverID, d.FullName, d.ProfilePhotoUrl, d.PhoneNumber, d.Email, d.KYCStatus, d.IsOnline,
                         d.VehiclePlateNumber, v.Name AS VehicleTypeName,
                         (SELECT COUNT(*) FROM Trips t WHERE t.DriverID = d.DriverID) AS TripCount,
                         (SELECT ISNULL(AVG(r.Score),0) FROM Ratings r
                          INNER JOIN Trips t ON r.TripID = t.TripID WHERE t.DriverID = d.DriverID) AS RatingValue
                  FROM Drivers d
                  INNER JOIN VehicleTypes v ON d.VehicleTypeID = v.VehicleTypeID" + whereSql + orderBy +
                  " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptDrivers.DataSource = dt;
            rptDrivers.DataBind();

            // Photo when the driver has one, initials otherwise.
            foreach (RepeaterItem item in rptDrivers.Items)
            {
                var photo = item.FindControl("pnlPhoto") as Panel;
                var initials = item.FindControl("pnlInitials") as Panel;
                if (photo == null || initials == null) continue;

                var row = item.DataItem as DataRowView;
                bool hasPhoto = row != null
                    && row.Row.Table.Columns.Contains("ProfilePhotoUrl")
                    && Helper.TripHelper.DriverPhotoUrl(row["ProfilePhotoUrl"]).Length > 0;
                photo.Visible = hasPhoto;
                initials.Visible = !hasPhoto;
            }
            SetActiveSortArrow(rptDrivers, SortKey, SortDir);
            rptDrivers.Visible = true;
            SetNoDataRow(rptDrivers, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "drivers");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }
    }
}