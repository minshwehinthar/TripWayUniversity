using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class TripManagementPage : Helper.ListPageBase
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
                { "date", "t.RequestedAt" },
                { "service", "s.Name" },
                { "customer", "c.FullName" },
                { "driver", "d.FullName" },
                { "fare", "t.Fare" },
                { "status", "t.Status" },
                { "payment", "t.PaymentStatus" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                LoadServiceFilter();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                string statusFilter = Request.QueryString["status"] ?? "";
                if (ddlStatus.Items.FindByValue(statusFilter) != null) ddlStatus.SelectedValue = statusFilter;
                string serviceFilter = Request.QueryString["service"] ?? "";
                if (ddlService.Items.FindByValue(serviceFilter) != null) ddlService.SelectedValue = serviceFilter;
                Bind();
            }
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            Bind();
        }

        protected void ddlService_SelectedIndexChanged(object sender, EventArgs e)
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

        protected void rptTrips_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "delete") return;
            DeleteTrip(Convert.ToInt32(e.CommandArgument));
            Bind();
        }

        /// <summary>
        /// Removes a trip and everything that points at it. The child tables carry foreign
        /// keys onto Trips with no cascade, and the customer and driver history pages read
        /// straight from them, so a plain DELETE FROM Trips would be rejected and a trip left
        /// behind would keep showing up on both sides. All of it runs in one transaction, so a
        /// failure halfway through leaves the trip exactly as it was.
        ///
        /// ActivityLogs is the one exception: the column is nullable, so the audit trail is
        /// kept and simply unlinked instead of being deleted with the trip.
        /// </summary>
        private void DeleteTrip(int tripId)
        {
            try
            {
                using (SqlConnection conn = Helper.DBHelper.GetConnection())
                {
                    conn.Open();
                    using (SqlTransaction tx = conn.BeginTransaction())
                    {
                        // OBJECT_ID guards the tables that are created on demand elsewhere, so
                        // this still works against a database where they do not exist yet.
                        RunInTransaction(conn, tx, @"IF OBJECT_ID('dbo.TripStops','U')   IS NOT NULL DELETE FROM dbo.TripStops   WHERE TripID=@t;
                                              IF OBJECT_ID('dbo.TripGPSLogs','U') IS NOT NULL DELETE FROM dbo.TripGPSLogs WHERE TripID=@t;
                                              IF OBJECT_ID('dbo.ChatMessages','U') IS NOT NULL DELETE FROM dbo.ChatMessages WHERE TripID=@t;
                                              IF OBJECT_ID('dbo.Ratings','U')      IS NOT NULL DELETE FROM dbo.Ratings      WHERE TripID=@t;
                                              IF OBJECT_ID('dbo.Payments','U')     IS NOT NULL DELETE FROM dbo.Payments     WHERE TripID=@t;
                                              IF OBJECT_ID('dbo.ActivityLogs','U') IS NOT NULL UPDATE dbo.ActivityLogs SET TripID=NULL WHERE TripID=@t;
                                              DELETE FROM Trips WHERE TripID=@t;", tripId);

                        tx.Commit();
                    }
                }

                // Null, not the id: the trip row is gone, and ActivityLogs.TripID is a
                // foreign key onto it.
                Helper.TripHelper.LogActivity("TripDeleted", null, "Admin deleted trip #" + tripId + " and its related records.");
            }
            catch
            {
                ClientScript.RegisterStartupScript(GetType(), "tripdeleteblocked",
                    "TwToast.error('Could not delete this trip. Please try again.');", true);
            }
        }

        /// <summary>
        /// One statement list on the trip's transaction, so every child table is cleared or
        /// none of them is.
        /// </summary>
        private static void RunInTransaction(SqlConnection conn, SqlTransaction tx, string sql, int tripId)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn, tx))
            {
                cmd.Parameters.AddWithValue("@t", tripId);
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// Same helper shape as Driver/TripHistory.aspx.cs, so the two history pages filter by
        /// service in exactly the same way.
        /// </summary>
        private void LoadServiceFilter()
        {
            ddlService.Items.Clear();
            ddlService.Items.Add(new ListItem("All Services", ""));
            DataTable svc = Helper.DBHelper.ExecuteQuery("SELECT ServiceTypeID, Name FROM ServiceTypes ORDER BY Name");
            foreach (DataRow row in svc.Rows)
                ddlService.Items.Add(new ListItem(row["Name"].ToString(), row["ServiceTypeID"].ToString()));
        }

        private void Bind()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            var where = new List<string>();
            var pars = new List<SqlParameter>();

            if (!string.IsNullOrEmpty(ddlStatus.SelectedValue))
            {
                where.Add("t.Status = @st");
                pars.Add(new SqlParameter("@st", ddlStatus.SelectedValue));
            }

            if (!string.IsNullOrEmpty(ddlService.SelectedValue))
            {
                where.Add("t.ServiceTypeID = @svc");
                pars.Add(new SqlParameter("@svc", ddlService.SelectedValue));
            }

            string search = (txtSearch.Text ?? "").Trim();
            if (search.Length > 0)
            {
                where.Add(@"(CAST(t.TripID AS NVARCHAR) = @sid OR ISNULL(c.FullName,'') LIKE @spat OR ISNULL(ISNULL(d.FullName,'Pending'),'') LIKE @spat)");
                pars.Add(new SqlParameter("@sid", search));
                pars.Add(new SqlParameter("@spat", "%" + search + "%"));
            }

            string whereSql = where.Count > 0 ? " WHERE " + string.Join(" AND ", where) : "";

            object totalObj = Helper.DBHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM Trips t
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID" + whereSql,
                pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY t.TripID DESC";

            string sql =
                @"SELECT t.TripID, t.RequestedAt, t.Fare, t.Status, t.PaymentStatus, s.Name AS ServiceName,
                         ISNULL(c.FullName,'—') AS CustomerName, c.PhoneNumber AS CustomerPhone, c.ProfilePhotoUrl AS CustomerPhoto,
                         ISNULL(ISNULL(d.FullName,'Pending'),'—') AS DriverName, d.PhoneNumber AS DriverPhone, d.ProfilePhotoUrl AS DriverPhoto
                  FROM Trips t
                  INNER JOIN ServiceTypes s ON t.ServiceTypeID = s.ServiceTypeID
                  INNER JOIN Customers c ON t.CustomerID = c.CustomerID
                  LEFT JOIN Drivers d ON t.DriverID = d.DriverID" + whereSql + orderBy +
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
            rptTrips.Visible = true;
            SetNoDataRow(rptTrips, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "trips");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }
    }
}