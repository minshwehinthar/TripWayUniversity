<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="TripWay.DefaultPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ======= Hero ======= -->
    <section class="relative bg-white overflow-hidden">
        <!-- Subtle decorative shapes -->
        <div class="absolute inset-0 overflow-hidden pointer-events-none">
            <div class="absolute -top-32 -right-32 w-[500px] h-[500px] bg-[#dbeafe] rounded-full blur-3xl opacity-60"></div>
            <div class="absolute -bottom-32 -left-32 w-[400px] h-[400px] bg-[#eff6ff] rounded-full blur-3xl opacity-80"></div>
        </div>

        <div class="relative max-w-7xl mx-auto px-4 sm:px-6 py-16 sm:py-24 lg:py-28 grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            <div>
                <span class="inline-flex items-center gap-2 rounded-full bg-[#dbeafe] border border-[#bfdbfe] px-4 py-1.5 text-xs font-semibold text-[#1d4ed8]">
                    <span class="size-1.5 rounded-full bg-[#007AFF] animate-pulse"></span> Hpa-An On-Demand Transport
                </span>
                <h1 class="mt-6 text-4xl sm:text-5xl lg:text-6xl font-extrabold leading-tight tracking-tight text-slate-900">
                    Book a Ride in Hpa-An,<br />
                    <span class="text-[#007AFF]">Arrive Your Way</span>
                </h1>
                <p class="mt-5 text-lg text-slate-500 max-w-xl leading-relaxed">Motorbike, tuk-tuk, saloon or van &mdash; fixed meters, fair prices and live GPS tracking. TripWay is Hpa-An's own ride-hailing platform.</p>
                <div class="mt-8 flex flex-wrap gap-3">
                    <asp:Panel ID="pnlHeroGuest" runat="server" CssClass="contents">
                        <a href='<%= ResolveUrl("~/Register.aspx") %>' class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#007AFF] text-white hover:bg-[#0068d9] transition-all duration-200 shadow-lg shadow-[#007AFF]/20 text-sm font-semibold hover:shadow-xl hover:shadow-[#007AFF]/30 hover:-translate-y-0.5">
                            Create an Account
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg>
                        </a>
                    </asp:Panel>
                    <asp:Panel ID="pnlHeroUser" runat="server" Visible="false" CssClass="contents">
                        <asp:HyperLink ID="lnkHeroDashboard" runat="server"
                            CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-[#007AFF] text-white hover:bg-[#0068d9] transition-all duration-200 shadow-lg shadow-[#007AFF]/20 text-sm font-semibold hover:shadow-xl hover:shadow-[#007AFF]/30 hover:-translate-y-0.5">
                            Go to Dashboard
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg>
                        </asp:HyperLink>
                    </asp:Panel>
                    <a href='<%= ResolveUrl("~/Services.aspx") %>' class="inline-flex items-center gap-2 px-6 py-3 rounded-xl border border-slate-200 text-slate-700 hover:bg-gray-100 hover:border-slate-300 transition-all duration-200 text-sm font-semibold hover:-translate-y-0.5">
                        Explore Services
                    </a>
                </div>

                <!-- Stats row -->
                <div class="mt-12 grid grid-cols-2 sm:grid-cols-4 gap-6">
                    <div>
                        <p class="text-2xl font-extrabold text-slate-900"><asp:Label ID="lblDrivers" runat="server" Text="0" /></p>
                        <p class="text-xs text-slate-400 mt-0.5">Drivers Onboard</p>
                    </div>
                    <div>
                        <p class="text-2xl font-extrabold text-slate-900"><asp:Label ID="lblTrips" runat="server" Text="0" /></p>
                        <p class="text-xs text-slate-400 mt-0.5">Trips Completed</p>
                    </div>
                    <div>
                        <p class="text-2xl font-extrabold text-slate-900"><asp:Label ID="lblPassengers" runat="server" Text="0" /></p>
                        <p class="text-xs text-slate-400 mt-0.5">Happy Passengers</p>
                    </div>
                    <div>
                        <p class="text-2xl font-extrabold text-slate-900">0%</p>
                        <p class="text-xs text-slate-400 mt-0.5">Driver Commission</p>
                    </div>
                </div>
            </div>

            <!-- Hero visual: featured package cards -->
            <div class="grid grid-cols-2 gap-4">
                <asp:Repeater ID="rptHeroPackages" runat="server" OnItemDataBound="rptHeroPackages_ItemDataBound">
                    <ItemTemplate>
                        <a runat="server" id="lnkHeroPackage" href='<%= ResolveUrl("~/Login.aspx") %>' class="rounded-xl overflow-hidden border border-slate-100 bg-white shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1 group">
                            <div class="p-4">
                                <div class="flex items-center justify-between gap-2">
                                    <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-[10px] font-bold bg-[#eff6ff] text-[#007AFF]">Day Tour</span>
                                    <span class="text-[10px] text-slate-400"><%# Container.DataItem is System.Data.DataRowView dv && dv.Row["PlaceCount"] != DBNull.Value ? dv.Row["PlaceCount"].ToString() + " places" : "" %></span>
                                </div>
                                <h3 class="mt-3 text-sm font-bold text-slate-900 leading-snug group-hover:text-[#007AFF] transition-colors"><%# Eval("PackageName") %></h3>
                                <p class="mt-1.5 text-xs text-slate-500 leading-relaxed line-clamp-2"><%# Eval("Description") %></p>
                                <p class="mt-3 text-sm font-extrabold text-[#007AFF]">MMK <%# string.Format("{0:N0}", Eval("BaseFare")) %></p>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlHeroEmpty" runat="server" Visible="false" CssClass="col-span-2 grid grid-cols-2 gap-4">
                    <a href='<%= ResolveUrl("~/Register.aspx") %>' class="rounded-xl overflow-hidden border border-slate-100 bg-white shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
                        <div class="p-4 flex flex-col items-center justify-center text-center min-h-36">
                            <span class="size-12 rounded-xl bg-[#dbeafe] text-[#007AFF] flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg></span>
                            <p class="mt-3 font-bold text-sm text-slate-900">Your ride here</p>
                            <p class="text-xs text-slate-500 mt-1">Book your first trip</p>
                        </div>
                    </a>
                    <a href='<%= ResolveUrl("~/Register.aspx") %>' class="rounded-xl overflow-hidden border border-slate-100 bg-white shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-1">
                        <div class="p-4 flex flex-col items-center justify-center text-center min-h-36">
                            <span class="size-12 rounded-xl bg-[#eff6ff] text-[#007AFF] flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/></svg></span>
                            <p class="mt-3 font-bold text-sm text-slate-900">Become a driver</p>
                            <p class="text-xs text-slate-500 mt-1">Earn 100% of every fare</p>
                        </div>
                    </a>
                </asp:Panel>
            </div>
        </div>
    </section>

    <!-- ======= Vehicle classes ======= -->
    <section class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
            <div class="text-center max-w-2xl mx-auto">
                <span class="inline-flex items-center gap-1.5 rounded-full bg-[#dbeafe] text-[#1d4ed8] px-3 py-1 text-xs font-semibold">Choose Your Ride</span>
                <h2 class="mt-4 text-3xl sm:text-4xl font-extrabold text-slate-900">A vehicle for every journey</h2>
                <p class="mt-3 text-slate-500 text-lg">Fixed fare meters on every class — no surge games.</p>
            </div>
            <div class="mt-14 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#e0f2fe] text-[#0284c7] flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6 inline-block align-middle"><circle cx="18.5" cy="17.5" r="3.5"/><circle cx="5.5" cy="17.5" r="3.5"/><circle cx="15" cy="5" r="1"/><path stroke-linecap="round" stroke-linejoin="round" d="M12 17.5V14l-3-3 4-3 2 3h2"/></svg>
                    </div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">Motorbike</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">1 rider. Fastest way through Hpa-An traffic. ~100–300 MMK/km.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#fef3c7] text-[#d97706] flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6 inline-block align-middle"><circle cx="7" cy="16.5" r="2.75"/><circle cx="17" cy="16.5" r="2.75"/><path stroke-linecap="round" stroke-linejoin="round" d="M4.25 16.5h5.5M14.5 16.5h4M6 13.5 8 8.25h5L15.5 13.5M15.5 13.5h3L19 11.5M8 8.25l3.25-2.25h2.5L15.5 8.25"/></svg>
                    </div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">Tuk-Tuk</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Up to 3 passengers. Comfortable short-town rides.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#dbeafe] text-[#007AFF] flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path stroke-linecap="round" stroke-linejoin="round" d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg>
                    </div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">Saloon</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Up to 4 passengers. Clean, metered sedan rides.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#d1fae5] text-[#059669] flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-6 inline-block align-middle"><circle cx="6" cy="17" r="2.5"/><circle cx="17.5" cy="17" r="2.5"/><path stroke-linecap="round" stroke-linejoin="round" d="M3.5 17H6M15 17h5M5.5 14.5 7 8h9l2.5 6.5M16.25 8 19 12.5H21M4.75 11H15M7 8l-.75 3.5H3.5"/></svg>
                    </div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">VIP Van</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Up to 10 passengers. Airport &amp; group trips with luggage.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ======= Services / What We Do ======= -->
    <section class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
            <div class="text-center max-w-2xl mx-auto">
                <span class="inline-flex items-center gap-1.5 rounded-full bg-[#dbeafe] text-[#1d4ed8] px-3 py-1 text-xs font-semibold">What We Do</span>
                <h2 class="mt-4 text-3xl sm:text-4xl font-extrabold text-slate-900">Three flexible ways to travel</h2>
                <p class="mt-3 text-slate-500 text-lg">Point-to-point, hourly or a full day out — choose what fits your day.</p>
            </div>
            <div class="mt-14 grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#dbeafe] text-[#007AFF] flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg></div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">A to B rides</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Pickup to drop-off anywhere in Hpa-An. Pay by distance meter with an up-front quote before you confirm.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#dcfce7] text-[#16a34a] flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg></div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">Hourly hire</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Book a driver by the hour for errands, meetings or sightseeing. Same driver, clean per-hour meter the whole time.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-7 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="size-12 rounded-xl bg-[#ede9fe] text-[#6d28d9] flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5"/></svg></div>
                    <h3 class="mt-5 font-bold text-slate-900 text-lg">Day tours</h3>
                    <p class="mt-2 text-sm text-slate-500 leading-relaxed">Curated multi-stop tours of Zwabin, Kyauk Ka Lat, Kyee Kan &amp; more — one price includes the driver waiting.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ======= How It Works ======= -->
    <section class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
            <div class="text-center max-w-2xl mx-auto">
                <span class="inline-flex items-center gap-1.5 rounded-full bg-[#dbeafe] text-[#1d4ed8] px-3 py-1 text-xs font-semibold">How It Works</span>
                <h2 class="mt-4 text-3xl sm:text-4xl font-extrabold text-slate-900">From booking to arrival in 4 steps</h2>
            </div>
            <div class="mt-14 grid grid-cols-1 md:grid-cols-4 gap-6 text-center">
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-6 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="mx-auto size-12 rounded-xl bg-[#dbeafe] text-[#1d4ed8] flex items-center justify-center font-black text-lg">1</div>
                    <h4 class="mt-4 font-bold text-slate-900">Register</h4>
                    <p class="mt-1 text-sm text-slate-500">Create your account as a passenger or driver.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-6 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="mx-auto size-12 rounded-xl bg-[#d1fae5] text-[#047857] flex items-center justify-center font-black text-lg">2</div>
                    <h4 class="mt-4 font-bold text-slate-900">Book a ride</h4>
                    <p class="mt-1 text-sm text-slate-500">Pick a service, set pickup &amp; destination, get your fare.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-6 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="mx-auto size-12 rounded-xl bg-[#fef3c7] text-[#b45309] flex items-center justify-center font-black text-lg">3</div>
                    <h4 class="mt-4 font-bold text-slate-900">Get matched</h4>
                    <p class="mt-1 text-sm text-slate-500">The nearest online driver accepts and drives to you.</p>
                </div>
                <div class="bg-white border border-slate-100 rounded-2xl shadow-sm p-6 hover:shadow-lg hover:-translate-y-1 transition-all duration-200">
                    <div class="mx-auto size-12 rounded-xl bg-[#ede9fe] text-[#6d28d9] flex items-center justify-center font-black text-lg">4</div>
                    <h4 class="mt-4 font-bold text-slate-900">Ride &amp; pay</h4>
                    <p class="mt-1 text-sm text-slate-500">Track live, pay your way and rate the ride.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ======= Popular Packages ======= -->
    <section class="py-20 bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6">
            <div class="flex items-center justify-between gap-3 flex-wrap">
                <div>
                    <span class="inline-flex items-center gap-1.5 rounded-full bg-[#dbeafe] text-[#1d4ed8] px-3 py-1 text-xs font-semibold">Featured</span>
                    <h2 class="mt-3 text-3xl sm:text-4xl font-extrabold text-slate-900">Popular Packages</h2>
                    <p class="mt-2 text-slate-500">One price includes driver, fuel and waiting while you explore.</p>
                </div>
                <a href='<%= ResolveUrl("~/Services.aspx") %>' class="text-sm font-semibold text-[#007AFF] inline-flex items-center gap-1 hover:gap-2 transition-all">See all packages <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg></a>
            </div>

            <div class="mt-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <asp:Repeater ID="rptPackages" runat="server" OnItemDataBound="rptPackages_ItemDataBound">
                    <ItemTemplate>
                        <div class="bg-white border border-slate-100 rounded-2xl shadow-sm overflow-hidden flex flex-col group hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
                            <div class="p-5 flex-1 flex flex-col">
                                <div class="flex items-center justify-between mb-3">
                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-[#eff6ff] text-[#007AFF]">Day Tour</span>
                                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-[#f1f5f9] text-slate-500"><%# Container.DataItem is System.Data.DataRowView dv && dv.Row["PlaceCount"] != DBNull.Value ? dv.Row["PlaceCount"].ToString() + " places" : "" %></span>
                                </div>
                                <h3 class="font-bold text-slate-900 text-lg group-hover:text-[#007AFF] transition-colors"><%# Eval("PackageName") %></h3>
                                <p class="mt-2 text-sm text-slate-500 leading-relaxed flex-1 line-clamp-3"><%# Eval("Description") %></p>
                                <div class="mt-4 flex items-center justify-between pt-3 border-t border-[#e2e8f0]">
                                    <span class="text-base font-extrabold text-[#007AFF]">MMK <%# string.Format("{0:N0}", Eval("BaseFare")) %></span>
                                    <a runat="server" id="lnkPackageBook" href='<%= ResolveUrl("~/Login.aspx") %>' class="inline-flex items-center gap-1.5 text-xs font-bold text-[#007AFF]">
                                        Book <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-2.5 shrink-0"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3"/></svg>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoPackages" runat="server" Visible="false">
                    <div class="col-span-1 sm:col-span-2 lg:col-span-3 rounded-2xl border border-slate-100 bg-white shadow-sm px-6 py-12 text-center">
                        <p class="text-sm text-gray-400"><asp:Literal ID="litEmpty" runat="server" /></p>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </section>

    <!-- ======= CTA ======= -->
    <section class="bg-white">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 py-20">
            <div class="tw-cta-banner rounded-2xl p-8 md:p-14 text-center text-white">
                <h2 class="text-3xl sm:text-4xl font-extrabold">Ready to move around Hpa-An?</h2>
                <p class="mt-3 text-white/85 max-w-xl mx-auto text-lg">Join thousands of passengers and drivers already riding on TripWay.</p>
                <asp:Panel ID="pnlCtaGuest" runat="server" CssClass="mt-8 flex justify-center gap-3 flex-wrap">
                    <a href='<%= ResolveUrl("~/Login.aspx") %>' class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-white text-[#007AFF] hover:bg-gray-100 transition-all duration-200 text-sm font-semibold hover:-translate-y-0.5">Login</a>
                    <a href='<%= ResolveUrl("~/Register.aspx") %>' class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-blue-950/40 border border-white/40 text-white hover:bg-blue-950/60 transition-all duration-200 text-sm font-semibold hover:-translate-y-0.5">Get Started</a>
                </asp:Panel>
                <asp:Panel ID="pnlCtaUser" runat="server" Visible="false" CssClass="mt-8 flex justify-center gap-3 flex-wrap">
                    <asp:HyperLink ID="lnkCtaDashboard" runat="server"
                        CssClass="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-white text-[#007AFF] hover:bg-gray-100 transition-all duration-200 text-sm font-semibold hover:-translate-y-0.5">
                        Go to My Dashboard
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4"><path stroke-linecap="round" stroke-linejoin="round" d="M13.5 4.5L21 12m0 0l-7.5 7.5M21 12H3" /></svg>
                    </asp:HyperLink>
                </asp:Panel>
            </div>
        </div>
    </section>

</asp:Content>