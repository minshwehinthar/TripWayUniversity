<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AboutUs.aspx.cs" Inherits="TripWay.AboutUsPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-5xl mx-auto space-y-10 py-8">

        <div class="text-center max-w-3xl mx-auto">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 text-xs font-semibold">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 19.128a9.38 9.38 0 0 0 2.625.372 9.337 9.337 0 0 0 4.121-.952 4.125 4.125 0 0 0-7.533-2.493M15 19.128v-.003c0-1.113-.285-2.16-.786-3.07M15 19.128v.106A12.318 12.318 0 0 1 8.624 21c-2.331 0-4.512-.645-6.374-1.766l-.001-.109a6.375 6.375 0 0 1 11.964-3.07M12 6.375a3.375 3.375 0 1 1-6.75 0 3.375 3.375 0 0 1 6.75 0Zm8.25 2.25a2.625 2.625 0 1 1-5.25 0 2.625 2.625 0 0 1 5.25 0Z"/></svg> About Us
            </span>
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mt-4">Hpa-An's own ride-hailing platform</h1>
            <p class="text-gray-500 mt-3 text-sm sm:text-base leading-relaxed">
                TripWay makes getting around Kayin State simple, fair and transparent. We connect verified drivers with
                passengers through fixed meters, official distances and zero hidden surge pricing.
            </p>
        </div>

        <%-- Stats --%>
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-5">
            <div class="bg-white p-5 rounded-lg shadow-sm text-center space-y-1">
                <p class="text-3xl font-extrabold text-[#007AFF]"><asp:Label ID="lblDrivers" runat="server" Text="0" /></p>
                <p class="text-xs font-medium text-gray-500">Verified Drivers</p>
            </div>
            <div class="bg-white p-5 rounded-lg shadow-sm text-center space-y-1">
                <p class="text-3xl font-extrabold text-green-600"><asp:Label ID="lblPassengers" runat="server" Text="0" /></p>
                <p class="text-xs font-medium text-gray-500">Passengers</p>
            </div>
            <div class="bg-white p-5 rounded-lg shadow-sm text-center space-y-1">
                <p class="text-3xl font-extrabold text-purple-600"><asp:Label ID="lblTrips" runat="server" Text="0" /></p>
                <p class="text-xs font-medium text-gray-500">Trips Completed</p>
            </div>
            <div class="bg-white p-5 rounded-lg shadow-sm text-center space-y-1">
                <p class="text-3xl font-extrabold text-yellow-600">0%</p>
                <p class="text-xs font-medium text-gray-500">Driver Commission</p>
            </div>
        </div>

        <%-- How we work --%>
        <div>
            <h2 class="text-lg font-bold text-gray-900 mb-4">Why TripWay</h2>
            <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-[#007AFF]/10 text-[#007AFF] items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/>
  <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">Verified Drivers</h3>
                    <p class="text-sm text-gray-500">Every driver is checked for NRC, licensed, and their vehicle inspected before going online — so you always ride with someone trusted.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-green-100 text-green-600 items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75m-3-7.036A11.959 11.959 0 0 1 3.598 6 11.99 11.99 0 0 0 3 9.749c0 5.592 3.824 10.29 9 11.623 5.176-1.332 9-6.03 9-11.622 0-1.31-.21-2.571-.598-3.751h-.152c-3.196 0-6.1-1.248-8.25-3.285Z"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">Fair, Fixed Meters</h3>
                    <p class="text-sm text-gray-500">Fares use official Hpa-An km distances with an up-front quote before you confirm — no surge pricing, ever.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-purple-100 text-purple-600 items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path d="M3.75 13.5L14.25 2.25L12 10.5H20.25L9.75 21.75L12 13.5H3.75Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">0% Commission</h3>
                    <p class="text-sm text-gray-500">Unlike big international apps, TripWay charges drivers no commission — every kyat of the fare belongs to the person behind the wheel.</p>
                </div>
            </div>
        </div>

        <%-- Values --%>
        <div>
            <h2 class="text-lg font-bold text-gray-900 mb-4">What we stand for</h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-5">
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-[#007AFF]/10 text-[#007AFF] items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">Our Mission</h3>
                    <p class="text-sm text-gray-500">Make safe, affordable, transparent transport available to every resident and visitor of Hpa-An — connected by the drivers who know these roads best.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-green-100 text-green-600 items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">Our Vision</h3>
                    <p class="text-sm text-gray-500">A modern local transport network across Kayin State where passengers and drivers both win, and riding on demand is the natural default.</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm space-y-3">
                    <span class="inline-flex size-11 rounded-lg bg-purple-100 text-purple-600 items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12c0 1.268-.63 2.39-1.593 3.068a3.745 3.745 0 0 1-1.043 3.296 3.745 3.745 0 0 1-3.296 1.043A3.745 3.745 0 0 1 12 21c-1.268 0-2.39-.63-3.068-1.593a3.746 3.746 0 0 1-3.296-1.043 3.745 3.745 0 0 1-1.043-3.296A3.745 3.745 0 0 1 3 12c0-1.268.63-2.39 1.593-3.068a3.745 3.745 0 0 1 1.043-3.296 3.746 3.746 0 0 1 3.296-1.043A3.746 3.746 0 0 1 12 3c1.268 0 2.39.63 3.068 1.593a3.746 3.746 0 0 1 3.296 1.043 3.746 3.746 0 0 1 1.043 3.296A3.745 3.745 0 0 1 21 12Z"/></svg>
                    </span>
                    <h3 class="font-semibold text-gray-900 text-sm">Our Promise</h3>
                    <p class="text-sm text-gray-500">Fixed meters shown before you ride, live GPS for every trip, money-back fair policies, and 24/7 support for passengers and drivers alike.</p>
                </div>
            </div>
        </div>

        <%-- Hotels --%>
        <div>
            <h2 class="text-lg font-bold text-gray-900 mb-4">Hotels we serve</h2>
            <p class="text-sm text-gray-500 mb-6">Drop-off points our drivers know well. Book any of them as your destination in one tap.</p>

            <asp:Panel ID="pnlAboutHotelsEmpty" runat="server" Visible="false" CssClass="bg-white rounded-lg shadow-sm p-6 text-center">
                <p class="text-sm text-gray-500">No partner hotels have been published yet.</p>
            </asp:Panel>

            <asp:Panel ID="pnlAboutHotels" runat="server" CssClass="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                <asp:Repeater ID="rptAboutHotels" runat="server">
                    <ItemTemplate>
                        <div class="bg-white p-5 rounded-lg shadow-sm h-full flex gap-4">
                            <%-- Initials are the base layer and the logo sits on top of them,
                                 rather than two panels taking turns being visible. Two mutually
                                 exclusive panels could both end up hidden and leave an empty gap;
                                 this cannot, because the initials are always rendered. --%>
                            <div class="relative size-16 shrink-0">
                                <span class="tw-skeleton absolute inset-0 size-16 rounded-lg"></span>
                                <asp:Image runat="server" Visible='<%# HasAboutPhoto(Container.DataItem, "LogoPhotoUrl") %>'
                                    ImageUrl='<%# AboutPhotoUrl(Container.DataItem, "LogoPhotoUrl") %>'
                                    CssClass="absolute inset-0 size-16 rounded-lg object-cover"
                                    onerror="this.style.visibility='hidden'" />
                            </div>
                            <div class="min-w-0">
                                <h3 class="font-semibold text-gray-900 text-sm truncate"><%# AboutText(Eval("Name")) %></h3>
                                <p class="text-xs text-gray-500 mt-1"><%# AboutText(Eval("Address")) %></p>
                                <p class="text-xs text-[#007AFF] font-semibold mt-1"><%# AboutPhone(Eval("Phone")) %></p>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
        </div>

        <%-- Drivers --%>
        <div>
            <h2 class="text-lg font-bold text-gray-900 mb-4">Meet our drivers</h2>
            <p class="text-sm text-gray-500 mb-6">Every TripWay driver is identity-checked and licence-verified before they take a single trip.</p>

            <asp:Panel ID="pnlAboutDriversEmpty" runat="server" Visible="false" CssClass="bg-white rounded-lg shadow-sm p-6 text-center">
                <p class="text-sm text-gray-500">No drivers have completed verification yet.</p>
            </asp:Panel>

            <asp:Panel ID="pnlAboutDrivers" runat="server" CssClass="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-5">
                <asp:Repeater ID="rptAboutDrivers" runat="server">
                    <ItemTemplate>
                        <div class="bg-white p-6 rounded-lg shadow-sm text-center space-y-3">
                            <%-- Same base-layer arrangement as the hotel card. --%>
                            <div class="relative size-20 mx-auto">
                                <span class="tw-skeleton tw-skeleton-avatar absolute inset-0 size-20 rounded-full"></span>
                                <asp:Image runat="server" Visible='<%# HasAboutPhoto(Container.DataItem, "ProfilePhotoUrl") %>'
                                    ImageUrl='<%# AboutPhotoUrl(Container.DataItem, "ProfilePhotoUrl") %>'
                                    CssClass="absolute inset-0 size-20 rounded-full object-cover"
                                    onerror="this.style.visibility='hidden'" />
                            </div>
                            <div>
                                <h3 class="font-semibold text-gray-900 text-sm truncate"><%# AboutText(Eval("FullName")) %></h3>
                                <p class="text-xs text-gray-500 mt-0.5"><%# AboutText(Eval("VehicleName")) %></p>
                            </div>
                            <p class="text-xs text-gray-500">
                                <span class="text-[#007AFF] font-bold"><%# AboutRating(Eval("AverageRating")) %></span>
                                <span class="mx-1 text-gray-300">|</span>
                                <%# AboutTrips(Eval("CompletedTrips")) %> completed
                            </p>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </asp:Panel>
        </div>

        <%-- Team --%>
        <div>
            <h2 class="text-lg font-bold text-gray-900 mb-4">Meet Our Development Team</h2>
            <p class="text-sm text-gray-500 mb-6">The four developers behind TripWay.</p>
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
                <div class="bg-white p-6 rounded-lg shadow-sm text-center space-y-3">
                    <asp:Image ID="imgTeamLeader" runat="server" ImageUrl="~/Images/minshwehinthar.png"
                        CssClass="size-20 rounded-full object-cover mx-auto" />
                    <div>
                        <h3 class="font-semibold text-gray-900 text-sm">Min Shwe Hin Thar</h3>
                        <p class="text-xs font-bold text-[#007AFF] mt-0.5">2223-3CS-51</p>
                    </div>
                    <p class="text-xs text-gray-500">Team Leader</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm text-center space-y-3">
                    <asp:Image ID="Image1" runat="server" ImageUrl="~/Images/minhonghtaw.jpeg"
                        CssClass="size-20 rounded-full object-cover mx-auto" />
                    <div>
                        <h3 class="font-semibold text-gray-900 text-sm">Min Hong Htaw</h3>
                        <p class="text-xs font-bold text-[#007AFF] mt-0.5">2223-3CS-102</p>
                    </div>
                    <p class="text-xs text-gray-500">Developer</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm text-center space-y-3">
                    <asp:Image ID="Image2" runat="server" ImageUrl="~/Images/nannweniwin.jpeg"
                        CssClass="size-20 rounded-full object-cover mx-auto" />
                    <div>
                        <h3 class="font-semibold text-gray-900 text-sm">Nan Nwe Ni Win</h3>
                        <p class="text-xs font-bold text-[#007AFF] mt-0.5">2324-3CT-35</p>
                    </div>
                    <p class="text-xs text-gray-500">Developer</p>
                </div>
                <div class="bg-white p-6 rounded-lg shadow-sm text-center space-y-3">
                    <asp:Image ID="Image3" runat="server" ImageUrl="~/Images/nawthaeeiphyu.jpeg"
                        CssClass="size-20 rounded-full object-cover mx-auto" />
                    <div>
                        <h3 class="font-semibold text-gray-900 text-sm">Naw Thae Ei Phyu</h3>
                        <p class="text-xs font-bold text-[#007AFF] mt-0.5">2324-3CS-45</p>
                    </div>
                    <p class="text-xs text-gray-500">Developer</p>
                </div>
            </div>
        </div>

        <%-- Mission --%>
        <div class="bg-blue-50 border border-blue-200 rounded-lg p-8">
            <div class="flex flex-col sm:flex-row items-start gap-4">
                <span class="inline-flex size-12 rounded-lg bg-[#007AFF] text-white items-center justify-center shrink-0">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 21a9.004 9.004 0 0 0 8.716-6.747M12 21a9.004 9.004 0 0 1-8.716-6.747M12 21c2.485 0 4.5-4.03 4.5-9S14.485 3 12 3m0 18c-2.485 0-4.5-4.03-4.5-9S9.515 3 12 3m0 0a8.997 8.997 0 0 1 7.843 4.582M12 3a8.997 8.997 0 0 0-7.843 4.582m15.686 0A11.953 11.953 0 0 1 12 10.5c-2.998 0-5.74-1.1-7.843-2.918m15.686 0A8.959 8.959 0 0 1 21 12c0 .778-.099 1.533-.284 2.253m0 0A17.919 17.919 0 0 1 12 16.5c-3.162 0-6.133-.815-8.716-2.247m0 0A9.015 9.015 0 0 1 3 12c0-1.605.42-3.113 1.157-4.418"/></svg>
                </span>
                <div>
                    <h3 class="font-bold text-gray-900">Our mission in action</h3>
                    <p class="text-sm text-gray-600 leading-relaxed mt-2">
                        To make safe, affordable transport a daily reality for Hpa-An — where passengers get fair fares and
                        drivers keep 100% of what they earn. We believe the people who know these roads best deserve to be
                        the ones who move the town.
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>