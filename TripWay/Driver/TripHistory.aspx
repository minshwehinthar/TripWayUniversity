<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripHistory.aspx.cs" Inherits="TripWay.Driver.TripHistoryPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Trip History</h1>
                    <p class="text-sm text-gray-400">Your completed and cancelled trips, ready to review.</p>
                </div>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="tw-input pl-9" placeholder="Search by customer name or trip ID&hellip;" OnTextChanged="txtSearch_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
                    <asp:DropDownList ID="ddlService" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlService_SelectedIndexChanged" CssClass="tw-input w-auto" />
                </div>

                <div class="flex items-center gap-2 text-sm text-gray-600 w-full md:w-auto justify-end">
                    <span class="font-medium">Limit:</span>
                    <asp:DropDownList ID="ddlPerPage" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPerPage_SelectedIndexChanged" CssClass="tw-input w-auto !h-8 !px-2.5 !rounded-lg">
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="25" Value="25" />
                        <asp:ListItem Text="50" Value="50" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>
        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlTable" runat="server" CssClass="bg-white rounded-2xl shadow-sm overflow-x-auto">
            <asp:Repeater ID="rptTrips" runat="server" OnItemCommand="rptTrips_ItemCommand" OnItemDataBound="rptTrips_ItemDataBound">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[1180px]">
                        <thead>
                            <tr>
                                <th class="!w-12 !text-center">No.</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortcustomerA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="customer" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortcustomerD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="customer" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Customer</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortserviceA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="service" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortserviceD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="service" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Service</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortvehicleA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="vehicle" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortvehicleD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="vehicle" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Vehicle</span>
                                    </div>
                                </th>
                                <th>Stops</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortfareA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="fare" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortfareD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="fare" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Fare</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortstatusA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="status" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortstatusD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="status" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Status</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortpaymentA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="payment" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortpaymentD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="payment" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Payment</span>
                                    </div>
                                </th>
                                <th>Rating</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortdateA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="date" OnClick="SortHeaderAsc_Click" ToolTip="Sort oldest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortdateD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="date" OnClick="SortHeaderDesc_Click" ToolTip="Sort newest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Date</span>
                                    </div>
                                </th>
                                <th class="!text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="hover:bg-gray-100 transition-colors">
                        <td class="!text-center"><span class="text-gray-400 text-xs"><%# GetRowNumber(Container.ItemIndex) %></span></td>
                        <td>
                            <div class="flex items-center gap-3">
                                <asp:Panel ID="pnlCustomerPhoto" runat="server" Visible="false"><asp:Image runat="server" ImageUrl='<%# CustomerPhoto(Eval("CustomerPhoto")) %>' CssClass="size-10 rounded-full object-cover bg-white border border-slate-100 shrink-0" /></asp:Panel><asp:Panel ID="pnlCustomerInitials" runat="server"><span class="tw-avatar <%# GetAvatarCss(Eval("CustomerID")) %>"><%# GetInitial(Eval("CustomerName").ToString()) %></span></asp:Panel>
                                <div class="min-w-0">
                                    <div class="font-semibold text-gray-900 text-sm truncate"><%# Server.HtmlEncode(Eval("CustomerName").ToString()) %></div>
                                    <div class="text-xs text-gray-400"><%# Server.HtmlEncode(Eval("CustomerPhone").ToString()) %></div>
                                </div>
                            </div>
                        </td>
                        <td><%# Server.HtmlEncode(Eval("ServiceName").ToString()) %></td>
                        <td><%# Server.HtmlEncode(Eval("VehicleName").ToString()) %></td>
                        <td class="text-center"><span class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold <%# (int)Eval("StopsCount") > 0 ? "bg-blue-50 text-blue-600" : "bg-gray-100 text-gray-400" %>"><%# ((int)Eval("StopsCount")) > 0 ? Eval("StopsCount") + " pts" : "\u2014" %></span></td>
                        <td class="font-semibold text-gray-900 whitespace-nowrap">MMK <%# string.Format("{0:N0}", Eval("Fare")) %></td>
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# GetStatusCss(Eval("Status").ToString()) %>"><%# Server.HtmlEncode(Eval("Status").ToString()) %></span></td>
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# GetStatusCss(Eval("PaymentStatus").ToString()) %>"><%# Server.HtmlEncode(Eval("PaymentStatus").ToString()) %></span></td>
                        <td class="whitespace-nowrap"><asp:Literal ID="litRating" runat="server" /></td>
                        <td class="whitespace-nowrap text-gray-500"><%# FormatTime(Eval("RequestedAt"), "dd MMM yyyy, HH:mm") %></td>
                        <td class="!text-center">
                            <div class="inline-flex items-center justify-center gap-1.5">
                                <asp:LinkButton ID="lbtnView" runat="server" CssClass="tw-action" CommandName="view" CommandArgument='<%# Eval("TripID") %>' ToolTip="View details" CausesValidation="false"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg></asp:LinkButton>
                                <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("TripID") %>' ToolTip="Delete trip" CausesValidation="false"
                                    OnClientClick="return confirm('Delete this trip? This cannot be undone.');">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/></svg>
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </asp:Panel>

        <%-- Empty state. The driver is not the one who books, so the call to action points at
             the request queue rather than at a booking page, and the wording changes when the
             list is empty only because a filter is on. --%>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm px-6 py-14">
            <div class="text-center">
                <span class="inline-flex items-center justify-center size-16 rounded-full bg-blue-50 text-blue-500 mb-4">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 13.5h3.86a2.25 2.25 0 0 1 2.012 1.244l.256.512a2.25 2.25 0 0 0 2.013 1.244h3.218a2.25 2.25 0 0 0 2.013-1.244l.256-.512a2.25 2.25 0 0 1 2.012-1.244h3.859m-19.5.338V18a2.25 2.25 0 0 0 2.25 2.25h15A2.25 2.25 0 0 0 21.75 18v-4.162c0-.224-.034-.447-.1-.661L19.24 5.338a2.25 2.25 0 0 0-2.15-1.588H6.911a2.25 2.25 0 0 0-2.15 1.588L2.35 13.177a2.25 2.25 0 0 0-.1.661Z"/></svg>
                </span>
                <h3 class="text-lg font-bold text-gray-900"><asp:Literal ID="litEmptyTitle" runat="server" /></h3>
                <p class="text-sm text-gray-400 mt-2 max-w-md mx-auto leading-relaxed"><asp:Literal ID="litEmptyBody" runat="server" /></p>
                <div class="mt-6 flex flex-wrap items-center justify-center gap-2.5">
                    <a href="<%= ResolveUrl("~/Driver/TripRequests.aspx") %>" class="tw-btn-primary">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0"/></svg>
                        Browse Trip Requests
                    </a>
                    <asp:LinkButton ID="btnClearFilters" runat="server" OnClick="btnClearFilters_Click" CausesValidation="false" CssClass="tw-btn-secondary">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z"/></svg>
                        Clear Filters
                    </asp:LinkButton>
                    <a href="<%= ResolveUrl("~/Driver/Dashboard.aspx") %>" class="tw-pager-btn">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75"/></svg>
                        Back to Dashboard
                    </a>
                </div>
            </div>
        </asp:Panel>

        <div class="tw-pager">
            <span class="tw-pager-info">
                <asp:Literal ID="litPageInfo" runat="server" />
            </span>
            <div class="flex items-center gap-1.5">
                <asp:LinkButton ID="btnPrev" runat="server" OnClick="btnPrev_Click" CausesValidation="false" CssClass="tw-pager-btn" Enabled="false">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 19.5 8.25 12l7.5-7.5"/></svg>Prev
                </asp:LinkButton>
                <asp:Repeater ID="rptPaging" runat="server">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnPage" runat="server" Text='<%# Eval("Page") %>'
                            CommandArgument='<%# Eval("Page") %>' OnClick="PageNumber_Click" CausesValidation="false"
                            CssClass='<%# GetPageButtonCss(Eval("Page"), CurrentPage) %>' />
                    </ItemTemplate>
                </asp:Repeater>
                <asp:LinkButton ID="btnNext" runat="server" OnClick="btnNext_Click" CausesValidation="false" CssClass="tw-pager-btn" Enabled="false">
                    Next<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg>
                </asp:LinkButton>
            </div>
        </div>
        <script>initLiveSearch('<%= txtSearch.ClientID %>', 500, '<%= txtSearch.UniqueID %>');</script>
    </div>
</asp:Content>
