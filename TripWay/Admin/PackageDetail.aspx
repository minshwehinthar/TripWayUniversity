<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PackageDetail.aspx.cs" Inherits="TripWay.Admin.PackageDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">
        <asp:Panel ID="pnlMissing" runat="server" Visible="false" CssClass="p-5 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm flex flex-wrap items-center justify-between gap-3">
            <span>This package no longer exists.</span>
            <a href="PackageManagement.aspx" class="tw-btn-outline">Back to Packages</a>
        </asp:Panel>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlPackage" runat="server" Visible="false" CssClass="space-y-6">
            <div class="flex flex-wrap items-end justify-between gap-3">
                <div>
                    <h1 class="text-xl font-bold text-gray-900"><asp:Label ID="lblName" runat="server" /></h1>
                    <p class="text-sm text-gray-400">Package #<asp:Label ID="lblPackageId" runat="server" /> · <asp:Label ID="lblSource" runat="server" /> · created <asp:Label ID="lblCreated" runat="server" /></p>
                </div>
                <div class="flex items-center gap-2">
                    <a href='PackageEdit.aspx?id=<%= PackageIdParam %>' class="tw-btn-primary">Edit Package</a>
                </div>
            </div>

            <div class="grid lg:grid-cols-3 gap-6">
                <div class="lg:col-span-2 space-y-5">
                    <div class="bg-white rounded-2xl shadow-sm p-5">
                        <h2 class="font-bold text-gray-900 mb-3">Tour Route</h2>
                        <div id="mapPackage" class="h-80 w-full rounded-xl border border-gray-200"></div>
                    </div>

                    <div class="bg-white rounded-2xl shadow-sm p-5">
                        <h2 class="font-bold text-gray-900 mb-3">Stops</h2>
                        <asp:Panel ID="pnlNoPlaces" runat="server" Visible="false">
                            <p class="text-sm text-gray-400">No stops added yet.</p>
                        </asp:Panel>
                        <div class="space-y-1"><asp:Literal ID="litPlaces" runat="server" /></div>
                    </div>
                </div>

                <div class="space-y-5">
                    <div class="bg-white rounded-2xl shadow-sm overflow-hidden">
                        <asp:Panel ID="pnlCover" runat="server" Visible="false">
                            <asp:Image ID="imgCover" runat="server" CssClass="w-full h-48 object-cover" />
                        </asp:Panel>
                        <div class="p-5 space-y-3">
                            <div class="tw-detail-grid">
                                <div><div class="tw-detail-label">Duration</div><div class="tw-detail-value"><asp:Label ID="lblDuration" runat="server" /></div></div>
                                <div><div class="tw-detail-label">Places</div><div class="tw-detail-value"><asp:Label ID="lblPlacesCount" runat="server" /></div></div>
                                <div><div class="tw-detail-label">Status</div><div class="tw-detail-value"><asp:Label ID="lblActive" runat="server" /></div></div>
                            </div>
                            <div class="pt-3 border-t border-gray-100">
                                <div class="flex items-center justify-between mb-1">
                                    <span class="text-sm text-gray-500">Price</span>
                                    <span class="text-lg font-bold text-gray-900"><asp:Label ID="lblPrice" runat="server" /></span>
                                </div>
                            </div>
                            <div class="pt-3 border-t border-gray-100 flex items-center justify-between">
                                <span class="text-sm text-gray-500">Times booked</span>
                                <span class="text-sm font-semibold text-gray-900"><asp:Label ID="lblBookings" runat="server" /></span>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </asp:Panel>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script>
        var PLACES = <%= PlacesJson %>;

        document.addEventListener('DOMContentLoaded', function () {
            var el = document.getElementById('mapPackage');
            if (!el || typeof L === 'undefined') return;

            var map = L.map('mapPackage').setView([16.890, 97.633], 12);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);

            var pts = [];
            for (var i = 0; i < PLACES.length; i++) {
                var p = PLACES[i];
                var isFirst = i === 0, isLast = i === PLACES.length - 1;
                var color = isFirst ? 'bg-emerald-500' : (isLast ? 'bg-rose-500' : 'bg-blue-500');
                L.marker([p[1], p[2]], { icon: L.divIcon({
                    className: '',
                    html: '<span class="flex items-center justify-center size-6 rounded-full ' + color + ' text-white text-[11px] font-bold border-2 border-white shadow">' + (i + 1) + '</span>'
                }) }).addTo(map).bindPopup('<strong>' + p[0] + '</strong>');
                pts.push([p[1], p[2]]);
            }
            // Itinerary along real roads rather than straight between the numbered stops.
            var stops = PLACES.map(function (p) { return { lat: p[1], lng: p[2] }; });
            if (TripRoute.isRouteable(stops)) {
                TripRoute.create(map, stops, { color: '#2563eb', weight: 4, opacity: 0.85 });
            } else if (pts.length > 1) {
                L.polyline(pts, { color: '#2563eb', weight: 4, opacity: 0.85, dashArray: '5 7' }).addTo(map);
            }
            if (pts.length) map.fitBounds(L.latLngBounds(pts).pad(0.3));
        });
    </script>
</asp:Content>
