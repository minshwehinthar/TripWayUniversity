<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="TripWay.Customer.DashboardPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">

        <%-- Customer identity banner --%>
        <div class="w-full bg-white rounded-xl border border-slate-200 p-6 shadow-sm overflow-hidden">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                <div class="lg:col-span-8 space-y-4">
                    <div class="flex items-center gap-4">
                        <div class="relative shrink-0">
                            <asp:Panel ID="pnlPhoto" runat="server" Visible="false" CssClass="size-20 rounded-2xl border-2 border-slate-200 bg-white shadow-sm overflow-hidden">
                                <asp:Image ID="imgProfilePhoto" runat="server" CssClass="size-20 rounded-2xl object-cover" />
                            </asp:Panel>
                            <asp:Panel ID="pnlAvatar" runat="server" CssClass="size-20 rounded-2xl border-2 border-slate-200 bg-blue-50 text-blue-600 shadow-sm flex items-center justify-center">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8"><path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/></svg>
                            </asp:Panel>
                        </div>
                        <div class="space-y-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#007AFF]/10 text-[#007AFF] border border-[#007AFF]/20">Customer</span>
                                <span class="text-xs text-gray-400">TripWay Ride Hailing</span>
                            </div>
                            <h1 class="text-xl sm:text-2xl font-bold text-gray-900">Welcome back, <asp:Label ID="lblName" runat="server" /></h1>
                        </div>
                    </div>
                    <p class="text-xs sm:text-sm text-gray-500 leading-relaxed">Book a ride, follow your active trip and review your full journey history any time.</p>
                    <div class="flex items-center justify-between gap-4 flex-wrap pt-2 border-t border-slate-100">
                        <div class="flex items-center gap-3 text-xs text-gray-500 flex-wrap">
                            <span class="flex items-center gap-1.5 bg-gray-100 px-3 py-1.5 rounded-md border border-slate-200 font-medium">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 text-[#007AFF]"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>Hpa-An
                            </span>
                            <span class="flex items-center gap-1.5 bg-gray-100 px-3 py-1.5 rounded-md border border-slate-200 font-medium">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 text-[#007AFF]"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 6c1.5 0 2.25.75 2.25 2.25M13.5 10.5h.008v.008H13.5V10.5Zm-3 0h.008v.008H10.5V10.5Zm-3 0h.008v.008H7.5V10.5Zm-3 0h.008v.008H4.5V10.5Zm9-6.75h.008v.008H13.5V3.75Zm6 3h.008v.008H19.5V6.75Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12c0 5.385 4.365 9.75 9.75 9.75h3.75a2.25 2.25 0 0 0 2.25-2.25V5.25a2.25 2.25 0 0 0-2.25-2.25h-3.75C6.615 3 2.25 7.365 2.25 12Zm9 5.25h.008v.008H11.25V17.25Zm3 0h.008v.008H14.25V17.25Zm3 0h.008v.008H17.25V17.25Z"/></svg>Ride Hailing
                            </span>
                        </div>
                        <a href="Profile.aspx" class="inline-flex items-center gap-1.5 text-xs font-semibold text-[#007AFF] hover:underline">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.24-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.123.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>Update Profile &rarr;
                        </a>
                    </div>
                </div>
                <div class="lg:col-span-4">
                    <a href="BookTrip.aspx"
                        class="relative aspect-[16/10] w-full rounded-xl bg-gradient-to-br from-[#007AFF] to-[#1d4ed8] border border-slate-200 shadow-sm overflow-hidden group flex flex-col justify-end p-4 text-white">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute top-3 right-4 text-yellow-300"><path stroke-linecap="round" stroke-linejoin="round" d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09ZM18.259 8.715 18 9.75l-.259-1.035a3.375 3.375 0 0 0-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 0 0 2.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 0 0 2.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 0 0-2.456 2.456ZM16.894 20.567 16.5 21.75l-.394-1.183a2.25 2.25 0 0 0-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 0 0 1.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 0 0 1.423 1.423l1.183.394-1.183.394a2.25 2.25 0 0 0-1.423 1.423Z"/></svg>
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7 mb-1 group-hover:-translate-y-0.5 transition-transform"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
                        <span class="text-sm font-semibold">Book Your Next Ride</span>
                        <span class="text-xs text-blue-100 mt-0.5">Motorbike, tuk-tuk, saloon or VIP van</span>
                    </a>
                </div>
            </div>
        </div>

        <%-- Active trip banner --%>
        <asp:Panel ID="pnlActiveBanner" runat="server" Visible="false"
            CssClass="p-4 rounded-xl bg-blue-50 border border-blue-200 flex flex-wrap items-center justify-between gap-3">
            <div class="flex items-center gap-3">
                <span class="size-10 rounded-xl bg-blue-600 text-white flex items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                </span>
                <div>
                    <p class="text-sm font-bold text-blue-900"><asp:Label ID="lblActiveStatus" runat="server" /></p>
                    <p class="text-xs text-blue-700"><asp:Label ID="lblActiveService" runat="server" /> — <asp:Label ID="lblActiveDriver" runat="server" /></p>
                </div>
            </div>
            <a href="ActiveTrip.aspx" class="tw-btn-secondary">View Live Trip</a>
        </asp:Panel>

        <%-- Overview statistics --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <a href="TripHistory.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-[#007AFF]/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Total Trips</span>
                    <div class="p-2 rounded-lg bg-[#007AFF]/10 text-[#007AFF] group-hover:bg-[#007AFF] group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M6 7a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M18 21a2 2 0 1 0 0-4 2 2 0 0 0 0 4Z" />
  <path stroke-linecap="round" stroke-linejoin="round" d="M6 7v3a3 3 0 0 0 3 3h6a3 3 0 0 1 3 3v1" stroke-dasharray="2.5 2.5" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblTotalTrips" runat="server" Text="0" CssClass="text-3xl font-extrabold text-gray-900" />
                    <span class="text-xs font-medium text-[#007AFF] flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <a href="TripHistory.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-emerald-500/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Trips This Month</span>
                    <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-600 group-hover:bg-emerald-500 group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3.75 18.75V7.5A2.25 2.25 0 0 1 6 5.25h12A2.25 2.25 0 0 1 20.25 7.5v11.25m-16.5 0A2.25 2.25 0 0 0 6 21h12a2.25 2.25 0 0 0 2.25-2.25m-16.5 0v-7.5A2.25 2.25 0 0 1 6 9h12a2.25 2.25 0 0 1 2.25 2.25v7.5" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblMonthTrips" runat="server" Text="0" CssClass="text-3xl font-extrabold text-emerald-600" />
                    <span class="text-xs font-medium text-emerald-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <div
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Total Spent</span>
                    <div class="p-2 rounded-lg bg-violet-500/10 text-violet-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375A1.125 1.125 0 0 1 2.25 19.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <span class="text-3xl font-extrabold text-violet-600">MMK <asp:Label ID="lblTotalSpent" runat="server" Text="0" /></span>
                    <span class="text-xs font-medium text-gray-400">Paid trips</span>
                </div>
            </div>
            <div
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Most Used Ride</span>
                    <div class="p-2 rounded-lg bg-orange-500/10 text-orange-500">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 12.75V12A2.25 2.25 0 0 1 4.5 9.75h15A2.25 2.25 0 0 1 21.75 12v.75m-19.5 0V19.5A2.25 2.25 0 0 0 4.5 21.75h15a2.25 2.25 0 0 0 2.25-2.25V12.75m-19.5 0A2.25 2.25 0 0 0 4.5 15h15a2.25 2.25 0 0 0 2.25-2.25m-19.5 0V6.108c0-1.135.845-2.098 1.976-2.192.373-.03.748-.057 1.124-.08M8.25 3.75V4.5m0 0L5.106 5.106M2.25 6.75V7.5m19.5 0v-.75c0-1.135-.845-2.098-1.976-2.192a48.424 48.424 0 0 0-1.123-.08m-5.801 0c-.065.21-.1.433-.1.664 0 .414.336.75.75.75h4.5a.75.75 0 0 0 .75-.75 2.25 2.25 0 0 0-.1-.664m-5.8 0A2.251 2.251 0 0 1 13.5 2.25H15c1.012 0 1.867.668 2.15 1.586m-5.8 0c-.376.023-.75.05-1.124.08C9.095 4.01 8.25 4.973 8.25 6.108V6.75" />
</svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblFavoriteVehicle" runat="server" Text="--" CssClass="text-3xl font-extrabold text-orange-500" />
                    <span class="text-xs font-medium text-gray-400">Favourite vehicle</span>
                </div>
            </div>
        </div>

        <%-- Charts. Both series are built by Dashboard.aspx.cs, which reads the same Paid
             rule as Total Spent above and groups on the local day by shifting RequestedAt
             forward, so a trip booked late at night is counted on the day it was booked. --%>
        <div class="grid grid-cols-1 lg:grid-cols-12 gap-5">
            <div class="lg:col-span-7 bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                    <div class="flex items-center gap-3">
                        <div class="p-2 rounded-lg bg-[#007AFF]/10 text-[#007AFF]">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M3 13.125C3 12.504 3.504 12 4.125 12h2.25c.621 0 1.125.504 1.125 1.125v6.75C7.5 20.496 6.996 21 6.375 21h-2.25A1.125 1.125 0 0 1 3 19.875v-6.75ZM9.75 8.625c0-.621.504-1.125 1.125-1.125h2.25c.621 0 1.125.504 1.125 1.125v11.25c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V8.625ZM16.5 4.125C16.5 3.504 17.004 3 17.625 3h2.25C20.496 3 21 3.504 21 4.125v15.75c0 .621-.504 1.125-1.125 1.125h-2.25a1.125 1.125 0 0 1-1.125-1.125V4.125Z" />
</svg>
                        </div>
                        <div>
                            <p class="text-sm font-bold text-gray-900">Seven-Day Income</p>
                            <p class="text-xs text-gray-500">Paid trips per day</p>
                        </div>
                    </div>
                    <div class="text-right">
                        <p class="text-2xl font-extrabold text-gray-900" id="incomeTotal">MMK 0</p>
                        <p class="text-xs text-gray-500">Last 7 days</p>
                    </div>
                </div>
                <div class="mt-3 relative h-64">
                    <canvas id="incomeChart"></canvas>
                    <p id="incomeEmpty" class="absolute inset-0 hidden items-center justify-center px-4 text-center text-xs text-gray-400">No paid trips in the last 7 days.</p>
                </div>
            </div>

            <div class="lg:col-span-5 bg-white rounded-xl border border-slate-200 p-6 shadow-sm">
                <div class="flex items-center gap-3">
                    <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6">
  <path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
</svg>
                    </div>
                    <div>
                        <p class="text-sm font-bold text-gray-900">Today's Trips</p>
                        <p class="text-xs text-gray-500" id="todayDate">&nbsp;</p>
                    </div>
                </div>
                <div class="mt-4 relative h-56">
                    <canvas id="todayRing"></canvas>
                    <p id="todayEmpty" class="absolute inset-0 hidden items-center justify-center text-xs text-gray-400">No trips requested today.</p>
                </div>
            </div>
        </div>

        <script type="application/json" id="incomeData"><%= Income7DayJson %></script>
        <script type="application/json" id="todayData"><%= TodayTripsJson %></script>
        <script src="<%= ResolveUrl("~/Scripts/chart.js") %>?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/Scripts/chart.js")).Ticks %>"></script>
        <script>
            (function () {
                'use strict';

                function readJson(id) {
                    var el = document.getElementById(id);
                    if (!el) return null;
                    try { return JSON.parse(el.textContent); } catch (e) { return null; }
                }

                function money(n) {
                    return 'MMK ' + Number(n || 0).toLocaleString('en-US');
                }

                /* Axis labels stay short so they cannot crowd the plot: 4,200 reads as 4k. */
                function shortMoney(n) {
                    n = Number(n) || 0;
                    if (n >= 1000000) return (n / 1000000).toFixed(n % 1000000 ? 1 : 0) + 'M';
                    if (n >= 1000) return Math.round(n / 1000) + 'k';
                    return String(n);
                }

                /* If this file 404s the page would otherwise show two empty cards with no
                   complaint of any kind, which is indistinguishable from "no data yet". Say
                   so on the page instead of failing silently. */
                function chartLibraryMissing() {
                    window.console && console.error(
                        'TripWay: Chart.js did not load, so the dashboard charts cannot be drawn. ' +
                        'Check that Scripts/chart.js is present in the deployed output.');

                    ['incomeChart', 'todayRing'].forEach(function (id) {
                        var canvas = document.getElementById(id);
                        if (!canvas || !canvas.parentNode) return;
                        canvas.classList.add('hidden');

                        var note = document.createElement('p');
                        note.className = 'absolute inset-0 flex items-center justify-center px-4 text-center text-xs text-gray-400';
                        note.textContent = 'Charts unavailable: Scripts/chart.js did not load.';
                        canvas.parentNode.appendChild(note);
                    });
                }

                function applyChartDefaults() {
                    Chart.defaults.font.family = window.getComputedStyle(document.body).fontFamily;
                    Chart.defaults.font.size = 11;
                    Chart.defaults.color = '#9ca3af';
                }

                function drawIncome(data) {
                    var canvas = document.getElementById('incomeChart');
                    if (!canvas || !data) return;

                    /* Seven days of zero gives a flat line lying on the axis with a 0/0.5/1
                       scale, which is indistinguishable from a chart that failed to draw.
                       When there is nothing to plot, say so instead of drawing a flat line. */
                    var values = (data.values || []).map(Number);
                    var hasIncome = values.some(function (v) { return v > 0; });
                    var note = document.getElementById('incomeEmpty');
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
                                borderColor: '#007AFF',
                                backgroundColor: 'rgba(0, 122, 255, 0.10)',
                                borderWidth: 3,
                                tension: 0.4,
                                fill: true,
                                pointRadius: 4,
                                pointHoverRadius: 6,
                                pointBackgroundColor: '#007AFF',
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

                function drawRing(data) {
                    var canvas = document.getElementById('todayRing');
                    if (!canvas || !data) return;

                    var slices = [
                        { label: 'Completed',   value: Number(data.completed)   || 0, color: '#0084ff' },
                        { label: 'In progress', value: Number(data.inProgress) || 0, color: '#ff7b00' },
                        { label: 'Cancelled',   value: Number(data.cancelled)   || 0, color: '#fb7185' }
                    ];
                    var total = 0;
                    slices.forEach(function (s) { total += s.value; });

                    /* An all-zero doughnut draws an empty ring, which reads as broken rather
                       than as "nothing happened", so the canvas gives way to a line of text. */
                    var empty = document.getElementById('todayEmpty');
                    if (empty) {
                        empty.classList.toggle('hidden', total > 0);
                        empty.classList.toggle('flex', total === 0);
                    }
                    canvas.classList.toggle('hidden', total === 0);

                    /* The ring is a share of one day's trips, so a single in-progress trip fills
                       the whole circle and reads as 100%. Printing the count in the middle
                       keeps that honest without changing what the ring means. */
                    var centreLabel = {
                        id: 'centreLabel',
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
                                        label: function (ctx) {
                                            var n = ctx.parsed;
                                            return ' ' + n + (n === 1 ? ' trip' : ' trips');
                                        }
                                    }
                                }
                            }
                        }
                    });
                }

                function init() {
                    var income = readJson('incomeData');
                    var today = readJson('todayData');

                    /* These two numbers come straight from the database, so they are written
                       before anything to do with drawing. The header used to read MMK 0 when
                       the chart library was missing, which is worse than no chart at all: it
                       looks like the customer has spent nothing. */
                    var totalEl = document.getElementById('incomeTotal');
                    if (totalEl && income) totalEl.textContent = money(income.total);

                    var dateEl = document.getElementById('todayDate');
                    if (dateEl && today) dateEl.textContent = today.date || '';

                    if (!window.Chart) { chartLibraryMissing(); return; }

                    applyChartDefaults();
                    drawIncome(income);
                    drawRing(today);
                }

                if (document.readyState === 'loading') {
                    document.addEventListener('DOMContentLoaded', init);
                } else {
                    init();
                }
            })();
        </script>
    </div>
</asp:Content>