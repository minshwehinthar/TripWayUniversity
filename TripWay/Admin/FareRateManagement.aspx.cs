using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web;
using System.Web.UI.WebControls;

namespace TripWay.Admin
{
    public partial class FareRateManagementPage : Helper.ListPageBase
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
                { "vehicle", "v.Name" },
                { "perkm", "f.PerKmRate" },
                { "hourly", "f.HourlyRate" },
                { "updated", "f.UpdatedAt" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            Helper.AuthHelper.RequireAdmin(this);
            if (!IsPostBack)
            {
                if (ViewState["PageSize"] == null) ViewState["PageSize"] = DefaultPageSize;
                if (ddlPerPage.Items.FindByValue(PageSize.ToString()) != null) ddlPerPage.SelectedValue = PageSize.ToString();
                BindRates();
                if (ViewState["EditingId"] != null)
                {
                    ShowEditor(Convert.ToInt32(ViewState["EditingId"]), Convert.ToBoolean(ViewState["IsNew"]));
                }
            }
        }

        private int? EditingId
        {
            get { return ViewState["EditingId"] != null ? (int?)Convert.ToInt32(ViewState["EditingId"]) : null; }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            CurrentPageIndex = 0;
            BindRates();
        }

        protected void ddlPerPage_SelectedIndexChanged(object sender, EventArgs e)
        {
            HandlePerPageChanged(ddlPerPage, DefaultPageSize);
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            CurrentPageIndex = Math.Max(0, CurrentPageIndex - 1);
            BindRates();
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            CurrentPageIndex++;
            BindRates();
        }

        protected override void OnPageIndexNavigated()
        {
            BindRates();
        }

        protected void rptRates_ItemCommand(object sender, RepeaterCommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            if (e.CommandName == "view")
            {
                OpenAppModal(BuildFareModalHtml(id), "max-w-xl");
                return;
            }
            if (e.CommandName == "edit")
            {
                ViewState["EditingId"] = id;
                ViewState["IsNew"] = false;
                ShowEditor(id, false);
                return;
            }
            if (e.CommandName != "delete") return;

            try
            {
                Helper.DBHelper.ExecuteNonQuery("DELETE FROM FareRates WHERE FareRateID=@id", new SqlParameter("@id", id));
                Helper.TripHelper.LogActivity("FareRateDeleted", null, "Admin deleted fare rate " + id + ".");
                lblMessage.Text = "Fare rate deleted.";
                pnlMessage.Visible = true;
                pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";
                BindRates();
            }
            catch
            {
                lblMessage.Text = "Cannot delete this fare rate — it is in use.";
                pnlMessage.Visible = true;
                pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200";
            }
        }

