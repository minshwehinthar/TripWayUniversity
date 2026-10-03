<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActivityLogs.aspx.cs" Inherits="TripWay.Admin.ActivityLogsPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Activity Logs</h1>
                    <p class="text-sm text-gray-400">Audit trail of trips, KYC decisions and platform events.</p>
                </div>
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtDetails" runat="server" CssClass="tw-input pl-9" placeholder="Search details or event…" OnTextChanged="txtDetails_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
                    <asp:DropDownList ID="ddlEvent" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlEvent_SelectedIndexChanged" CssClass="tw-input w-auto">
                        <asp:ListItem Text="All Events" Value="" />
                        <asp:ListItem Text="Trip Events" Value="Trip" />
                    </asp:DropDownList>
                    <%-- Deletes every row the current filter matches, not just the page on screen.
                         The count and the scope are worked out server side so the confirmation can
                         state exactly what is about to go. --%>
                    <asp:Button ID="btnDeleteAll" runat="server" Text="Delete all"
                        OnClick="btnDeleteAll_Click" CausesValidation="false"
                        OnClientClick="var m=this.getAttribute('data-confirm');return confirm(m||'Delete the events in the log? This cannot be undone.');"
                        CssClass="tw-btn-outline tw-btn-soft-danger" />
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
        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
            <asp:Repeater ID="rptLogs" runat="server" OnItemCommand="rptLogs_ItemCommand">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[1000px]">
                        <thead>
                            <tr>
                                <th class="w-14">No</th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSorteventA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="event" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSorteventD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="event" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Event</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortdetailsA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="details" OnClick="SortHeaderAsc_Click" ToolTip="Sort A to Z"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortdetailsD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="details" OnClick="SortHeaderDesc_Click" ToolTip="Sort Z to A"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Details</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortwhenA" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="when" OnClick="SortHeaderAsc_Click" ToolTip="Sort oldest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortwhenD" runat="server" CssClass="tw-sort-arrow" UseSubmitBehavior="false" CommandArgument="when" OnClick="SortHeaderDesc_Click" ToolTip="Sort newest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Date</span>
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
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# GetStatusCss(Eval("EventType").ToString()) %>"><%# Eval("EventType") %></span></td>
                        <td class="text-gray-600 text-sm"><%# Eval("Details") %></td>
                        <td class="!text-center"><span class="text-gray-400 text-xs whitespace-nowrap"><%# FormatTime(Eval("RecordedAt"), "dd MMM yyyy, HH:mm:ss") %></span></td>
                        <td class="!text-center"><div class="inline-flex items-center justify-center gap-1.5"><asp:LinkButton ID="lbtnView" runat="server" CssClass="tw-action" CommandName="view" CommandArgument='<%# Eval("TripID") %>'
                                Visible='<%# Eval("TripID") != System.DBNull.Value %>' ToolTip="View trip" CausesValidation="false">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                            </asp:LinkButton>
                            <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("LogID") %>'
                                ToolTip="Delete entry" OnClientClick="return confirm('Delete this log entry?');" CausesValidation="false">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.668 48.668 0 0 0-7.5 0"/></svg>
                            </asp:LinkButton></div></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr id="trNoData" runat="server" visible="false">
                            <td colspan="5" class="px-6 py-14 text-center"><p class="text-sm text-gray-400">No data available...</p></td>
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
        <script>initLiveSearch('<%= txtDetails.ClientID %>', 500, '<%= txtDetails.UniqueID %>');</script>
    </div>
</asp:Content>