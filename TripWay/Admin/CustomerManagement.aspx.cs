using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class CustomerManagementPage : Helper.ListPageBase
    {
        private const int DefaultPageSize = 10;

        private int CurrentPageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        private static readonly Dictionary<string, string> AllowedSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "name", "c.FullName" },
                { "phone", "c.PhoneNumber" },
                { "trips", "TripCount" },
                { "spent", "TotalSpent" },
                { "joined", "c.CreatedAt" },
                { "status", "c.Status" }
            };

        /// <summary>
        /// The states a customer account may be put into. The posted value is checked against
        /// this before it reaches the database, because a dropdown is a suggestion, not a
        /// guarantee: the value arrives from the client and can be anything.
        /// </summary>
        private static readonly string[] AllowedStatuses =
            { "Active", "Pending", "Approved", "Rejected", "Suspended" };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                string statusFilter = Request.QueryString["status"] ?? "";
                if (ddlStatus.Items.FindByValue(statusFilter) != null) ddlStatus.SelectedValue = statusFilter;
                Bind();
            }
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
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
        /// Answers the two things a row can ask for: putting a customer into a new state, and
        /// deleting one. They are kept in one handler because both arrive as a command on the
        /// same repeater, and splitting them would mean two methods bound to one event.
        /// </summary>
        protected void rptCustomers_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "delete") return;

            int id = Convert.ToInt32(e.CommandArgument);

            try
            {
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Customers WHERE CustomerID=@id", new SqlParameter("@id", id));
                Helper.TripHelper.LogActivity("Admin", null, "Deleted customer #" + id + ".");
                Bind();
            }
            catch
            {
                ClientScript.RegisterStartupScript(GetType(), "delblocked",
                    "TwToast.error('Cannot delete this customer — they have trips or other activity on record.');", true);
            }
        }

        /// <summary>
        /// Puts the stored status into the row's drop-down, so the list shows what is actually
        /// saved rather than whatever the first item happens to be. A value that is not in the
        /// list is added rather than dropped: the point of the row is to show the real state, and
        /// silently falling back to the first entry would misreport it.
        /// </summary>
        protected void rptCustomers_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var ddl = (DropDownList)e.Item.FindControl("ddlRowStatus");
            if (ddl == null) return;

            var row = e.Item.DataItem as DataRowView;
            if (row == null) return;

            /* The id rides along on the control rather than being read back out of the markup,
               which is what lets the handler know which row was changed. */
            ddl.Attributes["data-customerid"] = Convert.ToString(row["CustomerID"]);

            string current = Convert.ToString(row["Status"]);
            if (ddl.Items.FindByValue(current) == null)
            {
                ddl.Items.Add(new ListItem(
                    string.IsNullOrEmpty(current) ? "(blank)" : current, current));
            }
            ddl.SelectedValue = current;
        }

        protected void ddlRowStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            var ddl = (DropDownList)sender;
            /* The list is fixed in the markup, so anything arriving here that is not in it came
               from a crafted post. The allowlist below is the only thing that matters. */
            string next = ddl.SelectedValue;

            int customerId;
            if (!int.TryParse(ddl.Attributes["data-customerid"], out customerId))
            {
                Toast("That row could not be identified.", true);
                Bind();
                return;
            }

            if (Array.IndexOf(AllowedStatuses, next) < 0)
            {
                Toast("That is not a status a customer can be given.", true);
                Bind();
                return;
            }

            object before = Helper.DBHelper.ExecuteScalar(
                "SELECT Status FROM Customers WHERE CustomerID = @id", new SqlParameter("@id", customerId));
            if (before == null || before == DBNull.Value)
            {
                Toast("That customer no longer exists.");
                Bind();
                return;
            }

            string was = before.ToString();
            if (was == next)
            {
                // Nothing changed. Rebinding puts the row back as it was rather than leaving the
                // list claiming a state the database never accepted.
                Toast((was.Length == 0 ? "(blank)" : was) + " — no change.");
                Bind();
                return;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Customers SET Status = @st WHERE CustomerID = @id",
                new SqlParameter("@st", next),
                new SqlParameter("@id", customerId));

            Helper.TripHelper.LogActivity("CustomerStatusChanged", null,
                "Admin changed customer " + customerId + " from " + was + " to " + next + ".");

            Toast("Customer is now " + next + ".");
            Bind();
        }

        private void Bind()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            var conditions = new List<string>();
            var pars = new List<SqlParameter>();
            if (search.Length > 0)
            {
                conditions.Add("(ISNULL(FullName,'') LIKE @spat OR ISNULL(PhoneNumber,'') LIKE @spat OR ISNULL(Email,'') LIKE @spat)");
                pars.Add(new SqlParameter("@spat", "%" + search + "%"));
            }
            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
            {
                conditions.Add("c.Status = @st");
                pars.Add(new SqlParameter("@st", ddlStatus.SelectedValue));
            }

            string where = conditions.Count > 0 ? " WHERE " + string.Join(" AND ", conditions) : "";

            object totalObj = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Customers c" + where, pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY CustomerID DESC";

            string sql =
                @"SELECT c.CustomerID, c.FullName, c.Email, c.PhoneNumber, c.CreatedAt, c.Status,
                         c.ProfilePhotoUrl AS CustomerPhoto,
                         (SELECT COUNT(*) FROM Trips t WHERE t.CustomerID = c.CustomerID) AS TripCount,
                         (SELECT ISNULL(SUM(Fare),0) FROM Trips t WHERE t.CustomerID = c.CustomerID AND t.Status <> 'Cancelled') AS TotalSpent
                  FROM Customers c " + where + orderBy +
                  " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptCustomers.DataSource = dt;
            rptCustomers.DataBind();
            SetActiveSortArrow(rptCustomers, SortKey, SortDir);
            rptCustomers.Visible = true;
            SetNoDataRow(rptCustomers, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "customers");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }
    }
}