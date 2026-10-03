using System;
using System.Collections.Generic;
using System.Data;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TripWay.Helper
{
    public class PageItem
    {
        public int Page { get; set; }
        public bool IsCurrent { get; set; }
    }

    public class ListPageBase : System.Web.UI.Page
    {
        protected const int MaxVisiblePages = 5;
        protected int CurrentPage { get; private set; }

        protected int PageIndex
        {
            get { return ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0; }
            set { ViewState["PageIndex"] = value; }
        }

        protected int PageSize
        {
            get { return ViewState["PageSize"] != null ? Convert.ToInt32(ViewState["PageSize"]) : 10; }
            set { ViewState["PageSize"] = value; }
        }

        /// <summary>
        /// Puts the "Show" dropdown and the page size in agreement on the first render.
        /// <para>
        /// A hardcoded default that is not one of the dropdown's own values is the trap this
        /// exists to close. ActivityLogs defaulted to 20 against a 5/10/25/50 list, so
        /// Items.FindByValue("20") came back null, the control stayed on its first item and the
        /// page claimed "5 per page" while the query fetched twenty rows.
        /// </para>
        /// </summary>
        protected void SeedPageSizeFrom(DropDownList ddl, int fallback)
        {
            if (ddl == null) { PageSize = fallback; return; }

            // A stored size is only kept when the control can actually display it.
            if (ViewState["PageSize"] != null && ddl.Items.FindByValue(PageSize.ToString()) != null)
            {
                ddl.SelectedValue = PageSize.ToString();
                return;
            }

            PageSize = ddl.Items.FindByValue(fallback.ToString()) != null
                ? fallback
                : ParsePageSize(ddl.SelectedValue, fallback);

            // Guarded: a caller whose fallback is absent from its own list must not throw here.
            if (ddl.Items.FindByValue(PageSize.ToString()) != null)
                ddl.SelectedValue = PageSize.ToString();
        }

        private static int ParsePageSize(string text, int fallback)
        {
            int size;
            return int.TryParse(text, out size) && size > 0 ? size : fallback;
        }

        protected void HandlePerPageChanged(DropDownList ddl, int defaultSize)
        {
            int size = defaultSize;
            if (ddl != null && !string.IsNullOrEmpty(ddl.SelectedValue) && !ddl.SelectedValue.Equals("-1"))
                int.TryParse(ddl.SelectedValue, out size);
            PageSize = size;
            PageIndex = 0;
            OnPageIndexNavigated();
        }

        protected void BindPrevNext(LinkButton btnPrev, LinkButton btnNext, int currentPageIndex, int totalPages)
        {
            if (btnPrev != null) btnPrev.Enabled = totalPages > 1 && currentPageIndex > 0;
            if (btnNext != null) btnNext.Enabled = totalPages > 1 && currentPageIndex < totalPages - 1;
        }

        protected string GetPagerInfo(int total, int pageIndex0Based, string noun)
        {
            if (total == 0) return "No " + (noun ?? "records") + " found";
            int from = pageIndex0Based * PageSize + 1;
            int to = Math.Min((pageIndex0Based + 1) * PageSize, total);
            return "Showing " + from + "&ndash;" + to + " of " + total.ToString("N0") + " " + (noun ?? "records");
        }

        /// <summary>
        /// A startup script is written out with the rest of the form, which is before the script
        /// block at the foot of the master that defines appOpenModal. Calling it there throws a
        /// ReferenceError and the lightbox simply never appears, with nothing in the console but
        /// a line that is easy to miss. So the call waits for the document: by then the functions
        /// are defined and the modal markup has been parsed.
        ///
        /// The wrapper is written out in full rather than calling a helper on the master, because
        /// a helper defined at the foot of the master is exactly what is not there yet.
        /// The queue is not needed either: a startup script fires once, and DOMContentLoaded fires
        /// once, so there is never more than one call waiting.
        /// </summary>
        private static string DeferUntilReady(string call)
        {
            return "(function(f){if(document.readyState==='loading')"
                 + "document.addEventListener('DOMContentLoaded',f);else f();})(" + call + ");";
        }

        /// <summary>
        /// Opens the shared lightbox. "widthClass" narrows the panel for the small forms
        /// (the rating box uses "max-w-md"); every other caller keeps the default width.
        /// </summary>
        protected void OpenAppModal(string html, string widthClass = null)
        {
            var json = new JavaScriptSerializer();
            string js = DeferUntilReady("function(){appOpenModal(" + json.Serialize(html)
                + (string.IsNullOrEmpty(widthClass) ? "" : "," + json.Serialize(widthClass)) + ");}");
            ClientScript.RegisterStartupScript(GetType(), "openAppModal_" + Guid.NewGuid().ToString("N"), js, true);
        }

        /// <summary>
        /// Opens the shared lightbox around a server-rendered panel. Use this instead of
        /// OpenAppModal when the form needs real postback controls and validators, which cannot be
        /// built as client-side HTML. The panel is moved into the modal body and put back on every
        /// postback, so a page that re-renders it must reopen it too or the form disappears.
        /// </summary>
        protected void OpenPanelModal(Panel panel, string widthClass = null)
        {
            var json = new JavaScriptSerializer();
            string js = DeferUntilReady("function(){appOpenPanel(" + json.Serialize(panel.ClientID)
                + (string.IsNullOrEmpty(widthClass) ? "" : "," + json.Serialize(widthClass)) + ");}");
            ClientScript.RegisterStartupScript(GetType(), "openPanelModal_" + Guid.NewGuid().ToString("N"), js, true);
        }

        /// <summary>
        /// Shows a toast. The text is encoded for JavaScript rather than pasted in, because these
        /// messages routinely carry a name or a state read back out of the database, and one stray
        /// quote in either would turn the whole script into a syntax error and swallow the message.
        /// </summary>
        protected void Toast(string message, bool isError = false)
        {
            string js = "TwToast." + (isError ? "error" : "success") + "(" +
                        HttpUtility.JavaScriptStringEncode(message ?? "") + ");";
            ClientScript.RegisterStartupScript(GetType(), "twtoast_" + Guid.NewGuid().ToString("N"), js, true);
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            TripHelper.EnsureTripStops();
            TripHelper.EnsureEtaColumns();
        }

        protected string GetRowNumber(int itemIndex)
        {
            int pageIndex = ViewState["PageIndex"] != null ? Convert.ToInt32(ViewState["PageIndex"]) : 0;
            int pageSize = ViewState["PageSize"] != null ? Convert.ToInt32(ViewState["PageSize"]) : 10;
            return ((pageIndex * pageSize) + itemIndex + 1).ToString();
        }

        protected string GetInitial(string value)
        {
            if (string.IsNullOrEmpty(value)) return "?";
            string trimmed = value.Trim();
            return trimmed.Length == 0 ? "?" : trimmed.Substring(0, 1).ToUpperInvariant();
        }

        protected string GetAvatarCss(object id)
        {
            long n = Convert.ToInt64(id ?? 0);
            string[] colors = { "tw-avatar-blue", "tw-avatar-green", "tw-avatar-violet", "tw-avatar-amber" };
            return colors[(int)((n % colors.Length + colors.Length) % colors.Length)];
        }

        /// <summary>
        /// Header arrival chip for the driver's own pages. Nothing when no estimate was given,
        /// "Arrived"/"On the way" once there is nothing left to count down, otherwise the live
        /// countdown chip Site.Master keeps ticking.
        /// </summary>
        protected string DriverEtaChip(object minutes, object setAt, string status)
        {
            if (minutes == null || minutes == DBNull.Value || Convert.ToInt32(minutes) <= 0) return "";
            if (status == "Arrived" || status == "Started")
                return "<span class=\"inline-flex px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-50 text-emerald-600\">"
                    + (status == "Started" ? "On the way" : "Arrived") + "</span>";
            return TripHelper.EtaLiveChipHtml(Convert.ToInt32(minutes), setAt);
        }

        /// <summary>
        /// Every profile card on the site is the same pair of panels: a photo when one was
        /// uploaded, otherwise the coloured initial avatar. Each page used to carry its own
        /// copy of this switch, so the rule lives here once.
        /// </summary>
        protected void ShowPhoto(object storedPath, Panel photoPanel, Image photo, Panel initialPanel)
        {
            string url = TripHelper.CustomerPhotoUrl(storedPath);
            bool has = url.Length > 0;

            photoPanel.Visible = has;
            initialPanel.Visible = !has;
            if (has) photo.ImageUrl = ResolveUrl("~/" + url);
        }

        /// <summary>
        /// The image source for a profile cell, resolved exactly the way ShowPhoto resolves it.
        /// Returns "" when there is nothing to show, so the cell can fall back to initials.
        /// List cells bind this straight into an ImageUrl rather than setting it after DataBind.
        /// </summary>
        protected static string PhotoSrc(object storedPath)
        {
            return ResolvePhoto(storedPath, TripHelper.CustomerPhotoUrl);
        }

        /// <summary>
        /// The driver equivalent. Drivers keep their photos in their own folder, so this must not
        /// reuse the customer resolver.
        /// </summary>
        protected static string DriverPhotoSrc(object storedPath)
        {
            return ResolvePhoto(storedPath, TripHelper.DriverPhotoUrl);
        }

        /// <summary>
        /// True when the row carries a real photo, so the cell shows the photo instead of initials.
        /// </summary>
        protected static bool HasPhoto(object storedPath)
        {
            return PhotoSrc(storedPath).Length > 0;
        }

        private static string ResolvePhoto(object storedPath, Func<object, string> resolver)
        {
            string url = resolver(storedPath);
            return url.Length == 0 ? "" : VirtualPathUtility.ToAbsolute("~/" + url);
        }

        protected string FormatTime(object value, string format = "dd MMM yyyy, HH:mm")
        {
            return TripHelper.FormatMyanmarTime(value, format);
        }

        /// <summary>
        /// The payment badge next to the method name. Takes the Image as an argument because the
        /// field lives on each page, and the rule was being copied into every one of them.
        /// </summary>
        protected void ShowPaymentIcon(Image icon, object stored)
        {
            string method = stored == null || stored == DBNull.Value ? "" : stored.ToString();
            string url = TripHelper.PaymentMethodIcon(method);
            icon.Visible = url.Length > 0;
            if (url.Length == 0) return;

            icon.ImageUrl = ResolveUrl(url);
            // If the brand file has not been uploaded to Images/ yet, hide the img rather
            // than showing a broken-image icon next to the text.
            icon.Attributes["onerror"] = "this.style.display='none';";
        }

        /// <summary>
        /// The one line under the payment row of the summary card. Reads the Payments row
        /// whether the page aliased it as PaidAt or PayPaidAt, and drops the "mark it paid"
        /// nudge on a trip that is already closed, since there is nothing left to mark.
        /// </summary>
        protected static string PaymentRecordHtml(DataRow r)
        {
            string status = r["PaymentStatus"] == DBNull.Value ? "" : r["PaymentStatus"].ToString();
            if (status != "Paid")
            {
                return r["Status"] != null && r["Status"] != DBNull.Value
                       && (r["Status"].ToString() == "Completed" || r["Status"].ToString() == "Cancelled")
                    ? "<span class=\"text-gray-500\">The fare was never collected on this trip.</span>"
                    : "<span class=\"text-gray-500\">Fare not collected yet &mdash; mark it paid once you have the money.</span>";
            }

            object paidAt = r.Table.Columns.Contains("PaidAt") ? r["PaidAt"]
                : r.Table.Columns.Contains("PayPaidAt") ? r["PayPaidAt"] : null;
            string amount = Convert.ToDecimal(r["Fare"]).ToString("N0");
            string when = paidAt == null || paidAt == DBNull.Value
                ? "" : TripHelper.FormatMyanmarTime(paidAt, "dd MMM yyyy, HH:mm");

            return string.IsNullOrEmpty(when)
                ? "<span class=\"text-gray-500\">Fare MMK " + System.Web.HttpUtility.HtmlEncode(amount) + " collected.</span>"
                : "<span class=\"text-gray-500\">Fare MMK " + System.Web.HttpUtility.HtmlEncode(amount)
                  + " collected on " + System.Web.HttpUtility.HtmlEncode(when) + ".</span>";
        }

        protected bool ListHasPrev(GridView g)
        {
            return g.PageCount > 0 && g.PageIndex > 0;
        }

        protected bool ListHasNext(GridView g)
        {
            return g.PageCount > 0 && g.PageIndex < g.PageCount - 1;
        }

        protected List<PageItem> GetPageItems(int currentPageIndex, int totalPages)
        {
            var items = new List<PageItem>();
            if (totalPages < 1) return items;

            if (currentPageIndex < 1) currentPageIndex = 1;
            if (currentPageIndex > totalPages) currentPageIndex = totalPages;

            int start = currentPageIndex - (MaxVisiblePages / 2);
            if (start < 1) start = 1;

            int end = start + MaxVisiblePages - 1;
            if (end > totalPages)
            {
                end = totalPages;
                start = Math.Max(1, end - MaxVisiblePages + 1);
            }

            for (int i = start; i <= end; i++)
                items.Add(new PageItem { Page = i, IsCurrent = i == currentPageIndex });

            return items;
        }

        protected string GetPageButtonCss(object page, int currentPageIndex)
        {
            int p = Convert.ToInt32(page);
            bool active = p == currentPageIndex;
            return "tw-pager-btn size-8 justify-center px-0 font-semibold" + (active ? " active" : "");
        }

        protected void PageNumber_Click(object sender, EventArgs e)
        {
            LinkButton lb = sender as LinkButton;
            if (lb == null || string.IsNullOrEmpty(lb.CommandArgument)) return;

            int page;
            if (!int.TryParse(lb.CommandArgument, out page) || page < 1) return;

            ViewState["PageIndex"] = page - 1;
            OnPageIndexNavigated();
        }

        protected virtual void OnPageIndexNavigated()
        {
        }

        protected string SortKey
        {
            get { return (ViewState["SortKey"] as string) ?? ""; }
            set { ViewState["SortKey"] = value; }
        }

        protected string SortDir
        {
            get { return (ViewState["SortDir"] as string) ?? ""; }
            set { ViewState["SortDir"] = value; }
        }

        protected void SortHeaderAsc_Click(object sender, EventArgs e)
        {
            SetSort(((LinkButton)sender).CommandArgument, "ASC");
        }

        protected void SortHeaderDesc_Click(object sender, EventArgs e)
        {
            SetSort(((LinkButton)sender).CommandArgument, "DESC");
        }

        private void SetSort(string column, string direction)
        {
            SortKey = column;
            SortDir = direction;
            PageIndex = 0;
            OnPageIndexNavigated();
        }

        protected void SetActiveSortArrow(Repeater rpt, string key, string dir)
        {
            if (rpt == null || string.IsNullOrEmpty(key)) return;
            if (string.IsNullOrEmpty(dir)) dir = "ASC";
            foreach (Control c in rpt.Controls)
            {
                RepeaterItem ri = c as RepeaterItem;
                if (ri == null || ri.ItemType != ListItemType.Header) continue;

                string id = "lnkSort" + key + (string.Equals(dir, "ASC", StringComparison.OrdinalIgnoreCase) ? "A" : "D");
                LinkButton btn = ri.FindControl(id) as LinkButton;
                if (btn != null) btn.CssClass = "tw-sort-arrow active";
                break;
            }
        }

        protected void SetNoDataRow(Repeater rpt, bool showEmpty)
        {
            EmptyState.TableRow(rpt, showEmpty);
        }

        /// <summary>
        /// The empty state for a list that is a set of cards or a grid rather than a table,
        /// where the trNoData row has no colspan to sit in. The Panel holds a Literal called
        /// "litEmpty" whose text this sets.
        /// </summary>
        protected void SetNoDataBlock(Panel panel, bool showEmpty, string message)
        {
            EmptyState.Block(panel, showEmpty, message);
        }

        protected void SetTotalRow(Repeater rpt, bool showTotal, string text)
        {
            if (rpt == null || rpt.Controls.Count == 0) return;
            var item = rpt.Controls[rpt.Controls.Count - 1] as RepeaterItem;
            if (item == null || item.ItemType != ListItemType.Footer) return;
            var tr = item.FindControl("trTotals") as System.Web.UI.HtmlControls.HtmlGenericControl;
            if (tr != null) tr.Visible = showTotal;
            var lit = item.FindControl("litTotal") as System.Web.UI.WebControls.Literal;
            if (lit != null) lit.Text = text;
        }

        protected void BindPageNumbers(Repeater rptPaging, int currentPageIndex, int totalPages)
        {
            CurrentPage = currentPageIndex;
            rptPaging.Visible = totalPages > 1;
            if (totalPages <= 1)
            {
                rptPaging.DataSource = null;
                rptPaging.DataBind();
                return;
            }
            rptPaging.DataSource = GetPageItems(currentPageIndex, totalPages);
            rptPaging.DataBind();
        }

        /// <summary>
        /// The shape of a status badge: rounded-full, padding and type size. Assigning
        /// CssClass replaces the whole string, so a code-behind that only sets the colour
        /// drops the rounding. Prepend this to whatever colours GetStatusCss returns.
        ///
        /// It has to go on the same element as the background colour. Putting the rounding
        /// on a wrapper span and the colour on the inner asp:Label does not work: a parent's
        /// border-radius does not round a child's background, so the badge renders as a
        /// square-cornered box inside a rounded transparent one.
        /// </summary>
        protected const string PillBase = "inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold ";

        protected string GetStatusCss(string status)
        {
            switch (status)
            {
                case "Approved":
                case "Active":
                case "Completed":
                case "Paid":
                case "Accepted":
                    return "bg-emerald-50 text-emerald-700";
                case "Pending":
                case "Requested":
                case "Unpaid":
                    return "bg-blue-50 text-blue-700";
                case "Rejected":
                case "Cancelled":
                case "Failed":
                case "Suspended":
                    return "bg-red-50 text-red-700";
                case "Arrived":
                case "Started":
                    return "bg-amber-50 text-amber-700";
                default:
                    return "bg-gray-100 text-gray-600";
            }
        }
    }
}
