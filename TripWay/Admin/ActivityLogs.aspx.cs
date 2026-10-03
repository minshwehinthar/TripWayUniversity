using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class ActivityLogsPage : Helper.ListPageBase
    {
        /* 5 is the first entry in the "Show" dropdown, which is what the user sees on arrival.
           It used to be 20, a value the dropdown cannot display, so the control said 5 while the
           query fetched 20 rows. SeedPageSizeFrom now keeps the two in step. */
        private const int DefaultPageSize = 5;

        private int CurrentPageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        private static readonly Dictionary<string, string> AllowedSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "when", "RecordedAt" },
                { "event", "EventType" },
                { "details", "Details" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                SeedPageSizeFrom(ddlPerPage, DefaultPageSize);
                Bind();
            }
        }

        protected void ddlEvent_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            Bind();
        }

        protected void txtDetails_TextChanged(object sender, EventArgs e)
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

        protected void rptLogs_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "delete")
            {
                int logId;
                if (int.TryParse((e.CommandArgument ?? "").ToString(), out logId))
                {
                    Helper.DBHelper.ExecuteNonQuery(
                        "DELETE FROM ActivityLogs WHERE LogID=@id",
                        new SqlParameter("@id", logId));
                    Bind();
                }
                return;
            }

            if (e.CommandName != "view") return;
            int tripId = Convert.ToInt32(e.CommandArgument);
            OpenAppModal(Helper.TripHelper.BuildTripModalHtml(tripId, "TripDetail.aspx?id=" + tripId));
        }

        /// <summary>
        /// The search and event filter as a WHERE clause, built once so the grid, the row count
        /// and the delete-all all agree on what "the rows currently shown" means. If this were
        /// written out three times they would drift, and the button would end up deleting a
        /// different set from the one the admin was looking at.
        /// </summary>
        private int? _matchCount;

        private string BuildFilter(out List<SqlParameter> pars)
        {
            var where = new List<string>();
            pars = new List<SqlParameter>();

            if (ddlEvent.SelectedValue == "Trip")
            {
                where.Add("TripID IS NOT NULL");
            }

            string details = (txtDetails.Text ?? "").Trim();
            if (details.Length > 0)
            {
                where.Add("(ISNULL(Details,'') LIKE @spat OR EventType LIKE @spat)");
                pars.Add(new SqlParameter("@spat", "%" + details + "%"));
            }

            return where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";
        }

        private int CountMatching()
        {
            List<SqlParameter> pars;
            string whereSql = BuildFilter(out pars);
            return Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM ActivityLogs " + whereSql, pars.ToArray()));
        }

        /// <summary>
        /// The confirmation for the delete-all button. It names the number of rows and says
        /// whether a filter is narrowing the blast radius, because "Delete all?" on its own is
        /// not enough to tell an admin that a search they left in place will be honoured and
        /// that the action cannot be undone.
        /// </summary>
        protected string DeleteAllConfirmText
        {
            get
            {
                int count = _matchCount ?? CountMatching();
                bool filtered = ddlEvent.SelectedValue == "Trip" || (txtDetails.Text ?? "").Trim().Length > 0;
                string scope = filtered
                    ? "the " + count + " event(s) matching the current filter"
                    : "ALL " + count + " events in the log";
                return "Delete " + scope + "?\n\nThis cannot be undone.";
            }
        }

        /// <summary>
        /// Deletes every row the current filter matches, ignoring pagination: "delete all" means
        /// all of them, not the five on screen. Without a filter this empties the table, which is
        /// the point of the button. No entry is written afterwards, because logging the wipe would
        /// put a row straight back into the log the admin asked to clear.
        /// </summary>
        protected void btnDeleteAll_Click(object sender, EventArgs e)
        {
            List<SqlParameter> pars;
            string whereSql = BuildFilter(out pars);

            Helper.DBHelper.ExecuteNonQuery("DELETE FROM ActivityLogs" + whereSql, pars.ToArray());

            // The page we were on may no longer exist now that its rows are gone.
            CurrentPageIndex = 0;
            Bind();
        }

        private void Bind()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            List<SqlParameter> pars;
            string whereSql = BuildFilter(out pars);

            object totalObj = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM ActivityLogs " + whereSql, pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            // Kept so the delete-all confirmation can quote the same number without asking the
            // database a second, identical COUNT on every render of the page.
            _matchCount = total;
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY LogID DESC";

            string sql =
                "SELECT LogID, EventType, TripID, Details, RecordedAt FROM ActivityLogs" + whereSql + orderBy +
                  " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptLogs.DataSource = dt;
            rptLogs.DataBind();
            SetActiveSortArrow(rptLogs, SortKey, SortDir);
            rptLogs.Visible = true;
            SetNoDataRow(rptLogs, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "events");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);

            /* The confirmation is handed to the button as data, not built into its OnClientClick.
               A server tag cannot hold an inline code block, and reading the wording back as
               attribute data also means a quote in it stays a quote rather than ending the string
               the client script is holding. Set here, next to the count it quotes, so the button
               cannot offer a number that disagrees with the grid above it. */
            btnDeleteAll.Attributes["data-confirm"] = DeleteAllConfirmText;
        }
    }
}