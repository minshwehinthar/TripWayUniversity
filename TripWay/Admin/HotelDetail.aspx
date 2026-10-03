<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HotelDetail.aspx.cs" Inherits="TripWay.Admin.HotelDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-3xl space-y-6">

        <asp:Panel ID="pnlMissing" runat="server" Visible="false" CssClass="p-5 rounded-lg bg-amber-50 border border-amber-200 text-amber-800 text-sm flex flex-wrap items-center justify-between gap-3">
            <span>This hotel no longer exists.</span>
            <a href="HotelManagement.aspx" class="tw-btn-outline">Back to Hotels</a>
        </asp:Panel>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlHotel" runat="server" Visible="false" CssClass="space-y-6">
            <%-- Identity card: Edit is the only action on this page. Hiding a hotel from the
                 booking page is the Active checkbox on the edit form, and deleting one is the
                 delete action in the hotel list, so nothing is lost by dropping both here. --%>
            <div class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
                <div class="relative shrink-0">
                    <span class="relative block size-20">
                        <asp:Panel ID="pnlLogoNone" runat="server" Visible="false">
                            <span class="absolute inset-0 size-20 rounded-2xl bg-emerald-600/10 text-emerald-600 flex items-center justify-center">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21" />
                                </svg>
                            </span>
                        </asp:Panel>
                        <asp:Panel ID="pnlLogo" runat="server" Visible="false">
                            <asp:Image ID="imgLogo" runat="server" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
                        </asp:Panel>
                    </span>
                </div>

                <div class="min-w-0 flex-1">
                    <div class="font-semibold text-gray-900 truncate"><asp:Label ID="lblCardName" runat="server" /></div>
                    <asp:Label ID="lblActive" runat="server" CssClass="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold mt-2" />
                    <div class="flex items-center gap-2.5 mt-3">
                        <a href="HotelEdit.aspx?id=<%= HotelIdParam %>" class="tw-btn-primary inline-flex items-center justify-center gap-1.5 !h-9 !px-3 !text-xs">Edit Hotel</a>
                        <span class="text-xs text-gray-400"><asp:Label ID="lblTrips" runat="server" /></span>
                    </div>
                </div>
            </div>

            <%-- Location --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Location</h2>
                <p class="text-sm text-gray-500 mb-6">The point the customer's trip is routed to on the booking page.</p>
                <div id="mapHotel" class="h-80 w-full rounded-xl border border-gray-200"></div>
                <div class="tw-detail-grid mt-5">
                    <div><div class="tw-detail-label">Latitude</div><div class="tw-detail-value"><asp:Label ID="lblLat" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Longitude</div><div class="tw-detail-value"><asp:Label ID="lblLng" runat="server" /></div></div>
                </div>
            </div>

            <%-- Contact --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Contact</h2>
                <p class="text-sm text-gray-500 mb-6">How a customer reaches this hotel.</p>
                <div class="tw-detail-grid">
                    <div><div class="tw-detail-label">Phone</div><div class="tw-detail-value"><asp:Label ID="lblPhone" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Email</div><div class="tw-detail-value break-all"><asp:Label ID="lblEmail" runat="server" /></div></div>
                </div>
                <div class="pt-4 mt-4 border-t border-gray-100">
                    <div class="tw-detail-label">Address</div>
                    <div class="text-sm text-gray-700 leading-relaxed"><asp:Label ID="lblAddress" runat="server" /></div>
                </div>
            </div>
        </asp:Panel>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/leaflet.js") %>"></script>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/leaflet/leaflet.css") %>" />
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var el = document.getElementById('mapHotel');
            if (!el || typeof L === 'undefined') return;
            if (!<%= HasHotelJs %>) return;   // the "no longer exists" panel is showing instead

            var lat = <%= LatJs %>, lng = <%= LngJs %>;
            var map = L.map(el).setView([lat, lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
            L.marker([lat, lng], {
                icon: L.divIcon({ className: '', html: '<span class="block size-5 rounded-full bg-blue-600 border-2 border-white shadow"></span>' })
            }).addTo(map);
        });
    </script>
</asp:Content>
