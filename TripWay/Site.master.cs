using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace TripWay
{
    public partial class SiteMaster : MasterPage
    {
        private string _pendingBadge = "";
        private string _badgeFile = "";
        private string _dashUrl = "";

        private static readonly HashSet<string> PublicPages =
            new HashSet<string>(StringComparer.OrdinalIgnoreCase)
            {
                "Default", "Services", "FAQs", "AboutUs", "ContactUs"
            };

        /// <summary>One admin page's place in the trail and in the sidebar.</summary>
        private sealed class AdminPage
        {
            /// <summary>The list page this one hangs off, or null when the page is a list itself.</summary>
            public string Parent;
            /// <summary>Text shown for this page, and for its parent when linked from a child.</summary>
            public string Label;
            /// <summary>Sidebar entry that stays highlighted while this page is open.</summary>
            public string Sidebar;
            /// <summary>
            /// Optional record page slotted between the parent and this one, for a page that edits one
            /// specific row and would otherwise have no way back to it. Set with <see cref="RecordParam"/>.
            /// </summary>
            public string Record;
            public string RecordParam;
        }

        // Single source of truth for the admin breadcrumb and the sidebar highlight, so a child page
        // can never end up pointing at the wrong list the way Admin/TripDetail used to.
        private static readonly Dictionary<string, AdminPage> AdminPages =
            new Dictionary<string, AdminPage>(StringComparer.OrdinalIgnoreCase)
            {
                { "Dashboard",          new AdminPage { Label = "Dashboard",          Sidebar = "Dashboard" } },
                { "DriverManagement",   new AdminPage { Label = "Driver Management",   Sidebar = "DriverManagement" } },
                { "CreateDriver",       new AdminPage { Parent = "DriverManagement",   Label = "Create New Driver", Sidebar = "DriverManagement" } },
                { "DriverDetail",       new AdminPage { Parent = "DriverManagement",   Label = "Driver Details",    Sidebar = "DriverManagement" } },
                { "DriverEdit",         new AdminPage { Parent = "DriverManagement",   Label = "Edit Driver",       Sidebar = "DriverManagement" } },
                { "CustomerManagement", new AdminPage { Label = "Customer Management", Sidebar = "CustomerManagement" } },
                { "CreateCustomer",     new AdminPage { Parent = "CustomerManagement", Label = "Create New Customer", Sidebar = "CustomerManagement" } },
                { "CustomerDetail",     new AdminPage { Parent = "CustomerManagement", Label = "Customer Details",   Sidebar = "CustomerManagement" } },
                { "CustomerEdit",       new AdminPage { Parent = "CustomerManagement", Label = "Edit Customer",      Sidebar = "CustomerManagement" } },
                { "TripManagement",     new AdminPage { Label = "Trip Management",     Sidebar = "TripManagement" } },
                { "TripDetail",         new AdminPage { Parent = "TripManagement",     Label = "Trip Details",       Sidebar = "TripManagement" } },
                { "PackageManagement",  new AdminPage { Label = "Package Management",  Sidebar = "PackageManagement" } },
                { "PackageCreate",      new AdminPage { Parent = "PackageManagement",  Label = "Create New Package", Sidebar = "PackageManagement" } },
                { "PackageDetail",      new AdminPage { Parent = "PackageManagement",  Label = "Package Details",    Sidebar = "PackageManagement" } },
                { "PackageEdit",        new AdminPage { Parent = "PackageManagement",  Record = "PackageDetail", RecordParam = "id", Label = "Edit Package",       Sidebar = "PackageManagement" } },
                { "HotelManagement",    new AdminPage { Label = "Hotel Management",    Sidebar = "HotelManagement" } },
                { "HotelCreate",        new AdminPage { Parent = "HotelManagement",    Label = "Create New Hotel",   Sidebar = "HotelManagement" } },
                { "HotelDetail",        new AdminPage { Parent = "HotelManagement",    Label = "Hotel Details",      Sidebar = "HotelManagement" } },
                { "HotelEdit",          new AdminPage { Parent = "HotelManagement",    Label = "Edit Hotel",         Sidebar = "HotelManagement" } },
                { "FareRateManagement", new AdminPage { Label = "Fare Rate Management", Sidebar = "FareRateManagement" } },
                { "ActivityLogs",       new AdminPage { Label = "Activity Logs",       Sidebar = "ActivityLogs" } },
                { "Profile",            new AdminPage { Label = "Profile",             Sidebar = "Profile" } }
            };

        // Only the non-admin child pages still need this: their trail is written on the page itself.
        private static readonly Dictionary<string, string> ChildToParent =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "TripDetail", "TripHistory" },
                { "RequestDetail", "TripRequests" }
            };

        // The customer and driver trail labels, keyed by folder and file name together because both
        // sides reuse names like Dashboard, Profile and TripDetail. Left to the file name alone the
        // label was guessed, which called Customer/TripHistory "Trip History" while its own sidebar
        // calls it "Past Trips". Only the pages that do not write their own trail reach this; the
        // four that override BreadcrumbContent keep their own labels.
        private static readonly Dictionary<string, string> SideLabels =
            new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
            {
                { "Customer/Dashboard",   "Dashboard" },
                { "Customer/BookTrip",    "Book a Trip" },
                { "Customer/ActiveTrip",  "Active Trip" },
                { "Customer/TripHistory", "Past Trips" },
                { "Customer/TripDetail",  "Trip Details" },
                { "Customer/Profile",     "Profile" },
                { "Driver/Dashboard",     "Dashboard" },
                { "Driver/TripRequests",  "Trip Requests" },
                { "Driver/ActiveTrip",    "Active Trip" },
                { "Driver/TripHistory",   "Trip History" },
                { "Driver/TripDetail",    "Trip Details" },
                { "Driver/RequestDetail", "Request Details" },
                { "Driver/Profile",       "Profile" }
            };

        protected void Page_Load(object sender, EventArgs e)
        {
            SetupNavigation();
            BuildBreadcrumb();
        }

        private static bool IsAdminPage(string absolutePath)
        {
            return absolutePath.IndexOf("/Admin/", StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private static AdminPage AdminPageFor(string absolutePath, string fileName)
        {
            AdminPage page;
            if (IsAdminPage(absolutePath) && !string.IsNullOrEmpty(fileName)
                && AdminPages.TryGetValue(fileName, out page))
            {
                return page;
            }
            return null;
        }

        /// <summary>
        /// Sidebar entry that owns the current page. Admin pages answer from the map; the driver and
        /// customer child pages answer from ChildToParent.
        /// </summary>
        private string SidebarOwnerFor(string absolutePath, string fileName)
        {
            AdminPage admin = AdminPageFor(absolutePath, fileName);
            if (admin != null)
                return admin.Sidebar;

            string parent;
            if (!string.IsNullOrEmpty(fileName) && ChildToParent.TryGetValue(fileName, out parent))
                return parent;

            return "";
        }

        private static string Prettify(string fileName)
        {
            return System.Text.RegularExpressions.Regex.Replace(fileName, "([a-z0-9])([A-Z])", "$1 $2");
        }

        /// <summary>
        /// The trail label for a customer or driver page, or null when the page is not one of theirs.
        /// The folder is pulled off the front of the path so the two sides cannot read each other's
        /// entries, and so an unmapped page still falls back to the file name.
        /// </summary>
        private static string SideLabel(string absolutePath, string fileName)
        {
            if (string.IsNullOrEmpty(fileName)) return null;

            int lastSlash = absolutePath.LastIndexOf('/');
            if (lastSlash < 0) return null;
            string folder = absolutePath.Substring(0, lastSlash);
            int folderSlash = folder.LastIndexOf('/');
            if (folderSlash >= 0) folder = folder.Substring(folderSlash + 1);

            if (!string.Equals(folder, "Customer", StringComparison.OrdinalIgnoreCase)
                && !string.Equals(folder, "Driver", StringComparison.OrdinalIgnoreCase))
                return null;

            string label;
            return SideLabels.TryGetValue(folder + "/" + fileName, out label) ? label : null;
        }

        /// <summary>
        /// The record id for a page's extra crumb, or null when the page has no record level or the id
        /// is not in the query string.
        /// </summary>
        private string RecordId(AdminPage page)
        {
            if (string.IsNullOrEmpty(page.Record) || string.IsNullOrEmpty(page.RecordParam))
                return null;

            string id = Request.QueryString[page.RecordParam];
            if (string.IsNullOrEmpty(id)) return null;

            int parsed;
            return int.TryParse(id, out parsed) && parsed > 0 ? parsed.ToString() : null;
        }

        private void BuildBreadcrumb()
        {
            if (litBreadcrumb == null) return;

            // Hidden by SetupNavigation, so there is nothing to draw and nothing to look up.
            if (pnlBreadcrumb != null && !pnlBreadcrumb.Visible) return;

            string path = Request.Url.AbsolutePath;
            string file = System.IO.Path.GetFileNameWithoutExtension(path);
            AdminPage page = AdminPageFor(path, file);

            var sb = new System.Text.StringBuilder();
            sb.Append("<ol class=\"flex flex-wrap items-center gap-x-1.5 gap-y-1 text-sm\">");

            const string separator =
                "<li class=\"shrink-0 text-gray-400\"><svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" " +
                "viewBox=\"0 0 24 24\" stroke-width=\"1.5\" stroke=\"currentColor\" class=\"size-2.5 shrink-0\">" +
                "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" d=\"m8.25 4.5 7.5 7.5-7.5 7.5\"/></svg></li>";

            if (page == null)
            {
                // Nothing mapped: keep the old trail, dashboard then the page name. Customer and
                // Driver pages land here, and their own dashboard is already the first crumb, so it
                // must not trail itself the way the mapped branch guards against.
                bool isDashboard = file.Equals("Dashboard", StringComparison.OrdinalIgnoreCase);
                if (!isDashboard)
                    sb.Append(CrumbLink("Dashboard", _dashUrl, true)).Append(separator);
                sb.Append("<li class=\"text-sm font-semibold text-gray-900\">")
                  .Append(System.Web.HttpUtility.HtmlEncode(SideLabel(path, file) ?? Prettify(file)))
                  .Append("</li>");
            }
            else if (string.IsNullOrEmpty(page.Parent))
            {
                // A list page. The dashboard is its own parent, so it must not trail itself.
                if (!string.Equals(page.Sidebar, "Dashboard", StringComparison.OrdinalIgnoreCase))
                    sb.Append(CrumbLink("Dashboard", _dashUrl, true)).Append(separator);
                sb.Append("<li class=\"text-sm font-semibold text-gray-900\">")
                  .Append(System.Web.HttpUtility.HtmlEncode(page.Label)).Append("</li>");
            }
            else
            {
                AdminPage parent;
                AdminPages.TryGetValue(page.Parent, out parent);

                sb.Append(CrumbLink("Dashboard", _dashUrl, true)).Append(separator);
                sb.Append(CrumbLink(parent != null ? parent.Label : Prettify(page.Parent),
                                    ResolveUrl("~/Admin/" + page.Parent + ".aspx"), false))
                  .Append(separator);

                // A page that edits one specific row can drop a link to that row in between, so it is
                // not stranded with only the list to go back to. Absent the id in the query string
                // there is nothing to link to, so the level is left out.
                string recordId = RecordId(page);
                if (recordId != null)
                {
                    AdminPage record;
                    AdminPages.TryGetValue(page.Record, out record);
                    sb.Append(CrumbLink(record != null ? record.Label : Prettify(page.Record),
                                        ResolveUrl("~/Admin/" + page.Record + ".aspx")
                                        + "?id=" + System.Web.HttpUtility.UrlEncode(recordId), false))
                      .Append(separator);
                }

                sb.Append("<li class=\"text-sm font-semibold text-gray-900\">")
                  .Append(System.Web.HttpUtility.HtmlEncode(page.Label)).Append("</li>");
            }

            sb.Append("</ol>");
            litBreadcrumb.Text = sb.ToString();
        }

        /// <summary>
        /// One crumb. Only the Dashboard carries the house glyph: repeating it on every level made
        /// the trail read as a row of identical icons, so the rest are plain text.
        /// </summary>
        private static string CrumbLink(string text, string url, bool withIcon)
        {
            string icon = withIcon
                ? "<svg xmlns=\"http://www.w3.org/2000/svg\" fill=\"none\" viewBox=\"0 0 24 24\" stroke-width=\"1.5\" "
                  + "stroke=\"currentColor\" class=\"size-4 inline-block align-middle\">"
                  + "<path stroke-linecap=\"round\" stroke-linejoin=\"round\" "
                  + "d=\"m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25\"/>"
                  + "</svg>"
                : "";

            return "<li><a href=\"" + System.Web.HttpUtility.HtmlAttributeEncode(url ?? "")
                 + "\" class=\"flex items-center gap-1.5 text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors\">"
                 + icon + System.Web.HttpUtility.HtmlEncode(text) + "</a></li>";
        }

        private void SetupNavigation()
        {
            bool loggedIn = Helper.AuthHelper.IsLoggedIn();
            string role = Helper.AuthHelper.GetRole();
            string email = Helper.AuthHelper.GetEmail();

            string fileName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);
            bool isPublicPage = PublicPages.Contains(fileName);

            pnlSidebar.Visible = !isPublicPage && loggedIn;
            pnlAppHeader.Visible = !isPublicPage && loggedIn;
            // The trail belongs to the same shell as the sidebar, so it follows the same rule. A
            // public page, or a logged out visitor on the login and register pages, has no dashboard
            // to point the first crumb at.
            pnlBreadcrumb.Visible = !isPublicPage && loggedIn;
            pnlPublicHeader.Visible = isPublicPage || !loggedIn;
            pnlFooter.Visible = isPublicPage || !loggedIn;
            lnkLogin.Visible = !loggedIn;
            lnkRegister.Visible = !loggedIn;
            lnkMobileLogin.Visible = !loggedIn;
            lnkPublicDashboard.Visible = loggedIn;
            lnkPublicLogout.Visible = loggedIn;
            lnkMobileLogout.Visible = loggedIn;
            lnkLogout.Visible = loggedIn && !isPublicPage;

            // Bound on every request, public or not, so the header is already populated
            // if a logged in visitor lands on a marketing page.
            List<PublicNavLink> publicNav = new List<PublicNavLink>
            {
                new PublicNavLink { Url = ResolveUrl("~/Default.aspx"),  Text = "Home" },
                new PublicNavLink { Url = ResolveUrl("~/Services.aspx"), Text = "Services" },
                new PublicNavLink { Url = ResolveUrl("~/FAQs.aspx"),     Text = "FAQs" },
                new PublicNavLink { Url = ResolveUrl("~/AboutUs.aspx"),   Text = "About" },
                new PublicNavLink { Url = ResolveUrl("~/ContactUs.aspx"), Text = "Contact" }
            };
            rptPublicNav.DataSource = publicNav;
            rptPublicNav.DataBind();
            rptPublicMobileNav.DataSource = publicNav;
            rptPublicMobileNav.DataBind();

            if (isPublicPage)
            {
                appShell.Attributes["class"] = "flex flex-col min-h-screen";
                mainContentArea.Attributes["class"] = "flex-1";
            }
            else if (loggedIn)
            {
                appShell.Attributes["class"] = "h-screen overflow-hidden flex flex-col";
                mainContentArea.Attributes["class"] = "p-6 flex-1 overflow-y-auto";
            }
            else
            {
                appShell.Attributes["class"] = "flex flex-col min-h-screen";
                mainContentArea.Attributes["class"] = "flex-1";
            }

            if (!loggedIn)
                return;

            BuildUserInfo(role, email, Helper.AuthHelper.GetAccountId());

            string dashUrl = "";
            switch (role)
            {
                case "Admin":
                    dashUrl = ResolveUrl("~/Admin/Dashboard.aspx");
                    litSidebarTitle.Text = "Admin Panel";
                    _pendingBadge = Helper.DBHelper.ExecuteScalar(
                        "SELECT COUNT(*) FROM Drivers WHERE KYCStatus = 'Pending'").ToString();
                    _badgeFile = "DriverManagement.aspx";
                    SetupSidebar(new List<SidebarLink>
                    {
                        new SidebarLink { Url = ResolveUrl("~/Admin/Dashboard.aspx"), Icon = "chart-line", Text = "Dashboard" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/DriverManagement.aspx"), Icon = "truck", Text = "Drivers & KYC" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/CustomerManagement.aspx"), Icon = "users", Text = "Customers" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/TripManagement.aspx"), Icon = "map", Text = "Trips" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/FareRateManagement.aspx"), Icon = "coin", Text = "Fare Rates" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/PackageManagement.aspx"), Icon = "star", Text = "Packages" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/HotelManagement.aspx"), Icon = "home", Text = "Hotels" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/ActivityLogs.aspx"), Icon = "history", Text = "Activity Logs" },
                        new SidebarLink { Url = ResolveUrl("~/Admin/Profile.aspx"), Icon = "user-cog", Text = "Profile" }
                    });
                    break;
                case "Driver":
                    dashUrl = ResolveUrl("~/Driver/Dashboard.aspx");
                    litSidebarTitle.Text = "Driver Panel";
                    SetupSidebar(new List<SidebarLink>
                    {
                        new SidebarLink { Url = ResolveUrl("~/Driver/Dashboard.aspx"), Icon = "chart-line", Text = "Dashboard" },
                        new SidebarLink { Url = ResolveUrl("~/Driver/TripRequests.aspx"), Icon = "bell", Text = "Trip Requests" },
                        new SidebarLink { Url = ResolveUrl("~/Driver/ActiveTrip.aspx"), Icon = "map", Text = "Active Trip" },
                        new SidebarLink { Url = ResolveUrl("~/Driver/TripHistory.aspx"), Icon = "history", Text = "Trip History" },
                        new SidebarLink { Url = ResolveUrl("~/Driver/Profile.aspx"), Icon = "user-cog", Text = "Profile" }
                    });
                    break;
                case "Customer":
                    dashUrl = ResolveUrl("~/Customer/Dashboard.aspx");
                    litSidebarTitle.Text = "Customer";
                    SetupSidebar(new List<SidebarLink>
                    {
                        new SidebarLink { Url = ResolveUrl("~/Customer/Dashboard.aspx"), Icon = "home", Text = "Dashboard" },
                        new SidebarLink { Url = ResolveUrl("~/Customer/BookTrip.aspx"), Icon = "gps", Text = "Book a Trip" },
                        new SidebarLink { Url = ResolveUrl("~/Customer/ActiveTrip.aspx"), Icon = "map", Text = "Active Trip" },
                        new SidebarLink { Url = ResolveUrl("~/Customer/TripHistory.aspx"), Icon = "history", Text = "Past Trips" },
                        new SidebarLink { Url = ResolveUrl("~/Customer/Profile.aspx"), Icon = "user-cog", Text = "Profile" }
                    });
                    break;
            }
            _dashUrl = dashUrl;
            if (lnkPublicDashboard != null) lnkPublicDashboard.NavigateUrl = dashUrl;
        }

        public void RefreshUserInfo()
        {
            if (litUserInfo == null || !Helper.AuthHelper.IsLoggedIn()) return;
            BuildUserInfo(Helper.AuthHelper.GetRole(), Helper.AuthHelper.GetEmail(), Helper.AuthHelper.GetAccountId());
        }

        private void BuildUserInfo(string role, string email, int accountId)
        {
            string profileName = email;
            string profileImgUrl = "";
            string initials = GetInitial(email);

            string table = role == "Customer" ? "Customers"
                : role == "Driver" ? "Drivers"
                : "Admins";
            string nameCol = role == "Customer" ? "FullName"
                : role == "Driver" ? "FullName"
                : "FullName";
            string photoCol = role == "Customer" ? "ProfilePhotoUrl"
                : "ProfilePhotoUrl";
            string idCol = role + "ID";

            try
            {
                DataTable prof = Helper.DBHelper.ExecuteQuery(
                    "SELECT " + nameCol + ", " + photoCol + " FROM " + table + " WHERE " + idCol + " = @Id",
                    new SqlParameter("@Id", accountId));
                if (prof.Rows.Count > 0)
                {
                    if (!string.IsNullOrWhiteSpace(prof.Rows[0][0].ToString()))
                        profileName = prof.Rows[0][0].ToString();
                    object photo = prof.Rows[0][1];
                    if (photo != DBNull.Value && !string.IsNullOrWhiteSpace(photo.ToString()))
                        profileImgUrl = "~/" + photo.ToString();
                }
                initials = GetInitial(profileName);
            }
            catch { }

            string avatarHtml;
            if (!string.IsNullOrEmpty(profileImgUrl))
            {
                avatarHtml = "<img src='" + System.Net.WebUtility.HtmlEncode(ResolveUrl(profileImgUrl)) + "' alt='Profile' class='profile-avatar' />";
            }
            else
            {
                string avatarBg = role == "Admin" ? "bg-blue-100 text-blue-600" : role == "Driver" ? "bg-amber-100 text-amber-600" : "bg-emerald-100 text-emerald-600";
                avatarHtml = "<span class='profile-avatar " + avatarBg + " flex items-center justify-center text-sm font-bold'>" + System.Net.WebUtility.HtmlEncode(initials) + "</span>";
            }

            litUserInfo.Text = "<div class='header-profile-container'>"
                + avatarHtml
                + "<div class='profile-info'>"
                + "<span class='profile-name'>" + System.Net.WebUtility.HtmlEncode(profileName) + "</span>"
                + "<span class='profile-email'>" + System.Net.WebUtility.HtmlEncode(email) + "</span>"
                + "</div></div>";
        }

        private string GetInitial(string value)
        {
            if (string.IsNullOrEmpty(value)) return "?";
            string trimmed = value.Trim();
            return trimmed.Length == 0 ? "?" : trimmed.Substring(0, 1).ToUpperInvariant();
        }

        private void SetupSidebar(List<SidebarLink> links)
        {
            rptSidebarLinks.DataSource = links;
            rptSidebarLinks.DataBind();
        }

        protected void rptSidebarLinks_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var link = (System.Web.UI.HtmlControls.HtmlAnchor)e.Item.FindControl("navLink");
            if (link == null) return;

            var data = e.Item.DataItem as SidebarLink;

            string currentPath = Request.Url.AbsolutePath;
            bool isActive = currentPath.Equals(link.HRef, StringComparison.OrdinalIgnoreCase);
            if (!isActive)
            {
                string linkBase = System.IO.Path.GetFileNameWithoutExtension(link.HRef);
                string owner = SidebarOwnerFor(currentPath,
                    System.IO.Path.GetFileNameWithoutExtension(currentPath));
                isActive = !string.IsNullOrEmpty(owner)
                    && string.Equals(owner, linkBase, StringComparison.OrdinalIgnoreCase);
            }
            link.Attributes["class"] = "nav-item flex items-center gap-3 py-2.5 px-4 text-[13px] rounded-lg transition-colors duration-150 "
                + (isActive ? "bg-blue-600 text-white font-semibold"
                            : "font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-900");
            link.Attributes["title"] = data != null ? data.Text : "";

            var badge = (System.Web.UI.HtmlControls.HtmlGenericControl)e.Item.FindControl("navBadge");
            if (badge != null)
            {
                string fileName = System.IO.Path.GetFileName(link.HRef);
                bool hasCount = !string.IsNullOrEmpty(_pendingBadge) && _pendingBadge != "0";
                badge.Visible = hasCount && !string.IsNullOrEmpty(_badgeFile)
                    && fileName.Equals(_badgeFile, StringComparison.OrdinalIgnoreCase);
                badge.InnerText = _pendingBadge;
            }
        }

        /// <summary>One link in the public header, shown in both the desktop row and the mobile menu.</summary>
        public class PublicNavLink
        {
            public string Url { get; set; }
            public string Text { get; set; }
        }

        /// <summary>
        /// Marks the public header link for the page being viewed. This is decided here
        /// rather than in script because the server always knows the requested path,
        /// while the browser only sees it after the fact and gets it wrong at a
        /// directory root.
        /// </summary>
        protected void rptPublicNav_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            // The two navs share this handler, so the anchor is named differently in each
            // template. e.Item is the naming container, so each repeater's control is
            // found on its own and the two cannot collide.
            var link = e.Item.FindControl("publicNavLink") as System.Web.UI.HtmlControls.HtmlAnchor
                       ?? e.Item.FindControl("publicMobileNavLink") as System.Web.UI.HtmlControls.HtmlAnchor;
            if (link == null) return;

            var data = e.Item.DataItem as PublicNavLink;
            if (data == null) return;

            bool isActive = IsCurrentPublicPage(data.Url);
            link.Attributes["class"] = "px-3 py-2 rounded-md transition-colors "
                + (isActive ? "tw-nav-active font-semibold"
                            : "text-gray-700 hover:text-blue-600");
            if (isActive)
            {
                link.Attributes["aria-current"] = "page";
                link.Attributes["title"] = "Current page";
            }
            else
            {
                link.Attributes.Remove("aria-current");
                link.Attributes.Remove("title");
            }
        }

        /// <summary>
        /// True when <paramref name="url"/> is the document being served. A request for
        /// the site root arrives with no file name at all, because Default.aspx is a
        /// default document rather than part of the path, so that counts as Home. The
        /// same goes for a virtual directory reached without its closing slash, which
        /// IIS normally redirects but need not be relied on. Both cases are recognised
        /// by the last segment being empty or carrying no extension; a real page such as
        /// Login.aspx always has one, so it correctly matches nothing.
        /// </summary>
        private bool IsCurrentPublicPage(string url)
        {
            if (string.IsNullOrEmpty(url)) return false;

            string current = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
            string target = System.IO.Path.GetFileName(url);

            if (string.Equals(current, target, StringComparison.OrdinalIgnoreCase)) return true;

            if (current.Length == 0 || current.IndexOf('.') === -1)
            {
                return string.Equals(target, "Default.aspx", StringComparison.OrdinalIgnoreCase);
            }

            return false;
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Helper.AuthHelper.Logout();
            Response.Redirect("~/Login.aspx");
        }

        public class SidebarLink
        {
            public string Url { get; set; }
            public string Icon { get; set; }
            public string Text { get; set; }
        }
    }
}