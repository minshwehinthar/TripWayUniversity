<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverDetail.aspx.cs" Inherits="TripWay.Admin.DriverDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Driver Profile</h2>
            <p class="text-sm text-gray-500">Everything on record for this driver.</p>
        </div>

        <asp:Panel ID="pnlError" runat="server" data-tw-toast="1" Visible="false"
            CssClass="p-5 rounded-lg bg-red-50 border border-red-200 text-red-700 text-sm flex flex-wrap items-center justify-between gap-3">
            <span><asp:Label ID="lblError" runat="server" /></span>
            <a href="DriverManagement.aspx" class="tw-btn-outline !h-9 !text-xs">Back to Drivers</a>
        </asp:Panel>

        <asp:Panel ID="pnlDriver" runat="server" Visible="false" CssClass="space-y-6">

            <%-- Identity card: the same card the driver sees on their own profile page, minus
                 the photo picker, because this page only shows what is stored. --%>
            <div class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
                <div class="relative shrink-0">
                    <span data-tw-cover class="relative block size-20">
                        <span id="pnlDriverAvatar" runat="server" class="tw-skeleton tw-skeleton-avatar absolute inset-0 size-20 rounded-2xl"></span>
                        <asp:Image ID="imgDriverPhoto" runat="server" Visible="false" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
                    </span>
                </div>

                <div class="min-w-0 flex-1">
                    <h1 class="text-lg font-bold text-gray-900 truncate"><asp:Label ID="lblName" runat="server" /></h1>
                    <p class="text-sm text-gray-500 truncate"><asp:Label ID="lblEmail" runat="server" /></p>
                    <div class="flex flex-wrap items-center gap-2 mt-1.5">
                        <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Driver</span>
                        <asp:Label ID="lblOnline" runat="server" CssClass="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold" />
                        <asp:Label ID="lblKycState" runat="server" CssClass="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold" />
                        <span class="text-xs text-gray-400">Driver #<asp:Label ID="lblDriverId" runat="server" /> &middot; joined <asp:Label ID="lblJoined" runat="server" /></span>
                    </div>
                </div>
            </div>

            <%-- Personal information: the same fields as DriverEdit.aspx, read only --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
                <p class="text-sm text-gray-500 mb-6">Identity details recorded for this driver.</p>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <asp:Repeater ID="rptIdentity" runat="server">
                        <ItemTemplate>
                            <div>
                                <div class="block text-sm font-bold text-gray-900 mb-1.5"><%# Eval("Label") %></div>
                                <div class="tw-readonly"><%# Eval("Value") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <%-- Vehicle &amp; licensing --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Vehicle &amp; Licensing</h2>
                <p class="text-sm text-gray-500 mb-6">Vehicle reference and the registered KYC documents on file.</p>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <asp:Repeater ID="rptVehicle" runat="server">
                        <ItemTemplate>
                            <div>
                                <div class="block text-sm font-bold text-gray-900 mb-1.5"><%# Eval("Label") %></div>
                                <div class="tw-readonly"><%# Eval("Value") %></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <%-- Plate number (full width) --%>
                    <div class="sm:col-span-2">
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Plate Number</div>
                        <div class="tw-readonly"><asp:Label ID="lblPlate" runat="server" /></div>
                    </div>

                    <%-- Last known location (full width) --%>
                    <div class="sm:col-span-2">
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Last Known Location</div>
                        <div class="tw-readonly"><asp:Label ID="lblLastLocation" runat="server" /></div>
                    </div>
                </div>

                <div class="border-t border-gray-100 pt-5 mt-5">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                        <div>
                            <div class="block text-sm font-bold text-gray-900 mb-1.5">NRC Number</div>
                            <div class="tw-readonly"><asp:Label ID="lblNrc" runat="server" /></div>
                        </div>
                        <div>
                            <div class="block text-sm font-bold text-gray-900 mb-1.5">Driver License Number</div>
                            <div class="tw-readonly"><asp:Label ID="lblLicense" runat="server" /></div>
                        </div>
                    </div>

                    <%-- The four documents, drawn exactly like the slots on DriverEdit.aspx.
                         Read only: no picker, no upload. Click a document to view it full size. --%>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 mt-5">
                        <asp:Repeater ID="rptDocs" runat="server">
                            <ItemTemplate>
                                <div>
                                    <div class="block text-sm font-bold text-gray-900 mb-1.5"><%# Enc(Eval("Label")) %></div>
                                    <button type="button" class="group block w-full cursor-pointer text-left"
                                        <%# DocAttrs(Eval("Src"), Eval("Label"), Eval("FileName"), Eval("IsPdf")) %>>
                                        <span data-tw-cover data-tw-has-doc="1" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40 transition-colors group-hover:border-blue-400">
                                            <span data-fb="1" class="absolute inset-0 items-center justify-center text-blue-300"
                                                style='<%# Convert.ToBoolean(Eval("IsImage")) ? "display:none" : "display:flex" %>'>
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                                </svg>
                                            </span>
                                            <asp:Image runat="server" ImageUrl='<%# Eval("Src") %>'
                                                Visible='<%# Convert.ToBoolean(Eval("IsImage")) %>'
                                                CssClass="absolute inset-0 size-full object-cover"
                                                onerror="this.style.display='none';var f=this.parentNode.querySelector('[data-fb]');if(f)f.style.display='flex';" />
                                        </span>
                                    </button>
                                    <span class="mt-1.5 block truncate text-center text-[11px] text-gray-400"><%# Enc(Eval("FileName")) %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:Panel ID="pnlNoDocs" runat="server" Visible="false" CssClass="sm:col-span-2 lg:col-span-4">
                            <p class="text-sm text-gray-400 text-center py-6">No documents uploaded yet.</p>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
