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
  <path stroke-linecap="round" stroke-linejoin="round" d="m21 7.5-9-5.25L3 7.5m18 0-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
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
  <path stroke-linecap="round" stroke-linejoin="round" d="m21 7.5-9-5.25L3 7.5m18 0-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
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
  <path stroke-linecap="round" stroke-linejoin="round" d="m21 7.5-9-5.25L3 7.5m18 0-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
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
  <path stroke-linecap="round" stroke-linejoin="round" d="m21 7.5-9-5.25L3 7.5m18 0-9 5.25m9-5.25v9l-9 5.25M3 7.5l9 5.25M3 7.5v9l9 5.25m0-9v9" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblRevenueToday" runat="server" CssClass="text-3xl font-extrabold text-violet-600">0</asp:Label>
                    <span class="text-xs font-medium text-gray-400">Completed trips</span>
                </div>
            </div>
        </div>

        <%-- Drivers online. The map and the Recent Trip Activity table were both removed: the map
             needed Leaflet plus a tile server on every admin page load, and the activity table
             duplicated what the driver and customer dashboards already show per trip. Fleet
             availability is the question an admin actually opens this page to answer, so it is a
             ring. The online list stays underneath it, because a chart cannot open a driver. --%>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
            <div class="flex items-center justify-between gap-3 mb-4">
                <div class="flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-emerald-500"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                    <h2 class="text-sm font-bold text-gray-900">Drivers Online Now</h2>
                </div>
                <span class="text-xs font-semibold px-2 py-1 rounded-full bg-emerald-50 text-emerald-700"><asp:Label ID="lblOnlineCount" runat="server" Text=" " /></span>
            </div>

            <div class="grid md:grid-cols-5 gap-6 items-center">
                <div class="md:col-span-2 relative h-56 w-full mx-auto" style="max-width:240px">
                    <canvas id="driversOnlineRing"></canvas>
                    <p id="driversOnlineEmpty" class="absolute inset-0 hidden items-center justify-center px-4 text-center text-xs text-gray-400">No drivers registered yet.</p>
                </div>

                <div class="md:col-span-3">
                    <p class="text-xs font-semibold uppercase tracking-wide text-gray-400 mb-1">On the road now</p>
                    <asp:Repeater ID="rptOnline" runat="server" OnItemCommand="rptOnline_ItemCommand">
                        <ItemTemplate>
                            <div class="flex items-center gap-3 py-2 border-b border-gray-50 last:border-0">
                                <span class="tw-avatar <%# GetAvatarCss(Eval("DriverID")) %>"><%# GetInitial(Eval("FullName").ToString()) %></span>
                                <div class="flex-1 min-w-0">
                                    <div class="text-sm font-bold text-gray-900 truncate"><%# Eval("FullName") %></div>
                                    <div class="text-xs text-gray-400"><%# Eval("VehicleTypeName") %></div>
                                </div>
                                <asp:LinkButton ID="lbtnView" runat="server" CssClass="tw-action" CommandName="view" CommandArgument='<%# Eval("DriverID") %>' ToolTip="View details" CausesValidation="false"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg></asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoOnline" runat="server" Visible="false" CssClass="tw-empty">No drivers online right now.</asp:Panel>
                </div>
            </div>
        </div>
    </div>

        <script type="application/json" id="driversOnlineData"><%= DriversOnlineJson %></script>
        <script src="<%= ResolveUrl("~/Scripts/chart.js") %>?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/Scripts/chart.js")).Ticks %>"></script>
        <script>
            (function () {
                'use strict';

                /* A payload that will not parse used to be swallowed and read as an empty fleet,
                   which put a blank ring on the page with no explanation. Name the fault instead. */
                function readJson(id) {
                    var el = document.getElementById(id);
                    if (!el) {
                        window.console && console.error('TripWay: #' + id + ' is missing.');
                        return null;
                    }
                    var raw = el.textContent;
                    if (!raw || !raw.trim()) {
                        window.console && console.error(
                            'TripWay: #' + id + ' is empty. DriversOnlineJson rendered nothing, so this is a server-side failure.');
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

                function cardFailed(noteId, what, detail) {
                    var canvas = document.getElementById('driversOnlineRing');
                    var note = document.getElementById(noteId);
                    if (canvas) canvas.classList.add('hidden');
                    if (!note) return;
                    note.textContent = what + ' could not be drawn. ' + (detail || '');
                    note.classList.remove('hidden');
                    note.classList.add('flex');
                    window.console && console.error('TripWay: ' + what + ' failed to draw: ' + (detail || 'unknown error'));
                }

                /* If this file 404s the card would be blank with no complaint of any kind, which
                   reads the same as nobody being online. Say so instead. */
                function chartLibraryMissing() {
                    window.console && console.error(
                        'TripWay: Chart.js did not load, so the admin fleet ring cannot be drawn. ' +
                        'Check that Scripts/chart.js is present in the deployed output.');
                    var canvas = document.getElementById('driversOnlineRing');
                    var note = document.getElementById('driversOnlineEmpty');
                    if (canvas) canvas.classList.add('hidden');
                    if (!note) return;
                    note.textContent = 'Charts unavailable: Scripts/chart.js did not load.';
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
                    var fleet = readJson('driversOnlineData');
                    if (fleet) setText('lblOnlineCount', fleet.online + ' of ' + fleet.total + ' online');

                    if (!window.Chart) { chartLibraryMissing(); return; }

                    try {
                        Chart.defaults.font.family = window.getComputedStyle(document.body).fontFamily;
                        Chart.defaults.font.size = 11;
                        Chart.defaults.color = '#9ca3af';
                    } catch (e) { cardFailed('driversOnlineEmpty', 'Drivers Online Now', e.message); return; }

                    if (!fleet) { cardFailed('driversOnlineEmpty', 'Drivers Online Now', 'the server sent no data'); return; }

                    try { drawFleet(fleet); }
                    catch (e) { cardFailed('driversOnlineEmpty', 'Drivers Online Now', e.message); }
                }

                if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init);
                else init();
            })();
        </script>
</asp:Content>