<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="TripWay.Driver.DashboardPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">

        <%-- Driver identity banner --%>
        <div class="w-full bg-white rounded-xl border border-slate-200 p-6 shadow-sm overflow-hidden">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-6 items-center">
                <div class="lg:col-span-8 space-y-4">
                    <div class="flex items-center gap-4">
                        <div class="size-20 rounded-2xl border-2 border-slate-200 bg-blue-50 text-blue-600 shadow-sm flex items-center justify-center shrink-0">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8"><path stroke-linecap="round" stroke-linejoin="round" d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path stroke-linecap="round" stroke-linejoin="round" d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>
                        </div>
                        <div class="space-y-1">
                            <div class="flex items-center gap-2 flex-wrap">
                                <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-[#007AFF]/10 text-[#007AFF] border border-[#007AFF]/20">Driver</span>
                                <span class="text-xs text-gray-400">TripWay Ride Hailing</span>
                            </div>
                            <h1 class="text-xl sm:text-2xl font-bold text-gray-900">Welcome back, <asp:Label ID="lblName" runat="server" /></h1>
                            <p class="text-xs sm:text-sm text-gray-500 leading-relaxed"><asp:Label ID="lblSub" runat="server" /></p>
                        </div>
                    </div>
                    <div class="flex items-center justify-between gap-4 flex-wrap pt-2 border-t border-slate-100">
                        <div class="flex items-center gap-3 text-xs text-gray-500 flex-wrap">
                            <span class="flex items-center gap-1.5 bg-gray-100 px-3 py-1.5 rounded-md border border-slate-200 font-medium">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5 text-[#007AFF]"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>Hpa-An
                            </span>
                            <span class="flex items-center gap-1.5 bg-emerald-50 px-3 py-1.5 rounded-md border border-emerald-200 font-medium text-emerald-700">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21a9.004 9.004 0 0 0 8.716-6.747M12 21a9.004 9.004 0 0 1-8.716-6.747M12 21c2.485 0 4.5-4.03 4.5-9S14.485 3 12 3m0 18c-2.485 0-4.5-4.03-4.5-9S9.515 3 12 3m0 0a8.997 8.997 0 0 1 7.843 4.582M12 3a8.997 8.997 0 0 0-7.843 4.582m15.686 0A11.953 11.953 0 0 1 12 10.5c-2.998 0-5.74-1.1-7.843-2.918m15.686 0A8.959 8.959 0 0 1 21 12c0 .778-.099 1.533-.284 2.253m0 0A17.919 17.919 0 0 1 12 16.5c-3.162 0-6.133-.815-8.716-2.247m0 0A9.015 9.015 0 0 1 3 12c0-1.605.42-3.113 1.157-4.418"/></svg>Online status
                            </span>
                        </div>
                        <div class="flex items-center gap-3">
                            <asp:LinkButton ID="lnkToggleOnline" runat="server" OnClick="lnkToggleOnline_Click" CausesValidation="false" Style="display:none" />
                            <label class="inline-flex items-center gap-2.5 cursor-pointer select-none">
                                <input type="checkbox" class="sr-only peer" <%= IsOnlineNow ? "checked='checked'" : "" %>
                                    onchange='__doPostBack("<%= lnkToggleOnline.UniqueID %>","")' />
                                <span class="relative w-9 h-5 rounded-full bg-gray-300 transition-colors duration-150 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-200 peer-checked:bg-emerald-500 after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:size-4 after:rounded-full after:bg-white after:shadow-sm after:transition-transform after:duration-150 peer-checked:after:translate-x-4"></span>
                                <asp:Label ID="lblOnlineText" runat="server" CssClass="text-sm font-medium text-gray-900" />
                            </label>
                            <a href="Profile.aspx" class="inline-flex items-center gap-1.5 text-xs font-semibold text-[#007AFF] hover:underline">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5"><path stroke-linecap="round" stroke-linejoin="round" d="M9.594 3.94c.09-.542.56-.94 1.11-.94h2.593c.55 0 1.02.398 1.11.94l.213 1.281c.063.374.313.686.645.87.074.04.147.083.22.127.324.196.72.257 1.075.124l1.217-.456a1.125 1.125 0 0 1 1.37.49l1.296 2.247a1.125 1.125 0 0 1-.26 1.431l-1.003.827c-.293.24-.438.613-.43.992a7.723 7.723 0 0 1 0 .255c-.008.378.137.75.43.991l1.004.827c.424.35.534.955.26 1.43l-1.298 2.247a1.125 1.125 0 0 1-1.369.491l-1.217-.456c-.355-.133-.75-.072-1.076.124a6.47 6.47 0 0 1-.22.128c-.331.183-.581.495-.644.869l-.213 1.281c-.09.543-.56.94-1.11.94h-2.594c-.55 0-1.019-.398-1.11-.94l-.213-1.281c-.062-.374-.312-.686-.644-.87a6.52 6.52 0 0 1-.22-.127c-.325-.196-.72-.257-1.076-.124l-1.217.456a1.125 1.125 0 0 1-1.369-.49l-1.297-2.247a1.125 1.125 0 0 1 .26-1.431l1.004-.827c.292-.24.437-.613.43-.991a6.932 6.932 0 0 1 0-.255c.007-.38-.138-.751-.43-.992l-1.004-.827a1.125 1.125 0 0 1-.26-1.43l1.297-2.247a1.125 1.125 0 0 1 1.37-.491l1.216.456c.356.133.751.072 1.076-.123.072-.044.146-.087.22-.128.332-.183.582-.495.644-.869l.214-1.281Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>Update Profile &rarr;
                            </a>
                        </div>
                    </div>
                </div>
                <div class="lg:col-span-4">
                    <a href="TripRequests.aspx"
                        class="relative aspect-[16/10] w-full rounded-xl bg-gradient-to-br from-[#007AFF] to-[#1d4ed8] border border-slate-200 shadow-sm overflow-hidden group flex flex-col justify-end p-4 text-white">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 absolute top-3 right-4 text-yellow-300"><path stroke-linecap="round" stroke-linejoin="round" d="M9.813 15.904 9 18.75l-.813-2.846a4.5 4.5 0 0 0-3.09-3.09L2.25 12l2.846-.813a4.5 4.5 0 0 0 3.09-3.09L9 5.25l.813 2.846a4.5 4.5 0 0 0 3.09 3.09L15.75 12l-2.846.813a4.5 4.5 0 0 0-3.09 3.09ZM18.259 8.715 18 9.75l-.259-1.035a3.375 3.375 0 0 0-2.455-2.456L14.25 6l1.036-.259a3.375 3.375 0 0 0 2.455-2.456L18 2.25l.259 1.035a3.375 3.375 0 0 0 2.456 2.456L21.75 6l-1.035.259a3.375 3.375 0 0 0-2.456 2.456ZM16.894 20.567 16.5 21.75l-.394-1.183a2.25 2.25 0 0 0-1.423-1.423L13.5 18.75l1.183-.394a2.25 2.25 0 0 0 1.423-1.423l.394-1.183.394 1.183a2.25 2.25 0 0 0 1.423 1.423l1.183.394-1.183.394a2.25 2.25 0 0 0-1.423 1.423Z"/></svg>
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-7 mb-1 group-hover:-translate-y-0.5 transition-transform"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                        <span class="text-sm font-semibold">Find Trips</span>
                        <span class="text-xs text-blue-100 mt-0.5">Accept new ride requests when online</span>
                    </a>
                </div>
            </div>
        </div>

        <%-- KYC banner --%>
        <asp:Panel ID="pnlKycBanner" runat="server" Visible="false"
            CssClass="p-4 rounded-xl bg-amber-50 border border-amber-200 flex flex-wrap items-center justify-between gap-3">
            <div class="flex items-center gap-3">
                <span class="size-10 rounded-xl bg-amber-500 text-white flex items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z"/></svg>
                </span>
                <div>
                    <p class="text-sm font-bold text-amber-900">Your KYC is <asp:Label ID="lblKycState" runat="server" />.</p>
                    <p class="text-xs text-amber-700">An admin will review your documents before you can go online.</p>
                </div>
            </div>
        </asp:Panel>

        <%-- Active trip banner --%>
        <asp:Panel ID="pnlActiveBanner" runat="server" Visible="false"
            CssClass="p-4 rounded-xl bg-blue-50 border border-blue-200 flex flex-wrap items-center justify-between gap-3">
            <div class="flex items-center gap-3">
                <span class="size-10 rounded-xl bg-blue-600 text-white flex items-center justify-center">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path stroke-linecap="round" stroke-linejoin="round" d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>
                </span>
                <div>
                    <p class="text-sm font-bold text-blue-900">You have an <asp:Label ID="lblActiveStatus" runat="server" /> trip.</p>
                    <p class="text-xs text-blue-700"><asp:Label ID="lblActiveService" runat="server" /></p>
                </div>
            </div>
            <a href="ActiveTrip.aspx" class="tw-btn-secondary">Open Trip Screen</a>
        </asp:Panel>

        <%-- Overview statistics --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
            <div
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Today's Earnings</span>
                    <div class="p-2 rounded-lg bg-emerald-500/10 text-emerald-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M2.25 18.75a60.07 60.07 0 0 1 15.797 2.101c.727.198 1.453-.342 1.453-1.096V18.75M3.75 4.5v.75A.75.75 0 0 1 3 6h-.75m0 0v-.375c0-.621.504-1.125 1.125-1.125H20.25M2.25 6v9m18-10.5v.75c0 .414.336.75.75.75h.75m-1.5-1.5h.375c.621 0 1.125.504 1.125 1.125v9.75c0 .621-.504 1.125-1.125 1.125h-.375m1.5-1.5H21a.75.75 0 0 0-.75.75v.75m0 0H3.75m0 0h-.375a1.125 1.125 0 0 1-1.125-1.125V15m1.5 1.5v-.75A.75.75 0 0 0 3 15h-.75M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Zm3 0h.008v.008H18V10.5Zm-12 0h.008v.008H6V10.5Z"/></svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <span class="text-3xl font-extrabold text-emerald-600">MMK <asp:Label ID="lblTodayEarnings" runat="server" Text="0" /></span>
                    <span class="text-xs font-medium text-gray-400">Paid trips</span>
                </div>
            </div>
            <a href="TripHistory.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-[#007AFF]/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Trips Today</span>
                    <div class="p-2 rounded-lg bg-[#007AFF]/10 text-[#007AFF] group-hover:bg-[#007AFF] group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblTodayTrips" runat="server" Text="0" CssClass="text-3xl font-extrabold text-gray-900" />
                    <span class="text-xs font-medium text-[#007AFF] flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <a href="TripHistory.aspx"
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm hover:border-violet-500/50 transition-all flex flex-col justify-between group space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">All-Time Trips</span>
                    <div class="p-2 rounded-lg bg-violet-500/10 text-violet-600 group-hover:bg-violet-500 group-hover:text-white transition-colors">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblTotalTrips" runat="server" Text="0" CssClass="text-3xl font-extrabold text-violet-600" />
                    <span class="text-xs font-medium text-violet-600 flex items-center gap-1 group-hover:translate-x-1 transition-transform">View <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                </div>
            </a>
            <div
                class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm flex flex-col justify-between space-y-3">
                <div class="flex items-center justify-between">
                    <span class="text-xs font-semibold text-gray-500">Average Rating</span>
                    <div class="p-2 rounded-lg bg-amber-500/10 text-amber-600">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z"/></svg>
                    </div>
                </div>
                <div class="flex items-baseline justify-between">
                    <asp:Label ID="lblRating" runat="server" Text="--" CssClass="text-3xl font-extrabold text-amber-600" />
                    <span class="text-xs font-medium text-gray-400">From customers</span>
                </div>
            </div>
        </div>

        <%-- Recent trips --%>
        <div class="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
            <div class="flex items-center justify-between gap-3 flex-wrap mb-4">
                <div class="flex items-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 text-violet-500"><path stroke-linecap="round" stroke-linejoin="round" d="M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"/></svg>
                    <h2 class="text-sm font-bold text-gray-900">Recent Trips</h2>
                </div>
                <a href="TripHistory.aspx" class="text-xs font-semibold text-[#007AFF] hover:underline inline-flex items-center gap-1">View all <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></a>
            </div>
            <asp:Repeater ID="rptRecent" runat="server" OnItemCommand="rptRecent_ItemCommand">
                <HeaderTemplate>
                    <table class="tw-table w-full text-sm">
                        <thead><tr><th>Date</th><th>Service</th><th>Stops</th><th>Customer</th><th>Fare</th><th>Status</th><th>Payment</th><th></th></tr></thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td class="whitespace-nowrap"><%# FormatTime(Eval("RequestedAt"), "dd MMM yyyy, HH:mm") %></td>
                        <td><%# Eval("ServiceName") %></td>
                        <td class="text-center"><span class="inline-flex px-2 py-0.5 rounded-full text-xs font-semibold <%# (int)Eval("StopsCount") > 0 ? "bg-blue-50 text-blue-600" : "bg-gray-100 text-gray-400" %>"><%# ((int)Eval("StopsCount")) > 0 ? Eval("StopsCount") + " pts" : "—" %></span></td>
                        <td><%# Eval("CustomerName") %></td>
                        <td class="font-semibold text-gray-900">MMK <%# string.Format("{0:N0}", Eval("Fare")) %></td>
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# GetStatusCss(Eval("Status").ToString()) %>"><%# Eval("Status") %></span></td>
                        <td><span class="inline-flex px-2 py-1 rounded-full text-xs font-semibold <%# GetStatusCss(Eval("PaymentStatus").ToString()) %>"><%# Eval("PaymentStatus") %></span></td>
                        <td><asp:LinkButton ID="lbtnView" runat="server" CssClass="tw-action" CommandName="view" CommandArgument='<%# Eval("TripID") %>' ToolTip="View details" CausesValidation="false"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg></asp:LinkButton></td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        <tr id="trNoData" runat="server" visible="false">
                            <td colspan="8" class="px-6 py-14 text-center"><p class="text-sm text-gray-400">No data available...</p></td>
                        </tr>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Content>