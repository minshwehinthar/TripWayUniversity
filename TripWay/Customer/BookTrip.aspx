<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="BookTrip.aspx.cs" Inherits="TripWay.Customer.BookTripPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="ContentBreadcrumb" ContentPlaceHolderID="BreadcrumbContent" runat="server">
    <ol class="flex flex-wrap items-center gap-x-1.5 gap-y-1 text-sm">
        <li>
            <a href="Dashboard.aspx" class="flex items-center gap-1.5 text-[13px] font-medium text-gray-500 hover:text-gray-900 transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m2.25 12 8.954-8.955c.44-.439 1.152-.439 1.591 0L21.75 12M4.5 9.75v10.125c0 .621.504 1.125 1.125 1.125H9.75v-4.875c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125V21h4.125c.621 0 1.125-.504 1.125-1.125V9.75M8.25 21h8.25"/></svg>Dashboard
            </a>
        </li>
        <li class="shrink-0 text-gray-400"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="m8.25 4.5 7.5 7.5-7.5 7.5"/></svg></li>
        <li class="text-sm font-semibold text-gray-900">Book a Trip</li>
    </ol>
</asp:Content>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">Book a Trip</h1>
            <p class="text-sm text-gray-400">Choose a service, set your locations and confirm the upfront fare.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <div class="grid lg:grid-cols-3 gap-6">
            <div class="lg:col-span-2 space-y-6">

                <%-- ============ 1. Service type ============
                     The three cards are the picker. The real DropDownList is kept (hidden)
                     because it is what posts back and drives UpdatePanels() on the server;
                     a card click sets it and fires its change event. --%>
                <section class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50">
                    <div class="flex items-center justify-between mb-4">
                        <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-400">1. Service Type</span>
                        <span class="text-[11px] text-slate-400">Fixed rate guaranteed</span>
                    </div>

                    <asp:DropDownList ID="ddlServiceType" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlServiceType_SelectedIndexChanged"
                        CssClass="hidden" CausesValidation="false">
                        <asp:ListItem Value="1" Text="Point-to-Point (A to B)" Selected="True" />
                        <asp:ListItem Value="2" Text="Hourly Hire" />
                        <asp:ListItem Value="3" Text="Package Tour" />
                    </asp:DropDownList>

                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-3.5" id="serviceGrid">
                        <button type="button" class="service-card text-left rounded-xl p-4 border transition-all duration-150"
                            data-service="p2p" onclick="pickService('1')">
                            <div class="flex items-start justify-between mb-3">
                                <span class="service-icon w-8 h-8 rounded-lg flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"/></svg>
                                </span>
                                <span class="service-check w-5 h-5 rounded-full bg-blue-600 text-white flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                </span>
                            </div>
                            <h3 class="font-bold text-[13px] text-slate-900">Point-to-Point</h3>
                            <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">Direct transit with upfront mileage pricing.</p>
                            <div class="service-price mt-3 pt-3 border-t border-slate-100 text-[11px] font-semibold text-blue-700"><%= FormatSelectedRate(SelectedPerKm, "/km") %></div>
                        </button>

                        <button type="button" class="service-card text-left rounded-xl p-4 border transition-all duration-150"
                            data-service="hourly" onclick="pickService('2')">
                            <div class="flex items-start justify-between mb-3">
                                <span class="service-icon w-8 h-8 rounded-lg flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                                </span>
                                <span class="service-check w-5 h-5 rounded-full bg-blue-600 text-white flex items-center justify-center" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                </span>
                            </div>
                            <h3 class="font-semibold text-[13px] text-slate-900">Hourly Charter</h3>
                            <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">Dedicated standby vehicle for a flexible schedule.</p>
                            <div class="service-price mt-3 pt-3 border-t border-slate-100 text-[11px] font-semibold text-blue-700"><%= FormatSelectedRate(SelectedPerHour, "/hr") %></div>
                        </button>

                        <button type="button" class="service-card text-left rounded-xl p-4 border transition-all duration-150"
                            data-service="package" onclick="pickService('3')">
                            <div class="flex items-start justify-between mb-3">
                                <span class="service-icon w-8 h-8 rounded-lg flex items-center justify-center">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z"/></svg>
                                </span>
                                <span class="service-check w-5 h-5 rounded-full bg-blue-600 text-white flex items-center justify-center" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                </span>
                            </div>
                            <h3 class="font-semibold text-[13px] text-slate-900">Package Tour</h3>
                            <p class="text-[11px] text-slate-500 mt-1 leading-relaxed">Fixed itinerary covering every place in the tour.</p>
                            <div class="service-price mt-3 pt-3 border-t border-slate-100 text-[11px] font-semibold text-blue-700">All-inclusive fare</div>
                        </button>
                    </div>
                </section>

                <%-- ============ Hourly charter (hour cards drive the hidden DropDownList) ============ --%>
                <asp:Panel ID="pnlHourly" runat="server" Visible="false">
                    <section class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-400"><span id="lblStepHourly">2.</span> <span id="lblTitleHourly">Hourly Charter</span></span>
                            <span class="text-[11px] text-slate-400">Flat rate per hour</span>
                        </div>

                        <asp:DropDownList ID="ddlHours" runat="server" CssClass="hidden" CausesValidation="false">
                            <asp:ListItem Value="1" Text="1 hour" />
                            <asp:ListItem Value="2" Text="2 hours" />
                            <asp:ListItem Value="3" Text="3 hours" />
                            <asp:ListItem Value="4" Text="4 hours" />
                            <asp:ListItem Value="5" Text="5 hours" />
                            <asp:ListItem Value="6" Text="6 hours" />
                            <asp:ListItem Value="8" Text="8 hours (full day)" />
                        </asp:DropDownList>

                        <%-- The hour prices are rendered on the server as well as by the script.
                             This grid used to be empty in the markup and filled in by JavaScript
                             alone, so the hourly charter showed no price at all until the script
                             ran. The script replaces this content on load and whenever the
                             vehicle changes, so the two must show the same figures. --%>
                        <div id="hourGrid" class="grid grid-cols-2 sm:grid-cols-4 gap-2.5"><%= ServerHourCardsHtml %></div>

                        <div class="mt-5 pt-4 border-t border-slate-100">
                            <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-3">Standby Included</div>
                            <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-slate-50 text-slate-500 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Dedicated driver for the full hour count</span>
                                </div>
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-slate-50 text-slate-500 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Clock starts from your pickup point</span>
                                </div>
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-slate-50 text-slate-500 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Wait time billed inside the booked hours</span>
                                </div>
                            </div>
                        </div>
                    </section>
                </asp:Panel>

                <%-- ============ Package circuit (package cards + itinerary + inclusions) ============
                     The itinerary, the pickup row and the map are all driven from PackageJson, so a
                     package with no places says so instead of rendering an empty card. --%>
                <asp:Panel ID="pnlPackage" runat="server" Visible="false">
                    <section class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50">
                        <div class="flex items-center justify-between mb-4 gap-3">
                            <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-400"><span id="lblStepPackage">2.</span> <span id="lblTitlePackage">Curated Package Circuit</span></span>
                            <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-[11px] font-semibold shrink-0">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                Curated daypass
                            </span>
                        </div>

                        <asp:DropDownList ID="ddlPackage" runat="server" CssClass="hidden" CausesValidation="false" />
                        <div id="packageGrid" class="grid grid-cols-1 sm:grid-cols-2 gap-3"></div>

                        <div class="mt-5 pt-4 border-t border-slate-100 flex flex-wrap items-center justify-between gap-3">
                            <div class="flex items-center gap-3 min-w-0">
                                <span class="w-9 h-9 rounded-lg bg-slate-50 text-slate-500 flex items-center justify-center shrink-0">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.6" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                                </span>
                                <div class="min-w-0">
                                    <div class="text-[10px] font-semibold uppercase tracking-wider text-slate-400">Pickup</div>
                                    <div id="lblPackagePickup" class="text-[13px] font-semibold text-slate-400 truncate">Set your pickup on the map</div>
                                </div>
                            </div>
                            <button type="button" id="btnPackageChange" onclick="setPinMode('pickup')" class="text-[11px] font-semibold text-blue-700 hover:text-blue-800 shrink-0">Change</button>
                        </div>

                        <div class="mt-5">
                            <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-3">Sequential Tour Itinerary</div>
                            <div id="divPlaces" class="grid grid-cols-1 sm:grid-cols-2 gap-2.5"></div>
                        </div>

                        <div class="mt-5 pt-4 border-t border-slate-100">
                            <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-3">Package Inclusions</div>
                            <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Private vehicle and driver for the full circuit</span>
                                </div>
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Every place visited in the listed order</span>
                                </div>
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Live road distance and drive time on the map</span>
                                </div>
                                <div class="flex items-center gap-2.5">
                                    <span class="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                    </span>
                                    <span class="text-[11px] text-slate-500 leading-snug">Return to your pickup point after the last stop</span>
                                </div>
                            </div>
                        </div>
                    </section>
                </asp:Panel>

                <%-- ============ Route & stops (P2P + Hourly + Package itinerary) ============
                     The map sits in its own rounded frame now, with the road metrics floating
                     over the bottom of it. #mapRoute is reset below because it used to be
                     deliberately frameless on a white page. --%>
                <asp:Panel ID="pnlMap" runat="server">
                    <section class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50">
                        <div class="flex flex-wrap items-center justify-between gap-3 mb-4">
                            <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-400"><span id="lblStepRoute">2.</span> <span id="lblTitleRoute">Route &amp; Stops</span></span>
                            <div class="flex gap-2">
                                <button type="button" id="btnModePickup" onclick="setPinMode('pickup')" class="tw-btn-primary">Start</button>
                                <button type="button" id="btnModeStop" onclick="setPinMode('stop')" class="tw-btn-outline">+ Point</button>
                                <button type="button" id="btnModeDrop" onclick="setPinMode('drop')" class="tw-btn-outline">End</button>
                            </div>
                        </div>

                        <div id="routePoints" class="space-y-2.5"></div>

                        <style>
                            /* Hotel card on the map: white card, no Leaflet frame */
                            .tw-hotel-popup .leaflet-popup-content-wrapper {
                                border-radius: 0.75rem;
                                box-shadow: 0 10px 25px -6px rgba(0, 0, 0, 0.2);
                            }
                            .tw-hotel-popup .leaflet-popup-content { margin: 0.625rem 0.75rem; }
                            .tw-hotel-popup .leaflet-popup-tip { box-shadow: none; }

                            /* The chosen hotel, so the customer can see which card they picked */
                            .hotel-card-active {
                                border-color: #007AFF;
                                box-shadow: 0 0 0 2px rgba(0, 122, 255, 0.28);
                            }

                            /* The map now lives inside the rounded frame above, so the container
                               only has to fill it: no radius, no border, no shadow of its own. */
                            #mapRoute,
                            #mapRoute.leaflet-container {
                                border: 0 !important;
                                box-shadow: none !important;
                                background: #f1f5f9;
                            }

                            /* Leaflet paints a #ddd backdrop and blends tiles with
                               plus-lighter, which reads as a dark panel. Reset both. */
                            #mapRoute.leaflet-container img.leaflet-tile {
                                mix-blend-mode: normal;
                            }

                            /* Drop the click ring, but keep a visible focus ring: Leaflet
                               makes the container tabindex="0", so keyboard users do
                               need to see where they are. */
                            #mapRoute:focus { outline: none; }

                            #mapRoute:focus-visible {
                                outline: 2px solid #2563eb;
                                outline-offset: -2px;
                            }
                        </style>

                        <div class="relative isolate w-full h-72 rounded-xl overflow-hidden border border-slate-200 bg-slate-100 mt-4">
                            <div id="mapRoute" class="h-full w-full"></div>

                            <%-- Road metrics float over the map. Isolated wrapper + z-1100 keeps
                                 this above Leaflet's own panes and controls. --%>
                            <div class="absolute bottom-3 left-3 right-3 z-[1100] bg-white/95 backdrop-blur-md px-4 py-2.5 rounded-xl border border-slate-200/80 shadow-sm flex flex-wrap items-center justify-between gap-x-4 gap-y-1">
                                <div class="flex items-center gap-3 text-xs">
                                    <span class="inline-flex items-center gap-1.5 font-semibold text-slate-800">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-[18px] inline-block align-middle text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"/></svg>
                                        <span id="lblRoadDistance">Road distance <strong>&mdash;</strong></span>
                                    </span>
                                    <span class="h-3 w-px bg-slate-200"></span>
                                    <span class="inline-flex items-center gap-1.5 font-semibold text-slate-800">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-[18px] inline-block align-middle text-slate-500"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                                        <span id="lblRoadTime">Drive time <strong>&mdash;</strong></span>
                                    </span>
                                    <span id="lblRouteStops" class="hidden h-3 w-px bg-slate-200"></span>
                                    <span id="lblRouteStopText" class="hidden inline-flex items-center gap-1.5 font-semibold text-slate-800">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-[18px] inline-block align-middle text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z"/></svg>
                                        <span id="lblRoadStops">0 curated stops</span>
                                    </span>
                                </div>
                                <div class="flex items-center gap-2">
                                    <span id="lblRoadStatus" class="text-xs text-slate-500">Add a start and an end to see the road route.</span>
                                    <button type="button" id="btnRoadRetry" class="tw-btn-outline hidden" onclick="drawRoadRoute()">Retry</button>
                                </div>
                            </div>
                        </div>

                        <%-- Shown when a point is tapped outside the bookable area. A quiet notice
                             with a short heading, not a red alarm across the whole card. --%>
                        <div id="lblAreaError" class="hidden mt-3 flex items-start gap-2.5 rounded-xl border border-amber-100 bg-amber-50/70 p-3">
                            <span class="w-5 h-5 rounded-full bg-amber-100 text-amber-600 flex items-center justify-center shrink-0 mt-px">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z"/></svg>
                            </span>
                            <div class="min-w-0">
                                <div class="text-[12px] font-semibold text-amber-800">Outside our service area</div>
                                <div id="lblAreaErrorText" class="text-[11px] leading-snug text-amber-700/90 mt-0.5"></div>
                            </div>
                        </div>

                        <div class="mt-4 flex flex-col sm:flex-row gap-2">
                            <input id="txtPlace" type="text" data-enter="place" placeholder="Search Hpa-An address&hellip;" class="tw-input flex-1" />
                            <button type="button" onclick="searchPlace()" class="tw-btn-primary shrink-0">Search</button>
                        </div>
                        <p id="placeResults" class="hidden mt-2 text-[11px] text-slate-500 bg-slate-50 border border-slate-200 rounded-lg p-2.5"></p>
                        <p id="lblMapHint" class="mt-2 text-[11px] text-slate-400">Tap <strong>Start</strong> then the map to set the beginning, <strong>+ Point</strong> to add more places, and <strong>End</strong> for the destination. Add as many stops as you like.</p>
                    </section>
                </asp:Panel>

                <%-- ============ Hotels ============ --%>
                <asp:Panel ID="pnlHotels" runat="server" Visible="false">
                    <section class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50">
                        <div class="flex items-center justify-between mb-4 gap-3">
                            <h2 class="text-base font-bold tracking-tight text-slate-900">Hotel transfers</h2>
                            <div class="flex items-center gap-2.5 shrink-0">
                                <div class="relative">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4 absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none"><path stroke-linecap="round" stroke-linejoin="round" d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"/></svg>
                                    <input id="txtHotelSearch" type="text" data-enter="hotel" autocomplete="off"
                                        placeholder="Search hotels&hellip;" aria-label="Search hotels"
                                        class="tw-input pl-8 w-40 sm:w-52" />
                                </div>
                                <span id="lblHotelCount" class="shrink-0 inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-white border border-slate-200/80 shadow-sm text-xs font-semibold text-slate-700"></span>
                            </div>
                        </div>

                        <%-- Inline note beside the hotel grid. A hotel that cannot be used is
                             explained here rather than in a toast: the reason belongs next to
                             the list it came from, and it stays on screen until the next click. --%>
                        <p id="hotelNote" class="hidden mb-3 text-[11px] text-amber-800 bg-amber-50 border border-amber-200 rounded-lg p-2.5"></p>

                        <p id="lblHotelEmpty" class="hidden mb-3 text-[11px] text-slate-500 bg-slate-50 border border-slate-200 rounded-lg p-2.5"></p>

                        <%-- One card per hotel, three across. The whole card is the click target:
                             choosing a hotel drops its pin and shows the same photo and details
                             on the map. The photo sits on a placeholder so a hotel with no
                             uploaded logo still looks like a card. --%>
                        <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                            <asp:Repeater ID="rptHotels" runat="server">
                                <ItemTemplate>
                                    <div class="hotel-card group overflow-hidden rounded-xl border border-slate-100 bg-white transition-all duration-150 hover:border-blue-200 hover:shadow-sm cursor-pointer"
                                        data-hotel-card='<%# Eval("HotelID") %>'
                                        data-area='<%# HotelInArea(Eval("Lat"), Eval("Lng")) %>'
                                        onclick='routeToHotel(<%# Eval("HotelID") %>)'>

                                        <div class="relative h-24 overflow-hidden bg-slate-100">
                                            <span class="absolute inset-0 flex items-center justify-center text-slate-300">
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6"><path stroke-linecap="round" stroke-linejoin="round" d="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"/></svg>
                                            </span>
                                            <%# HotelPhotoTag(Eval("LogoPhotoUrl")) %>
                                            <span class="hotel-check absolute top-2 right-2 w-5 h-5 rounded-full bg-blue-600 text-white flex items-center justify-center shadow-sm" style="display:none">
                                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>
                                            </span>
                                        </div>

                                        <div class="p-3">
                                            <div class="hotel-name text-[13px] font-bold text-slate-900 truncate"><%# HotelText(Eval("Name")) %></div>
                                            <%# HotelAddressTag(Eval("Address")) %>
                                            <%# HotelPhoneTag(Eval("Phone")) %>
                                            <%# HotelMapTag(Eval("Lat"), Eval("Lng")) %>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </section>
                </asp:Panel>
            </div>

            <%-- ============ Summary + confirm ============
                 Trip Summary: what the fare is made of, then the same
                 vehicle/passenger/payment controls and the Confirm button as before. The
                 route itself is left to the map and the Route Points panel beside it -
                 repeating every place name here only made the summary long enough to
                 push the Confirm button below the fold. --%>
            <div class="lg:col-span-1">
                <div class="bg-white rounded-2xl border border-slate-100 p-6 shadow-sm/50 space-y-4 lg:sticky lg:top-6">
                    <div class="flex items-center justify-between gap-3">
                        <h2 class="text-[15px] font-bold text-slate-900">Trip Summary</h2>
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-blue-50 text-blue-700 text-[11px] font-semibold shrink-0">
                            <span class="size-1.5 rounded-full bg-blue-600"></span>Live
                        </span>
                    </div>

                    <div class="flex flex-col gap-2">
                        <%-- Same pattern as the payment brands: the cards are the selector and the
                             real DropDownList stays hidden because it is what posts back and what
                             the server re-reads on Confirm. --%>
                        <span class="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Vehicle</span>
                        <asp:DropDownList ID="ddlVehicle" runat="server" CssClass="hidden" CausesValidation="false" />
                        <div id="vehicleGrid" class="grid grid-cols-1 sm:grid-cols-2 gap-2"></div>
                    </div>

                    <div class="flex flex-col gap-1.5">
                        <label class="text-[11px] font-semibold uppercase tracking-wider text-slate-400" for="<%= ddlPassengers.ClientID %>">Passengers</label>
                        <%-- One list, showing every number the chosen vehicle can actually
                             carry: 1-10 for the VIP van, 1-4 for a saloon or tuk tuk, and a
                             single 1 for the motorbike. paintPassengerOptions() rewrites these
                             options from the real seat capacity, and CheckCapacity re-checks
                             the posted value on the server. --%>
                        <asp:DropDownList ID="ddlPassengers" runat="server" CssClass="tw-input">
                            <asp:ListItem Value="1" Text="1" />
                            <asp:ListItem Value="2" Text="2" />
                            <asp:ListItem Value="3" Text="3" />
                            <asp:ListItem Value="4" Text="4" />
                            <asp:ListItem Value="5" Text="5" />
                            <asp:ListItem Value="6" Text="6" />
                            <asp:ListItem Value="7" Text="7" />
                            <asp:ListItem Value="8" Text="8" />
                            <asp:ListItem Value="9" Text="9" />
                            <asp:ListItem Value="10" Text="10" />
                        </asp:DropDownList>
                        <p id="lblPaxWarn" class="text-[11px] text-slate-400"></p>
                    </div>

                    <div class="border-t border-slate-100 pt-4">
                        <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400 mb-3">Fare Breakdown</div>

                        <div class="space-y-2.5 text-[13px]">
                            <div class="flex items-center justify-between gap-3">
                                <span class="text-slate-500">Service</span>
                                <span class="font-semibold text-slate-800 text-right"><asp:Label ID="lblServiceLabel" runat="server" Text="Point-to-Point" /></span>
                            </div>
                            <div id="rowSumDistance" class="flex items-center justify-between gap-3">
                                <span class="text-slate-500">Distance</span>
                                <span class="font-semibold text-slate-800"><span id="lblDistance">--</span></span>
                            </div>
                            <div id="rowSumPerKm" class="flex items-center justify-between gap-3">
                                <span class="text-slate-500">Mileage charge</span>
                                <span class="font-semibold text-slate-800"><span id="lblSumPerKm">--</span>
                                    <span class="text-slate-400 font-normal">(<span id="lblSumPerKmRate">--</span>)</span></span>
                            </div>
                            <div id="rowSumDuration" class="flex items-center justify-between gap-3">
                                <span class="text-slate-500">Duration</span>
                                <span class="font-semibold text-slate-800"><span id="lblSumDuration">--</span>
                                    <span class="text-slate-400 font-normal">(<span id="lblSumHourRate">--</span>)</span></span>
                            </div>
                            <div id="rowSumPackage" class="flex items-center justify-between gap-3">
                                <span class="text-slate-500">Package daypass</span>
                                <span class="font-semibold text-slate-800"><span id="lblSumPackage">--</span></span>
                            </div>
                        </div>
                    </div>

                    <div class="border-t border-slate-100 pt-4">
                        <%-- The brand cards are the only selector. The value is posted through a
                             hidden field and re-validated against AllowedPaymentMethods on the
                             server, so a tampered post cannot invent a payment method. --%>
                        <asp:HiddenField ID="hfPayment" runat="server" Value="Cash" />

                        <div class="mb-2">
                            <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Payment</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Pay the driver directly</div>
                        </div>
                        <div class="grid grid-cols-3 gap-1 rounded-xl bg-slate-100 p-1" role="group" aria-label="Payment method">
                            <button type="button" class="tw-pay-seg" data-pay="KPay" aria-pressed="false" onclick="pickPayment('KPay');">
                                <span class="tw-pay-logo"><img src="<%= ResolveUrl("~/KPay.jpeg") %>" alt="KPay"
                                    class="object-contain" onerror="this.style.visibility='hidden';" /></span>
                                <span>KPay</span>
                            </button>
                            <button type="button" class="tw-pay-seg" data-pay="WavePay" aria-pressed="false" onclick="pickPayment('WavePay');">
                                <span class="tw-pay-logo"><img src="<%= ResolveUrl("~/Wavepay.jpeg") %>" alt="WavePay"
                                    class="object-contain" onerror="this.style.visibility='hidden';" /></span>
                                <span>WavePay</span>
                            </button>
                            <button type="button" class="tw-pay-seg" data-pay="Cash" aria-pressed="false" onclick="pickPayment('Cash');">
                                <span class="tw-pay-logo"><img src="<%= ResolveUrl("~/Cash.png") %>" alt="Cash"
                                    class="object-contain" onerror="this.style.visibility='hidden';" /></span>
                                <span>Cash</span>
                            </button>
                        </div>
                    </div>

                    <div class="border-t border-slate-100 pt-4 flex items-end justify-between gap-3">
                        <div>
                            <div class="text-[11px] font-semibold uppercase tracking-wider text-slate-400">Total Estimate</div>
                            <div class="text-[11px] text-slate-400 mt-0.5">Fixed upfront &mdash; no surge</div>
                        </div>
                        <div id="lblEstimate" class="text-2xl font-bold text-blue-700 leading-none">--</div>
                    </div>

                    <asp:HiddenField ID="hfPickupLat" runat="server" />
                    <asp:HiddenField ID="hfPickupLng" runat="server" />
                    <asp:HiddenField ID="hfPickupAddr" runat="server" />
                    <asp:HiddenField ID="hfDropLat" runat="server" />
                    <asp:HiddenField ID="hfDropLng" runat="server" />
                    <asp:HiddenField ID="hfDropAddr" runat="server" />
                    <asp:HiddenField ID="hfStops" runat="server" />
                    <asp:HiddenField ID="hfHotelId" runat="server" />
                    <asp:HiddenField ID="hfKm" runat="server" />
                    <asp:HiddenField ID="hfFare" runat="server" />

                    <%-- Only shown while one of this customer's trips is still in flight. The
                         Confirm button is dead in that state, so it says why here and links to
                         the trip, rather than leaving a button that silently does nothing. --%>
                    <asp:Panel ID="pnlActiveTrip" runat="server" Visible="false"
                        CssClass="mb-3 rounded-xl border border-amber-200 bg-amber-50 px-3 py-2.5">
                        <p class="text-[13px] font-semibold text-amber-800">You already have a trip in progress.</p>
                        <p class="text-[11px] text-amber-700 mt-0.5">Finish or cancel it before booking another one.</p>
                        <a href="ActiveTrip.aspx" class="tw-btn-outline mt-2 !py-1.5 !text-xs inline-flex items-center gap-1.5">View your active trip</a>
                    </asp:Panel>

                    <asp:Button ID="btnCreateTrip" runat="server" Text="Confirm &amp; Request Driver" OnClick="btnCreateTrip_Click"
                        OnClientClick="return confirmReadyToSubmit();"
                        CssClass="tw-btn-primary w-full justify-center rounded-xl" />

                    <p class="text-[11px] text-slate-400 text-center">No charge until a driver accepts your trip.</p>
                </div>
            </div>
        </div>
    </div>

    <script src="<%= ResolveUrl("~/Scripts/leaflet.js") %>"></script>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/leaflet/leaflet.css") %>" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script>
        var RATES = <%= FareJson %>;
        var VEHICLES = <%= VehicleJson %>;
        var PACKS = <%= PackageJson %>;
        var HOTELS = <%= HotelJson %>;

        var currentService = { '1': 'p2p', '2': 'hourly', '3': 'package' }['<%= ServiceTypeJson %>'] || 'p2p';
        var STAGE = { start: 'start', waypoint: 'waypoint', end: 'end' };
        var pointStage = STAGE.start;
        var route = { points: [], hasEnd: false };
        var map = null, markers = [], roadLine = null, hotelMarker = null;
        var roadKm = 0, roadMinutes = 0, roadReady = false;
        var itinerary = [], stopMarkers = [];

        function fmtDriveTime(min) {
            if (!min || min <= 0) return '—';
            if (min < 60) return min + ' min';
            var h = Math.floor(min / 60), m = Math.round(min % 60);
            return m === 0 ? h + ' h' : h + ' h ' + m + ' min';
        }

        function setRoadInfo(distanceText, timeText, statusText, showRetry) {
            var d = document.getElementById('lblRoadDistance');
            var t = document.getElementById('lblRoadTime');
            var s = document.getElementById('lblRoadStatus');
            var b = document.getElementById('btnRoadRetry');
            if (d) d.innerHTML = 'Road distance <strong>' + distanceText + '</strong>';
            if (t) t.innerHTML = 'Drive time <strong>' + timeText + '</strong>';
            if (s) s.textContent = statusText;
            if (b) b.classList.toggle('hidden', !showRetry);
        }

        function haversine(a, b) {
            var R = 6371, dLat = (b[0] - a[0]) * Math.PI / 180, dLng = (b[1] - a[1]) * Math.PI / 180;
            var s = Math.sin(dLat / 2) * Math.sin(dLat / 2) + Math.cos(a[0] * Math.PI / 180) * Math.cos(b[0] * Math.PI / 180)
                * Math.sin(dLng / 2) * Math.sin(dLng / 2);
            return R * (2 * Math.atan2(Math.sqrt(s), Math.sqrt(1 - s)));
        }
        function roundFare(v) { return Math.round(v / 100) * 100; }
        function fmtKm(km) { return km ? km.toFixed(1) + ' km' : '--'; }
        function fmtKs(v) { return v ? 'MMK ' + Number(v).toLocaleString('en-US') : '--'; }

        // Everything rendered into innerHTML below is either from PACKS or from a reverse
        // geocoder, so it is escaped once here instead of trusting the source.
        function enc(value) {
            return String(value == null ? '' : value)
                .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
        }

        /// <summary>
        /// The three services are numbered sections, so the step numbers and titles have to
        /// follow the service: point-to-point only has a route (2), while hourly and package
        /// add their own section first and push the map down to 3.
        /// </summary>
        function paintServiceSteps() {
            var routeStep = document.getElementById('lblStepRoute');
            var routeTitle = document.getElementById('lblTitleRoute');
            var hourStep = document.getElementById('lblStepHourly');
            var hourTitle = document.getElementById('lblTitleHourly');
            var packStep = document.getElementById('lblStepPackage');
            var packTitle = document.getElementById('lblTitlePackage');

            if (routeStep) routeStep.textContent = currentService === 'p2p' ? '2.' : '3.';
            if (routeTitle) {
                routeTitle.textContent = currentService === 'package' ? 'Tour Circuit Map'
                    : (currentService === 'hourly' ? 'Pickup & Standby Route' : 'Route & Stops');
            }
            if (hourStep) hourStep.textContent = '2.';
            if (hourTitle) hourTitle.textContent = 'Hourly Charter';
            if (packStep) packStep.textContent = '2.';
            if (packTitle) packTitle.textContent = 'Curated Package Circuit';

            // The picker is "Start" only when the customer also has to set a destination.
            var pickupBtn = document.getElementById('btnModePickup');
            if (pickupBtn) pickupBtn.textContent = currentService === 'p2p' ? 'Start' : 'Pickup';
        }

        // =====================================================================
        // SERVICE AREA
        // ---------------------------------------------------------------------
        // A point is accepted when REVERSE GEOCODING returns an address that
        // mentions Hpa-An. The click is turned into a place name with Nominatim
        // and that text is matched, instead of testing the raw coordinates
        // against a radius.
        //
        // The dashed circle is still drawn (it is a useful visual guide) but it
        // is no longer what decides whether a point is accepted.
        //
        // NOTE: the helper is referenced as global::TripWay.Helper.TripHelper
        // because inline markup expressions are compiled inside "namespace ASP",
        // where the short name "Helper" does not resolve. (That literal tag pair
        // must not be written out in a comment here: the ASPX parser scans raw
        // text for it and would try to compile the comment as an expression.)
        // =====================================================================
        var SERVICE_AREA = {
            center: {
                lat: <%= global::TripWay.Helper.TripHelper.ServiceAreaLat.ToString("R", System.Globalization.CultureInfo.InvariantCulture) %>,
                lng: <%= global::TripWay.Helper.TripHelper.ServiceAreaLng.ToString("R", System.Globalization.CultureInfo.InvariantCulture) %>
            },
            message: '<%= Server.HtmlEncode(global::TripWay.Helper.TripHelper.ServiceAreaMessage) %>',

            // --- address text matching -------------------------------------
            // The customer may click anywhere on the map. The point is only
            // accepted when the address Nominatim returns for it is in
            // Hpa-An Township, so this is the whole service-area rule - there
            // is no drawn boundary and no radius check on this side.
            matchNames: ['hpa-an township'],

            // Shown under the English message when a point is refused.
            messageBurmese: 'ဝန်ဆောင်မှုမပေးပါ'
        };

        // =====================================================================
        // ADDRESS TEXT VALIDATION (reverse geocoding)
        //
        // The customer can click anywhere on the map. A point is accepted only
        // when the address Nominatim returns for it is in Hpa-An Township.
        //
        // Reverse geocoding is a network call, so this is asynchronous.
        // Everything that places a point therefore goes through
        // validateByAddress() first and only calls choosePoint() once

        // the address has been cleared.
        // =====================================================================

        // Sequence token: reverse lookups are slow, so a user tapping twice can
        // get two answers back out of order. Only the newest click is allowed to
        // place a point; older replies are dropped.
        var areaCheckSeq = 0;

        // How many reverse lookups are in flight right now.
        //
        // A point only reaches route.points, and so the hidden fields the server reads, once
        // the Nominatim lookup for it comes back. Confirm used to post whenever it was clicked,
        // so a customer who tapped the map and reached for Confirm straight away posted a form
        // that still described the previous state - and was then told to set a point they had
        // just set, or, worse, booked a trip to the wrong place. Whether it failed depended
        // purely on how long the network took, which is why it looked random. Confirm now waits
        // for the map to catch up instead.
        var pendingPointChecks = 0;

        // Nominatim allows roughly a request per second and answers 403 when pushed, and a
        // dropped connection can leave the fetch pending indefinitely. Without this the button
        // would stay disabled forever and the trip could not be booked at all, which is a worse
        // failure than the one being fixed. On expiry the page stops pretending it is still
        // waiting: a point that never arrives was never going to reach the server either.
        var pointCheckStallMs = 8000;
        var pointCheckStallTimer = null;

        // Page_Load disables Confirm outright when the customer already has a trip in flight,
        // and renders that as a disabled button. Remembered so re-enabling after a point check
        // cannot undo the server's decision.
        var confirmBlockedByServer = false;

        // Set once the form is on its way to the server, so a point check that lands while the
        // post is still in flight cannot hand the customer a live button and invite a second
        // booking. Nothing clears it: either the response navigates away, or the page reloads
        // with a fresh button.
        var confirmSubmitting = false;

        function syncConfirmAvailability() {
            var btn = document.getElementById('<%= btnCreateTrip.ClientID %>');
            if (!btn) return;

            if (confirmSubmitting) {
                btn.disabled = true;
                btn.classList.add('opacity-60', 'cursor-not-allowed');
                return;
            }

            if (pendingPointChecks > 0) {
                btn.disabled = true;
                btn.classList.add('opacity-60', 'cursor-not-allowed');
                if (pointCheckStallTimer) clearTimeout(pointCheckStallTimer);
                pointCheckStallTimer = setTimeout(function () {
                    pointCheckStallTimer = null;
                    pendingPointChecks = 0;
                    syncConfirmAvailability();
                }, pointCheckStallMs);
                return;
            }

            if (pointCheckStallTimer) { clearTimeout(pointCheckStallTimer); pointCheckStallTimer = null; }
            if (confirmBlockedByServer) return;   // leave the server's own disabled state alone
            btn.disabled = false;
            btn.classList.remove('opacity-60', 'cursor-not-allowed');
        }

        function beginPointCheck() {
            pendingPointChecks++;
            syncConfirmAvailability();
        }

        function endPointCheck() {
            pendingPointChecks = Math.max(0, pendingPointChecks - 1);
            syncConfirmAvailability();
        }

        // Belt and braces for the paths that do not go through the button: Enter on the confirm
        // button is a real click, and a hand-triggered form.submit() is still reachable from the
        // console. Both must wait too, rather than posting a half-updated form.
        //
        // Taking the lock here also replaces the guard the client-side redirect used to carry.
        // That disabled the button just before navigating, which no longer exists because the
        // redirect is the server's job now, and a button left live while the post is in flight
        // can be pressed twice and book two trips. Disabling on the way out closes that gap.
        function confirmReadyToSubmit() {
            if (pendingPointChecks > 0) {
                var pending = document.getElementById('<%= btnCreateTrip.ClientID %>');
                if (pending) pending.focus();
                return false;
            }

            // The lock is taken in a timeout, never inline in this handler. Disabling a submit
            // button while its own click is still being processed can cancel the submission
            // outright: the form never posts, the page never reloads, and because nothing
            // clears the flag the button stays dead for the rest of the session. That is what
            // this did when it ran inline, and the result was a Confirm button that disabled
            // itself and never booked anything. Letting the click finish first means the
            // submit always goes, and the button still goes dead before a second click can
            // reach the server.
            setTimeout(function () {
                confirmSubmitting = true;
                syncConfirmAvailability();
            }, 0);
            return true;
        }

        // Small cache so dragging/zooming and repeated taps on the same spot do
        // not hammer the public Nominatim instance, which allows roughly one
        // request per second.
        var reverseCache = {};
        function reverseCacheKey(lat, lng) { return lat.toFixed(4) + ',' + lng.toFixed(4); }

        /// <summary>
        /// True when the address text mentions one of the accepted place names.
        /// Case-insensitive, and tolerant of the spacing variants Nominatim uses
        /// ("Hpa-An", "Hpa An", "HPA_AN") plus the Burmese name.
        /// </summary>
        function addressIsAllowed(text) {
            if (!text) return false;
            var hay = String(text).toLowerCase();
            var names = SERVICE_AREA.matchNames || [];
            for (var i = 0; i < names.length; i++) {
                if (hay.indexOf(String(names[i]).toLowerCase()) !== -1) return true;
            }
            return false;
        }

        /// <summary>
        /// Coordinate check for points that come from the database (hotels) rather than from a
        /// map tap. Each hotel row carries the answer from the same helper the booking server
        /// uses, so both sides agree without duplicating the rule in script.
        /// </summary>
        function inServiceArea(hotelId) {
            var el = document.querySelector('[data-hotel-card="' + String(hotelId) + '"]');
            return !el || el.getAttribute('data-area') === '1';
        }

        /// <summary>
        /// Reverse geocodes a coordinate and hands the address text to cb(text, ok).
        /// "ok" is false when the lookup failed or came back empty, so the caller
        /// can tell a genuine "outside Hpa-An" apart from "the geocoder is down".
        ///
        /// Deliberately fails OPEN: if Nominatim is unreachable, rate limited or
        /// returns nothing, the point is not rejected here. The server still
        /// enforces the real boundary when the booking is posted, so failing open
        /// cannot produce an out-of-area booking - it only means the friendly
        /// early warning is skipped while the geocoder is unavailable.
        /// </summary>
        function reverseLookup(lat, lng, cb) {
            var key = reverseCacheKey(lat, lng);
            if (reverseCache[key] !== undefined) { cb(reverseCache[key], true); return; }

            var url = 'https://nominatim.openstreetmap.org/reverse?format=json&zoom=14&addressdetails=1'
                + '&lat=' + encodeURIComponent(lat) + '&lon=' + encodeURIComponent(lng);

            fetch(url)
                .then(function (r) {
                    if (!r.ok) throw new Error('reverse geocode HTTP ' + r.status);
                    return r.json();
                })
                .then(function (j) {
                    var text = j && j.display_name ? j.display_name : '';
                    reverseCache[key] = text;
                    cb(text, !!text);
                })
                .catch(function () {
                    // Network down, offline, or 403 from the rate limiter.
                    cb('', false);
                });
        }

        /// <summary>
        /// The gate for every way a coordinate can enter the route. Calls back
        /// with the address to store, or with null when the point was refused.
        /// Callers must not touch any route state before the callback fires.
        ///
        /// There is no radius or boundary check here on purpose: the customer may
        /// click any point on the map, and the address text alone decides.
        /// </summary>
        function validateByAddress(lat, lng, cb) {
            var seq = ++areaCheckSeq;

            reverseLookup(lat, lng, function (text, ok) {
                // A newer click happened while this one was in flight: drop the answer, but
                // still call back. Returning silently here used to leave the caller's pending
                // check outstanding, because the count is released by the callback and this
                // branch never reached it. Tapping the map twice - which is how a start and a
                // destination are normally set - leaked one count per superseded click, and
                // Confirm stayed disabled long after the map had settled. A superseded click
                // reports as refused so nothing on the page changes and no error is shown,
                // since the newer click is the one being honoured.
                if (seq !== areaCheckSeq) { cb(null); return; }

                if (!ok) {
                    // Geocoder unavailable - fail open and let the server decide.
                    // A coordinate pair is never used as the label: it would surface in
                    // the route list, the summary chips and Trips.PickupAddress. The
                    // numbers already live in PickupLat/PickupLng, which is what the
                    // driver's map and the live API navigate by.
                    clearAreaError();
                    cb(text || 'Pinned point');
                    return;
                }

                if (!addressIsAllowed(text)) {
                    showAreaError(lat, lng);
                    cb(null);
                    return;
                }

                clearAreaError();
                cb(text);
            });
        }

        function clearAreaError() {
            var el = document.getElementById('lblAreaError');
            var text = document.getElementById('lblAreaErrorText');
            if (text) text.textContent = '';
            if (el) el.classList.add('hidden');
        }

        /// <summary>
        /// Tells the user the point is out of area. Shows an inline banner and,
        /// when the map is up, a popup pinned to the spot that was refused.
        /// </summary>
        function showAreaError(lat, lng) {
            var msg = SERVICE_AREA.message;

            var el = document.getElementById('lblAreaError');
            var text = document.getElementById('lblAreaErrorText');
            if (text) {
                text.textContent = SERVICE_AREA.messageBurmese
                    ? msg + ' — ' + SERVICE_AREA.messageBurmese
                    : msg;
            }
            if (el) el.classList.remove('hidden');

            if (typeof L === 'undefined' || !map) return;

            try {
                L.popup({ closeButton: false, autoPan: false })
                    .setLatLng([lat, lng])
                    .setContent('<div style="font:500 12px/1.45 ui-sans-serif,system-ui,sans-serif;color:#92400e;'
                        + 'background:#fffbeb;border:1px solid #fde68a;padding:7px 10px;border-radius:10px;'
                        + 'box-shadow:0 8px 20px rgba(0,0,0,.10)">'
                        + msg + '</div>')
                    .openOn(map);

                setTimeout(function () { map.closePopup(); }, 3200);
            } catch (e) { }
        }

        /// <summary>
        /// One explicit state for "what will the next map click do?". Driving the buttons and
        /// the clicks from a single stage is what stops a second tap from landing on the Start.
        /// </summary>
        function setPointStage(stage) {
            if (currentService === 'package' && stage !== STAGE.start) return;
            pointStage = stage;
            // These three buttons live in the map panel. They are looked up by id and written to
            // unguarded, so if the map panel is not in the document this threw a TypeError on the
            // very first line of the page's DOMContentLoaded handler. An exception there stops
            // every later line from running, which left the hour grid empty and the service cards
            // showing their server placeholder: the page looked like it had no prices on it.
            var modes = [['btnModePickup', STAGE.start], ['btnModeStop', STAGE.waypoint], ['btnModeDrop', STAGE.end]];
            for (var i = 0; i < modes.length; i++) {
                var btn = document.getElementById(modes[i][0]);
                if (btn) btn.className = modes[i][1] === stage ? 'tw-btn-primary' : 'tw-btn-outline';
            }
            updateMapHint();
        }

        // Kept so the existing Start / + Point / End buttons keep working unchanged.
        function setPinMode(mode) {
            if (mode === 'pickup') setPointStage(STAGE.start);
            else if (mode === 'stop') setPointStage(STAGE.waypoint);
            else setPointStage(STAGE.end);
        }

        function updateMapHint() {
            var hint = document.getElementById('lblMapHint');
            if (!hint) return;
            if (currentService === 'package') return;
            if (currentService === 'hourly') { hint.textContent = 'Tap the map to set the pickup point.'; return; }
            if (pointStage === STAGE.start) hint.textContent = 'Tap the map to set the Start point.';
            else if (pointStage === STAGE.waypoint) hint.textContent = 'Tap the map to add another point before the destination.';
            else hint.textContent = 'Tap the map to set the End point. Your Start point stays where it is.';
        }

        function setHidden(id, value) {
            var el = document.getElementById(id);
            if (el) el.value = value;
        }

        /// <summary>
        /// Applies a map click to the current stage. Returns false when the
        /// click was refused, so callers can stop before touching any other state.
        ///
        /// The out-of-area gate runs first: a rejected point must not reach the
        /// route array, must not clear a chosen hotel, and must not move the End.
        ///
        /// The invariant that fixes the reported bug: points[0] is the Start and is only ever
        /// written while the stage is "start". Once the Start exists the stage moves to "end",
        /// so a second click can never land back on the Start. The End branch replaces the LAST
        /// point and appends instead of overwriting when only a Start exists.
        /// </summary>
        function choosePoint(lat, lng, addr) {
            var p = { lat: lat, lng: lng, addr: addr };
            var pts = route.points, n = pts.length;

            if (pointStage === STAGE.start) {
                if (n === 0) pts.push(p); else pts[0] = p;
                // Point-to-point is the only service with a destination, so only then advance.
                // Hourly and package re-place the pickup on every tap instead.
                if (currentService === 'p2p') setPointStage(STAGE.end);
                return true;
            }

            if (pointStage === STAGE.waypoint) {
                // Stay in this stage so several waypoints can be added in a row. Until an End
                // exists they simply append, which keeps them in the order they were clicked;
                // once there is a destination they are inserted in front of it.
                if (route.hasEnd) pts.splice(n - 1, 0, p);
                else pts.push(p);
                return true;
            }

            // End. pts[0] is the Start and is never touched from here.
            if (n === 0) { pts.push(p); route.hasEnd = true; setPointStage(STAGE.start); }
            else if (n === 1) pts.push(p);          // only a Start so far: append, do not overwrite
            else if (route.hasEnd) pts[n - 1] = p;   // move the existing destination
            else { pts.push(p); route.hasEnd = true; } // no destination yet: keep the waypoints
            return true;
        }

        function placePoint(lat, lng, onOk) {
            // Address text decides this, not the coordinates. Nothing on the page
            // changes until the reverse lookup comes back and passes: a rejected
            // click must not move a pin, clear the chosen hotel or shift the End.
            beginPointCheck();
            validateByAddress(lat, lng, function (addr) {
                // One release point rather than one per exit. Confirm is disabled for as long
                // as this count is above zero, so any path that forgot to release it - a
                // throw from redrawRoute, a callback that misbehaves - left the customer
                // unable to book at all. finally makes that impossible.
                try {
                    if (addr === null) return;      // refused or superseded

                    // Read the stage now, because choosePoint may advance or reset it.
                    var wasEndStage = (pointStage === STAGE.end);

                    if (!choosePoint(lat, lng, addr)) return;
                    // Moving the destination by hand means it is no longer the chosen hotel.
                    if (wasEndStage) clearHotelSelection();
                    redrawRoute();
                    if (typeof onOk === 'function') onOk();
                } finally {
                    endPointCheck();
                }
            });
        }

        function pointColor(index) {
            var total = route.points.length;
            return index === 0 ? 'bg-emerald-500' : (index === total - 1 ? 'bg-rose-500' : 'bg-blue-500');
        }

        function removePoint(index) {
            if (index === route.points.length - 1) { clearHotelSelection(); route.hasEnd = false; }
            route.points.splice(index, 1);
            // Only a Start left means the next click should set the destination again.
            if (route.points.length === 0) { route.hasEnd = false; setPointStage(STAGE.start); }
            else if (route.points.length === 1 && currentService === 'p2p') setPointStage(STAGE.end);
            redrawRoute();
        }

        // The brand cards are the selector; the value travels in a hidden field and is
        // re-validated server-side against AllowedPaymentMethods.
        function pickPayment(value) {
            var field = document.getElementById('<%= hfPayment.ClientID %>');
            if (field) field.value = value;
            syncPaymentCards();
        }

        function syncPaymentCards() {
            var field = document.getElementById('<%= hfPayment.ClientID %>');
            var current = field ? field.value : '';
            var segs = document.querySelectorAll('.tw-pay-seg');
            for (var i = 0; i < segs.length; i++) {
                var match = segs[i].getAttribute('data-pay') === current;
                segs[i].classList.toggle('is-active', match);
                // The fill is the only visual cue, so state it for assistive tech too.
                segs[i].setAttribute('aria-pressed', match ? 'true' : 'false');
            }
        }

        function redrawRoute() {
            if (!map) return;
            paintServiceSteps();
            while (markers.length) { map.removeLayer(markers.pop()); }
            var html = '', pts = route.points;
            for (var i = 0; i < pts.length; i++) {
                var color = pointColor(i);
                markers.push(L.marker([pts[i].lat, pts[i].lng], {
                    icon: L.divIcon({ className: '', html: '<span class="block size-5 rounded-full ' + color + ' border-2 border-white shadow"></span>' })
                }).addTo(map).bindTooltip(pts[i].addr || 'Point ' + (i + 1), { direction: 'top', offset: L.point(0, -14) }));
                html += '<div class="flex items-center gap-3 p-3.5 rounded-xl bg-white border border-slate-100">'
                    + '<div class="w-8 h-8 rounded-lg ' + nodeBadge(i, pts.length) + ' flex items-center justify-center font-bold text-[11px] shrink-0">' + nodeLetter(i) + '</div>'
                    + '<div class="min-w-0 flex-1">'
                    + '<div class="text-[10px] font-semibold uppercase tracking-wider ' + nodeLabelColor(i, pts.length) + '">' + nodeLabel(i, pts.length) + '</div>'
                    + '<div class="text-[13px] font-semibold text-slate-800 truncate">' + enc(pts[i].addr || 'Pinned point') + '</div>'
                    + '</div>'
                    + '<button type="button" onclick="removePoint(' + i + ')" class="inline-flex items-center justify-center size-7 rounded-md text-slate-400 hover:text-red-500 hover:bg-red-50 transition-colors shrink-0" title="Remove this point">'
                    + '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12"/></svg>'
                    + '</button>'
                    + '</div>';
            }
            if (!html) {
                html = '<div class="p-3.5 rounded-xl border border-dashed border-slate-200 text-[11px] text-slate-400 text-center">'
                    + 'No points yet &mdash; tap the map to add your pickup point.</div>';
            }
            document.getElementById('routePoints').innerHTML = html;

            paintPackageRoute();
            drawRoadRoute();
            syncHidden();
            recomputeFare();
        }

        // Node badge, letter and label for the route list: A pickup, B/C stops, last one the
        // drop-off, so the list reads like a driver run sheet.
        function nodeLetter(i) {
            return i === 0 ? 'A' : (i === 1 ? 'B' : (i === 2 ? 'C' : (i + 1)));
        }

        function nodeLabel(i, total) {
            if (i === 0) return 'Pickup';
            if (i === total - 1) return 'Drop-off';
            return 'Stop ' + nodeLetter(i);
        }

        function nodeBadge(i, total) {
            if (i === 0) return 'bg-emerald-50 text-emerald-600';
            if (i === total - 1) return 'bg-rose-50 text-rose-600';
            return 'bg-blue-50 text-blue-600';
        }

        function nodeLabelColor(i, total) {
            if (i === 0) return 'text-emerald-600';
            if (i === total - 1) return 'text-rose-600';
            return 'text-blue-600';
        }

        /// <summary>
        /// Points the road line follows: whatever the customer picked, then the package
        /// itinerary stops (skipped when the customer already pinned the same spot).
        /// </summary>
        function pathPoints() {
            var pts = route.points.slice();
            for (var i = 0; i < itinerary.length; i++) {
                var s = itinerary[i], dup = false;
                for (var j = 0; j < pts.length; j++) {
                    if (Math.abs(pts[j].lat - s.lat) < 0.000001 && Math.abs(pts[j].lng - s.lng) < 0.000001) { dup = true; break; }
                }
                if (!dup) pts.push({ lat: s.lat, lng: s.lng, addr: s.name });
            }
            return pts;
        }

        function drawStopMarkers() {
            if (!map) return;
            while (stopMarkers.length) { map.removeLayer(stopMarkers.pop()); }
            for (var i = 0; i < itinerary.length; i++) {
                var s = itinerary[i];
                stopMarkers.push(L.marker([s.lat, s.lng], {
                    icon: L.divIcon({
                        className: '',
                        html: '<span class="block size-6 rounded-md bg-blue-600 text-white text-[11px] font-bold border-2 border-white shadow flex items-center justify-center">' + (i + 1) + '</span>'
                    })
                }).addTo(map).bindTooltip(s.name, { direction: 'top', offset: L.point(0, -16) }));
            }
        }

        /// <summary>
        /// Asks the routing service for the real road line through every picked point and shows
        /// the road distance / drive time. A dashed straight line stands in while loading and
        /// stays if routing is unavailable, so the map is never empty.
        /// </summary>
        /// <summary>
        /// Word in the metrics bar. A package ends back at the pickup, so it says so instead
        /// of the point count, which is already shown by the stop chip.
        /// </summary>
        function roadStatusText(pts) {
            if (currentService === 'package') {
                var back = route.points[0];
                return 'Return to ' + (back ? (back.addr || 'your pickup point') : 'your pickup point') + '.';
            }
            return 'Road route through ' + pts.length + ' point(s).';
        }

        function drawRoadRoute() {
            if (!map) return;
            var pts = pathPoints();
            if (roadLine) { roadLine.clear(); roadLine = null; }
            roadKm = 0; roadMinutes = 0; roadReady = false;

            if (!TripRoute.isRouteable(pts)) {
                setRoadInfo('\u2014', '\u2014', pts.length
                    ? 'Add an end point to see the road route.'
                    : (itinerary.length ? 'Tap the map to add your pickup point.' : 'Add a start and an end to see the road route.'), false);
                if (pts.length) map.fitBounds(L.latLngBounds(pts.map(function (p) { return [p.lat, p.lng]; })).pad(0.3));
                return;
            }

            setRoadInfo('calculating\u2026', 'calculating\u2026', 'Working out the road route\u2026', false);
            roadLine = TripRoute.create(map, pts, {
                weight: 6,
                onRoad: function (info) {
                    roadReady = true; roadKm = info.km; roadMinutes = info.minutes;
                    setRoadInfo(fmtKm(roadKm), fmtDriveTime(roadMinutes), roadStatusText(pts), false);
                    paintPackageRoute();
                    if (currentService === 'p2p' && roadKm > 0) {
                        document.getElementById('lblDistance').textContent = fmtKm(roadKm) + ' road';
                    }
                },
                onFail: function () {
                    setRoadInfo('\u2014', '\u2014', 'Could not load the road route \u2014 the dashed line is a straight-line guide.', true);
                }
            });
        }

        function syncHidden() {
            var pts = route.points, first = pts[0], last = pts.length ? pts[pts.length - 1] : null;
            setHidden('<%= hfPickupLat.ClientID %>', first ? first.lat : '');
            setHidden('<%= hfPickupLng.ClientID %>', first ? first.lng : '');
            setHidden('<%= hfPickupAddr.ClientID %>', first ? (first.addr || '') : '');
            setHidden('<%= hfDropLat.ClientID %>', last ? last.lat : '');
            setHidden('<%= hfDropLng.ClientID %>', last ? last.lng : '');
            setHidden('<%= hfDropAddr.ClientID %>', last ? (last.addr || '') : '');
            var mids = pts.slice(1, Math.max(1, pts.length - 1)).map(function (p) { return [p.lat, p.lng]; });
            setHidden('<%= hfStops.ClientID %>', JSON.stringify(mids));
        }

        /// <summary>
        /// Says why a hotel cannot be used, in the hotel panel itself. The booking page shows
        /// no toasts for picking things: the chosen card, the map pin and the summary already
        /// show what happened, and the only toast on this page is the result of confirming.
        /// </summary>
        function hotelNote(text) {
            var el = document.getElementById('hotelNote');
            if (!el) return;
            el.textContent = text;
            el.classList.toggle('hidden', !text);
        }

        /// <summary>
        /// Sends the trip to a hotel: makes it the destination pin, remembers the hotel on the
        /// booking, then lets the normal redraw path recompute the road route and the fare.
        /// </summary>
        function routeToHotel(id) {
            try {
                var h = HOTELS[id];
                hotelNote('');
                if (!h) {
                    // The card is on the page but its data is not, which means the two were built
                    // from different rows. Say which hotel it was rather than "choose another",
                    // because the customer cannot act on that and it is our mismatch, not theirs.
                    var card = document.querySelector('[data-hotel-card="' + String(id) + '"] .hotel-name');
                    var named = card ? (card.textContent || '').trim() : '';
                    if (window.console && console.error) console.error('No hotel data for id ' + id);
                    hotelNote((named ? '“' + named + '”' : 'That hotel')
                        + ' cannot be used as a destination right now. Please pick another hotel,'
                        + ' or tap the map to set the point yourself.');
                    return;
                }
                // A hotel saved without coordinates is not bookable either, so say that plainly
                // instead of refusing it as if it were somewhere outside the service area.
                if (!h.ok) {
                    hotelNote('“' + h.name + '” has no map location yet, so it cannot be your '
                        + 'destination. Please contact us or choose another hotel.');
                    return;
                }
                // Appends (or moves) the destination; the Start pin is left untouched.
                setPointStage(STAGE.end);
                // A hotel is an admin-entered point inside the bookable area, so it is checked by
                // coordinate with the same helper the server uses. It is not reverse geocoded:
                // a slow or unavailable geocoder must not stop a hotel from appearing on the map.
                if (!inServiceArea(id)) {
                    showAreaError(h.lat, h.lng);
                    return;
                }
                clearAreaError();
                choosePoint(h.lat, h.lng, h.addr || h.name);
                setHidden('<%= hfHotelId.ClientID %>', String(id));
                redrawRoute();
                drawHotelMarker(h);
                markHotelSelected(id);
                if (map) map.fitBounds(L.latLngBounds(route.points.map(function (p) { return [p.lat, p.lng]; })).pad(0.3));
            } catch (err) {
                if (window.console && console.error) console.error(err);
                hotelNote('Sorry, that hotel could not be set as your destination. Please try again.');
            }
        }

        /// <summary>
        /// The chosen hotel carries its own marker and opens a card on the map with its photo,
        /// name, address and contacts, so the details live on the map rather than in a button.
        /// It goes away with the selection.
        /// </summary>
        function drawHotelMarker(h) {
            clearHotelMarker();
            if (!map) return;
            hotelMarker = L.marker([h.lat, h.lng], {
                icon: L.divIcon({
                    className: '',
                    iconSize: [30, 30],
                    iconAnchor: [15, 15],
                    html: '<span class="flex size-[30px] items-center justify-center rounded-full bg-[#007AFF] text-white ring-2 ring-white shadow">'
                        + '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4">'
                        + '<path stroke-linecap="round" stroke-linejoin="round" d="M3 18v-6a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v6M3 18h18M3 21v-3M21 21v-3M6 10V7a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v3M12 10V7a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v3"/></svg>'
                        + '</span>'
                })
            }).addTo(map);
            hotelMarker.bindPopup(hotelPopupHtml(h), {
                closeButton: true,
                offset: L.point(0, -14),
                maxWidth: 260,
                className: 'tw-hotel-popup'
            });
            hotelMarker.openPopup();
        }

        /// <summary>
        /// The hotel card shown on the map. Text is escaped because it comes from the
        /// Hotels table, and the logo falls back to a placeholder when it is missing.
        /// </summary>
        function hotelPopupHtml(h) {
            function esc(v) {
                return String(v == null ? '' : v)
                    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }
            var photo = h.logo
                ? '<img src="' + esc(h.logo) + '" alt="" class="size-14 rounded-lg object-cover ring-1 ring-gray-200" />'
                : '<span class="size-14 rounded-lg bg-gray-100 border border-dashed border-gray-300 inline-block"></span>';
            var contact = [];
            if (h.phone) contact.push(esc(h.phone));
            if (h.email) contact.push(esc(h.email));
            return '<div class="flex gap-3 items-start">'
                + photo
                + '<div class="min-w-0">'
                + '<div class="font-bold text-gray-900 text-sm leading-tight">' + esc(h.name) + '</div>'
                + (h.addr ? '<div class="text-xs text-gray-500 mt-0.5">' + esc(h.addr) + '</div>' : '')
                + (contact.length ? '<div class="text-xs text-gray-400 mt-0.5">' + contact.join(' &middot; ') + '</div>' : '')
                + '</div></div>';
        }

        function clearHotelMarker() {
            if (hotelMarker && map) map.removeLayer(hotelMarker);
            hotelMarker = null;
        }

        function markHotelSelected(id) {
            var cards = document.querySelectorAll('[data-hotel-card]');
            for (var i = 0; i < cards.length; i++) {
                var on = cards[i].getAttribute('data-hotel-card') === String(id);
                cards[i].classList.toggle('hotel-card-active', on);
                var badge = cards[i].querySelector('.hotel-check');
                if (badge) badge.style.display = on ? '' : 'none';
            }
        }

        // Dropping or removing the destination by hand means it is no longer the hotel.
        function clearHotelSelection() {
            setHidden('<%= hfHotelId.ClientID %>', '');
            markHotelSelected(0);
            clearHotelMarker();
        }

        function getVehicle() { return parseInt(document.getElementById('<%= ddlVehicle.ClientID %>').value, 10) || 0; }
        function getHours() { var h = document.getElementById('<%= ddlHours.ClientID %>'); return h ? (parseInt(h.value, 10) || 0) : 0; }

        /// The hour blocks on sale. Must match the ddlHours ListItems in the markup and the
        /// HourlyHourBlocks array in BookTrip.aspx.cs, which is what actually gets charged.
        var HOUR_BLOCKS = [1, 2, 3, 4, 5, 6, 8];

        /// <summary>
        /// The whole hourly price, and the only place it is worked out on the client.
        ///
        /// Hourly hire is one flat rate for every hour, never on distance:
        ///     fare = HourlyRate x hours
        /// There is no base fare for the first hour and no higher rate for the hours after it,
        /// so 1,000 an hour reads 1h 1,000, 2h 2,000, 3h 3,000 ... 6h 6,000, 8h 8,000.
        ///
        /// A block that is not on sale prices at 0 rather than being extrapolated, so the page
        /// says "Rate unavailable" instead of quoting for hours the server will refuse.
        /// </summary>
        function hourFare(rate, hours) {
            if (!rate || rate.perHour == null) return 0;
            var n = parseInt(hours, 10) || 0;
            if (HOUR_BLOCKS.indexOf(n) < 0) return 0;
            return roundFare(rate.perHour * n);
        }

        function checkPax() {
            var v = getVehicle();
            var pax = parseInt(document.getElementById('<%= ddlPassengers.ClientID %>').value, 10) || 1;
            var info = VEHICLES[v];
            var warnEl = document.getElementById('lblPaxWarn');
            if (!warnEl) return;
            if (!info) {
                warnEl.textContent = '';
                warnEl.className = 'text-[11px] text-slate-400';
                return;
            }
            // The list is already narrowed to this vehicle, so anything outside the range can
            // only be a stale or hand-edited value. Say so instead of quietly booking it.
            if (pax < info.min || pax > info.max) {
                warnEl.textContent = paxLimitText(info) + ' Pick ' + info.min + '–' + info.max + '.';
                warnEl.className = 'text-[11px] text-amber-700 bg-amber-50 border border-amber-200 rounded-lg p-2';
            } else {
                warnEl.textContent = paxLimitText(info);
                warnEl.className = 'text-[11px] text-slate-400';
            }
        }

        /// <summary>
        /// The limit line under the passenger box, worded from the real capacity: a motorbike
        /// carries one rider, everything else reads as "up to N passengers".
        /// </summary>
        function paxLimitText(info) {
            if (info.max <= info.min) return info.name + ' carries ' + info.max + ' passenger' + (info.max === 1 ? '' : 's') + ' only.';
            return 'Up to ' + info.max + ' passengers in ' + info.name + '.';
        }

        /// <summary>
        /// Rebuilds the passenger list from the seats the chosen vehicle actually has, so a
        /// motorbike offers one option and a VIP van offers ten. A selection that is still
        /// legal is kept; anything else falls back to the smallest number that always works.
        /// The value that posts is re-checked by CheckCapacity on the server.
        /// </summary>
        function paintPassengerOptions() {
            var pax = document.getElementById('<%= ddlPassengers.ClientID %>');
            var info = VEHICLES[getVehicle()];
            if (!pax) return;
            // No capacity data for this vehicle: leave the posted list alone, but still repaint
            // the limit line so it cannot keep naming the vehicle that was chosen before.
            if (!info) { checkPax(); return; }

            var wanted = parseInt(pax.value, 10) || 0;
            var html = '';
            for (var n = info.min; n <= info.max; n++) html += '<option value="' + n + '">' + n + '</option>';
            pax.innerHTML = html;
            pax.value = String(wanted >= info.min && wanted <= info.max ? wanted : info.min);
            pax.selectedIndex = parseInt(pax.value, 10) - info.min;
            checkPax();
        }

        function getPaxValue() {
            var el = document.getElementById('<%= ddlPassengers.ClientID %>');
            return el ? (parseInt(el.value, 10) || 0) : 0;
        }

        /// <summary>
        /// Card click drives the hidden DropDownList instead of posting on its own, so the
        /// server still runs ddlServiceType_SelectedIndexChanged and UpdatePanels().
        /// </summary>
        function pickService(value) {
            var sel = document.getElementById('<%= ddlServiceType.ClientID %>');
            if (!sel) return;
            for (var i = 0; i < sel.options.length; i++) {
                if (sel.options[i].value === value) {
                    if (sel.selectedIndex === i) return;
                    sel.selectedIndex = i;
                    sel.dispatchEvent(new Event('change'));
                    return;
                }
            }
        }

        /// <summary>
        /// Paints the three service cards: the active one gets the blue frame and check badge,
        /// and every card shows the fare basis of the vehicle currently selected on the right.
        /// </summary>
        function paintServiceCards() {
            var cards = document.querySelectorAll('#serviceGrid .service-card');
            var rate = RATES[getVehicle()] || {};
            for (var i = 0; i < cards.length; i++) {
                var on = cards[i].getAttribute('data-service') === currentService;
                cards[i].className = 'service-card text-left rounded-xl p-4 border transition-all duration-150 '
                    + (on
                        ? 'border-blue-500 bg-blue-50/40'
                        : 'border-slate-100 bg-white hover:border-slate-200');

                var icon = cards[i].querySelector('.service-icon');
                if (icon) {
                    icon.className = 'service-icon w-8 h-8 rounded-lg flex items-center justify-center '
                        + (on ? 'bg-blue-600 text-white' : 'bg-slate-50 text-slate-500');
                }

                var check = cards[i].querySelector('.service-check');
                if (check) check.style.display = on ? '' : 'none';

                var title = cards[i].querySelector('h3');
                if (title) title.className = (on ? 'font-bold ' : 'font-semibold ') + 'text-[13px] text-slate-900';

                var price = cards[i].querySelector('.service-price');
                if (!price) continue;
                price.className = 'service-price mt-3 pt-3 border-t border-slate-100 text-[11px] font-semibold '
                    + (on ? 'text-blue-700' : 'text-slate-500');
                var kind = cards[i].getAttribute('data-service');
                if (kind === 'p2p') {
                    price.textContent = rate.perKm != null
                        ? fmtKs(rate.perKm) + '/km' : 'Rate unavailable';
                } else if (kind === 'hourly') {
                    price.textContent = rate.perHour != null
                        ? fmtKs(rate.perHour) + '/hr' : 'Rate unavailable';
                } else {
                    var pid = kgSelect ? (parseInt(kgSelect.value, 10) || 0) : 0;
                    price.textContent = PACKS[pid] ? fmtKs(PACKS[pid].fare) + ' daypass' : 'All-inclusive fare';
                }
            }
        }

        /// <summary>
        /// The hour cards are the picker: the real DropDownList stays hidden because it is
        /// what posts back, and each card shows the whole hire price for the vehicle, which is
        /// the figure the summary will charge. Distance never enters an hourly fare.
        /// </summary>
        function paintHourCards() {
            var grid = document.getElementById('hourGrid');
            if (!grid || !hSelect) return;
            var rate = RATES[getVehicle()] || {};
            var opts = hSelect.options, html = '';

            for (var i = 0; i < opts.length; i++) {
                var hours = parseInt(opts[i].value, 10) || 0;
                var on = opts[i].value === hSelect.value;
                var total = hourFare(rate, hours);
                html += '<button type="button" data-hours="' + opts[i].value + '" onclick="pickHours(\'' + opts[i].value + '\')"'
                    + ' class="hour-card text-left rounded-xl p-3.5 border transition-all duration-150 '
                    + (on ? 'border-blue-500 bg-blue-50/40' : 'border-slate-100 bg-white hover:border-slate-200') + '">'
                    + '<div class="flex items-center justify-between gap-2 mb-1.5">'
                    + '<span class="text-[13px] font-semibold text-slate-900">' + hours + (hours === 1 ? ' hour' : ' hours') + '</span>'
                    + '<span class="hour-check w-4 h-4 rounded-full bg-blue-600 text-white flex items-center justify-center shrink-0" style="display:' + (on ? '' : 'none') + '">'
                    + '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor" class="size-2.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>'
                    + '</span></div>'
                    + '<div class="text-[11px] text-slate-500">' + (hours >= 8 ? 'Full day cover' : 'Standby driver') + '</div>'
                    + '<div class="mt-2.5 pt-2.5 border-t border-slate-100 text-[11px] font-semibold ' + (on ? 'text-blue-700' : 'text-slate-500') + '">'
                    + (total ? fmtKs(total) : 'Rate unavailable') + '</div>'
                    + '</button>';
            }
            grid.innerHTML = html;
        }

        function pickHours(value) {
            if (!hSelect) return;
            for (var i = 0; i < hSelect.options.length; i++) {
                if (hSelect.options[i].value === value) {
                    if (hSelect.selectedIndex === i) return;
                    hSelect.selectedIndex = i;
                    hSelect.dispatchEvent(new Event('change'));
                    return;
                }
            }
        }

        /// <summary>
        /// A photo tile with a placeholder underneath it. If the file is missing the img hides
        /// itself on error, so a broken upload shows the tile rather than a broken-image icon.
        /// badge is optional markup pinned inside the tile.
        /// </summary>
        function photoTile(url, extraClass, badge) {
            var tile = '<div class="relative overflow-hidden bg-slate-100 ' + (extraClass || '') + '">'
                + '<span class="tw-skeleton absolute inset-0"></span>';
            if (url) {
                tile += '<img src="' + enc(url) + '" alt="" loading="lazy" class="absolute inset-0 size-full object-cover"'
                    + ' onerror="this.style.display=\'none\'" onload="this.style.display=\'block\'" />';
            }
            if (badge) tile += badge;
            return tile + '</div>';
        }

        /// <summary>
        /// Package cards come straight from PackageJson, so the card grid and the hidden
        /// DropDownList can never disagree about which package is booked.
        /// </summary>
        function paintPackageCards() {
            var grid = document.getElementById('packageGrid');
            if (!grid) return;
            var pid = kgSelect ? (parseInt(kgSelect.value, 10) || 0) : 0;
            var check = '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="3" stroke="currentColor"'
                + ' class="size-2.5"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>';
            var html = '', count = 0;

            for (var key in PACKS) {
                if (!PACKS.hasOwnProperty(key)) continue;
                count++;
                var p = PACKS[key];
                var on = parseInt(key, 10) === pid;
                var places = p.places ? p.places.length : 0;
                var shot = p.cover || '';
                html += '<button type="button" data-package="' + key + '" onclick="pickPackage(\'' + key + '\')"'
                    + ' class="package-card text-left rounded-xl border overflow-hidden transition-all duration-150 '
                    + (on ? 'border-blue-500 bg-blue-50/40' : 'border-slate-100 bg-white hover:border-slate-200') + '">'
                    + photoTile(shot, 'h-24 w-full')
                    + '<div class="p-4">'
                    + '<div class="flex items-start justify-between gap-2 mb-2">'
                    + '<span class="text-[13px] font-semibold text-slate-900">' + enc(p.name || 'Package ' + key) + '</span>'
                    + '<span class="package-check w-4 h-4 rounded-full bg-blue-600 text-white flex items-center justify-center shrink-0 mt-0.5" style="display:' + (on ? '' : 'none') + '">' + check + '</span>'
                    + '</div>'
                    + '<div class="flex items-center gap-1.5 text-[11px] text-slate-500">'
                    + '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" stroke="currentColor" class="size-3.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>'
                    + '<span>' + places + ' curated stop' + (places === 1 ? '' : 's') + '</span></div>'
                    + '<div class="mt-2.5 pt-2.5 border-t border-slate-100 text-[11px] font-semibold ' + (on ? 'text-blue-700' : 'text-slate-500') + '">'
                    + fmtKs(p.fare) + ' daypass</div>'
                    + '</div></button>';
            }

            if (!count) {
                html = '<div class="sm:col-span-2 p-3.5 rounded-xl border border-dashed border-slate-200 text-[11px] text-slate-400 text-center">'
                    + 'No tour packages are available yet &mdash; please ask the team.</div>';
            }
            grid.innerHTML = html;
        }

        function pickPackage(value) {
            if (!kgSelect) return;
            for (var i = 0; i < kgSelect.options.length; i++) {
                if (kgSelect.options[i].value === value) {
                    if (kgSelect.selectedIndex === i) return;
                    kgSelect.selectedIndex = i;
                    kgSelect.dispatchEvent(new Event('change'));
                    return;
                }
            }
        }

        /// <summary>
        /// The package pickup row and the stop count in the map metrics bar. Both read the
        /// live route, so moving the pickup repaints them without touching the itinerary.
        /// </summary>
        function paintPackageRoute() {
            var pickup = document.getElementById('lblPackagePickup');
            var first = route.points[0];
            if (pickup) {
                pickup.textContent = first
                    ? (first.addr || 'Pinned point')
                    : 'Set your pickup on the map';
                pickup.className = 'text-[13px] font-semibold truncate ' + (first ? 'text-slate-800' : 'text-slate-400');
            }

            var n = itinerary.length;
            var sep = document.getElementById('lblRouteStops');
            var text = document.getElementById('lblRouteStopText');
            var label = document.getElementById('lblRoadStops');
            var show = currentService === 'package' && n > 0;
            if (sep) sep.classList.toggle('hidden', !show);
            if (text) text.classList.toggle('hidden', !show);
            if (text) text.classList.toggle('inline-flex', show);
            if (label) label.textContent = n + ' curated stop' + (n === 1 ? '' : 's');
        }

        /// <summary>
        /// The Fare Breakdown rows. Only the lines that belong to the chosen service stay
        /// visible, and every figure comes from the same numbers the server charges.
        /// </summary>
        function paintFareBreakdown(straightKm) {
            var v = getVehicle(), rate = RATES[v] || {};
            var pid = kgSelect ? (parseInt(kgSelect.value, 10) || 0) : 0;
            var pack = PACKS[pid];
            var km = straightKm || 0;
            var rows = {
                rowSumDistance: currentService === 'p2p' && km > 0,
                rowSumPerKm: currentService === 'p2p' && rate.perKm != null,
                rowSumDuration: currentService === 'hourly' && rate.perHour != null,
                rowSumPackage: currentService === 'package' && !!pack
            };
            for (var id in rows) {
                var el = document.getElementById(id);
                if (el) el.classList.toggle('hidden', !rows[id]);
            }

            setText('lblSumPerKm', rate.perKm != null && km > 0 ? fmtKs(roundFare(rate.perKm * km * 1.3)) : '--');
            setText('lblSumPerKmRate', rate.perKm != null ? fmtKs(rate.perKm) + '/km' : '--');
            setText('lblSumDuration', getHours() + (getHours() === 1 ? ' hour' : ' hours'));
            setText('lblSumHourRate', rate.perHour != null ? fmtKs(rate.perHour) + ' / hour' : '--');
            setText('lblSumPackage', pack ? fmtKs(pack.fare) : '--');
        }

        function setText(id, value) {
            var el = document.getElementById(id);
            if (el) el.textContent = value;
        }

        /// <summary>
        /// Vehicle cards are the picker, exactly like the payment brands. The note on each card is
        /// the fare basis of the service that is currently selected, so switching service shows a
        /// different number on the same card instead of a column of dead text.
        /// </summary>
        function paintVehicleCards() {
            var grid = document.getElementById('vehicleGrid');
            if (!grid || !vSelect) return;
            var opts = vSelect.options, check = '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24"'
                + ' stroke-width="3" stroke="currentColor" class="size-2.5"><path stroke-linecap="round" stroke-linejoin="round"'
                + ' d="m4.5 12.75 6 6 9-13.5"/></svg>';
            var html = '', count = 0;

            for (var i = 0; i < opts.length; i++) {
                var id = opts[i].value;
                var on = id === vSelect.value;
                var info = VEHICLES[id] || {};
                var seats = (info.min != null && info.max != null)
                    ? (info.min === info.max ? info.min + ' seat' : info.min + '–' + info.max + ' seats')
                    : '';
                var note = vehicleRateNote(id);
                count++;
                html += '<button type="button" data-vehicle="' + id + '" onclick="pickVehicle(\'' + id + '\')"'
                    + ' class="vehicle-card text-left rounded-xl p-3 border transition-all duration-150 '
                    + (on ? 'border-blue-500 bg-blue-50/40' : 'border-slate-100 bg-white hover:border-slate-200') + '">'
                    + '<div class="flex items-start justify-between gap-2">'
                    + '<span class="text-[13px] font-semibold text-slate-900">' + enc(opts[i].text) + '</span>'
                    + '<span class="vehicle-check w-4 h-4 rounded-full bg-blue-600 text-white flex items-center justify-center shrink-0 mt-0.5" style="display:' + (on ? '' : 'none') + '">' + check + '</span>'
                    + '</div>'
                    + '<div class="mt-1.5 flex items-center gap-2.5 text-[11px]">'
                    + (seats ? '<span class="text-slate-500">' + seats + '</span>' : '')
                    + (note ? '<span class="font-semibold ' + (on ? 'text-blue-700' : 'text-slate-400') + '">' + note + '</span>' : '')
                    + '</div></button>';
            }

            if (!count) {
                html = '<div class="sm:col-span-2 p-3.5 rounded-xl border border-dashed border-slate-200 text-[11px]'
                    + ' text-slate-400 text-center">No vehicle classes are available yet.</div>';
            }
            grid.innerHTML = html;
        }

        /// <summary>
        /// What this vehicle costs on the service that is selected right now. A package is priced
        /// per tour, not per vehicle, so it shows nothing rather than a misleading rate.
        /// </summary>
        function vehicleRateNote(vehicleId) {
            var rate = RATES[vehicleId];
            if (!rate) return '';
            if (currentService === 'hourly') return rate.perHour ? fmtKs(rate.perHour) + '/hr' : '';
            if (currentService === 'p2p') return rate.perKm ? fmtKs(rate.perKm) + '/km' : '';
            return '';
        }

        function pickVehicle(value) {
            if (!vSelect) return;
            for (var i = 0; i < vSelect.options.length; i++) {
                if (vSelect.options[i].value === value) {
                    if (vSelect.selectedIndex === i) return;
                    vSelect.selectedIndex = i;
                    vSelect.dispatchEvent(new Event('change'));
                    return;
                }
            }
        }

        function recomputeFare() {
            paintServiceCards();
            paintHourCards();
            paintVehicleCards();
            paintPassengerOptions();
            var v = getVehicle();
            var rate = RATES[v];
            if (!rate) { setHidden('<%= hfFare.ClientID %>', ''); return; }
            var est = 0, km = 0, label = '--';
            if (currentService === 'p2p' && route.points.length >= 2 && v) {
                for (var i = 1; i < route.points.length; i++) {
                    km += haversine(
                        [route.points[i - 1].lat, route.points[i - 1].lng],
                        [route.points[i].lat, route.points[i].lng]);
                }
                // A vehicle with no per-km rate set has perKm === null, and null * km is NaN.
                // Without this test the estimate read "MMK NaN" and the hidden fare field was
                // posted as NaN, so the booking had to refuse it further down. Say the rate is
                // unavailable here instead, which is the same wording the vehicle card uses.
                if (rate.perKm == null) {
                    label = 'Rate unavailable';
                } else {
                    est = roundFare(rate.perKm * km * 1.3);
                    // The fare must match the server formula (straight-line x 1.3), but show the real
                    // road distance once routing has answered.
                    document.getElementById('lblDistance').textContent =
                        roadReady && roadKm > 0 ? fmtKm(roadKm) + ' road' : fmtKm(km * 1.3) + ' est.';
                    setHidden('<%= hfKm.ClientID %>', km.toFixed(2));
                    label = fmtKs(est);
                }
            } else if (currentService === 'hourly' && route.points.length && v) {
                est = hourFare(rate, getHours());
                label = fmtKs(est);
            } else if (currentService === 'package' && v) {
                var pid = parseInt(document.getElementById('<%= ddlPackage.ClientID %>').value, 10) || 0;
                if (PACKS[pid] && PACKS[pid].fare != null) {
                    est = roundFare(PACKS[pid].fare);
                    label = fmtKs(est);
                } else {
                    label = 'Rate unavailable';
                }
            }
            document.getElementById('lblEstimate').textContent = label;
            setHidden('<%= hfFare.ClientID %>', Math.round(est));
            paintFareBreakdown(km);
            checkPax();
        }

        function searchPlace() {
            var q = document.getElementById('txtPlace').value.trim();
            if (!q) return;
            var results = document.getElementById('placeResults');
            if (results) {
                results.textContent = 'Searching…';
                results.classList.remove('hidden');
            }
            fetch('https://nominatim.openstreetmap.org/search?format=json&limit=1&q=' + encodeURIComponent(q + ', Hpa-An, Myanmar'))
                .then(function (r) { return r.json(); })
                .then(function (rows) {
                    if (!rows.length) {
                        // Said next to the search box, not in a toast that disappears before
                        // it has been read.
                        if (results) results.textContent = 'No match for "' + q + '". Try a street or place name in Hpa-An.';
                        return;
                    }
                    if (results) results.classList.add('hidden');
                    var lat = parseFloat(rows[0].lat), lng = parseFloat(rows[0].lon);
                    if (currentService === 'package') {
                        // Packages do not use the map for their pickup point.
                        if (map) map.setView([lat, lng], 14);
                        return;
                    }
                    // Recentre only once the point has actually passed address
                    // validation, otherwise the map jumps to a place the customer
                    // is not allowed to book.
                    placePoint(lat, lng, function () {
                        if (map) map.setView([lat, lng], 14);
                    });
                })
                .catch(function (err) {
                    if (window.console && console.error) console.error(err);
                    if (results) results.textContent = 'The place search could not be reached. You can still tap the map to set your points.';
                });
        }

        /// <summary>
        /// What the page does with the outcome of pressing Confirm.
        ///
        /// A failure is reported here and stays here: the customer has to read what went wrong
        /// and fix it, and there is nowhere else for that message to live. A success is not
        /// reported at all - it navigates straight to the live trip, which opens on the request
        /// that was just made and is looking for a driver. The toast it replaces said the same
        /// thing, less usefully, and holding the page for it only delayed the trip.
        /// </summary>
        /// <summary>
        /// Reports a refused booking as a toast.
        ///
        /// Only refusals reach this page any more. A booking that worked leaves with a 302 from
        /// btnCreateTrip_Click before this markup is ever rendered, so there is no success case
        /// here to handle and nothing left to navigate: the trip page is already on its way.
        /// </summary>
        function handleConfirmResult() {
            var res = <%= ConfirmToastJson %>;
            if (!res) return;
            if (res.kind === 'error' && res.text) TwToast.error(res.text, 5200);
        }

        // Registered before the page's own initialisation below, and deliberately not part of
        // it, so a throw in the point, payment, keyboard or hotel search set-up cannot stop a
        // refusal from being reported. It used to be the fifth statement in that listener,
        // which meant those failures silenced the one message the customer needed to read.
        document.addEventListener('DOMContentLoaded', function () {
            try {
                handleConfirmResult();
            } catch (err) {
                if (window.console && console.error) console.error(err);
            }

            // Whatever state Page_Load decided is the baseline this page starts from. Captured
            // before anything here can re-enable the button.
            var confirmBtn = document.getElementById('<%= btnCreateTrip.ClientID %>');
            if (confirmBtn && confirmBtn.disabled) confirmBlockedByServer = true;
        });

        document.addEventListener('DOMContentLoaded', function () {
            setPointStage(STAGE.start);
            syncPaymentCards();
            guardEnterKey();
            initHotelSearch();

            var mapEl = document.getElementById('mapRoute');
            if (mapEl) {
                // No service-area boundary is drawn. The map opens on Hpa-An so
                // the customer starts somewhere sensible, and they are free to
                // click anywhere - a point is only accepted if its address comes
                // back as Hpa-An Township.
                map = L.map(mapEl);
                map.setView([SERVICE_AREA.center.lat, SERVICE_AREA.center.lng], 13);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
                map.on('click', function (e) { placePoint(e.latlng.lat, e.latlng.lng); });
            }

            if (currentService === 'hourly' || currentService === 'package') {
                var dropBtn = document.getElementById('btnModeDrop');
                var stopBtn = document.getElementById('btnModeStop');
                if (dropBtn) dropBtn.style.display = 'none';
                if (stopBtn) stopBtn.style.display = 'none';
                var hint = document.getElementById('lblMapHint');
                if (hint && currentService === 'hourly') hint.textContent = 'Tap the map to set the pickup point.';
                if (currentService === 'package') {
                    showPlaces();
                    if (itinerary.length && hint) {
                        var chosen = PACKS[kgSelect ? (parseInt(kgSelect.value, 10) || 0) : 0];
                        hint.textContent = 'The numbered pins are the ' + (chosen ? chosen.name : 'package')
                            + ' circuit. Tap the map to set your pickup point.';
                    }
                }
            }

            // Paints the service cards and the empty route list, so the page never opens with
            // an unstyled grid or an unexplained empty box.
            redrawRoute();
        });

        var vSelect = document.getElementById('<%= ddlVehicle.ClientID %>');
        var hSelect = document.getElementById('<%= ddlHours.ClientID %>');
        var pSelect = document.getElementById('<%= ddlPassengers.ClientID %>');
        var kgSelect = document.getElementById('<%= ddlPackage.ClientID %>');
        if (vSelect) vSelect.addEventListener('change', recomputeFare);
        if (hSelect) hSelect.addEventListener('change', recomputeFare);
        if (pSelect) pSelect.addEventListener('change', checkPax);
        if (kgSelect) kgSelect.addEventListener('change', function () { showPlaces(); recomputeFare(); });

        /// <summary>
        /// Debounced hotel search over the cards already on the page, the same idea as the live
        /// search on the history pages but without the postback: this page holds a half-built
        /// booking, so filtering must not round-trip the form and reset the route and package
        /// choices. Typing only repaints the cards, and Enter runs the filter at once.
        /// </summary>
        function initHotelSearch() {
            var input = document.getElementById('txtHotelSearch');
            var empty = document.getElementById('lblHotelEmpty');
            if (!input) return;
            // The card list is captured once, so a second call would filter a stale copy and
            // double every listener. Nothing re-renders the cards client-side, so once is enough.
            if (input.getAttribute('data-tw-ready') === '1') return;
            input.setAttribute('data-tw-ready', '1');

            var cards = [], timer = null;
            var list = document.querySelectorAll('[data-hotel-card]');
            for (var i = 0; i < list.length; i++) {
                cards.push({ node: list[i], text: (list[i].textContent || '').toLowerCase().replace(/\s+/g, ' ') });
            }

            function apply() {
                timer = null;
                var q = input.value.trim().toLowerCase();
                var shown = 0;
                for (var i = 0; i < cards.length; i++) {
                    var hit = !q || cards[i].text.indexOf(q) >= 0;
                    cards[i].node.style.display = hit ? '' : 'none';
                    if (hit) shown++;
                }
                if (!empty) return;
                if (q && !shown) {
                    empty.textContent = 'No hotel matches "' + input.value.trim() + '". Clear the search to see all of them.';
                    empty.classList.remove('hidden');
                } else {
                    empty.classList.add('hidden');
                }
            }

            input.addEventListener('input', function () {
                if (timer) clearTimeout(timer);
                timer = setTimeout(apply, 250);
            });
            input.addEventListener('keydown', function (e) {
                if (e.key !== 'Enter') return;
                if (timer) { clearTimeout(timer); timer = null; }
                apply();
            });
            // Leaving the box must not throw away a filter that is still waiting.
            input.addEventListener('blur', function () {
                if (!timer) return;
                clearTimeout(timer);
                apply();
            });
        }

        /// <summary>
        /// Enter must never create a booking. This form has exactly one submit button, the
        /// Confirm one, so pressing Enter in any plain field would post the form straight into
        /// btnCreateTrip_Click. Fields that want Enter do their own work through data-enter.
        /// </summary>
        function guardEnterKey() {
            document.addEventListener('keydown', function (e) {
                if (e.key !== 'Enter') return;
                var el = e.target;
                if (!el) return;
                var tag = (el.tagName || '').toLowerCase();
                if (tag !== 'input' && tag !== 'select' && tag !== 'textarea') return;
                // Enter on the confirm button itself is a real click and must still work.
                if (tag === 'input' && (el.type === 'submit' || el.type === 'button')) return;
                e.preventDefault();
                if (el.getAttribute('data-enter') === 'place') searchPlace();
            });
        }

        // "Hotels & Resorts (N on map)" badge in the hotel section header.
        (function () {
            var badge = document.getElementById('lblHotelCount');
            if (!badge) return;
            var count = 0;
            for (var k in HOTELS) if (HOTELS.hasOwnProperty(k) && HOTELS[k].ok) count++;
            badge.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.8" '
                + 'stroke="currentColor" class="size-[15px] text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" '
                + 'd="M3.75 21h16.5M4.5 3h15M5.25 3v18m13.5-18v18M9 6.75h1.5m-1.5 3h1.5m-1.5 3h1.5m3-6H15m-1.5 3H15m-1.5 3H15M9 21v-3.375c0-.621.504-1.125'
                + '1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21"/></svg>'
                + '<span>Hotels &amp; Resorts (' + count + ' on map)</span>';
        })();

        /// <summary>
        /// Renders the selected package: the itinerary grid, the pickup row and the numbered
        /// map markers. places[] keeps every place name in order, stops[] only the ones that
        /// have usable coordinates, so the two are matched by name and not by index.
        /// </summary>
        function showPlaces() {
            var pid = kgSelect ? (parseInt(kgSelect.value, 10) || 0) : 0;
            var p = PACKS[pid];
            var box = document.getElementById('divPlaces');
            itinerary = (p && p.stops) ? p.stops.slice() : [];
            if (box) {
                if (!p) {
                    box.innerHTML = '<div class="sm:col-span-2 p-3.5 rounded-xl border border-dashed border-slate-200'
                        + ' text-[11px] text-slate-400 text-center">Pick a package card above to see its itinerary.</div>';
                } else if (!p.places || !p.places.length) {
                    box.innerHTML = '<div class="sm:col-span-2 p-3.5 rounded-xl border border-dashed border-slate-200'
                        + ' text-[11px] text-slate-400 text-center">This package has no places yet'
                        + ' &mdash; please ask the team to add them.</div>';
                } else {
                    var html = '';
                    for (var i = 0; i < p.places.length; i++) {
                        // No coordinates on the card: they are noise for the customer and they are
                        // already on the map pin. The line only appears when a place has no map
                        // position at all, because then the driver cannot find it.
                        var s = stopByName(p.places[i]);
                        // The tile is the number and nothing else. A photo here repeated the
                        // package cover down every row, so the list read as the same picture
                        // several times over while the one thing that matters - which stop is
                        // which - was a small badge pinned in its corner. It is also the same
                        // number and the same blue as the markers drawStopMarkers puts on the
                        // map, so the list and the map can be read against each other.
                        html += '<div class="flex items-center gap-3 p-3 rounded-xl border border-slate-100 bg-white">'
                            + '<span class="w-10 h-10 rounded-xl bg-blue-600 text-white text-[15px] font-bold'
                            + ' flex items-center justify-center shrink-0">' + (i + 1) + '</span>'
                            + '<div class="min-w-0">'
                            + '<div class="text-[13px] font-semibold text-slate-800">' + enc(p.places[i]) + '</div>'
                            + (s ? '' : '<div class="text-[11px] text-amber-600 mt-0.5">No map position yet</div>')
                            + '</div></div>';
                    }
                    box.innerHTML = html;
                }
            }
            paintPackageCards();
            paintPackageRoute();
            drawStopMarkers();
            drawRoadRoute();
        }

        function stopByName(name) {
            for (var i = 0; i < itinerary.length; i++) {
                if (itinerary[i].name === name) return itinerary[i];
            }
            return null;
        }
    </script>
</asp:Content>