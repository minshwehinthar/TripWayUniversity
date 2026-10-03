<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripDetail.aspx.cs" Inherits="TripWay.Customer.TripDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="ContentBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
    <ol class="flex flex-wrap items-center gap-x-1.5 gap-y-1 text-sm">
        <li>
            <a href="Dashboard.aspx" class="flex items-center gap-1.5 text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"/></svg>Dashboard
            </a>
        </li>
        <li class="shrink-0 text-gray-400"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg></li>
        <li><asp:HyperLink ID="lnkCrumbList" runat="server" class="text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors">Trip History</asp:HyperLink></li>
        <li class="shrink-0 text-gray-400"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg></li>
        <li class="text-sm font-semibold text-gray-900"><asp:Label ID="lblCrumbName" runat="server" /></li>
    </ol>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">

        <%-- Same header shape as the driver and admin pages. The trip number is deliberately
             not shown here: the service name and the dates identify the trip for a person,
             and the internal id is not something to put in front of them. --%>
        <div class="flex flex-wrap items-end justify-between gap-3">
            <div class="min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                    <h1 class="text-xl font-bold text-gray-900">Trip Details</h1>
                    <span id="spnStatus" runat="server" />
                    <div id="spnEta" runat="server" />
                </div>
                <p class="text-sm text-gray-400 mt-1">
                    <asp:Literal ID="litSubtitle" runat="server" />
                </p>
            </div>
            <div class="flex items-center gap-2">
                <asp:HyperLink ID="lnkBack" runat="server" CssClass="tw-btn-outline">Back to History</asp:HyperLink>
                <asp:HyperLink ID="lnkActive" runat="server" CssClass="tw-btn-primary" Visible="false">View Live Trip</asp:HyperLink>
            </div>
        </div>

        <%-- Trip not found, or not this customer's to open --%>
        <asp:Panel ID="pnlNoTrip" runat="server" Visible="false"
            CssClass="bg-white rounded-2xl border border-dashed border-slate-300 p-10 text-center">
            <span class="inline-flex items-center justify-center size-14 rounded-full bg-slate-100 text-slate-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0"/></svg>
            </span>
            <p class="mt-3 text-sm font-semibold text-gray-900">Trip not found</p>
            <p class="mt-1 text-sm text-gray-400">This trip does not exist, or it is not one of yours. Your trips are in Trip History.</p>
            <a href="TripHistory.aspx" class="tw-btn-primary mt-4">Trip History</a>
        </asp:Panel>

        <%-- Same two column shape as the driver and admin pages: map, route and timeline on
             the left, everything else on the right. --%>
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

            <%-- ============ RIGHT: summary, driver, rating, chat ============ --%>
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

                <asp:Panel ID="pnlDriver" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-4">
                    <h2 class="font-bold text-gray-900">Driver Information</h2>
                    <div class="flex items-center gap-3">
                        <asp:Panel ID="pnlDriverPhoto" runat="server" Visible="false">
                            <asp:Image ID="imgDriverPhoto" runat="server" CssClass="size-14 rounded-full object-cover shrink-0 ring-2 ring-gray-100" />
                        </asp:Panel>
                        <asp:Panel ID="pnlDriverAvatar" runat="server">
                            <span class="tw-avatar tw-avatar-green size-14 text-xl"><asp:Label ID="lblDriverInitial" runat="server" /></span>
                        </asp:Panel>
                        <div class="min-w-0 flex-1">
                            <div class="font-bold text-gray-900 text-sm truncate"><asp:Label ID="lblDriverName" runat="server" /></div>
                            <div class="text-xs text-gray-400 truncate"><asp:Label ID="lblDriverRatingInline" runat="server" /></div>
                        </div>
                    </div>

                    <div class="pt-3 border-t border-gray-100 space-y-3">
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Phone</div>
                                <asp:HyperLink ID="lnkDriverPhone" runat="server" Visible="false" CssClass="tw-detail-value hover:text-[#007AFF] transition-colors">
                                    <asp:Label ID="lblDriverPhone" runat="server" />
                                </asp:HyperLink>
                                <div ID="divDriverPhoneText" runat="server" class="tw-detail-value"><asp:Label ID="lblDriverPhoneText" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 8.25h19.5M2.25 9h19.5m-16.5 5.25h6m-6 2.25h3m-3.75 3h15a2.25 2.25 0 0 0 2.25-2.25V6.75A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Payment Account</div>
                                <div class="tw-detail-value break-words"><asp:Label ID="lblDriverPaymentAccount" runat="server" /></div>
                            </div>
                        </div>
                        <div class="flex items-start gap-2.5">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25v10.5A2.25 2.25 0 0 0 4.5 19.5m19.5 0v.243a1.5 1.5 0 0 1-1.07 1.916l-7.5 4.615a1.5 1.5 0 0 1-1.93 0L3.32 8.91a1.5 1.5 0 0 1-1.07-1.916V6.75"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Email</div>
                                <asp:HyperLink ID="lnkDriverEmail" runat="server" Visible="false" CssClass="tw-detail-value hover:text-[#007AFF] transition-colors break-all">
                                    <asp:Label ID="lblDriverEmail" runat="server" />
                                </asp:HyperLink>
                                <div id="divDriverEmailText" runat="server" class="tw-detail-value break-all"><asp:Label ID="lblDriverEmailText" runat="server" /></div>
                            </div>
                        </div>
                    </div>

                    <asp:HyperLink ID="lnkCallDriver" runat="server" Visible="false" CssClass="tw-btn-outline w-full justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"/></svg>
                        Call Driver
                    </asp:HyperLink>
                </asp:Panel>

                <asp:Panel ID="pnlRating" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-2">
                    <h2 class="font-bold text-gray-900">Your Rating</h2>
                    <div class="text-2xl text-amber-400"><asp:Label ID="lblStars" runat="server" /></div>
                    <p class="text-sm text-gray-600"><asp:Label ID="lblRatingComment" runat="server" /></p>
                </asp:Panel>

                <asp:Panel ID="pnlChat" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm p-5">
                    <div class="rounded-xl border border-gray-200 flex flex-col overflow-hidden -mx-2 -mb-2" data-chat="1"
                         data-trip="<%= ChatTripId %>" data-api="<%= ChatApiUrl %>" data-me="Customer"
                         data-base="<%= ResolveUrl("~/") %>">
                        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-200">
                            <h2 class="font-bold text-gray-900 text-sm">Chat with Driver</h2>
                            <span data-chat-status class="text-xs font-semibold text-gray-400">Loading</span>
                        </div>
                        <div class="relative">
                            <div data-chat-list class="px-4 py-3 space-y-3 h-[22rem] sm:h-[26rem] overflow-y-auto overscroll-contain bg-gray-50/40"></div>
                            <button type="button" data-chat-jump class="hidden absolute bottom-3 left-1/2 -translate-x-1/2 rounded-full bg-gray-900 px-3 py-1.5 text-[11px] font-semibold text-white shadow-lg">
                                Jump to latest
                            </button>
                        </div>
                        <div data-chat-closed class="hidden px-4 py-4 text-sm text-gray-500 bg-gray-50 border-t border-gray-200"></div>
                        <div data-chat-form class="px-3 py-3 border-t border-gray-200 space-y-2">
                            <textarea data-chat-input rows="2" maxlength="1000"
                                      class="tw-input w-full resize-none" placeholder="Type a message..."></textarea>
                            <div data-chat-preview class="hidden items-center gap-2 rounded-lg bg-gray-50 border border-gray-200 px-2 py-1.5"></div>
                            <div class="flex items-center gap-2">
                                <input type="file" data-chat-file accept="image/*" class="hidden" />
                                <button type="button" data-chat-attach
                                        class="tw-btn-outline inline-flex items-center gap-1.5">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="m18.375 12.739-7.693 7.693a4.5 4.5 0 0 1-6.364-6.364l10.94-10.94A3 3 0 1 1 19.5 7.372L8.552 18.32m.009-.01-.01.01m5.699-9.941-7.81 7.81a1.5 1.5 0 0 0 2.112 2.13"/></svg>
                                    Photo
                                </button>
                                <button type="button" data-chat-send class="tw-btn-primary ml-auto">Send</button>
                            </div>
                        </div>
                        <div data-chat-error class="hidden px-3 pb-3 text-xs text-red-600"></div>
                    </div>
                </asp:Panel>
            </div>
        </asp:Panel>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/leaflet.js") %>"></script>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/leaflet/leaflet.css") %>" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script src="<%= ResolveUrl("~/Scripts/tripway-map.js") %>"></script>
    <script src="<%= ResolveUrl("~/Scripts/tripway-chat.js") %>"></script>
    <script>
        var P = <%= PathJson %>;

        document.addEventListener('DOMContentLoaded', function () {
            TripMap.render({ el: 'mapDetail', path: P, roadTarget: 'spnRoad' });
        });
    </script>
</asp:Content>
