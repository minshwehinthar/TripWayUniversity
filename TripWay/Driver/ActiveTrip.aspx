<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ActiveTrip.aspx.cs" Inherits="TripWay.Driver.ActiveTripPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-5">

        <%-- Page header. The status pill and ETA live here so they stay visible while
             scrolling the map and timeline. --%>
        <div class="flex flex-wrap items-end justify-between gap-3">
            <div class="min-w-0">
                <div class="flex items-center gap-2 flex-wrap">
                    <h1 class="text-xl font-bold text-gray-900">Active Trip</h1>
                    <%-- Status and ETA belong to the trip, so they are hidden with it rather
                         than left behind on screen once the trip is finished. --%>
                    <asp:Panel ID="pnlStatusRow" runat="server" Visible="false" CssClass="flex items-center gap-2 flex-wrap">
                        <span id="spnStatus" runat="server" class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold" />
                        <div id="spnEta" runat="server" />
                    </asp:Panel>
                </div>
                <asp:Panel ID="pnlSubtitle" runat="server" Visible="false">
                    <p class="text-sm text-gray-400 mt-1">
                        <asp:Literal ID="litSubtitle" runat="server" />
                    </p>
                </asp:Panel>
            </div>
            <div class="flex items-center gap-2">
                <a href="TripRequests.aspx" class="tw-btn-outline">Trip Requests</a>
                <a href="TripHistory.aspx" class="tw-btn-outline">Trip History</a>
                <%-- The one action on this page. It sits top right and walks the trip
                     forward one step per click, so its label is rebuilt in BindTrip
                     from the stage the trip is actually waiting on. It disappears
                     once the trip leaves the active list. --%>
                <asp:Panel ID="pnlNextAction" runat="server" Visible="false" CssClass="inline-flex">
                    <asp:LinkButton ID="btnNext" runat="server" OnClick="btnNext_Click"
                        CausesValidation="false" CssClass="tw-btn-primary shadow-sm" />
                </asp:Panel>
                <%-- Backing out is a legitimate answer at any stage, so cancel is offered on
                     every step rather than only on the first one. The confirm text is rebuilt
                     in BindTrip so it names the stage the trip is actually on. --%>
                <asp:LinkButton ID="btnCancel" runat="server" OnClick="btnCancel_Click" Visible="false"
                    CausesValidation="false" CssClass="tw-btn-outline tw-btn-soft-danger">Cancel Trip</asp:LinkButton>
            </div>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Nothing in progress --%>
        <asp:Panel ID="pnlNoTrip" runat="server" Visible="false"
            CssClass="bg-white rounded-2xl border border-dashed border-slate-300 p-10 text-center">
            <span class="inline-flex items-center justify-center size-14 rounded-full bg-slate-100 text-slate-400">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129.504 1.09 1.124a17.902 17.902 0 0 1-3.213 9.193 2.056 2.056 0 0 1-1.51.75H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
            </span>
            <p class="mt-3 text-sm font-semibold text-gray-900">No active trip</p>
            <p class="mt-1 text-sm text-gray-400">When you claim a job it will show up here with the route, the live timeline and your customer.</p>
            <a href="TripRequests.aspx" class="tw-btn-primary mt-4">Browse Trip Requests</a>
        </asp:Panel>

        <%-- The one trip in progress: map + route + timeline on the left, everything
             else on the right. --%>
        <asp:Panel ID="pnlTrip" runat="server" Visible="false" CssClass="grid lg:grid-cols-3 gap-5 items-start">

            <%-- ============ LEFT: map, route, timeline ============ --%>
            <div class="lg:col-span-2 space-y-5">

                <div class="bg-white rounded-2xl shadow-sm p-5">
                    <div class="flex items-center justify-between gap-3 mb-3">
                        <h2 class="font-bold text-gray-900">Live Map</h2>
                        <div id="spnMePin" runat="server" class="text-xs text-gray-400" />
                    </div>
                    <div id="mapActive" class="h-80 w-full rounded-xl border border-gray-200"></div>
                    <div class="mt-3 flex items-center gap-4 flex-wrap text-xs text-gray-500">
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-emerald-500"></span>Pickup</span>
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-blue-500"></span>Stop</span>
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-rose-500"></span>Destination</span>
                        <span class="flex items-center gap-1.5"><span class="size-2.5 rounded-full bg-gray-900"></span>You</span>
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

            <%-- ============ RIGHT: summary, customer, chat, actions ============ --%>
            <div class="lg:col-span-1 space-y-5">

                <div class="bg-white rounded-2xl shadow-sm p-5 space-y-3">
                    <h2 class="font-bold text-gray-900">Summary</h2>
                    <div><div class="tw-detail-label">Arrival</div><div id="spnEtaSummary" runat="server"></div></div>
                    <div><div class="tw-detail-label">Service</div><div class="tw-detail-value"><asp:Label ID="lblService" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Vehicle</div><div class="tw-detail-value"><asp:Label ID="lblVehicle" runat="server" /> · <asp:Label ID="lblPlate" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Package</div><div class="tw-detail-value"><asp:Label ID="lblPackage" runat="server" /></div></div>
                    <div><div class="tw-detail-label">Distance</div><div class="tw-detail-value"><asp:Label ID="lblTripDistance" runat="server" /><span id="spnRoad" class="block text-xs text-emerald-600 font-semibold mt-0.5"></span></div></div>
                    <div class="pt-2 border-t border-gray-100 flex items-center justify-between">
                        <span class="text-sm text-gray-500">Your earnings</span>
                        <span class="text-lg font-bold text-gray-900"><asp:Label ID="lblFare" runat="server" /></span>
                    </div>
                    <div class="flex items-center justify-between text-sm">
                        <span class="text-gray-500">Payment</span>
                        <span class="font-semibold inline-flex items-center gap-1.5"><asp:Image ID="imgPaymentIcon" runat="server" CssClass="tw-pay-badge" Visible="false" AlternateText="Payment method" /> <asp:Label ID="lblPayment" runat="server" /></span>
                    </div>
                    <p class="text-xs text-gray-500"><asp:Literal ID="litPaymentInfo" runat="server" /></p>
                    <asp:Literal ID="litEtaPromise" runat="server" />
                </div>

                <asp:Panel ID="pnlCustomer" runat="server" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-4">
                    <h2 class="font-bold text-gray-900">Customer Information</h2>
                    <div class="flex items-center gap-3">
                        <asp:Panel ID="pnlPhoto" runat="server" Visible="false">
                            <asp:Image ID="imgCustomerPhoto" runat="server" CssClass="size-14 rounded-full object-cover shrink-0 ring-2 ring-gray-100" />
                        </asp:Panel>
                        <asp:Panel ID="pnlInitial" runat="server">
                            <span class="tw-skeleton tw-skeleton-avatar size-14 shrink-0"></span>
                        </asp:Panel>
                        <div class="min-w-0">
                            <div class="font-bold text-gray-900 text-sm truncate"><asp:Label ID="lblCustName" runat="server" /></div>
                            <div class="text-xs text-gray-400 truncate"><asp:Label ID="lblCustPhone" runat="server" /></div>
                        </div>
                    </div>

                    <asp:Panel ID="pnlCustomerContacts" runat="server" CssClass="pt-3 border-t border-gray-100 space-y-3">
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
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-gray-400 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .659.506l5.518-.442c.499-.04.901.41.985.902l1.087 5.414a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L9.503 17.01a.562.562 0 0 1-.84-.61l1.087-5.414a.562.562 0 0 1 .985-.902l5.518.442a.562.562 0 0 0 .659-.506l2.125-5.111Z"/></svg>
                            <div class="min-w-0 flex-1">
                                <div class="tw-detail-label">Rating</div>
                                <div class="tw-detail-value"><asp:Label ID="lblRating" runat="server" /></div>
                            </div>
                        </div>
                    </asp:Panel>

                    <asp:HyperLink ID="lnkCallCustomer" runat="server" Visible="false" CssClass="tw-btn-outline w-full justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75c0 8.284 6.716 15 15 15h2.25a2.25 2.25 0 0 0 2.25-2.25v-1.372c0-.516-.351-.966-.852-1.091l-4.423-1.106c-.44-.11-.902.055-1.173.417l-.97 1.293c-.282.376-.769.542-1.21.38a12.035 12.035 0 0 1-7.143-7.143c-.162-.441.004-.928.38-1.21l1.293-.97c.363-.271.527-.734.417-1.173L6.963 3.102a1.125 1.125 0 0 0-1.091-.852H4.5A2.25 2.25 0 0 0 2.25 4.5v2.25Z"/></svg>
                        Call Customer
                    </asp:HyperLink>
                </asp:Panel>

                <asp:Panel ID="pnlChat" runat="server" CssClass="bg-white rounded-2xl shadow-sm p-5">
                    <div class="rounded-xl border border-gray-200 flex flex-col overflow-hidden -mx-2 -mb-2" data-chat="1"
                         data-trip="<%= ChatTripId %>" data-api="<%= ChatApiUrl %>" data-me="Driver"
                         data-base="<%= ResolveUrl("~/") %>">
                        <div class="flex items-center justify-between px-4 py-3 border-b border-gray-200">
                            <h2 class="font-bold text-gray-900 text-sm">Chat with Customer</h2>
                            <span data-chat-status class="text-xs font-semibold text-gray-400">Loading</span>
                        </div>
                        <%-- Fixed tall viewport: long conversations scroll inside this box
                             instead of stretching the page. --%>
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

                <%-- Progress checklist only. The trip moves forward one step at a time by
                     way of the single button in the page header, so there is nothing to
                     click in here; the card just shows which steps are done. --%>
                <asp:Panel ID="pnlActions" runat="server" Visible="false" CssClass="bg-white rounded-2xl shadow-sm p-5 space-y-3">
                    <div class="flex items-center justify-between gap-3">
                        <h2 class="font-bold text-gray-900">Trip Progress</h2>
                        <asp:LinkButton ID="btnMarkUnpaid" runat="server" OnClick="btnMarkUnpaid_Click" CausesValidation="false"
                            Visible="false" CssClass="text-xs font-semibold text-gray-400 hover:text-gray-900 underline"
                            OnClientClick="return confirm('Mark the fare as unpaid again?');">Mark fare unpaid</asp:LinkButton>
                    </div>

                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0 flex-1">
                            <div class="text-xs text-gray-500">Accept</div>
                            <div class="text-[11px] text-gray-400">Claimed from the requests page, where you set the arrival time the customer sees.</div>
                        </div>
                        <div class="shrink-0"><asp:Literal ID="litAccept" runat="server" /></div>
                    </div>

                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0 flex-1">
                            <div class="text-xs text-gray-500">Arrived</div>
                            <div class="text-[11px] text-gray-400">Mark that you have reached the pickup point.<asp:Literal ID="litEtaNote" runat="server" /></div>
                        </div>
                        <div class="shrink-0"><asp:Literal ID="litArrived" runat="server" /></div>
                    </div>

                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0 flex-1">
                            <div class="text-xs text-gray-500">Started</div>
                            <div class="text-[11px] text-gray-400">Start the trip when the customer is onboard.</div>
                        </div>
                        <div class="shrink-0"><asp:Literal ID="litStarted" runat="server" /></div>
                    </div>

                    <div class="flex items-start justify-between gap-3">
                        <div class="min-w-0 flex-1">
                            <div class="text-xs text-gray-500">Completed</div>
                            <div class="text-[11px] text-gray-400"><asp:Literal ID="litCompletedNote" runat="server" /></div>
                        </div>
                        <div class="shrink-0"><asp:Literal ID="litCompleted" runat="server" /></div>
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
        var ME = <%= MeJson %>;

        document.addEventListener('DOMContentLoaded', function () {
            TripMap.render({
                el: 'mapActive',
                path: P,
                me: ME,
                meLabel: 'You',
                driveToPickup: true,
                roadTarget: 'spnRoad'
            });
        });
    </script>
</asp:Content>
