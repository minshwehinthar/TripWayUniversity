using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class HotelManagementPage : Helper.ListPageBase
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
                { "name", "h.Name" },
                { "active", "h.HotelID" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            Helper.TripHelper.EnsureHotels();
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                BindHotels();
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            BindHotels();
        }

        protected void ddlPerPage_SelectedIndexChanged(object sender, EventArgs e)
        {
            HandlePerPageChanged(ddlPerPage, DefaultPageSize);
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            // A filter change can leave the current page past the end of the results.
            CurrentPageIndex = 0;
            BindHotels();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            CurrentPageIndex = Math.Max(0, CurrentPageIndex - 1);
            BindHotels();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPageIndex++;
            BindHotels();
        }

        protected override void OnPageIndexNavigated()
        {
            BindHotels();
        }

        protected void rptHotels_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "toggleActive")
            {
                ToggleHotelVisibility(Convert.ToInt32(e.CommandArgument));
                return;
            }

            if (e.CommandName != "delete") return;
            int id = Convert.ToInt32(e.CommandArgument);

            // Existing trips keep the coordinates they were booked with, so clearing the
            // reference is enough — the hotel row itself can go.
            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Trips SET HotelID = NULL WHERE HotelID = @id; DELETE FROM Hotels WHERE HotelID = @id;",
                new SqlParameter("@id", id));
            Helper.TripHelper.LogActivity("HotelDeleted", null, "Admin deleted hotel " + id + ".");

            DeleteStoredPhoto(LogoOf(id));

            lblMessage.Text = "Hotel deleted.";
            SetMessageStyle(false);
            pnlMessage.Visible = true;
            BindHotels();
        }

        /// <summary>
        /// Hides a hotel from customer view, or puts it back. The switch flips the stored flag
        /// rather than setting it from the checkbox, because that checkbox is plain markup and
        /// carries no state the server can trust.
        /// </summary>
        private void ToggleHotelVisibility(int hotelId)
        {
            try
            {
                Helper.DBHelper.ExecuteNonQuery(
                    "UPDATE Hotels SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END WHERE HotelID = @id",
                    new SqlParameter("@id", hotelId));

                object flag = Helper.DBHelper.ExecuteScalar(
                    "SELECT IsActive FROM Hotels WHERE HotelID = @id",
                    new SqlParameter("@id", hotelId));
                // A hotel that vanished between render and click has nothing to report on.
                if (flag == null || flag == DBNull.Value)
                {
                    SetMessageStyle(false);
                    lblMessage.Text = "That hotel no longer exists.";
                    pnlMessage.Visible = true;
                    BindHotels();
                    return;
                }

                bool nowActive = Convert.ToBoolean(flag);
                Helper.TripHelper.LogActivity("HotelVisibilityChanged", null,
                    "Admin " + (nowActive ? "published" : "hid") + " hotel " + hotelId + " from customer view.");

                lblMessage.Text = nowActive
                    ? "Hotel is now visible to customers."
                    : "Hotel is hidden from customers.";
                SetMessageStyle(false);
                pnlMessage.Visible = true;
            }
            catch
            {
                SetMessageStyle(true);
                lblMessage.Text = "Could not change this hotel's visibility. Please try again.";
                pnlMessage.Visible = true;
            }
            BindHotels();
        }

        private void SetMessageStyle(bool isError)
        {
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }

        private static string LogoOf(int hotelId)
        {
            return Helper.TripHelper.HotelPhotoUrl(Helper.DBHelper.ExecuteScalar(
                "SELECT LogoPhotoUrl FROM Hotels WHERE HotelID=@id",
                new SqlParameter("@id", hotelId)));
        }

        private void DeleteStoredPhoto(string relativeUrl)
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return;
            try
            {
                string full = Server.MapPath("~/" + relativeUrl);
                string root = Server.MapPath("~/" + Helper.TripHelper.HotelPhotoFolder);
                if (!string.IsNullOrEmpty(full) && !string.IsNullOrEmpty(root)
                    && full.StartsWith(root, StringComparison.OrdinalIgnoreCase) && File.Exists(full))
                    File.Delete(full);
            }
            catch { }
        }

        /// <summary>
        /// Data-binding expressions are compiled outside the page's namespace, so the logo
        /// helpers are exposed here as page members for the repeater template.
        /// </summary>
        protected bool HasLogo(object storedPath)
        {
            return Helper.TripHelper.HotelPhotoUrl(storedPath).Length > 0;
        }

        protected string LogoUrl(object storedPath)
        {
            return ResolveUrl("~/" + Helper.TripHelper.HotelPhotoUrl(storedPath));
        }

        protected string HotelAddress(object value)
        {
            string text = value == null || value == DBNull.Value ? "" : value.ToString();
            return text.Length == 0 ? "—" : HttpUtility.HtmlEncode(text);
        }

        protected string HotelPhone(object value)
        {
            string text = value == null || value == DBNull.Value ? "" : value.ToString();
            return text.Length == 0 ? "—" : HttpUtility.HtmlEncode(text);
        }

        protected string HotelEmail(object value)
        {
            string text = value == null || value == DBNull.Value ? "" : value.ToString();
            return text.Length == 0 ? "—" : HttpUtility.HtmlEncode(text);
        }

        private void BindHotels()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            // The OR group has to be parenthesised: without it, ANDing the status filter
            // on would bind to the last LIKE only and let unrelated rows through.
            string where = search.Length > 0
                ? " WHERE (h.Name LIKE @spat OR h.Address LIKE @spat OR h.Phone LIKE @spat OR h.Email LIKE @spat)"
                : "";
            var pars = new List<SqlParameter>();
            if (search.Length > 0) pars.Add(new SqlParameter("@spat", "%" + search + "%"));

            string statusFilter = ddlStatus.SelectedValue;
            if (statusFilter == "1" || statusFilter == "0")
            {
                where += where.Length > 0 ? " AND h.IsActive = @act" : " WHERE h.IsActive = @act";
                pars.Add(new SqlParameter("@act", statusFilter == "1"));
            }

            int total = Convert.ToInt32(Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Hotels h" + where, pars.ToArray()));
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY h.HotelID DESC";

            string sql =
                @"SELECT h.HotelID, h.Name, h.Address, h.Phone, h.Email, h.LogoPhotoUrl,
                         h.Lat, h.Lng, h.IsActive
                  FROM Hotels h" + where + orderBy +
                " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptHotels.DataSource = dt;
            rptHotels.DataBind();
            SetActiveSortArrow(rptHotels, SortKey, SortDir);
            rptHotels.Visible = true;
            SetNoDataRow(rptHotels, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "hotels");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }
    }
}
