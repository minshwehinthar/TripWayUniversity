using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class PackageManagementPage : Helper.ListPageBase
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
                { "name", "p.Name" },
                { "days", "p.DurationDays" },
                { "places", "PlacesCount" },
                { "price", "p.FixedPrice" },
                { "source", "CreatedByName" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            Helper.TripHelper.EnsurePackagePhotos();
            Helper.TripHelper.EnsurePackageActive();
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                txtSearch.Text = Request.QueryString["q"] ?? "";
                BindPackages();
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            BindPackages();
        }

        protected void ddlPerPage_SelectedIndexChanged(object sender, EventArgs e)
        {
            HandlePerPageChanged(ddlPerPage, DefaultPageSize);
        }

        protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
        {
            // A filter change can leave the current page past the end of the results.
            CurrentPageIndex = 0;
            BindPackages();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            CurrentPageIndex = Math.Max(0, CurrentPageIndex - 1);
            BindPackages();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPageIndex++;
            BindPackages();
        }

        protected override void OnPageIndexNavigated()
        {
            BindPackages();
        }

        protected void rptPackages_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "toggleActive")
            {
                TogglePackageVisibility(Convert.ToInt32(e.CommandArgument));
                return;
            }

            if (e.CommandName != "delete") return;

            int id = Convert.ToInt32(e.CommandArgument);

            try
            {
                var files = new List<string>();
                foreach (DataRow row in Helper.TripHelper.GetPackagePhotos(id).Rows)
                {
                    string url = Helper.TripHelper.PackagePhotoUrl(row["PhotoUrl"]);
                    if (url.Length > 0) files.Add(url);
                }
                string cover = Helper.TripHelper.PackagePhotoUrl(Helper.DBHelper.ExecuteScalar(
                    "SELECT CoverPhotoUrl FROM Packages WHERE PackageID=@id",
                    new SqlParameter("@id", id)));
                if (cover.Length > 0) files.Add(cover);

                Helper.DBHelper.ExecuteNonQuery(
                    "DELETE FROM PackagePhotos WHERE PackageID=@id; DELETE FROM PackagePlaces WHERE PackageID=@id; DELETE FROM Packages WHERE PackageID=@id;",
                    new SqlParameter("@id", id));
                Helper.TripHelper.LogActivity("PackageDeleted", null, "Admin deleted package " + id + ".");
                foreach (string url in files) DeleteStoredPhoto(url);

                lblMessage.Text = "Package deleted.";
                SetMessageStyle(false);
                pnlMessage.Visible = true;
                BindPackages();
            }
            catch
            {
                SetMessageStyle(true);
                lblMessage.Text = "Cannot delete this package — it is used by existing trips.";
                pnlMessage.Visible = true;
            }
        }

        /// <summary>
        /// Hides a package from customer view, or puts it back. The switch flips the stored flag
        /// rather than setting it from the checkbox, because that checkbox is plain markup and
        /// carries no state the server can trust.
        /// </summary>
        private void TogglePackageVisibility(int packageId)
        {
            try
            {
                // ISNULL mirrors the select above, so a package predating the flag column is
                // treated as visible rather than flipped out from under the admin.
                Helper.DBHelper.ExecuteNonQuery(
                    "UPDATE Packages SET IsActive = CASE WHEN ISNULL(IsActive,1) = 1 THEN 0 ELSE 1 END WHERE PackageID = @id",
                    new SqlParameter("@id", packageId));

                object flag = Helper.DBHelper.ExecuteScalar(
                    "SELECT ISNULL(IsActive,1) FROM Packages WHERE PackageID = @id",
                    new SqlParameter("@id", packageId));
                // A package that vanished between render and click has nothing to report on.
                if (flag == null || flag == DBNull.Value)
                {
                    SetMessageStyle(false);
                    lblMessage.Text = "That package no longer exists.";
                    pnlMessage.Visible = true;
                    BindPackages();
                    return;
                }

                bool nowActive = Convert.ToBoolean(flag);
                Helper.TripHelper.LogActivity("PackageVisibilityChanged", null,
                    "Admin " + (nowActive ? "published" : "hid") + " package " + packageId + " from customer view.");

                lblMessage.Text = nowActive
                    ? "Package is now visible to customers."
                    : "Package is hidden from customers.";
                SetMessageStyle(false);
                pnlMessage.Visible = true;
            }
            catch
            {
                SetMessageStyle(true);
                lblMessage.Text = "Could not change this package's visibility. Please try again.";
                pnlMessage.Visible = true;
            }
            BindPackages();
        }

        private void SetMessageStyle(bool isError)
        {
            pnlMessage.CssClass = isError
                ? "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200"
                : "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
        }

        /// <summary>
        /// Data-binding expressions are compiled outside the page's namespace, so the cover
        /// photo helpers are exposed here as page members for the repeater template.
        /// </summary>
        protected bool HasCoverPhoto(object storedPath)
        {
            return Helper.TripHelper.PackagePhotoUrl(storedPath).Length > 0;
        }

        protected string CoverThumbUrl(object storedPath)
        {
            return ResolveUrl("~/" + Helper.TripHelper.PackagePhotoUrl(storedPath));
        }
        private void DeleteStoredPhoto(string relativeUrl)
        {
            if (string.IsNullOrWhiteSpace(relativeUrl)) return;
            try
            {
                string full = Server.MapPath("~/" + relativeUrl);
                string root = Server.MapPath("~/" + Helper.TripHelper.PackagePhotoFolder);
                if (!string.IsNullOrEmpty(full) && !string.IsNullOrEmpty(root)
                    && full.StartsWith(root, StringComparison.OrdinalIgnoreCase) && File.Exists(full))
                    File.Delete(full);
            }
            catch { }
        }

        private void BindPackages()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            string where = search.Length > 0 ? " WHERE p.Name LIKE @spat" : "";
            var pars = new List<SqlParameter>();
            if (search.Length > 0) pars.Add(new SqlParameter("@spat", "%" + search + "%"));

            string statusFilter = ddlStatus.SelectedValue;
            if (statusFilter == "1" || statusFilter == "0")
            {
                where += where.Length > 0 ? " AND p.IsActive = @act" : " WHERE p.IsActive = @act";
                pars.Add(new SqlParameter("@act", statusFilter == "1"));
            }

            object totalObj = Helper.DBHelper.ExecuteScalar(
                "SELECT COUNT(*) FROM Packages p" + where, pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY p.PackageID DESC";

            string sql =
                @"SELECT p.PackageID, p.Name, p.DurationDays, p.FixedPrice, p.CoverPhotoUrl,
                         ISNULL(p.IsActive, 1) AS IsActive,
                         ISNULL(d.FullName,'Created by admin') AS CreatedByName,
                         (SELECT COUNT(*) FROM PackagePlaces pp WHERE pp.PackageID = p.PackageID) AS PlacesCount
                   FROM Packages p
                   LEFT JOIN Drivers d ON p.CreatedByDriverID = d.DriverID" + where + orderBy +
                   " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptPackages.DataSource = dt;
            rptPackages.DataBind();
            SetActiveSortArrow(rptPackages, SortKey, SortDir);
            rptPackages.Visible = true;
            SetNoDataRow(rptPackages, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "packages");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }
    }
}