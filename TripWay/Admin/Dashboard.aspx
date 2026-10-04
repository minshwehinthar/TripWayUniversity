<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="TripWay.Admin.DashboardPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">

        <%-- Admin identity banner --%>
        <div class="w-full bg-white rounded-xl border border-slate-200 p-6 shadow-sm overflow-hidden">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                <div class="lg:col-span-8 space-y-4">
                    <div class="flex items-center gap-4">
                        <div class="size-20 rounded-2xl border-2 border-slate-200 bg-blue-50 text-blue-600 shadow-sm flex items-center justify-center shrink-0">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z"/></svg>
                        </div>
                        <div class="space-y-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-blue-600/10 text-blue-600 border border-blue-600/20">Admin</span>
                                <span class="text-xs text-gray-400">TripWay Platform</span>
                            </div>
                            <h1 class="text-xl sm:text-2xl font-bold text-gray-900">Admin Dashboard</h1>
                        </div>
                    </div>
                    <p class="text-xs sm:text-sm text-gray-500 leading-relaxed">
                        Manage customers, drivers, packages, fare rates and trips, and review live activity from this workspace.
                    </p>
                    <div class="flex items-center justify-between gap-4 flex-wrap pt-2 border-t border-slate-100">
                        <div class="flex items-center gap-3 text-xs text-gray-500 flex-wrap">
                            <span class="flex items-center gap-1.5 bg-gray-100 px-3 py-1.5 rounded-md border border-slate-200 font-medium">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5"/></svg><asp:Label ID="lblToday" runat="server" />
                            </span>
                            <span class="flex items-center gap-1.5 bg-gray-100 px-3 py-1.5 rounded-md border border-slate-200 font-medium">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 text-blue-600"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>Hpa-An
                            </span>
                        </div>
                        <a href="Profile.aspx" class="inline-flex items-center gap-1.5 text-xs font-semibold text-[#007AFF] hover:underline">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.24-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.123.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>Admin Profile &rarr;
                        </a>
                    </div>
                </div>
                <div class="lg:col-span-4">
                    <a href="DriverManagement.aspx"
                        class="relative aspect-[16/10] w-full rounded-xl bg-gradient-to-br from-[#007AFF] to-[#1d4ed8] border border-slate-200 shadow-sm overflow-hidden group flex flex-col justify-end p-4 text-white">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute top-3 right-4 text-yellow-300"><path stroke-linecap="round" stroke-linejoin="round" d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09ZM18.259 8.715 18 9.75l-.259-1.035a3.375 3.375 0 0 0-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 0 0 2.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 0 0 2.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 0 0-2.456 2.456ZM16.894 20.567 16.5 21.75l-.394-1.183a2.25 2.25 0 0 0-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 0 0 1.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 0 0 1.423 1.423l1.183.394-1.183.394a2.25 2.25 0 0 0-1.423 1.423Z"/></svg>
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7 mb-1 group-hover:-translate-y-0.5 transition-transform"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/></svg>
                        <span class="text-sm font-semibold">TripWay Admin</span>
                        <span class="text-xs text-blue-100 mt-0.5">Driver &amp; trip management workspace</span>
                    </a>
                </div>
            </div>
        </div>

        <%-- Overview statistics --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <a href="CustomerManagement.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-[#007AFF]/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Customers</span>
                    <div class="p-2 rounded-lg bg-[#007AFF]/10 text-[#007AFF] group-hover:bg-[#007AFF] group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblCustomers" runat="server" CssClass="text-3xl font-extrabold text-gray-900">0</asp:Label>
                    <span class="text-xs font-medium text-[#007AFF] flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <a href="DriverManagement.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-orange-500/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Drivers</span>
                    <div class="p-2 rounded-lg bg-orange-500/10 text-orange-500 group-hover:bg-orange-500 group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblDrivers" runat="server" CssClass="text-3xl font-extrabold text-orange-500">0</asp:Label>
                    <span class="text-xs font-medium text-orange-500 flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <a href="TripManagement.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-emerald-500/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Trips Today</span>
                    <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-600 group-hover:bg-emerald-500 group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M6 12 3.269 3.125A59.769 59.769 0 0 1 21.485 12 59.768 59.768 0 0 1 3.27 20.875L5.999 12Zm0 0h7.5" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblTripsToday" runat="server" CssClass="text-3xl font-extrabold text-emerald-600">0</asp:Label>
                    <span class="text-xs font-medium text-emerald-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <div
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Revenue Today</span>
                    <div class="p-2 rounded-lg bg-violet-500/10 text-violet-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 6.75A2.25 2.25 0 0 1 4.5 4.5h15a2.25 2.25 0 0 1 2.25 2.25v10.5A2.25 2.25 0 0 1 19.5 19.5h-15a2.25 2.25 0 0 1-2.25-2.25V6.75Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M12 9a3 3 0 1 1 0 6 3 3 0 0 1 0-6Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M6 9h.008M18 15h.008" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblRevenueToday" runat="server" CssClass="text-3xl font-extrabold text-violet-600">0</asp:Label>
                    <span class="text-xs font-medium text-gray-400">Paid &amp; completed</span>
                </div>
            </div>
        </div>

        <%-- Income outcome and today's trips. These count the whole platform, not one driver's
             slice, which is the only difference from the same two charts on the driver dashboard.
             Both rules are shared with it, though: income is money in for a ride that finished,
             and today's trips split into the three buckets an admin acts on. --%>
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-5">
            <div class="lg:col-span-7 bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
                <div class="flex items-center gap-3">
                    <div class="p-2 rounded-lg bg-violet-500/10 text-violet-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
