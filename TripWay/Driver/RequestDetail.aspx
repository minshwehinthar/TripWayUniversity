<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RequestDetail.aspx.cs" Inherits="TripWay.Driver.RequestDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="ContentBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
    <ol class="flex flex-wrap items-center gap-x-1.5 gap-y-1 text-sm">
        <li>
            <a href="Dashboard.aspx" class="flex items-center gap-1.5 text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"/></svg>Dashboard
            </a>
        </li>
        <li class="shrink-0 text-gray-400"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg></li>
        <li><a href="TripRequests.aspx" class="text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors">Trip Requests</a></li>
        <li class="shrink-0 text-gray-400"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg></li>
        <li><asp:Label ID="lblCrumbName" runat="server" CssClass="text-sm font-semibold text-gray-900" /></li>
    </ol>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">
        <div class="flex flex-wrap items-end justify-between gap-3">
            <div>
                <h1 class="text-xl font-bold text-gray-900">Trip Request</h1>
                <p class="text-sm text-gray-400">Requested <asp:Label ID="lblRequested" runat="server" /> · <asp:Label ID="lblAgo" runat="server" /></p>
            </div>
            <a href="TripRequests.aspx" class="tw-btn-outline">Back to Requests</a>
        </div>

        <asp:Panel ID="pnlError" runat="server" data-tw-toast="1" Visible="false" CssClass="p-5 rounded-xl bg-red-50 border border-red-200 text-red-700 text-sm">
            <asp:Label ID="lblError" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlTaken" runat="server" Visible="false" CssClass="p-5 rounded-xl bg-amber-50 border border-amber-200 text-amber-800 text-sm flex flex-wrap items-center justify-between gap-3">
            <span>This request is no longer open — it was accepted by another driver or has already been closed.</span>
            <a href="TripRequests.aspx" class="tw-btn-outline">See other requests</a>
        </asp:Panel>

        <asp:Panel ID="pnlContent" runat="server" Visible="false">
            <div class="grid lg:grid-cols-3 gap-6">
                <div class="lg:col-span-2 space-y-5">
                    <div class="bg-white rounded-2xl shadow-sm p-5">
                        <div class="flex items-center justify-between gap-3 mb-3">
                            <h2 class="font-bold text-gray-900">Route</h2>
                            <span class="text-xs text-gray-400"><asp:Label ID="lblTripDistance" runat="server" /></span>
                        </div>
                        <div id="mapRequest" class="h-72 w-full rounded-xl border border-gray-200 mb-3"></div>
                        <div class="space-y-1"><asp:Literal ID="litRoute" runat="server" /></div>
                    </div>

                    <div class="bg-white rounded-2xl shadow-sm p-5">
                        <h2 class="font-bold text-gray-900 mb-3">Trip Details</h2>
                        <div class="tw-detail-grid">
                            <div><div class="tw-detail-label">Service</div><div class="tw-detail-value"><asp:Label ID="lblService" runat="server" /></div></div>
                            <div><div class="tw-detail-label">Vehicle</div><div class="tw-detail-value"><asp:Label ID="lblVehicle" runat="server" /></div></div>
                            <div><div class="tw-detail-label">Package</div><div class="tw-detail-value"><asp:Label ID="lblPackage" runat="server" /></div></div>
                            <div><div class="tw-detail-label">Payment</div><div class="tw-detail-value"><asp:Image ID="imgPaymentIcon" runat="server" CssClass="tw-pay-badge" Visible="false" AlternateText="Payment method" /> <asp:Label ID="lblPaymentMethod" runat="server" /></div></div>
                            <div><div class="tw-detail-label">Stops</div><div class="tw-detail-value"><asp:Label ID="lblStops" runat="server" /></div></div>
                            <div><div class="tw-detail-label">Status</div><div><span id="spnStatusPill" runat="server" class="inline-flex px-2 py-1 rounded-full text-xs font-semibold mt-1"><asp:Label ID="lblStatus" runat="server" /></span></div></div>
                        </div>
                        <div class="pt-4 mt-4 border-t border-gray-100 flex items-center justify-between">
                            <span class="text-sm text-gray-500">Your Earnings</span>
                            <span class="text-lg font-bold text-gray-900"><asp:Label ID="lblFare" runat="server" /></span>
                        </div>
                    </div>
                </div>

                <div class="lg:col-span-1 space-y-5">
                    <div class="bg-white rounded-2xl shadow-sm p-5 space-y-3">
                        <h2 class="font-bold text-gray-900">Customer</h2>
                        <div class="flex items-center gap-3">
                            <asp:Panel ID="pnlPhoto" runat="server" Visible="false">
                                <asp:Image ID="imgCustomerPhoto" runat="server" CssClass="size-14 rounded-full object-cover shrink-0 ring-2 ring-white" />
                            </asp:Panel>
                            <asp:Panel ID="pnlInitial" runat="server">
                                <span class="tw-avatar tw-avatar-blue size-14"><asp:Label ID="lblCustomerInitial" runat="server" /></span>
                            </asp:Panel>
                            <div class="min-w-0">
                                <div class="font-bold text-gray-900 text-sm truncate"><asp:Label ID="lblCustomerName" runat="server" /></div>
                                <div class="text-xs text-gray-400"><asp:Label ID="lblCustomerPhone" runat="server" /></div>
                            </div>
                        </div>
                        <div class="pt-2 border-t border-gray-100 space-y-1 text-sm text-gray-500">
                            <div><asp:Label ID="lblCustomerMeta" runat="server" /></div>
                            <div>Member since <asp:Label ID="lblCustomerSince" runat="server" /></div>
                        </div>
                        <asp:HyperLink ID="lnkCallCustomer" runat="server" Visible="false" CssClass="tw-btn-outline w-full justify-center">Call Customer</asp:HyperLink>
                    </div>

                    <div class="bg-white rounded-2xl shadow-sm p-5 space-y-3">
                        <h2 class="font-bold text-gray-900">Accept this job</h2>
                        <div class="rounded-xl bg-blue-50 border border-blue-200 p-4 space-y-3">
                            <div class="flex items-center justify-between text-sm">
                                <span class="text-blue-800">Road distance to pickup</span>
                                <span class="font-bold text-blue-900 text-right"><asp:Label ID="lblDistanceAway" runat="server" /><span class="block text-[11px] font-normal text-blue-700"><asp:Label ID="lblPickupDistance" runat="server" /></span></span>
                            </div>
                            <div class="flex items-center justify-between text-sm">
                                <span class="text-blue-800">Drive time</span>
                                <span class="font-bold text-blue-900"><asp:Label ID="lblDriveTime" runat="server" /></span>
                            </div>
                            <div class="flex items-center justify-between text-sm">
                                <span class="text-blue-800">Suggested arrival</span>
                                <span class="font-bold text-blue-900"><asp:Label ID="lblSuggestedEta" runat="server" /></span>
                            </div>
                            <div>
                                <label for="<%= txtEta.ClientID %>" class="tw-detail-label mb-1 block">I will arrive in (minutes)</label>
                                <div class="flex items-center gap-2">
                                    <asp:Button ID="btnEtaDown" runat="server" Text="−" CausesValidation="false" OnClick="btnEtaDown_Click" CssClass="tw-btn-outline" />
                                    <asp:TextBox ID="txtEta" runat="server" TextMode="Number" CssClass="tw-input text-center text-lg font-bold" />
                                    <asp:Button ID="btnEtaUp" runat="server" Text="+" CausesValidation="false" OnClick="btnEtaUp_Click" CssClass="tw-btn-outline" />
                                </div>
                                <p class="text-xs text-blue-700 mt-2" id="etaHint">The customer sees this time on their Active Trip, Trip Detail and Trip History pages.</p>
                            </div>
                        </div>
                        <asp:Button ID="btnAccept" runat="server" Text="Accept Job" OnClick="btnAccept_Click" CausesValidation="false" CssClass="tw-btn-primary w-full justify-center" />
                    </div>
                </div>
            </div>
        </asp:Panel>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script>
        var P = <%= PathJson %>;
        var ME = <%= MeJson %>;
        var AVG_SPEED_KMH = 25, ROAD_FACTOR = 1.3;
        var meMarker = null, approachRoute = null;

        // Drive-to-pickup shown along the real road, with live road distance and drive time.
        function drawApproach(map, from) {
            if (!from || !P.pickup) return null;
            approachRoute = TripRoute.create(map, [from, P.pickup], {
                color: '#1d4ed8', weight: 3, opacity: 0.85, dashArray: '7 7', fit: false,
                onRoad: function (info) {
                    var mins = Math.max(1, info.minutes);
                    setText('<%= lblDistanceAway.ClientID %>', info.km.toFixed(1) + ' km');
                    setText('<%= lblDriveTime.ClientID %>', formatDriveTime(mins));
                    setText('<%= lblSuggestedEta.ClientID %>', mins + ' min');
                    var input = document.getElementById('<%= txtEta.ClientID %>');
                    if (input) input.value = mins;
                }
            });
            return approachRoute;
        }

        function haversineKm(a, b) {
            var R = 6371, dLat = (b[0]-a[0])*Math.PI/180, dLng = (b[1]-a[1])*Math.PI/180;
            var s = Math.sin(dLat/2)*Math.sin(dLat/2) + Math.cos(a[0]*Math.PI/180)*Math.cos(b[0]*Math.PI/180)*Math.sin(dLng/2)*Math.sin(dLng/2);
            return R*(2*Math.atan2(Math.sqrt(s), Math.sqrt(1-s)));
        }
        function etaFromKm(km) {
            var m = Math.ceil((km * ROAD_FACTOR) / AVG_SPEED_KMH * 60);
            if (m < 1) m = 1;
            if (m > 180) m = 180;
            return m;
        }

        document.addEventListener('DOMContentLoaded', function () {
            var el = document.getElementById('mapRequest');
            if (el) {
                var map = L.map('mapRequest').setView([16.890, 97.633], 14);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
                var pts = [];
                if (P.pickup) { L.marker(P.pickup, { icon: L.divIcon({ className: '', html: '<span class="block size-4 rounded-full bg-emerald-500 border-2 border-white shadow"></span>' }) }).addTo(map); pts.push(P.pickup); }
                if (P.drop) { L.marker(P.drop, { icon: L.divIcon({ className: '', html: '<span class="block size-4 rounded-full bg-rose-500 border-2 border-white shadow"></span>' }) }).addTo(map); pts.push(P.drop); }
                if (P.stops && P.stops.length > 2) {
                    for (var si = 1; si < P.stops.length - 1; si++) {
                        L.marker(P.stops[si], { icon: L.divIcon({ className: '', html: '<span class="flex items-center justify-center size-5 rounded-full bg-blue-500 text-white text-[10px] font-bold border-2 border-white shadow">' + (si + 1) + '</span>' }) }).addTo(map);
                        pts.push(P.stops[si]);
                    }
                }
                if (ME) {
                    meMarker = L.marker(ME, { icon: L.divIcon({ className: '', html: '<span class="flex items-center justify-center size-5 rounded-full bg-gray-900 text-white text-[9px] font-bold border-2 border-white shadow">You</span>' }) }).addTo(map);
                    pts.push(ME);
                }
                if (ME) drawApproach(map, ME);
                if (pts.length) map.fitBounds(L.latLngBounds(pts).pad(0.25));
            }

            // Re-check the estimate against the browser's live GPS position.
            if (navigator.geolocation && P.pickup) {
                navigator.geolocation.getCurrentPosition(function (pos) {
                    var here = [pos.coords.latitude, pos.coords.longitude];
                    var straight = haversineKm(here, P.pickup);
                    var roadKm = Math.round(straight * ROAD_FACTOR * 10) / 10;
                    var mins = etaFromKm(straight);
                    var input = document.getElementById('<%= txtEta.ClientID %>');
                    if (input) input.value = mins;
                    setText('<%= lblDistanceAway.ClientID %>', roadKm.toFixed(1) + ' km');
                    setText('<%= lblPickupDistance.ClientID %>', '(' + straight.toFixed(1) + ' km as the crow flies)');
                    setText('<%= lblDriveTime.ClientID %>', formatDriveTime(mins));
                    setText('<%= lblSuggestedEta.ClientID %>', mins + ' min');
                    if (meMarker) meMarker.setLatLng(here);
                    if (approachRoute) approachRoute.set([{ lat: here[0], lng: here[1] }, P.pickup]);
                }, function () { });
            }
        });

        function formatDriveTime(mins) {
            if (mins <= 0) return '--';
            if (mins < 60) return mins + ' min';
            var h = Math.floor(mins / 60), m = mins % 60;
            return m === 0 ? h + ' h' : h + ' h ' + m + ' min';
        }

        function setText(id, text) {
            var el = document.getElementById(id);
            if (el) el.textContent = text;
        }
    </script>
</asp:Content>