        private string BuildFareModalHtml(int id)
        {
            DataTable t = Helper.DBHelper.ExecuteQuery(
                @"SELECT f.*, v.Name AS VehicleName
                  FROM FareRates f
                  INNER JOIN VehicleTypes v ON f.VehicleTypeID = v.VehicleTypeID
                  WHERE f.FareRateID=@id",
                new SqlParameter("@id", id));
            if (t.Rows.Count == 0)
                return "<div class=\"text-sm text-gray-500\">Fare rate not found.</div>";

            DataRow r = t.Rows[0];
            decimal perKm = r["PerKmRate"] == DBNull.Value ? 0m : Convert.ToDecimal(r["PerKmRate"]);
            decimal hourly = r["HourlyRate"] == DBNull.Value ? 0m : Convert.ToDecimal(r["HourlyRate"]);
            var sb = new StringBuilder();
            sb.Append("<div class=\"mb-5\"><h3 class=\"text-lg font-bold text-gray-900\">")
              .Append(HttpUtility.HtmlEncode(r["VehicleName"].ToString()))
              .Append("</h3></div>");

            sb.Append("<div class=\"tw-detail-grid mb-5\">")
              .Append("<div><div class=\"tw-detail-label\">Vehicle</div><div class=\"tw-detail-value\">").Append(HttpUtility.HtmlEncode(r["VehicleName"].ToString())).Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Per Km</div><div class=\"tw-detail-value font-bold text-gray-900\">").Append(perKm > 0 ? "MMK " + string.Format("{0:N0}", perKm) : "—").Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Per Hour</div><div class=\"tw-detail-value font-bold text-gray-900\">").Append(hourly > 0 ? "MMK " + string.Format("{0:N0}", hourly) : "—").Append("</div></div>")
              .Append("<div><div class=\"tw-detail-label\">Updated</div><div class=\"tw-detail-value\">").Append(r["UpdatedAt"] == DBNull.Value ? "—" : Helper.TripHelper.FormatMyanmarTime(r["UpdatedAt"], "dd MMM yyyy")).Append("</div></div>")
              .Append("</div>");

            return sb.ToString();
        }

        private void BindRates()
        {
            int pageSize = PageSize;
            int offset = CurrentPageIndex * pageSize;

            string search = (txtSearch.Text ?? "").Trim();
            string where = search.Length > 0 ? " WHERE v.Name LIKE @spat" : "";
            var pars = new List<SqlParameter>();
            if (search.Length > 0) pars.Add(new SqlParameter("@spat", "%" + search + "%"));

            object totalObj = Helper.DBHelper.ExecuteScalar(
                @"SELECT COUNT(*) FROM FareRates f
                  INNER JOIN VehicleTypes v ON f.VehicleTypeID = v.VehicleTypeID" + where, pars.ToArray());
            int total = Convert.ToInt32(totalObj);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (CurrentPageIndex >= totalPages) { CurrentPageIndex = Math.Max(0, totalPages - 1); offset = CurrentPageIndex * pageSize; }

            string orderBy = Helper.SortHelper.BuildOrderBy(SortKey, SortDir, AllowedSort);
            if (string.IsNullOrEmpty(orderBy)) orderBy = " ORDER BY v.VehicleTypeID";

            string sql =
                @"SELECT f.*, v.Name AS VehicleName
                  FROM FareRates f
                  INNER JOIN VehicleTypes v ON f.VehicleTypeID = v.VehicleTypeID" + where + orderBy +
                " OFFSET @offset ROWS FETCH NEXT @take ROWS ONLY";

            var paramList = new List<SqlParameter>(pars)
            {
                new SqlParameter("@offset", offset),
                new SqlParameter("@take", pageSize)
            };

            DataTable dt = Helper.DBHelper.ExecuteQuery(sql, paramList.ToArray());
            rptRates.DataSource = dt;
            rptRates.DataBind();
            SetActiveSortArrow(rptRates, SortKey, SortDir);
            rptRates.Visible = true;
            SetNoDataRow(rptRates, dt.Rows.Count == 0);

            litPageInfo.Text = GetPagerInfo(total, CurrentPageIndex, "fare rates");
            BindPageNumbers(rptPaging, CurrentPageIndex + 1, totalPages);
            BindPrevNext(btnPrev, btnNext, CurrentPageIndex, totalPages);
        }

        private void FillDropdowns()
        {
            DataTable v = Helper.DBHelper.ExecuteQuery("SELECT VehicleTypeID, Name FROM VehicleTypes ORDER BY VehicleTypeID");
            ddlVehicle.DataSource = v;
            ddlVehicle.DataTextField = "Name";
            ddlVehicle.DataValueField = "VehicleTypeID";
            ddlVehicle.DataBind();
        }

        private void ShowEditor(int id, bool isNew)
        {
            FillDropdowns();
            lblEditorTitle.Text = isNew ? "New Fare Rate" : "Edit Fare Rate";

            if (!isNew)
            {
                DataTable r = Helper.DBHelper.ExecuteQuery(
                    "SELECT * FROM FareRates WHERE FareRateID=@id",
                    new SqlParameter("@id", id));
                if (r.Rows.Count > 0)
                {
                    DataRow row = r.Rows[0];
                    if (ddlVehicle.Items.FindByValue(row["VehicleTypeID"].ToString()) != null)
                        ddlVehicle.SelectedValue = row["VehicleTypeID"].ToString();
                    txtPerKm.Text = row["PerKmRate"] == DBNull.Value ? "" : row["PerKmRate"].ToString();
                    txtHourly.Text = row["HourlyRate"] == DBNull.Value ? "" : row["HourlyRate"].ToString();
                }
            }

            ReopenEditor();
        }

        /// <summary>
        /// Puts the editor in the lightbox again without reloading it. Needed on every failed
        /// save: each postback re-renders the panel where the markup declares it, so without this
        /// a rejected save would close the lightbox and throw away what had been typed.
        /// The ViewState edit keys are deliberately left alone so the form stays an edit of the
        /// same row.
        /// </summary>
        private void ReopenEditor()
        {
            pnlEditor.Visible = true;
            OpenPanelModal(pnlEditor, "max-w-xl");
        }

        protected void btnNewRate_Click(object sender, EventArgs e)
        {
            ViewState["EditingId"] = 0;
            ViewState["IsNew"] = true;
            ShowEditor(0, true);
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ViewState.Remove("EditingId");
            ViewState.Remove("IsNew");
            pnlEditor.Visible = false;
        }

        protected void btnSaveRate_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) { ReopenEditor(); return; }

            decimal perKm, perHour;
            if (!TryRate(txtPerKm.Text, out perKm)) { Reject("The per-km rate must be a number of 0 or more."); return; }
            if (!TryRate(txtHourly.Text, out perHour)) { Reject("The per-hour rate must be a number of 0 or more."); return; }

            // One row per vehicle, holding both rates:
            //   point-to-point  ->  PerKmRate  x distance
            //   hourly hire     ->  HourlyRate x hours
            // A rate left blank is stored as NULL, which is how the booking page knows that service
            // is not offered for that vehicle and says "Rate unavailable" instead of quoting 0.
            // Saving both blank is refused: that is a row that prices nothing at all.
            if (perKm <= 0m && perHour <= 0m)
            {
                Reject("Enter a per-km rate, a per-hour rate, or both.");
                return;
            }
            object perKmOut = perKm > 0m ? (object)perKm : DBNull.Value;
            object hourlyOut = perHour > 0m ? (object)perHour : DBNull.Value;

            // A vehicle can only have one rate row, so a new row for a vehicle that already has one
            // is an edit of that row rather than a second row. Adding a duplicate used to be
            // possible, and the booking page then quoted the largest of the two instead of the
            // rate that was set.
            DataTable existing = Helper.DBHelper.ExecuteQuery(
                "SELECT FareRateID FROM FareRates WHERE VehicleTypeID=@v ORDER BY UpdatedAt DESC, FareRateID DESC",
                new SqlParameter("@v", ddlVehicle.SelectedValue));
            int targetId = EditingId.HasValue ? EditingId.Value : 0;
            if (existing.Rows.Count > 0) targetId = Convert.ToInt32(existing.Rows[0]["FareRateID"]);

            // BaseFare is no longer part of any calculation, and ServiceTypeID no longer selects
            // which rate applies, so both are written as constants in the SQL rather than passed
            // as parameters. BaseFare was being sent as @b and the save failed with "expects the
            // parameter '@b', which was not supplied"; with nothing left to pass, it cannot.
            if (targetId > 0)
            {
                Helper.DBHelper.ExecuteNonQuery(
                    @"UPDATE FareRates
                      SET VehicleTypeID=@v, BaseFare=0, ServiceTypeID=1,
                          PerKmRate=@pm, HourlyRate=@h, UpdatedAt=SYSUTCDATETIME()
                      WHERE FareRateID=@id",
                    new SqlParameter("@v", ddlVehicle.SelectedValue),
                    new SqlParameter("@pm", perKmOut),
                    new SqlParameter("@h", hourlyOut),
                    new SqlParameter("@id", targetId));
                Helper.TripHelper.LogActivity("FareRateUpdated", null, "Admin updated rates for vehicle " + ddlVehicle.SelectedValue + ".");
            }
            else
            {
                Helper.DBHelper.ExecuteNonQuery(
                    @"INSERT INTO FareRates (VehicleTypeID, ServiceTypeID, BaseFare, PerKmRate, HourlyRate)
                      VALUES (@v, 1, 0, @pm, @h)",
                    new SqlParameter("@v", ddlVehicle.SelectedValue),
                    new SqlParameter("@pm", perKmOut),
                    new SqlParameter("@h", hourlyOut));
                Helper.TripHelper.LogActivity("FareRateCreated", null, "Admin created rates for vehicle " + ddlVehicle.SelectedValue + ".");
            }

            lblMessage.Text = "Fare rate saved.";
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200";

            ViewState.Remove("EditingId");
            ViewState.Remove("IsNew");
            pnlEditor.Visible = false;
            BindRates();
        }

        /// <summary>
        /// Read one rate box. An empty box is not an error, it means that service is not offered
        /// for the vehicle, so it reads as 0; anything that is present but not a number of 0 or
        /// more fails and is reported by the caller.
        /// </summary>
        private static bool TryRate(string text, out decimal rate)
        {
            rate = 0m;
            if (text == null || text.Trim().Length == 0) return true;
            decimal value;
            if (!decimal.TryParse(text.Trim(), out value)) return false;
            if (value < 0m) return false;
            rate = value;
            return true;
        }

        private void Reject(string message)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = "p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200";

            // Only the save handler gets here, so the editor is the thing the admin was looking
            // at. Keep it on screen behind the message rather than closing it on them.
            ReopenEditor();
        }
    }
}