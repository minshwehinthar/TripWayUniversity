<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FareRateManagement.aspx.cs" Inherits="TripWay.Admin.FareRateManagementPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">
        <div class="mb-6 flex flex-col gap-4 bg-white rounded-xl">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900 tracking-tight">Fare Rate Management</h1>
                    <p class="text-sm text-gray-400">One rate row per vehicle. There is no base fare: point-to-point is charged per kilometre and hourly hire at a flat rate per hour. Leave a rate blank to switch that service off for the vehicle.</p>
                </div>
                <asp:Button ID="btnNewRate" runat="server" Text="+ New Rate" OnClick="btnNewRate_Click" CausesValidation="false" CssClass="tw-btn-primary" />
            </div>

            <div class="flex flex-col md:flex-row items-center justify-between gap-3 pt-3">
                <div class="flex flex-wrap items-center gap-3 w-full md:w-auto">
                    <div class="relative flex-1 min-w-56 max-w-sm">
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="tw-input pl-9" placeholder="Search vehicle…" OnTextChanged="txtSearch_TextChanged" />
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute left-3 top-3 text-gray-400 inline-block align-middle pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                    </div>
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
        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
            <asp:Repeater ID="rptRates" runat="server" OnItemCommand="rptRates_ItemCommand">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm min-w-[900px]">
                        <thead>
                            <tr>
                                <th class="w-14">No</th>
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
                                            <asp:LinkButton ID="lnkSortperkmA" runat="server" CssClass="tw-sort-arrow" CommandArgument="perkm" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortperkmD" runat="server" CssClass="tw-sort-arrow" CommandArgument="perkm" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Per Km</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSorthourlyA" runat="server" CssClass="tw-sort-arrow" CommandArgument="hourly" OnClick="SortHeaderAsc_Click" ToolTip="Sort low to high"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSorthourlyD" runat="server" CssClass="tw-sort-arrow" CommandArgument="hourly" OnClick="SortHeaderDesc_Click" ToolTip="Sort high to low"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span title="The flat rate charged for every hour of an hourly charter.">Per Hour</span>
                                    </div>
                                </th>
                                <th>
                                    <div class="flex items-center gap-1.5">
                                        <span class="tw-sort">
                                            <asp:LinkButton ID="lnkSortupdatedA" runat="server" CssClass="tw-sort-arrow" CommandArgument="updated" OnClick="SortHeaderAsc_Click" ToolTip="Sort oldest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 15.75 7.5-7.5 7.5 7.5"/></svg></asp:LinkButton>
                                            <asp:LinkButton ID="lnkSortupdatedD" runat="server" CssClass="tw-sort-arrow" CommandArgument="updated" OnClick="SortHeaderDesc_Click" ToolTip="Sort newest first"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" d="m19.5 8.25-7.5 7.5-7.5-7.5"/></svg></asp:LinkButton>
                                        </span>
                                        <span>Updated</span>
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
                        <td class="font-semibold text-gray-900"><%# Eval("VehicleName") %></td>
                        <td><%# Eval("PerKmRate") == System.DBNull.Value ? "—" : "MMK " +  string.Format("{0:N0}", Eval("PerKmRate")) %></td>
                        <td><%# Eval("HourlyRate") == System.DBNull.Value ? "—" : "MMK " +  string.Format("{0:N0}", Eval("HourlyRate")) %></td>
                        <td class="whitespace-nowrap text-gray-400"><%# FormatTime(Eval("UpdatedAt"), "dd MMM yyyy") %></td>
                        <td class="!text-center">
                            <div class="inline-flex items-center justify-center gap-1.5">
                                <asp:LinkButton ID="lbtnView" runat="server" CssClass="tw-action" CommandName="view" CommandArgument='<%# Eval("FareRateID") %>' ToolTip="View details" CausesValidation="false">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                                </asp:LinkButton>
                                <asp:LinkButton ID="lbtnEdit" runat="server" CssClass="tw-action" CommandName="edit" CommandArgument='<%# Eval("FareRateID") %>' ToolTip="Edit rate" CausesValidation="false">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z"/></svg>
                                </asp:LinkButton>
                                <asp:LinkButton ID="lbtnDelete" runat="server" CssClass="tw-action tw-action-danger" CommandName="delete" CommandArgument='<%# Eval("FareRateID") %>' ToolTip="Delete rate" CausesValidation="false"
                                    OnClientClick="return confirm('Delete this fare rate permanently?');">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/></svg>
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr id="trNoData" runat="server" visible="false">
                            <td colspan="6" class="px-6 py-14 text-center"><p class="text-sm text-gray-400">No data available...</p></td>
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

        <%-- Create and edit form. appOpenPanel moves this panel into the shared lightbox, so it
             needs no card of its own -- the modal supplies the background, padding and the
             max-w-xl width. max-w-xl is kept as well so it still reads as a form if the script
             never runs. --%>
        <asp:Panel ID="pnlEditor" runat="server" Visible="false" CssClass="tw-panel-parked">
            <div class="space-y-4 max-w-xl">
                <h2 class="font-bold text-gray-900"><asp:Label ID="lblEditorTitle" runat="server" /></h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div class="flex flex-col gap-1.5 md:col-span-2">
                        <label class="text-sm text-gray-900 font-bold">Vehicle Type</label>
                        <asp:DropDownList ID="ddlVehicle" runat="server" CssClass="tw-input w-full" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Per Km Rate (MMK)<span class="block text-[11px] font-normal text-gray-500">Charged for point-to-point, per kilometre</span></label>
                        <asp:TextBox ID="txtPerKm" runat="server" TextMode="Number" CssClass="tw-input" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Per Hour Rate (MMK)<span class="block text-[11px] font-normal text-gray-500">Charged for hourly hire, for every hour</span></label>
                        <asp:TextBox ID="txtHourly" runat="server" TextMode="Number" CssClass="tw-input" />
                    </div>
                </div>
                <div class="flex items-center gap-2">
                    <asp:Button ID="btnSaveRate" runat="server" Text="Save Rate" OnClick="btnSaveRate_Click" CssClass="tw-btn-primary" />
                    <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" OnClick="btnCancelEdit_Click" CausesValidation="false" CssClass="tw-btn-outline" />
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
