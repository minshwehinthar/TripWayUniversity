<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerManagement.aspx.cs" Inherits="TripWay.Admin.CustomerManagementPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Customer Management</h1>
                    <p class="text-sm text-gray-400">Registered riders across the platform.</p>
                </div>
                <a href="CreateCustomer.aspx" class="tw-btn-primary !py-2 !px-3 !text-sm inline-flex items-center gap-1.5">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15"/></svg>
                    Add Customer
                </a>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="tw-input pl-9" placeholder="Search name, phone or email…" OnTextChanged="txtSearch_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
                    <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged" CssClass="tw-input w-auto">
                        <asp:ListItem Text="All Status" Value="" />
                        <asp:ListItem Text="Active" Value="Active" />
                        <asp:ListItem Text="Pending" Value="Pending" />
                        <asp:ListItem Text="Approved" Value="Approved" />
                        <asp:ListItem Text="Rejected" Value="Rejected" />
                        <asp:ListItem Text="Suspended" Value="Suspended" />
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
            <asp:Repeater ID="rptCustomers" runat="server" OnItemCommand="rptCustomers_ItemCommand"
                OnItemDataBound="rptCustomers_ItemDataBound">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[900px]">
                        <thead>
                            <tr>
                                <th class="w-14">No</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortnameA" runat="server" CssClass="tw-sort-arrow" CommandArgument="name" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortnameD" runat="server" CssClass="tw-sort-arrow" CommandArgument="name" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Customer</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortphoneA" runat="server" CssClass="tw-sort-arrow" CommandArgument="phone" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortphoneD" runat="server" CssClass="tw-sort-arrow" CommandArgument="phone" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Phone</span>
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
                                            <asp:LinkButton ID="lnkSortspentA" runat="server" CssClass="tw-sort-arrow" CommandArgument="spent" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortspentD" runat="server" CssClass="tw-sort-arrow" CommandArgument="spent" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Total Spent</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortjoinedA" runat="server" CssClass="tw-sort-arrow" CommandArgument="joined" OnClick="SortHeaderAsc_Click" ToolTip="Sort oldest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortjoinedD" runat="server" CssClass="tw-sort-arrow" CommandArgument="joined" OnClick="SortHeaderDesc_Click" ToolTip="Sort newest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Joined</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortstatusA" runat="server" CssClass="tw-sort-arrow" CommandArgument="status" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortstatusD" runat="server" CssClass="tw-sort-arrow" CommandArgument="status" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
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
                    <tr class="hover:bg-slate-50 transition-colors">
                        <td class="!text-center"><span class="text-gray-500 text-xs font-semibold tabular-nums"><%# GetRowNumber(Container.ItemIndex) %></span></td>
                        <td>
                            <div class="flex items-center gap-3">
                                <div style='<%# HasPhoto(Eval("CustomerPhoto")) ? "" : "display:none" %>'><asp:Image runat="server" ImageUrl='<%# PhotoSrc(Eval("CustomerPhoto")) %>' AlternateText="Customer photo" CssClass="size-10 rounded-full object-cover shrink-0 ring-2 ring-gray-100" /></div><div style='<%# HasPhoto(Eval("CustomerPhoto")) ? "display:none" : "" %>'><span class="tw-avatar tw-avatar-green"><%# GetInitial(Eval("FullName").ToString()) %></span></div>
                                <div class="min-w-0">
                                    <div class="font-semibold text-gray-900 text-sm truncate"><%# Eval("FullName") %></div>
                                    <div class="text-xs text-gray-400 truncate"><%# Eval("Email") %></div>
                                </div>
                            </div>
                        </td>
                        <td class="whitespace-nowrap"><%# String.IsNullOrEmpty(Convert.ToString(Eval("PhoneNumber"))) ? "—" : Eval("PhoneNumber") %></td>
                        <td><%# Eval("TripCount") %></td>
                        <td>MMK <%# string.Format("{0:N0}", Eval("TotalSpent")) %></td>
                        <td class="whitespace-nowrap"><%# FormatTime(Eval("CreatedAt"), "dd MMM yyyy") %></td>
                        <td>
                            <%-- The row editor is a plain drop-down list, sized like the "Show" picker above it rather than
                                 like a text field: it only ever holds one short word, so a full-height
                                 input box is wasted space on every row. The padding and the rounding
                                 are trimmed here, so the important utilities have to beat .tw-input's
                                 fixed height and 0.5rem corners. Choosing a value saves it at once. --%>
                            <asp:DropDownList ID="ddlRowStatus" runat="server" AutoPostBack="true"
                                OnSelectedIndexChanged="ddlRowStatus_SelectedIndexChanged"
                                CssClass='<%# "tw-input w-auto !h-8 !px-2.5 !rounded-full " + GetStatusCss(Convert.ToString(Eval("Status"))) %>'
                                CausesValidation="false">
                                <asp:ListItem Text="Active" Value="Active" />
                                <asp:ListItem Text="Pending" Value="Pending" />
                                <asp:ListItem Text="Approved" Value="Approved" />
                                <asp:ListItem Text="Rejected" Value="Rejected" />
                                <asp:ListItem Text="Suspended" Value="Suspended" />
                            </asp:DropDownList>
                        </td>
                        <td class="!text-center"><div class="inline-flex items-center justify-center gap-1.5">
                            <a href='CustomerDetail.aspx?id=<%# Eval("CustomerID") %>' class="tw-action" title="View details">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                            </a>
                            <a href='CustomerEdit.aspx?id=<%# Eval("CustomerID") %>' class="tw-action" title="Edit">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z"/></svg>
                            </a>
                            <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("CustomerID") %>' ToolTip="Delete customer" CausesValidation="false"
                                OnClientClick="return confirm('Delete this customer permanently? This cannot be undone.');">
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