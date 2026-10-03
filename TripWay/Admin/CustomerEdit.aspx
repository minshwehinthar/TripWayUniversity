<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomerEdit.aspx.cs" Inherits="TripWay.Admin.CustomerEditPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Edit Customer</h2>
            <p class="text-sm text-gray-500">Update this customer's photo, personal details and account status.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Identity card --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Default photo placeholder, hidden by the shared script while a preview is up --%>
                    <span id="imgDefaultPhoto" runat="server" class="absolute inset-0 size-20 rounded-2xl bg-emerald-600/10 text-emerald-600 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.5 20.25a7.5 7.5 0 0 1 15 0 1.5 1.5 0 0 1-1.5 1.5H6a1.5 1.5 0 0 1-1.5-1.5Z" />
                        </svg>
                    </span>
                    <asp:Image ID="imgProfilePhoto" runat="server" Visible="false" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
                    <%-- Live preview of the selected photo, drawn over the stored one --%>
                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                </span>

                <%-- Edit photo button (bottom-right corner) --%>
                <button type="button" data-tw-pick
                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-emerald-600 hover:border-emerald-200"
                    title="Change profile photo" aria-label="Change profile photo">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                    </svg>
                </button>

                <%-- Hidden picker; the button above opens it and the shared script previews the result --%>
                <asp:FileUpload ID="fuProfilePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
            </div>

            <div class="min-w-0 flex-1">
                <h1 class="text-lg font-bold text-gray-900 truncate"><asp:Label ID="lblHeadName" runat="server" /></h1>
                <p class="text-sm text-gray-500 truncate"><asp:Label ID="lblHeadEmail" runat="server" /></p>
                <div class="flex flex-wrap items-center gap-2 mt-1.5">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Customer</span>
                    <asp:Label ID="lblHeadStatus" runat="server" CssClass="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold" />
                    <span class="text-xs text-gray-400"><asp:Label ID="lblHeadJoined" runat="server" /></span>
                </div>
                <div class="flex items-center gap-2.5 mt-3">
                    <button type="button" data-tw-pick
                        class="tw-btn-outline inline-flex items-center justify-center gap-1.5 !h-9 !px-3 !text-xs">Change photo</button>
                    <span data-tw-name data-tw-hint="JPG or PNG" class="truncate text-xs text-gray-400">JPG or PNG</span>
                </div>
            </div>
        </div>

        <%-- Personal information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
            <p class="text-sm text-gray-500 mb-6">Your changes are saved together with the Save Changes button.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Email --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="tw-input w-full" placeholder="Enter your email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="EditCustomer"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="EditCustomer"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Full name --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter your full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="EditCustomer"
                        ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Phone --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" placeholder="Enter your phone number" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="EditCustomer"
                        ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Gender --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Gender</label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="tw-input w-full">
                        <asp:ListItem Value="" Text="-- Select --" />
                        <asp:ListItem Value="Male" Text="Male" />
                        <asp:ListItem Value="Female" Text="Female" />
                        <asp:ListItem Value="Other" Text="Other" />
                    </asp:DropDownList>
                </div>

                <%-- Account status (admin only) --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Account Status</label>
                    <asp:DropDownList ID="ddlStatus" runat="server" CssClass="tw-input w-full">
                        <asp:ListItem Value="Active" Text="Active" />
                        <asp:ListItem Value="Suspended" Text="Suspended" />
                    </asp:DropDownList>
                    <p class="text-xs text-gray-400 mt-1.5">A suspended customer cannot sign in, but their trips are kept.</p>
                </div>

                <%-- Default pickup address (full width) --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Default Pickup Address</label>
                    <asp:TextBox ID="txtDefaultAddress" runat="server" TextMode="MultiLine" Rows="2"
                        CssClass="tw-input tw-textarea w-full" placeholder="Enter your default pickup address" />
                </div>
            </div>

            <%-- Save all changes --%>
            <div class="pt-4 flex flex-wrap items-center gap-4">
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click"
                    CssClass="tw-btn-primary" ValidationGroup="EditCustomer" />
                <label class="flex items-center gap-2 text-sm text-gray-700">
                    <asp:CheckBox ID="chkRemovePhoto" runat="server" />
                    Remove current photo
                </label>
                <a href="CustomerDetail.aspx?id=<%= CustomerIdParam %>" class="tw-btn-outline">Cancel</a>
            </div>
        </div>
    </div>
</asp:Content>