</svg>
                    </div>
                    <div>
                        <p class="text-sm font-bold text-gray-900">7-Day Income</p>
                        <p class="text-xs text-gray-500">MMK <asp:Label ID="lblWeekRevenue" runat="server" Text="0" /> · Last 7 days</p>
                    </div>
                </div>
                <div class="mt-3 relative h-64">
                    <canvas id="revenueChart"></canvas>
                    <p id="revenueEmpty" class="absolute inset-0 hidden items-center justify-center px-4 text-center text-xs text-gray-400">No paid trips in the last 7 days.</p>
                </div>
            </div>

            <div class="lg:col-span-5 bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
                <div class="flex items-center gap-3">
                    <div class="p-2 rounded-lg bg-[#007AFF]/10 text-[#007AFF]">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/>
  <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/>
</svg>
                    </div>
                    <div class="flex-1">
                        <p class="text-sm font-bold text-gray-900">Today's Trips</p>
                        <p class="text-xs text-gray-500"><asp:Label ID="lblAdminTodayDate" runat="server" Text=" " /></p>
                    </div>
                    <span class="text-xs font-semibold px-2 py-1 rounded-full bg-blue-50 text-blue-600"><asp:Label ID="lblAdminTodayTotal" runat="server" Text=" " /></span>
                </div>
                <div class="mt-4 relative h-56">
                    <canvas id="adminTodayRing"></canvas>
                    <p id="adminTodayEmpty" class="absolute inset-0 hidden items-center justify-center text-xs text-gray-400">No trips requested today.</p>
                </div>
            </div>
        </div>

        <%-- Fleet availability. The map and the Recent Trip Activity table were both removed: the
             map needed Leaflet plus a tile server on every admin page load, and the activity
             table duplicated what the driver and customer dashboards already show per trip. The
             ring answers the question an admin opens this page for, and the offline figure is
             spelled out rather than left for the reader to subtract: "1 of 4 online" hides the
             3 drivers who are not, which is the number most worth seeing.
             The driver list this card used to carry is gone; DriverManagement.aspx is where
             an admin goes to open one. --%>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
            <div class="flex items-center justify-between gap-3 mb-4">
                <div class="flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-emerald-500"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                    <h2 class="text-sm font-bold text-gray-900">Drivers Online Now</h2>
                </div>
                <asp:Label ID="lblOnlineCount" runat="server" Text=" " CssClass="text-xs font-semibold px-2 py-1 rounded-full bg-emerald-50 text-emerald-700" />
            </div>

            <div class="grid md:grid-cols-2 gap-6 items-center">
                <div class="relative h-56 w-full mx-auto" style="max-width:240px">
                    <canvas id="driversOnlineRing"></canvas>
                    <p id="driversOnlineEmpty" class="absolute inset-0 hidden items-center justify-center px-4 text-center text-xs text-gray-400">No drivers registered yet.</p>
                </div>

                <div class="grid grid-cols-2 gap-3">
                    <div class="rounded-lg border border-emerald-200 bg-emerald-50/60 px-4 py-3">
                        <p class="text-xs font-semibold text-emerald-700">Online</p>
                        <p class="text-2xl font-extrabold text-emerald-600 mt-0.5"><asp:Label ID="lblOnlineFigure" runat="server" Text="0" /></p>
                    </div>
                    <div class="rounded-lg border border-slate-200 bg-slate-50 px-4 py-3">
                        <p class="text-xs font-semibold text-gray-500">Offline</p>
                        <p class="text-2xl font-extrabold text-gray-500 mt-0.5"><asp:Label ID="lblOfflineFigure" runat="server" Text="0" /></p>
                    </div>
                    <p class="col-span-2 text-xs text-gray-400">
                        <asp:Label ID="lblFleetTotal" runat="server" Text=" " />
                    </p>
                </div>
            </div>
        </div>
    </div>

        <script type="application/json" id="revenueData"><%= Revenue7DayJson %></script>
        <script type="application/json" id="adminTodayData"><%= AdminTodayTripsJson %></script>
        <script type="application/json" id="driversOnlineData"><%= DriversOnlineJson %></script>
        <script src="<%= ResolveUrl("~/Scripts/chart.js") %>?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/Scripts/chart.js")).Ticks %>"></script>
        <script>
            (function () {
                'use strict';

                /* A payload that will not parse used to be swallowed and read as an empty week or
                   an empty fleet, which put blank canvases on the page with no explanation. Name
                   the fault instead of guessing which of the two it is. */
                function readJson(id) {
                    var el = document.getElementById(id);
                    if (!el) {
                        window.console && console.error('TripWay: #' + id + ' is missing.');
                        return null;
                    }
                    var raw = el.textContent;
                    if (!raw || !raw.trim()) {
                        window.console && console.error(
                            'TripWay: #' + id + ' is empty. The code-behind property rendered nothing, ' +
                            'so this is a server-side failure rather than a drawing problem.');
                        return null;
                    }
                    try { return JSON.parse(raw); }
                    catch (e) {
                        window.console && console.error('TripWay: #' + id + ' is not valid JSON: ' + e.message +
                            ' | first 120 chars: ' + raw.replace(/^\s+/, '').slice(0, 120));
                        return null;
                    }
                }

                function setText(id, value) {
                    var el = document.getElementById(id);
                    if (el) el.textContent = value;
                    else window.console && console.error('TripWay: #' + id + ' is missing from the page.');
                }

                function cardFailed(canvasId, noteId, what, detail) {
                    var canvas = document.getElementById(canvasId);
                    var note = document.getElementById(noteId);
                    if (canvas) canvas.classList.add('hidden');
                    if (!note) return;
                    note.textContent = what + ' could not be drawn. ' + (detail || '');
                    note.classList.remove('hidden');
                    note.classList.add('flex');
                    window.console && console.error('TripWay: ' + what + ' failed to draw: ' + (detail || 'unknown error'));
                }

                /* If this file 404s the cards would be blank with no complaint of any kind, which reads the same
                   as no income, no trips and nobody online. Say so on each one instead. */
                function chartLibraryMissing() {
                    window.console && console.error(
                        'TripWay: Chart.js did not load, so the admin dashboard charts cannot be drawn. ' +
                        'Check that Scripts/chart.js is present in the deployed output.');

                    [['revenueChart', 'revenueEmpty'],
                     ['adminTodayRing', 'adminTodayEmpty'],
                     ['driversOnlineRing', 'driversOnlineEmpty']].forEach(function (pair) {
                        var canvas = document.getElementById(pair[0]);
                        var note = document.getElementById(pair[1]);
                        if (canvas) canvas.classList.add('hidden');
                        if (!note) return;
                        note.textContent = 'Charts unavailable: Scripts/chart.js did not load.';
                        note.classList.remove('hidden');
                        note.classList.add('flex');
                    });
                }

                function applyChartDefaults() {
                    Chart.defaults.font.family = window.getComputedStyle(document.body).fontFamily;
                    Chart.defaults.font.size = 11;
                    Chart.defaults.color = '#9ca3af';
                }

                function money(n) {
                    return 'MMK ' + Number(n || 0).toLocaleString('en-US');
                }

                /* Axis labels stay short so they cannot crowd the plot: 18,900 reads as 19k. */
                function shortMoney(n) {
                    n = Number(n) || 0;
                    if (n >= 1000000) return (n / 1000000).toFixed(n % 1000000 ? 1 : 0) + 'M';
                    if (n >= 1000) return Math.round(n / 1000) + 'k';
                    return String(n);
                }

                function drawRevenue(data) {
                    var canvas = document.getElementById('revenueChart');
                    if (!canvas || !data) return;

                    /* Seven days of zero gives a flat line lying on the axis with a 0/0.5/1 scale,
                       which is indistinguishable from a chart that failed to draw. */
                    var values = (data.values || []).map(Number);
                    var hasIncome = values.some(function (v) { return v > 0; });
                    var note = document.getElementById('revenueEmpty');
                    if (note) {
                        note.classList.toggle('hidden', hasIncome);
                        note.classList.toggle('flex', !hasIncome);
                    }
                    canvas.classList.toggle('hidden', !hasIncome);
                    if (!hasIncome) return;

                    new Chart(canvas, {
                        type: 'line',
                        data: {
                            labels: data.labels || [],
                            datasets: [{
                                label: 'Paid income',
                                data: values,
                                borderColor: '#7c3aed',
                                backgroundColor: 'rgba(124, 58, 237, 0.10)',
                                borderWidth: 3,
                                tension: 0.4,
                                fill: true,
                                pointRadius: 4,
                                pointHoverRadius: 6,
                                pointBackgroundColor: '#7c3aed',
                                pointBorderColor: '#ffffff',
                                pointBorderWidth: 2
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            interaction: { mode: 'index', intersect: false },
                            plugins: {
                                legend: { display: false },
                                tooltip: {
                                    displayColors: false,
                                    callbacks: {
                                        title: function (items) {
                                            return (data.tips || [])[items[0].dataIndex] || items[0].label;
                                        },
                                        label: function (item) { return money(item.parsed.y); }
                                    }
                                }
                            },
                            scales: {
                                y: {
                                    beginAtZero: true,
                                    border: { display: false },
                                    grid: { color: '#f1f5f9', drawTicks: false },
                                    ticks: { padding: 8, maxTicksLimit: 5, callback: function (v) { return shortMoney(v); } }
                                },
                                x: {
                                    border: { display: false },
                                    grid: { display: false },
                                    ticks: { padding: 6 }
                                }
                            }
                        }
                    });
                }

                function drawAdminToday(data) {
                    var canvas = document.getElementById('adminTodayRing');
                    if (!canvas || !data) return;

                    var slices = [
                        { label: 'Completed',   value: Number(data.completed)   || 0, color: '#0084ff' },
                        { label: 'In progress', value: Number(data.inProgress) || 0, color: '#ff7b00' },
                        { label: 'Cancelled',   value: Number(data.cancelled)   || 0, color: '#fb7185' }
                    ];
                    var total = 0;
                    slices.forEach(function (s) { total += s.value; });

                    var empty = document.getElementById('adminTodayEmpty');
                    if (empty) {
                        empty.classList.toggle('hidden', total > 0);
                        empty.classList.toggle('flex', total === 0);
                    }
                    canvas.classList.toggle('hidden', total === 0);

                    /* One trip in progress is 100% of the day's trips, so the ring draws as an
                       unbroken circle that looks like a large number rather than a single one.
                       The count in the middle keeps that honest. */
                    var centreLabel = {
                        id: 'adminTodayCentre',
                        afterDatasetsDraw: function (chart) {
                            var arc = chart.getDatasetMeta(0).data[0];
                            if (!arc) return;
                            var ctx = chart.ctx;
                            ctx.save();
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'middle';
                            ctx.fillStyle = '#111827';
                            ctx.font = '600 24px ' + Chart.defaults.font.family;
                            ctx.fillText(String(total), arc.x, arc.y - 7);
                            ctx.fillStyle = '#9ca3af';
                            ctx.font = '11px ' + Chart.defaults.font.family;
                            ctx.fillText(total === 1 ? 'trip' : 'trips', arc.x, arc.y + 15);
                            ctx.restore();
                        }
                    };

                    new Chart(canvas, {
                        type: 'doughnut',
                        plugins: [centreLabel],
                        data: {
                            labels: slices.map(function (s) { return s.label; }),
                            datasets: [{
                                data: slices.map(function (s) { return s.value; }),
                                backgroundColor: slices.map(function (s) { return s.color; }),
                                borderWidth: 0,
                                hoverOffset: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '75%',
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        boxWidth: 12,
                                        boxHeight: 12,
                                        padding: 20,
                                        usePointStyle: true,
                                        pointStyle: 'circle'
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (item) {
                                            var v = Number(item.parsed) || 0;
                                            var pct = total ? Math.round(v / total * 100) : 0;
                                            return item.label + ': ' + v + ' (' + pct + '%)';
                                        }
                                    }
                                }
                            }
                        }
                    });
                }

                function payloadMissing(canvasId, noteId, what) {
                    var canvas = document.getElementById(canvasId);
                    var note = document.getElementById(noteId);
                    if (canvas) canvas.classList.add('hidden');
                    if (!note) return;
                    note.textContent = what + ' could not be read from the server. See the browser console.';
                    note.classList.remove('hidden');
                    note.classList.add('flex');
                }

                function drawFleet(data) {
                    var canvas = document.getElementById('driversOnlineRing');
                    if (!canvas) return;

                    var total = Number(data.total || 0);
                    var online = Number(data.online || 0);
                    var offline = Number(data.offline || 0);

                    /* No drivers at all is a different statement from "none are online right now",
                       and a ring with two zero slices cannot tell them apart. */
                    var note = document.getElementById('driversOnlineEmpty');
                    if (total <= 0) {
                        canvas.classList.add('hidden');
                        if (note) {
                            note.textContent = 'No drivers registered yet.';
                            note.classList.remove('hidden');
                            note.classList.add('flex');
                        }
                        return;
                    }

                    var centreLabel = {
                        id: 'fleetCentre',
                        afterDatasetsDraw: function (chart) {
                            var arc = chart.getDatasetMeta(0).data[0];
                            if (!arc) return;
                            var ctx = chart.ctx;
                            ctx.save();
                            ctx.textAlign = 'center';
                            ctx.textBaseline = 'middle';
                            ctx.fillStyle = '#111827';
                            ctx.font = '600 26px ' + Chart.defaults.font.family;
                            ctx.fillText(String(online), arc.x, arc.y - 7);
                            ctx.fillStyle = '#9ca3af';
                            ctx.font = '11px ' + Chart.defaults.font.family;
                            ctx.fillText(online === 1 ? 'driver online' : 'drivers online', arc.x, arc.y + 15);
                            ctx.restore();
                        }
                    };

                    new Chart(canvas, {
                        type: 'doughnut',
                        plugins: [centreLabel],
                        data: {
                            labels: ['Online', 'Offline'],
                            datasets: [{
                                data: [online, offline],
                                backgroundColor: ['#10b981', '#e2e8f0'],
                                borderWidth: 0,
                                hoverOffset: 6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            cutout: '68%',
                            plugins: {
                                legend: {
                                    position: 'bottom',
                                    labels: {
                                        boxWidth: 12,
                                        boxHeight: 12,
                                        padding: 18,
                                        usePointStyle: true,
                                        pointStyle: 'circle'
                                    }
                                },
                                tooltip: {
                                    callbacks: {
                                        label: function (item) {
                                            var v = Number(item.parsed) || 0;
                                            var pct = total ? Math.round(v / total * 100) : 0;
                                            return item.label + ': ' + v + ' (' + pct + '%)';
                                        }
                                    }
                                }
                            }
                        }
                    });
                }

                function init() {
                    /* Headings are written before Chart.js is touched. They come from the database
                       and have nothing to do with drawing, so they stay truthful when scripting is
                       off or the library is missing. */
                    var week = readJson('revenueData');
                    if (week) setText('lblWeekRevenue', Number(week.total || 0).toLocaleString('en-US'));

                    var today = readJson('adminTodayData');
                    if (today) {
                        setText('lblAdminTodayDate', today.date || '');
                        setText('lblAdminTodayTotal', (Number(today.total) || 0) + ' trips today');
                    }

                    var fleet = readJson('driversOnlineData');
                    if (fleet) {
                        setText('lblOnlineCount', fleet.online + ' of ' + fleet.total + ' online');
                        setText('lblOnlineFigure', Number(fleet.online) || 0);
                        setText('lblOfflineFigure', Number(fleet.offline) || 0);
                        setText('lblFleetTotal', (Number(fleet.total) || 0) +
                            (Number(fleet.total) === 1
                                ? ' driver registered on the platform'
                                : ' drivers registered on the platform'));
                    }

                    if (!window.Chart) { chartLibraryMissing(); return; }

                    try { applyChartDefaults(); }
                    catch (e) {
                        cardFailed('revenueChart', 'revenueEmpty', '7-Day Income', e.message);
                        cardFailed('adminTodayRing', 'adminTodayEmpty', "Today's Trips", e.message);
                        cardFailed('driversOnlineRing', 'driversOnlineEmpty', 'Drivers Online Now', e.message);
                        return;
                    }

                    /* Each card is drawn inside its own guard. Chart.js throws for reasons invisible
                       from here - a canvas already in use, a bad 2d context, a zero-sized parent -
                       and one throw used to stop the next chart before it started, which is why
                       every card on the page could go blank together with nothing logged. */
                    if (week) {
                        try { drawRevenue(week); }
                        catch (e) { cardFailed('revenueChart', 'revenueEmpty', '7-Day Income', e.message); }
                    } else {
                        payloadMissing('revenueChart', 'revenueEmpty', '7-Day Income data');
                    }

                    if (today) {
                        try { drawAdminToday(today); }
                        catch (e) { cardFailed('adminTodayRing', 'adminTodayEmpty', "Today's Trips", e.message); }
                    } else {
                        payloadMissing('adminTodayRing', 'adminTodayEmpty', "Today's Trips data");
                    }

                    if (fleet) {
                        try { drawFleet(fleet); }
                        catch (e) { cardFailed('driversOnlineRing', 'driversOnlineEmpty', 'Drivers Online Now', e.message); }
                    } else {
                        payloadMissing('driversOnlineRing', 'driversOnlineEmpty', 'Drivers Online Now data');
                    }
                }

                if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
                else init();
            })();
        </script>
</asp:Content>