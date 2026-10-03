using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Driver
{
    public partial class TripHistoryPage : Helper.ListPageBase
    {
        private const int DefaultPageSize = 5;

        private int DriverId { get { return Helper.AuthHelper.GetAccountId(); } }

        private int CurrentPageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        /// <summary>
        /// Every column whose header offers the two sort arrows. Anything not listed here cannot
        /// be sorted, so the value is chosen from a fixed set rather than pasted into the query.
        /// "vehicle" was added with the redesign, since the driver is the one who took the trip
        /// on a particular vehicle and the list did not say which.
        /// </summary>
        private static readonly Dictionary<string, string> AllowedSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "date", "t.RequestedAt" },
                { "service", "s.Name" },
                { "vehicle", "v.Name" },
                { "customer", "c.FullName" },
                { "fare", "t.Fare" },
                { "status", "t.Status" },
                { "payment", "t.PaymentStatus" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireDriver(this);
            if (!Page.IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                LoadServiceFilter();
                Bind();
            }
        }

        private void LoadServiceFilter()
        {
            ddlService.Items.Clear();
            ddlService.Items.Add(new ListItem("All Services", ""));
            DataTable svc = Helper.DBHelper.ExecuteQuery("SELECT ServiceTypeID, Name FROM ServiceTypes ORDER BY Name");
            foreach (DataRow row in svc.Rows)
                ddlService.Items.Add(new ListItem(row["Name"].ToString(), row["ServiceTypeID"].ToString()));
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            Bind();
        }

        protected void ddlService_SelectedIndexChanged(object sender, EventArgs e)
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

        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            if (ddlService.Items.Count > 0) ddlService.SelectedIndex = 0;
            CurrentPageIndex = 0;
            Bind();
        }

        protected override void OnPageIndexNavigated()
        {
            Bind();
        }

        /// <summary>
        /// "view" goes straight to the driver's own trip detail page. It used to open the shared
        /// lightbox instead, but the detail page is a full page with the stops list and the map,
        /// and a lightbox over a table of trips is the wrong size for it: it traps scrolling, the
        /// browser back button does not leave it, and the URL never changes, so the page cannot be
        /// linked to or reloaded. Redirecting also means Refresh does not re-post the form.
        ///
        /// "delete" removes the trip and everything hanging off it, and only after checking the
        /// trip really is this driver's.
        /// </summary>
        protected void rptTrips_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "delete")
            {
                int tripId = Convert.ToInt32(e.CommandArgument);
                object owner = Helper.DBHelper.ExecuteScalar(
                    "SELECT DriverID FROM Trips WHERE TripID=@t",
                    new SqlParameter("@t", tripId));
                if (owner == null || owner == DBNull.Value || Convert.ToInt32(owner) != DriverId)
                {
                    ShowMessage("Trip not found or you are not allowed to delete it.", true);
                    return;
                }

                // Same order as the customer page: the children go first so no statement can fail
                // on a foreign key, and ActivityLogs keeps its row with the link blanked rather
                // than losing the audit trail of who did what.
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM TripStops WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM TripGPSLogs WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Payments WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM ChatMessages WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Ratings WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("UPDATE ActivityLogs SET TripID=NULL WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Trips WHERE TripID=@t", new SqlParameter("@t", tripId));

                Helper.TripHelper.LogActivity("TripDeleted", null, "Driver " + DriverId + " deleted trip " + tripId + ".");
                ShowMessage("Trip deleted successfully.", false);

                // Deleting the last row on the last page would otherwise leave the driver on an
                // empty page; Bind() steps the page index back when that happens.
                Bind();
                return;
            }

            if (e.CommandName != "view") return;
            int viewTripId = Convert.ToInt32(e.CommandArgument);
            Response.Redirect("TripDetail.aspx?id=" + viewTripId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string msg, bool isError)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = msg;
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }

        /// <summary>
        /// Per row: the customer's photo when they uploaded one and their initials when they
        /// did not, and the stars for the rating the customer left.
        ///
        /// The rating is shown read-only. On the customer's own history page the stars are a
        /// button that opens the rating lightbox, because that rating is theirs to give; a driver
        /// can only be shown what they received, and must not be able to post a score for their
        /// own customer.
        /// </summary>
        protected void rptTrips_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            DataRowView row = e.Item.DataItem as DataRowView;
            if (row == null) return;

            var photo = e.Item.FindControl("pnlCustomerPhoto") as Panel;
            var initials = e.Item.FindControl("pnlCustomerInitials") as Panel;
            if (photo != null && initials != null)
            {
                bool hasPhoto = Helper.TripHelper.CustomerPhotoUrl(row["CustomerPhoto"]).Length > 0;
                photo.Visible = hasPhoto;
                initials.Visible = !hasPhoto;
            }

            var lit = e.Item.FindControl("litRating") as Literal;
            if (lit != null) lit.Text = GetRatingHtml(row["RatingScore"]);
        }

        /// <summary>Template helper: resolved customer photo, or "" when they have none.</summary>
        protected string CustomerPhoto(object storedPath)
        {
            string url = Helper.TripHelper.CustomerPhotoUrl(storedPath);
            return url.Length == 0 ? "" : ResolveUrl("~/" + url);
        }

        /// <summary>
        /// The stars a customer left. An unrated trip says so in words rather than showing five
        /// grey stars, which read as a score of zero.
        /// </summary>
        protected string GetRatingHtml(object score)
        {
            if (score == null || score == DBNull.Value)
                return "<span class=\"text-xs text-gray-400\">Not rated</span>";

            int value = Convert.ToInt32(score);
            return "<span class=\"tw-stars inline-flex items-center\" title=\"" + value + " out of 5\">"
                + Helper.TripHelper.StarsHtml(value, "size-4") + "</span>";
        }

        private void Bind()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            string where = " WHERE t.DriverID = @driver AND t.Status IN ('Completed','Cancelled')";
            var pars = new List<SqlParameter> { new SqlParameter("@driver", DriverId) };

            if (search.Length > 0)
            {
                where += " AND (CAST(t.TripID AS NVARCHAR) = @sid OR ISNULL(c.FullName,'') LIKE @spat)";
                pars.Add(new SqlParameter("@sid", search));
                pars.Add(new SqlParameter("@spat", "%" + search + "%"));
            }

            string serviceFilter = ddlService.SelectedValue;
            if (!string.IsNullOrEmpty(serviceFilter))
            {
                where += " AND t.ServiceTypeID = @svc";
                pars.Add(new SqlParameter("@svc", serviceFilter));
            }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY t.TripID DESC";

            object totalObj = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Trips t INNER JOIN Customers c ON t.CustomerID = c.CustomerID" + where,
                pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            // CustomerName, phone and photo are for the identity block on the row; VehicleName
            // and RatingScore came in with the redesign. The stops subquery was already here.
            string sql =
                "SELECT t.TripID, t.CustomerID, t.RequestedAt, t.Fare, t.Status, t.PaymentStatus, " +
                "s.Name AS ServiceName, v.Name AS VehicleName, ISNULL(c.FullName, '—') AS CustomerName, " +
                "ISNULL(NULLIF(LTRIM(RTRIM(c.PhoneNumber)), ''), '—') AS CustomerPhone, " +
                "c.ProfilePhotoUrl AS CustomerPhoto, " +
                "(SELECT COUNT(*) FROM TripStops ts WHERE ts.TripID=t.TripID) AS StopsCount, " +
                "(SELECT r.Score FROM Ratings r WHERE r.TripID=t.TripID) AS RatingScore " +
                "FROM Trips t " +
                "INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID " +
                "INNER JOIN Customers c ON t.CustomerID = c.CustomerID" + where + orderBy +
                " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());

            rptTrips.DataSource = dt;
            rptTrips.DataBind();
            SetActiveSortArrow(rptTrips, SortKey, SortDir);

            // The table and the empty state are alternatives, never both on screen. Which one
            // is right depends on whether a filter is on, so an empty result from a search says
            // "no trips found" rather than "you have never driven for us".
            bool filtering = search.Length > 0 || !string.IsNullOrEmpty(ddlService.SelectedValue);
            if (dt.Rows.Count == 0)
            {
                ShowEmptyState(filtering);
            }
            else
            {
                pnlTable.Visible = true;
                pnlEmpty.Visible = false;
            }

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "trips");

            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }

        private void ShowEmptyState(bool filtering)
        {
            pnlTable.Visible = false;
            pnlEmpty.Visible = true;

            if (filtering)
            {
                litEmptyTitle.Text = "No Trips Found";
                litEmptyBody.Text = "No trips match the current search or service filter. "
                    + "Try a trip ID, a different customer name, pick another service, or clear the filters to see your full history.";
            }
            else
            {
                litEmptyTitle.Text = "No Trips Yet";
                litEmptyBody.Text = "Completed and cancelled trips show up here with the customer, fare, payment and the rating you received. "
                    + "Take a trip from the request queue and your history will build up automatically.";
            }

            btnClearFilters.Visible = filtering;
        }
    }
}
