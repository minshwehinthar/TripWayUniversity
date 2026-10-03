<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Services.aspx.cs" Inherits="TripWay.ServicesPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-5xl mx-auto space-y-10 py-8 px-4 sm:px-6">

        <%-- Hero --%>
        <div class="text-center max-w-3xl mx-auto">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 text-xs font-semibold">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09Z"/></svg> Our Services
            </span>
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mt-4">Moving around Hpa-An, made simple</h1>
            <p class="text-gray-500 mt-3 text-sm sm:text-base">
                Fixed-meter, up-front fares. No surge pricing. Every trip tracked live — from motorbike to van, TripWay covers the whole town.
            </p>
        </div>

        <%-- Services grid --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
            <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                <span class="inline-flex size-11 rounded-lg bg-blue-100 text-blue-600 items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                </span>
                <h3 class="font-semibold text-gray-900 text-sm">Point-to-Point · Town Rides</h3>
                <p class="text-sm text-gray-500">Pickup to drop-off anywhere in Hpa-An. Fare is computed by distance with an upfront quote shown before you confirm — great for everyday commuting and quick errands.</p>
                <ul class="space-y-1.5 text-sm text-gray-500 pt-1">
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Live driver GPS tracking</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Fixed meter, confirmed upfront</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Pay by cash, KPay, WavePay or wallet</li>
                </ul>
            </div>
            <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                <span class="inline-flex size-11 rounded-lg bg-green-100 text-green-600 items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                </span>
                <h3 class="font-semibold text-gray-900 text-sm">Hourly Hire</h3>
                <p class="text-sm text-gray-500">Hire a driver by the hour with a minimum billing period. Ideal for shopping trips, medical appointments, or visiting family across town without juggling multiple rides.</p>
                <ul class="space-y-1.5 text-sm text-gray-500 pt-1">
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-green-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Clean per-hour meter</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-green-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Same driver the whole time</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-green-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Pause and resume as you like</li>
                </ul>
            </div>
            <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                <span class="inline-flex size-11 rounded-lg bg-purple-100 text-purple-600 items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M9 6.75V15m6-6v8.25m.503 3.498 4.875-2.437c.381-.19.622-.58.622-1.006V4.82c0-.836-.88-1.38-1.628-1.006l-3.869 1.934c-.317.159-.69.159-1.006 0L9.503 3.252a1.125 1.125 0 0 0-1.006 0L3.622 5.689C3.24 5.88 3 6.27 3 6.695V19.18c0 .836.88 1.38 1.628 1.006l3.869-1.934c.317-.159.69-.159 1.006 0l4.994 2.497c.317.158.69.158 1.006 0Z"/></svg>
                </span>
                <h3 class="font-semibold text-gray-900 text-sm">Packages · Day Tours</h3>
                <p class="text-sm text-gray-500">Pre-planned multi-stop itineraries at a single package price — Kyauk Ka Lat, Kyee Kan phaya, Hpa-An and Shweyinhmyaw. Driver waits while you explore.</p>
                <ul class="space-y-1.5 text-sm text-gray-500 pt-1">
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-purple-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>One price includes waiting</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-purple-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Built-in place list, editable</li>
                    <li class="flex items-start gap-2"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 mt-0.5 inline-block align-middle shrink-0 text-purple-600"><path stroke-linecap="round" stroke-linejoin="round" d="m4.5 12.75 6 6 9-13.5"/></svg>Great for groups up to 10</li>
                </ul>
            </div>
        </div>

        <%-- How booking works --%>
        <div class="bg-white p-6 rounded-lg shadow-sm">
            <h2 class="text-lg font-bold text-gray-900">How Booking Works</h2>
                <ol class="space-y-4 mt-6">
                    <li class="flex gap-4">
                        <span class="size-8 rounded-full bg-[#007AFF] text-white font-bold flex items-center justify-center shrink-0 text-sm">1</span>
                        <div><h4 class="font-bold text-gray-900 text-sm">Log in and pick a service</h4>
                        <p class="text-sm text-gray-500 mt-0.5">Choose Point-to-Point, Hourly or a Package.</p></div>
                    </li>
                    <li class="flex gap-4">
                        <span class="size-8 rounded-full bg-[#007AFF] text-white font-bold flex items-center justify-center shrink-0 text-sm">2</span>
                        <div><h4 class="font-bold text-gray-900 text-sm">Set your pickup &amp; destination</h4>
                        <p class="text-sm text-gray-500 mt-0.5">Drop pins on the map or search addresses — the fare meter updates live.</p></div>
                    </li>
                    <li class="flex gap-4">
                        <span class="size-8 rounded-full bg-[#007AFF] text-white font-bold flex items-center justify-center shrink-0 text-sm">3</span>
                        <div><h4 class="font-bold text-gray-900 text-sm">Get matched to a nearby driver</h4>
                        <p class="text-sm text-gray-500 mt-0.5">The first online driver in range accepts and drives to your pickup.</p></div>
                    </li>
                    <li class="flex gap-4">
                        <span class="size-8 rounded-full bg-[#007AFF] text-white font-bold flex items-center justify-center shrink-0 text-sm">4</span>
                        <div><h4 class="font-bold text-gray-900 text-sm">Track, ride, pay, rate</h4>
                        <p class="text-sm text-gray-500 mt-0.5">Watch the driver on the live map, pay by your choice, and rate the ride.</p></div>
                    </li>
                </ol>
            </div>
            <div class="bg-white p-6 rounded-lg shadow-sm">
                <h2 class="text-lg font-bold text-gray-900">Fares &amp; Meters</h2>
                <p class="text-sm text-gray-500 mt-2 mb-4">Rates are managed by TripWay admin and shown to you before you confirm. There is no base fare: point-to-point is charged per kilometre, hourly hire at a flat rate per hour.</p>
                <asp:Repeater ID="rptFares" runat="server">
                    <HeaderTemplate>
                        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="border border-gray-100 rounded-lg overflow-hidden bg-white">
                            <div class="px-4 py-3 bg-slate-50 border-b border-gray-100 flex items-center justify-between gap-2">
                                <span class="inline-flex items-center gap-2.5">
                                    <span class="size-8 rounded-lg bg-[#007AFF]/10 text-[#007AFF] flex items-center justify-center shrink-0">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                                    </span>
                                    <span class="text-sm font-bold text-gray-900"><%# Eval("VehicleTypeName") %></span>
                                </span>
                                <span class="px-2 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-[10px] font-bold">Up-front quote</span>
                            </div>
                            <div class="divide-y divide-gray-50">
                                <div class="px-4 py-2.5 flex items-center justify-between gap-2">
                                    <span class="text-xs font-semibold text-gray-500">Point-to-Point</span>
                                    <span class="text-xs text-gray-600">per km <span class="font-bold text-gray-900"><%# FmtN(Eval("PtpPerKm")) %></span></span>
                                </div>
                                <div class="px-4 py-2.5 flex items-center justify-between gap-2 bg-blue-50/50">
                                    <span class="text-xs font-semibold text-gray-500">Hourly</span>
                                    <span class="text-xs text-gray-600">per hour <span class="font-bold text-gray-900"><%# FmtN(Eval("HlyPerHour")) %></span></span>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoFares" runat="server" Visible="false">
                    <div class="rounded-lg border border-gray-100 bg-white px-4 py-10 text-center">
                        <p class="text-sm text-gray-400"><asp:Literal ID="litEmpty" runat="server" /></p>
                    </div>
                </asp:Panel>
            </div>

        <%-- CTA --%>
        <div class="bg-white rounded-lg shadow-sm p-8 flex flex-col sm:flex-row items-center justify-between gap-4">
            <div>
                <asp:Panel ID="pnlCtaGuest" runat="server" CssClass="contents">
                    <h3 class="text-lg font-bold text-gray-900">Ready to get started?</h3>
                    <p class="text-sm text-gray-500 mt-1">Create your TripWay account and book your first ride in minutes.</p>
                </asp:Panel>
                <asp:Panel ID="pnlCtaUser" runat="server" Visible="false" CssClass="contents">
                    <h3 class="text-lg font-bold text-gray-900">Welcome back!</h3>
                    <p class="text-sm text-gray-500 mt-1">Continue to your dashboard to book or manage your rides.</p>
                </asp:Panel>
            </div>
            <div class="flex items-center gap-3">
                <asp:Panel ID="pnlCtaGuestBtn" runat="server" CssClass="contents">
                    <a href='<%= ResolveUrl("~/Register.aspx") %>' class="tw-btn-primary">Register Now</a>
                    <a href='<%= ResolveUrl("~/Login.aspx") %>' class="tw-btn-outline">Login</a>
                </asp:Panel>
                <asp:Panel ID="pnlCtaUserBtn" runat="server" Visible="false" CssClass="contents">
                    <asp:HyperLink ID="lnkCtaDashboard" runat="server" CssClass="tw-btn-primary" Text="Go to Dashboard" />
                    <asp:HyperLink ID="lnkCtaBook" runat="server" CssClass="tw-btn-outline" Text="Book a Trip" Visible="false" />
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>