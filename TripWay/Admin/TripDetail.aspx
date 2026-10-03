<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripDetail.aspx.cs" Inherits="TripWay.Admin.TripDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">

        <%-- Same header shape as the driver pages: status pill and arrival chip stay put
             while the map and timeline scroll. --%>
        <div class="flex flex-wrap items-end justify-between gap-3">
            <div class="min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                    <h1 class="text-xl font-bold text-gray-900">Trip Details</h1>
                    <span id="spnStatus" runat="server" class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold" />
                    <div id="spnEta" runat="server" />
                </div>
                <p class="text-sm text-gray-400 mt-1">
                    <asp:Literal ID="litSubtitle" runat="server" />
                </p>
            </div>
            <div class="flex items-center gap-2">
                <a href="TripManagement.aspx" class="tw-btn-outline">Back to Trips</a>
            </div>
        </div>

        <%-- Trip not found --%>
        <asp:Panel ID="pnlNoTrip" runat="server" Visible="false"
            CssClass="bg-white rounded-2xl border border-dashed border-slate-300 p-10 text-center">
            <span class="inline-flex items-center justify-center size-14 rounded-full bg-slate-100 text-slate-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0"/></svg>
            </span>
            <p class="mt-3 text-sm font-semibold text-gray-900">Trip not found</p>
            <p class="mt-1 text-sm text-gray-400">This trip does not exist. Every trip is listed in Trips.</p>
            <a href="TripManagement.aspx" class="tw-btn-primary mt-4">Back to Trips</a>
        </asp:Panel>

        <%-- Same two column shape as the driver pages: map, route and timeline on the left,
             everything else on the right. --%>
        <asp:Panel ID="pnlTrip" runat="server" Visible="false" CssClass="grid lg:grid-cols-3 gap-5 items-start">

            <%-- ============ LEFT: map, route, timeline ============ --%>
            <div class="lg:col-span-2 space-y-5">

                <div class="bg-white rounded-2xl shadow-sm p-5">
                    <div class="flex items-center justify-between gap-3 mb-3">
                        <h2 class="font-bold text-gray-900">Route Map</h2>
                    </div>
                    <div id="mapDetail" class="h-80 w-full rounded-xl border border-gray-200"></div>
                    <div class="mt-3 flex items-center gap-4 flex-wrap text-xs text-gray-500">
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-emerald-500"></span>Pickup</span>
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-blue-500"></span>Stop</span>
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-rose-500"></span>Destination</span>
                        <span class="flex items-center gap-1.5"><span class="w-4 h-0.5 bg-violet-500 inline-block"></span>Travelled</span>
                    </div>
                </div>

                <div class="bg-white rounded-2xl shadow-sm p-5">
                    <h2 class="font-bold text-gray-900 mb-3">Route</h2>
                    <div class="space-y-1"><asp:Literal ID="litRoute" runat="server" /></div>
                </div>

                <div class="bg-white rounded-2xl shadow-sm p-5">
                    <h2 class="font-bold text-gray-900 mb-4">Journey Timeline</h2>
                    <div class="space-y-0">
                        <div class="flex gap-3">
                            <div class="flex flex-col items-center"><span class="size-2.5 rounded-full bg-emerald-500 mt-1.5"></span><span class="w-px bg-gray-200 flex-1"></span></div>
                            <div class="pb-4"><div class="tw-detail-label">Requested</div><div class="tw-detail-value"><asp:Label ID="lblTRequested" runat="server" /></div></div>
                        </div>
                        <div class="flex gap-3">
                            <div class="flex flex-col items-center"><span class="size-2.5 rounded-full bg-blue-500 mt-1.5"></span><span class="w-px bg-gray-200 flex-1"></span></div>
                            <div class="pb-4"><div class="tw-detail-label">Accepted</div><div class="tw-detail-value"><asp:Label ID="lblTAccepted" runat="server" /></div></div>
                        </div>
                        <div class="flex gap-3">
                            <div class="flex flex-col items-center"><span class="size-2.5 rounded-full bg-amber-500 mt-1.5"></span><span class="w-px bg-gray-200 flex-1"></span></div>
                            <div class="pb-4"><div class="tw-detail-label">Arrived</div><div class="tw-detail-value"><asp:Label ID="lblTArrived" runat="server" /></div></div>
                        </div>
                        <div class="flex gap-3">
                            <div class="flex flex-col items-center"><span class="size-2.5 rounded-full bg-blue-500 mt-1.5"></span><span class="w-px bg-gray-200 flex-1"></span></div>
                            <div class="pb-4"><div class="tw-detail-label">Started</div><div class="tw-detail-value"><asp:Label ID="lblTStarted" runat="server" /></div></div>
                        </div>
                        <div class="flex gap-3">
                            <div class="flex flex-col items-center"><span class="size-2.5 rounded-full bg-gray-400 mt-1.5"></span></div>
                            <div><div class="tw-detail-label">Completed</div><div class="tw-detail-value"><asp:Label ID="lblTCompleted" runat="server" /></div></div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- ============ RIGHT: summary, customer, driver, rating ============ --%>
            <div class="lg:col-span-1 space-y-5">

                <div class="bg-white rounded-2xl shadow-sm p-5 space-y-3">
                    <h2 class="font-bold text-gray-900">Summary</h2>
                    <div><div class="tw-detail-label">Arrival</div><div id="spnEtaSummary" runat="server"></div></div>
                    <div><div class="tw-detail-label">Service</div><div class="tw-detail-value"><asp:Label ID="lblService" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Vehicle</div><div class="tw-detail-value"><asp:Label ID="lblVehicle" runat="server" /> · <asp:Label ID="lblPlate" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Package</div><div class="tw-detail-value"><asp:Label ID="lblPackage" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Distance</div><div class="tw-detail-value"><asp:Label ID="lblTripDistance" runat="server" /><span id="spnRoad" class="block text-xs text-emerald-600 font-semibold mt-0.5"></span></div></div>
                    <div class="pt-2 border-t border-gray-100 flex items-center justify-between">
                        <span class="text-sm text-gray-500">Fare</span>
                        <span class="text-lg font-bold text-gray-900"><asp:Label ID="lblFare" runat="server" /></span>
                    </div>
                    <div class="flex items-center justify-between text-sm">
                        <span class="text-gray-500">Payment</span>
                        <span class="font-semibold inline-flex items-center gap-1.5"><asp:Image ID="imgPaymentIcon" runat="server" CssClass="tw-pay-badge" Visible="false" AlternateText="Payment method" /> <asp:Label ID="lblPayment" runat="server" /></span>
                    </div>
                    <p class="text-xs text-gray-500"><asp:Literal ID="litPaymentInfo" runat="server" /></p>
                </div>

                <asp:Panel ID="pnlCustomer" runat="server" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-4">
                    <h2 class="font-bold text-gray-900">Customer Information</h2>
                    <div class="flex items-center gap-3">
                        <asp:Panel ID="pnlPhoto" runat="server" Visible="false">
                            <asp:Image ID="imgCustomerPhoto" runat="server" CssClass="size-14 rounded-full object-cover shrink-0 ring-2 ring-gray-100" />
                        </asp:Panel>
                        <asp:Panel ID="pnlInitial" runat="server">
                            <span class="tw-avatar tw-avatar-green size-14"><asp:Label ID="lblCustInitial" runat="server" /></span>
                        </asp:Panel>
                        <div class="min-w-0">
                            <div class="font-bold text-gray-900 text-sm truncate"><asp:Label ID="lblCustName" runat="server" /></div>
                            <div class="text-xs text-gray-400 truncate"><asp:Label ID="lblCustPhone" runat="server" /></div>
                        </div>
                    </div>

                    <div class="pt-3 border-t border-gray-100 space-y-3">
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Phone</div>
                                <div class="tw-detail-value"><asp:Label ID="lblCustPhoneText" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Member since</div>
                                <div class="tw-detail-value"><asp:Label ID="lblCustSince" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .659.506l5.518-.442a.562.562 0 0 1 .985.902l1.087 5.414a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L9.503 17.01a.562.562 0 0 1-.84-.61l1.087-5.414a.562.562 0 0 1 .985-.902l5.518.442a.562.562 0 0 0 .659-.506l2.125-5.111Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Rating</div>
                                <div class="tw-detail-value"><asp:Label ID="lblCustRating" runat="server" /></div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlDriver" runat="server" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-4">
                    <h2 class="font-bold text-gray-900">Driver Information</h2>
                    <div class="flex items-center gap-3">
                        <asp:Panel ID="pnlDriverPhotoPanel" runat="server" Visible="false">
                            <asp:Image ID="imgDriverPhoto" runat="server" CssClass="size-14 rounded-full object-cover shrink-0 ring-2 ring-gray-100" />
                        </asp:Panel>
                        <asp:Panel ID="pnlDriverInitialPanel" runat="server">
                            <span class="tw-avatar tw-avatar-amber size-14"><asp:Label ID="lblDriverInitial" runat="server" /></span>
                        </asp:Panel>
                        <div class="min-w-0 flex-1">
                            <div class="font-bold text-gray-900 text-sm truncate"><asp:Label ID="lblDriverName" runat="server" /></div>
                            <div class="text-xs text-gray-400 truncate"><asp:Label ID="lblDriverPhone" runat="server" /></div>
                        </div>
                        <asp:HyperLink ID="lnkDriverProfile" runat="server" Visible="false" CssClass="tw-btn-outline shrink-0" title="Open driver profile">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6H5.25A2.25 2.25 0 0 0 3 8.25v10.5A2.25 2.25 0 0 0 5.25 21h10.5A2.25 2.25 0 0 0 18 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"/></svg>
                            Profile
                        </asp:HyperLink>
                    </div>

                    <div class="pt-3 border-t border-gray-100 space-y-3">
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Phone</div>
                                <div class="tw-detail-value"><asp:Label ID="lblDriverPhoneText" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Vehicle plate</div>
                                <div class="tw-detail-value"><asp:Label ID="lblDriverPlate" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .659.506l5.518-.442a.562.562 0 0 1 .985.902l1.087 5.414a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L9.503 17.01a.562.562 0 0 1-.84-.61l1.087-5.414a.562.562 0 0 1 .985-.902l5.518.442a.562.562 0 0 0 .659-.506l2.125-5.111Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Rating</div>
                                <div class="tw-detail-value"><asp:Label ID="lblDriverRating" runat="server" /></div>
                            </div>
                        </div>
                    </div>
                </asp:Panel>

                <asp:Panel ID="pnlRating" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-2">
                    <h2 class="font-bold text-gray-900">Customer Rating</h2>
                    <div class="text-2xl text-amber-400"><asp:Label ID="lblStars" runat="server" /></div>
                    <p class="text-sm text-gray-600"><asp:Label ID="lblRatingComment" runat="server" /></p>
                </asp:Panel>
            </div>
        </asp:Panel>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script src="<%= ResolveUrl("~/Scripts/tripway-map.js") %>"></script>
    <script>
        var P = <%= PathJson %>;

        document.addEventListener('DOMContentLoaded', function () {
            TripMap.render({ el: 'mapDetail', path: P, roadTarget: 'spnRoad' });
        });
    </script>
</asp:Content>
