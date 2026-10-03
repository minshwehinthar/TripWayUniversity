<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerDetail.aspx.cs" Inherits="TripWay.Admin.CustomerDetailPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Customer Profile</h2>
            <p class="text-sm text-gray-500">Account details and trip history for this customer.</p>
        </div>

        <asp:Panel ID="pnlMissing" runat="server" Visible="false"
            CssClass="p-5 rounded-lg bg-amber-50 border border-amber-200 text-amber-800 text-sm">
            This customer no longer exists.
        </asp:Panel>

        <asp:Panel ID="pnlCustomer" runat="server" Visible="false" CssClass="space-y-6">

            <%-- Identity card --%>
            <div class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
                <div class="relative shrink-0">
                    <span id="imgDefaultPhoto" runat="server" class="size-20 rounded-2xl bg-emerald-600/10 text-emerald-600 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.5 20.25a7.5 7.5 0 0 1 15 0 1.5 1.5 0 0 1-1.5 1.5H6a1.5 1.5 0 0 1-1.5-1.5Z" />
                        </svg>
                    </span>
                    <asp:Image ID="imgProfilePhoto" runat="server" Visible="false" CssClass="size-20 rounded-2xl object-cover" />
                </div>

                <div class="min-w-0 flex-1">
                    <h1 class="text-lg font-bold text-gray-900 truncate"><asp:Label ID="lblName" runat="server" /></h1>
                    <p class="text-sm text-gray-500 truncate"><asp:Label ID="lblEmail" runat="server" /></p>
                    <div class="flex flex-wrap items-center gap-2 mt-1.5">
                        <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Customer</span>
                        <asp:Label ID="lblStatus" runat="server" CssClass="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold" />
                        <span class="text-xs text-gray-400"><asp:Label ID="lblJoined" runat="server" /></span>
                    </div>
                </div>
            </div>

            <%-- Personal information (read-only) --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
                <p class="text-sm text-gray-500 mb-6">Read-only view of this customer's account details.</p>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Email</div>
                        <div class="tw-readonly"><asp:Label ID="lblEmailField" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</div>
                        <div class="tw-readonly"><asp:Label ID="lblNameField" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Phone</div>
                        <div class="tw-readonly"><asp:Label ID="lblPhone" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Gender</div>
                        <div class="tw-readonly"><asp:Label ID="lblGender" runat="server" /></div>
                    </div>

                    <div class="sm:col-span-2">
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Default Pickup Address</div>
                        <div class="tw-readonly"><asp:Label ID="lblAddress" runat="server" /></div>
                    </div>
                </div>
            </div>

            <%-- Account activity --%>
            <div class="bg-white rounded-lg shadow-sm p-6">
                <h2 class="text-base font-semibold text-gray-900 mb-1">Account Activity</h2>
                <p class="text-sm text-gray-500 mb-6">Trip totals and spend recorded for this account.</p>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Trips</div>
                        <div class="tw-readonly"><asp:Label ID="lblTrips" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Completed</div>
                        <div class="tw-readonly"><asp:Label ID="lblCompleted" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Cancelled</div>
                        <div class="tw-readonly"><asp:Label ID="lblCancelled" runat="server" /></div>
                    </div>
                    <div>
                        <div class="block text-sm font-bold text-gray-900 mb-1.5">Total Spent</div>
                        <div class="tw-readonly font-semibold"><asp:Label ID="lblSpent" runat="server" /></div>
                    </div>
                </div>

                <div class="pt-4">
                    <div class="block text-sm font-bold text-gray-900 mb-1.5">Last Trip</div>
                    <div class="tw-readonly"><asp:Label ID="lblLastTrip" runat="server" /></div>
                </div>
            </div>
        </asp:Panel>
    </div>
</asp:Content>
