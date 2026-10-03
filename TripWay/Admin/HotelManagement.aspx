<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HotelManagement.aspx.cs" Inherits="TripWay.Admin.HotelManagementPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Hotels</h1>
                    <p class="text-sm text-gray-400">Partner hotels customers can book a transfer to. Only active hotels are offered on the booking page.</p>
                </div>
                <a href="HotelCreate.aspx" class="tw-btn-primary">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
                    New Hotel
                </a>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="tw-input pl-9" placeholder="Search name, address, phone or email…" OnTextChanged="txtSearch_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
                    <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged" CssClass="tw-input w-auto">
                        <asp:ListItem Text="All statuses" Value="all" />
                        <asp:ListItem Text="Active" Value="1" />
                        <asp:ListItem Text="Hidden" Value="0" />
                    </asp:DropDownList>
                </div>

                <div class="flex items-center gap-2 text-sm text-gray-600 w-full md:w-auto justify-end">
                    <span class="font-medium">Limit:</span>
                    <asp:DropDownList ID="ddlPerPage" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPerPage_SelectedIndexChanged" CssClass="tw-input w-auto !h-8 !py-0 !px-2.5 !rounded-lg">
                        <asp:ListItem Text="5" Value="5" />
                        <asp:ListItem Text="10" Value="10" />
                        <asp:ListItem Text="25" Value="25" />
                        <asp:ListItem Text="50" Value="50" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
            <asp:Repeater ID="rptHotels" runat="server" OnItemCommand="rptHotels_ItemCommand">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[1000px]">
                        <thead>
                            <tr>
                                <th class="w-14">No</th>
                                <th class="w-16">Logo</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortnameA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="name" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortnameD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="name" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Hotel</span>
                                    </div>
                                </th>
                                <th>Address</th>
                                <th>Phone</th>
                                <th>Email</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortactiveA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="active" OnClick="SortHeaderAsc_Click" ToolTip="Sort oldest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortactiveD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="active" OnClick="SortHeaderDesc_Click" ToolTip="Sort newest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Status</span>
                                    </div>
                                </th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="hover:bg-gray-100 transition-colors">
                        <td class="!text-center"><span class="text-gray-500 text-xs font-semibold tabular-nums"><%# GetRowNumber(Container.ItemIndex) %></span></td>
                        <td>
                            <asp:PlaceHolder runat="server" Visible='<%# HasLogo(Eval("LogoPhotoUrl")) %>'>
                                <img src='<%# LogoUrl(Eval("LogoPhotoUrl")) %>' alt="" class="tw-avatar tw-avatar-photo object-cover shrink-0" />
                            </asp:PlaceHolder>
                            <asp:PlaceHolder runat="server" Visible='<%# !HasLogo(Eval("LogoPhotoUrl")) %>'>
                                <span class="tw-skeleton tw-skeleton-avatar size-10 shrink-0"></span>
                            </asp:PlaceHolder>
                        </td>
                        <td class="font-semibold text-gray-900 text-sm truncate"><%# Eval("Name") %></td>
                        <td class="text-gray-500 max-w-[220px]"><%# HotelAddress(Eval("Address")) %></td>
                        <td class="whitespace-nowrap"><%# HotelPhone(Eval("Phone")) %></td>
                        <td class="text-gray-500"><%# HotelEmail(Eval("Email")) %></td>
                        <td>
                            <%-- The switch, not the filter dropdown, is what changes a hotel's
                                 visibility: BookTrip only offers hotels with IsActive = 1.
                                 The link button is hidden and the pill is a checkbox driving it,
                                 matching the online-status switch on the driver pages. The
                                 checkbox is plain markup, so its position is decided from the
                                 stored flag on every render rather than remembered. --%>
                            <asp:LinkButton ID="lnkToggleActive" runat="server" CommandName="toggleActive"
                                CommandArgument='<%# Eval("HotelID") %>' CausesValidation="false" Style="display:none" />
                            <label class="inline-flex items-center gap-2.5 cursor-pointer select-none">
                                <input type="checkbox" class="sr-only peer" <%# Convert.ToBoolean(Eval("IsActive")) ? "checked='checked'" : "" %>
                                    onchange='__doPostBack("<%# ((System.Web.UI.WebControls.LinkButton)Container.FindControl("lnkToggleActive")).UniqueID %>","")' />
                                <span class="relative w-9 h-5 rounded-full bg-gray-300 transition-colors duration-150 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-200 peer-checked:bg-emerald-500 after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:size-4 after:rounded-full after:bg-white after:shadow-sm after:transition-transform after:duration-150 peer-checked:after:translate-x-4"></span>
                                <span class="text-sm font-medium text-gray-900"><%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Hidden" %></span>
                            </label>
                        </td>
                        <td class="!text-center">
                            <div class="inline-flex items-center justify-center gap-1.5">
                                <a href='HotelDetail.aspx?id=<%# Eval("HotelID") %>' class="tw-action" title="View details">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639-1.39 4.171-5.325 7.183-9.963 7.183-4.639 0-8.574-3.012-9.963-7.183Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                                </a>
                                <a href='HotelEdit.aspx?id=<%# Eval("HotelID") %>' class="tw-action" title="Edit">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z"/></svg>
                                </a>
                                <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("HotelID") %>' ToolTip="Delete hotel" CausesValidation="false"
                                    OnClientClick="return confirm('Delete this hotel? Bookings that referenced it keep their coordinates.');">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.668 48.668 0 0 0-7.5 0"/></svg>
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr id="trNoData" runat="server" visible="false">
                            <td colspan="8" class="px-6 py-14 text-center"><p class="text-sm text-gray-400">No hotels yet. Add one to offer it as a destination on the booking page.</p></td>
                        </tr>
                        </tbody>
                        </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>

        <div class="tw-pager">
            <span class="tw-pager-info"><asp:Literal ID="litPageInfo" runat="server" /></span>
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
