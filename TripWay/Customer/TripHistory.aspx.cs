using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Customer
{
    public partial class TripHistoryPage : Helper.ListPageBase
    {
        private const string PageSizeKey = "PageSize";
        private const int DefaultPageSize = 5;

        private int CustomerId { get { return Helper.AuthHelper.GetAccountId(); } }

        private int CurrentPageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        private static readonly Dictionary<string, string> AllowedSort =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "date", "t.RequestedAt" },
                { "service", "s.Name" },
                { "vehicle", "v.Name" },
                { "driver", "d.FullName" },
                { "fare", "t.Fare" },
                { "status", "t.Status" },
                { "payment", "t.PaymentStatus" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireCustomer(this);
            BuildStarKit();
            if (!Page.IsPostBack)
            {
                if (ViewState[PageSizeKey] == null) ViewState[PageSizeKey] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                LoadServiceFilter();
                Bind();
            }
            else
            {
                // A submitted rating rebinds itself; every other postback (sorting, paging,
                // searching, a star click) rebinds here so the table is never left empty.
                if (!SaveRatingFromModal()) Bind();
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

        protected override void OnPageIndexNavigated()
        {
            Bind();
        }

        /// <summary>
        /// Always five stars in the Rating column. An unrated trip shows the empty outline stars,
        /// a rated one fills that many of them gold. The span is the hook the page script swaps
        /// when a rating is submitted, so it must stay.
        /// </summary>
        protected string GetRatingHtml(object score)
        {
            int value = score == null || score == DBNull.Value ? 0 : Convert.ToInt32(score);
            return "<span class=\"tw-stars inline-flex items-center\">"
                + Helper.TripHelper.StarsHtml(value, "size-4") + "</span>";
        }

        /// <summary>
        /// The two star shapes (filled and empty) rendered once per page, so the script that
        /// repaints a row after a rating can copy them instead of carrying its own SVG.
        /// </summary>
        private void BuildStarKit()
        {
            litStarKit.Text = "<span data-tw-filled>" + Helper.TripHelper.StarSvg(true, "size-4")
                + "</span><span data-tw-empty>" + Helper.TripHelper.StarSvg(false, "size-4") + "</span>";
        }

        /// <summary>
        /// ETA chip for a history row. Both columns are nullable - a ride can finish without
        /// the driver ever giving an estimate - so the minutes are read defensively instead of
        /// being cast straight out of the row, which would throw on DBNull.
        /// </summary>
        protected string HistoryEtaChip(object minutes, object setAt, string status)
        {
            int eta = minutes == null || minutes == DBNull.Value ? 0 : Convert.ToInt32(minutes);
            if (eta <= 0) return "<span class=\"text-xs text-gray-400\">&mdash;</span>";
            return Helper.TripHelper.EtaStatusChipHtml(eta, setAt, status);
        }

        /// <summary>Template helper: resolved profile photo, or "" when the driver has none.</summary>
        protected string DriverPhoto(object storedPath)
        {
            string url = Helper.TripHelper.DriverPhotoUrl(storedPath);
            return url.Length == 0 ? "" : ResolveUrl("~/" + url);
        }

        protected void rptTrips_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;
            DataRowView row = e.Item.DataItem as DataRowView;
            if (row == null) return;

            // Driver photo when one was uploaded, initials otherwise.
            var photo = e.Item.FindControl("pnlDriverPhoto") as Panel;
            var initials = e.Item.FindControl("pnlDriverInitials") as Panel;
            if (photo != null && initials != null)
            {
                bool hasPhoto = Helper.TripHelper.DriverPhotoUrl(row["DriverPhoto"]).Length > 0;
                photo.Visible = hasPhoto;
                initials.Visible = !hasPhoto;
            }

            // The stars are plain markup; on an unrated trip a transparent LinkButton is laid
            // over them so the click is a normal server postback that opens the rating lightbox.
            var lit = e.Item.FindControl("litRating") as Literal;
            if (lit != null) lit.Text = GetRatingHtml(row["RatingScore"]);

            // Marks the row so the script can repaint just this one after a rating is sent.
            var wrap = e.Item.FindControl("pnlRate") as Panel;
            if (wrap != null) wrap.Attributes["data-tw-rate"] = Convert.ToString(row["TripID"]);

            var lbtnRate = e.Item.FindControl("lbtnRate") as LinkButton;
            if (lbtnRate != null) lbtnRate.Visible = CanRate(row);
        }

        private static bool CanRate(DataRowView row)
        {
            return row["Status"].ToString() == "Completed"
                && row["DriverID"] != DBNull.Value
                && row["RatingScore"] == DBNull.Value;
        }

        /// <summary>
        /// Saves the rating submitted from the lightbox (plain HTML inputs posted with the
        /// surrounding form). Returns true when a rating submission was handled.
        /// </summary>
        private bool SaveRatingFromModal()
        {
            string tripRaw = Request.Form["twrtTrip"];
            if (string.IsNullOrEmpty(tripRaw)) return false;

            int tripId, score;
            if (!int.TryParse(tripRaw, out tripId) || !int.TryParse(Request.Form["twrtScore"], out score) || score < 1 || score > 5)
            {
                ShowMessage("Pick a star rating between 1 and 5 before submitting.", true);
                return true;
            }

            object driver = Helper.DBHelper.ExecuteScalar(
                "SELECT DriverID FROM Trips WHERE TripID=@t AND CustomerID=@c AND Status='Completed'",
                new SqlParameter("@t", tripId), new SqlParameter("@c", CustomerId));
            if (driver == null || driver == DBNull.Value)
            {
                ShowMessage("This trip can no longer be rated.", true);
                return true;
            }

            string comment = (Request.Form["twrtComment"] ?? "").Trim();
            if (comment.Length > 500) comment = comment.Substring(0, 500);

            int rows = Helper.DBHelper.ExecuteNonQuery(
                @"IF NOT EXISTS (SELECT 1 FROM Ratings WHERE TripID=@t)
                    INSERT INTO Ratings (TripID, CustomerID, DriverID, Score, Comment) VALUES (@t, @c, @d, @s, @cmt)",
                new SqlParameter("@t", tripId), new SqlParameter("@c", CustomerId),
                new SqlParameter("@d", driver), new SqlParameter("@s", score),
                new SqlParameter("@cmt", comment.Length == 0 ? (object)DBNull.Value : (object)comment));
            if (rows == 0)
            {
                ShowMessage("You already rated this trip.", true);
                return true;
            }

            Helper.DBHelper.ExecuteNonQuery(
                "UPDATE Drivers SET AverageRating = (SELECT ROUND(AVG(CONVERT(DECIMAL(3,2), Score)),2) FROM Ratings WHERE DriverID=@d) WHERE DriverID=@d",
                new SqlParameter("@d", driver));
            Helper.TripHelper.LogActivity("Rated", tripId, "Customer " + CustomerId + " rated driver " + driver + " = " + score + "/5");
            ShowMessage("Thanks! Your rating has been submitted.", false);
            return true;
        }

        /// <summary>
        /// Checks the trip belongs to this customer, is finished and still unrated, then opens
        /// the rating lightbox for it.
        /// </summary>
        private bool OpenRatingModal(int tripId)
        {
            object driver = Helper.DBHelper.ExecuteScalar(
                @"SELECT d.FullName FROM Trips t INNER JOIN Drivers d ON t.DriverID = d.DriverID
                  WHERE t.TripID=@t AND t.CustomerID=@c AND t.Status='Completed' AND t.DriverID IS NOT NULL
                    AND NOT EXISTS (SELECT 1 FROM Ratings r WHERE r.TripID = t.TripID)",
                new SqlParameter("@t", tripId), new SqlParameter("@c", CustomerId));
            if (driver == null || driver == DBNull.Value)
            {
                ShowMessage("This trip can no longer be rated.", true);
                return false;
            }
            OpenAppModal(Helper.TripHelper.BuildRatingModalHtml(tripId, driver.ToString()), "max-w-md");
            return true;
        }

        protected void rptTrips_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "delete")
            {
                int tripId = Convert.ToInt32(e.CommandArgument);
                object owner = Helper.DBHelper.ExecuteScalar(
                    "SELECT CustomerID FROM Trips WHERE TripID=@t",
                    new SqlParameter("@t", tripId));
                if (owner == null || owner == DBNull.Value || Convert.ToInt32(owner) != CustomerId)
                {
                    ShowMessage("Trip not found or you are not allowed to delete it.", true);
                    return;
                }

                Helper.DBHelper.ExecuteNonQuery("DELETE FROM TripStops WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM TripGPSLogs WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Payments WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM ChatMessages WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Ratings WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("UPDATE ActivityLogs SET TripID=NULL WHERE TripID=@t", new SqlParameter("@t", tripId));
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM Trips WHERE TripID=@t", new SqlParameter("@t", tripId));

                Helper.TripHelper.LogActivity("TripDeleted", null, "Customer " + CustomerId + " deleted trip " + tripId + ".");
                ShowMessage("Trip deleted successfully.", false);
                Bind();
                return;
            }

            if (e.CommandName == "rate")
            {
                OpenRatingModal(Convert.ToInt32(e.CommandArgument));
                return;
            }

            if (e.CommandName != "view") return;
            int viewTripId = Convert.ToInt32(e.CommandArgument);
            Response.Redirect("TripDetail.aspx?id=" + viewTripId, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void Bind()
        {
            Helper.TripHelper.EnsureDriverProfilePhoto();

            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            string where = " WHERE t.CustomerID = @customer AND t.Status IN ('Completed','Cancelled')";
            var pars = new List<SqlParameter> { new SqlParameter("@customer", CustomerId) };

            if (search.Length > 0)
            {
                where += " AND (CAST(t.TripID AS NVARCHAR) = @sid OR ISNULL(d.FullName,'') LIKE @spat)";
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
                "SELECT COUNT(*) FROM Trips t LEFT JOIN Drivers d ON t.DriverID = d.DriverID" + where,
                pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string sql =
                "SELECT t.TripID, t.DriverID, t.RequestedAt, t.Fare, t.Status, t.PaymentStatus, " +
                // Arrival the driver promised on the ride, so the history row can show it.
                "t.EtaMinutes, t.EtaSetAt, " +
                "s.Name AS ServiceName, v.Name AS VehicleName, ISNULL(d.FullName, '—') AS DriverName, " +
                "ISNULL(NULLIF(LTRIM(RTRIM(d.PhoneNumber)), ''), '—') AS DriverPhone, " +
                "d.ProfilePhotoUrl AS DriverPhoto, " +
                "(SELECT r.Score FROM Ratings r WHERE r.TripID=t.TripID) AS RatingScore " +
                "FROM Trips t " +
                "INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID " +
                "INNER JOIN VehicleTypes v ON t.VehicleTypeID = v.VehicleTypeID " +
                "LEFT JOIN Drivers d ON t.DriverID = d.DriverID" + where + orderBy +
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

            bool filtering = (txtSearch.Text ?? "").Trim().Length > 0 || !string.IsNullOrEmpty(ddlService.SelectedValue);
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

        /// <summary>Clears the search box and service filter and shows the unfiltered list again.</summary>
        protected void btnClearFilters_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            if (ddlService.Items.Count > 0) ddlService.SelectedIndex = 0;
            CurrentPageIndex = 0;
            Bind();
        }

        /// <summary>
        /// Swaps the table for the empty-state card: icon, heading, body and the actions that
        /// make sense for the situation (clear filters only helps when something is filtered).
        /// </summary>
        private void ShowEmptyState(bool filtering)
        {
            pnlTable.Visible = false;
            pnlEmpty.Visible = true;

            if (filtering)
            {
                litEmptyTitle.Text = "No Trips Found";
                litEmptyBody.Text = "No trips match the current search or service filter. "
                    + "Try a different driver name, pick another service, or clear the filters to see your full history.";
            }
            else
            {
                litEmptyTitle.Text = "No Trips Yet";
                litEmptyBody.Text = "Finished and cancelled rides show up here with your driver, fare, payment and rating. "
                    + "Book your first trip and your history will build up automatically.";
            }

            btnClearFilters.Visible = filtering;
        }

        private void ShowMessage(string msg, bool isError)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = msg;
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }
    }
}