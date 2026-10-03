<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverManagement.aspx.cs" Inherits="TripWay.Admin.DriverManagementPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Driver Management</h1>
                    <p class="text-sm text-gray-400">Review KYC, verify documents and manage driver fleet.</p>
                </div>
                <a href="CreateDriver.aspx" class="tw-btn-primary !py-2 !px-3 !text-sm inline-flex items-center gap-1.5">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15"/></svg>
                    Add Driver
                </a>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="tw-input pl-9" placeholder="Search name, phone or email…" OnTextChanged="txtSearch_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
                    <asp:DropDownList ID="ddlKyc" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlKyc_SelectedIndexChanged" CssClass="tw-input w-auto">
                        <asp:ListItem Text="All KYC" Value="" />
                        <asp:ListItem Text="Pending" Value="Pending" />
                        <asp:ListItem Text="Approved" Value="Approved" />
                        <asp:ListItem Text="Rejected" Value="Rejected" />
                    </asp:DropDownList>
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
        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
            <asp:Repeater ID="rptDrivers" runat="server" OnItemCommand="rptDrivers_ItemCommand"
                OnItemDataBound="rptDrivers_ItemDataBound">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[1000px]">
                        <thead>
                            <tr>
                                <th class="w-14">No</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortnameA" runat="server" CssClass="tw-sort-arrow" CommandArgument="name" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortnameD" runat="server" CssClass="tw-sort-arrow" CommandArgument="name" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Driver</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortvehicleA" runat="server" CssClass="tw-sort-arrow" CommandArgument="vehicle" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortvehicleD" runat="server" CssClass="tw-sort-arrow" CommandArgument="vehicle" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Vehicle</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSorttripsA" runat="server" CssClass="tw-sort-arrow" CommandArgument="trips" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSorttripsD" runat="server" CssClass="tw-sort-arrow" CommandArgument="trips" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Trips</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortkycA" runat="server" CssClass="tw-sort-arrow" CommandArgument="kyc" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortkycD" runat="server" CssClass="tw-sort-arrow" CommandArgument="kyc" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>KYC</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortratingA" runat="server" CssClass="tw-sort-arrow" CommandArgument="rating" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortratingD" runat="server" CssClass="tw-sort-arrow" CommandArgument="rating" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Rating</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortonlineA" runat="server" CssClass="tw-sort-arrow" CommandArgument="online" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortonlineD" runat="server" CssClass="tw-sort-arrow" CommandArgument="online" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Online</span>
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
                            <div class="flex items-center gap-3">
                                <div style='<%# HasPhoto(Eval("ProfilePhotoUrl")) ? "" : "display:none" %>'><asp:Image runat="server" ImageUrl='<%# DriverPhotoSrc(Eval("ProfilePhotoUrl")) %>' AlternateText="Driver photo" CssClass="size-10 rounded-full object-cover shrink-0 ring-2 ring-gray-100" /></div><div style='<%# HasPhoto(Eval("ProfilePhotoUrl")) ? "display:none" : "" %>'><span class="tw-avatar tw-avatar-amber"><%# GetInitial(Eval("FullName").ToString()) %></span></div>
                                <div class="min-w-0">
                                    <div class="font-semibold text-gray-900 text-sm truncate"><%# Eval("FullName") %></div>
                                    <div class="text-xs text-gray-400"><%# Eval("PhoneNumber") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="font-semibold text-gray-900 text-sm truncate"><%# Eval("VehicleTypeName") %></div>
                            <div class="text-xs text-gray-400"><%# String.IsNullOrEmpty(Convert.ToString(Eval("VehiclePlateNumber"))) ? "-" : Eval("VehiclePlateNumber") %></div>
                        </td>
                        <td><%# Eval("TripCount") %></td>
                        <td>
                            <%-- The row editor is a plain drop-down list, sized like the "Show" picker above it rather than
                                 like a text field: it only ever holds one short word, so a full-height
                                 input box is wasted space on every row. The padding and the rounding
                                 are trimmed here, so the important utilities have to beat .tw-input's
                                 fixed height and 0.5rem corners. KYCStatus is the one field behind
                                 this, and choosing a value saves it at once. --%>
                            <asp:DropDownList ID="ddlRowKyc" runat="server" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlRowKyc_SelectedIndexChanged"
                                CssClass='<%# "tw-input w-auto !h-8 !px-2.5 !rounded-full " + GetStatusCss(Convert.ToString(Eval("KYCStatus"))) %>'
                                CausesValidation="false">
                                <asp:ListItem Text="Pending" Value="Pending" />
                                <asp:ListItem Text="Approved" Value="Approved" />
                                <asp:ListItem Text="Rejected" Value="Rejected" />
                            </asp:DropDownList>
                        </td>
                        <td><%# (Eval("RatingValue") == null || String.IsNullOrEmpty(Eval("RatingValue").ToString())) ? "-" : Eval("RatingValue", "{0:0.0}") %></td>
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# (Convert.ToBoolean(Eval("IsOnline")) ? "bg-emerald-50 text-emerald-700" : "bg-gray-100 text-gray-500") %>"><%# (Convert.ToBoolean(Eval("IsOnline")) ? "Online" : "Offline") %></span></td>
                        <td class="!text-center"><div class="inline-flex items-center justify-center gap-1.5"><a href='DriverDetail.aspx?id=<%# Eval("DriverID") %>' class="tw-action" title="Detail">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639-1.39 4.171-5.325 7.183-9.963 7.183-4.639 0-8.574-3.012-9.963-7.183Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                            </a>
                            <a href='DriverEdit.aspx?id=<%# Eval("DriverID") %>' class="tw-action" title="Edit">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z"/></svg>
                            </a>
                            <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("DriverID") %>' ToolTip="Delete driver" CausesValidation="false"
                                OnClientClick="return confirm('Delete this driver permanently? This cannot be undone.');">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/></svg>
                            </asp:LinkButton></div></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr id="trNoData" runat="server" visible="false">
                            <td colspan="8" class="px-6 py-14 text-center"><p class="text-sm text-gray-400">No data available...</p></td>
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