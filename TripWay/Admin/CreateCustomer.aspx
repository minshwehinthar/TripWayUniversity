<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateCustomer.aspx.cs" Inherits="TripWay.Admin.CreateCustomerPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Create Customer Account</h2>
            <p class="text-sm text-gray-500">Manually create a customer on the platform.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Identity card. The account does not exist yet, so there is no stored photo and
             no separate Save Photo button -- the single Create Customer button covers it. --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Default placeholder, hidden by the shared script once a photo is previewed --%>
                    <span class="absolute inset-0 size-20 rounded-2xl bg-emerald-600/10 text-emerald-600 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.5 20.25a7.5 7.5 0 0 1 15 0 1.5 1.5 0 0 1-1.5 1.5H6a1.5 1.5 0 0 1-1.5-1.5Z" />
                        </svg>
                    </span>
                    <%-- Live preview of the picked photo, drawn over the placeholder --%>
                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                </span>

                <%-- Pencil button in the bottom-right corner, same as the customer profile --%>
                <button type="button" data-tw-pick
                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-emerald-600 hover:border-emerald-200"
                    title="Choose profile photo" aria-label="Choose profile photo">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                    </svg>
                </button>

                <%-- Hidden picker; the button above opens it and the shared script previews the result --%>
                <asp:FileUpload ID="fuProfilePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
            </div>

            <div class="min-w-0 flex-1">
                <h1 class="text-lg font-bold text-gray-900 truncate">Profile Photo</h1>
                <p class="text-sm text-gray-500 truncate">Optional. The customer can replace it later from their own profile page.</p>
                <div class="flex items-center gap-2 mt-1.5">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Customer</span>
                    <span class="truncate text-xs text-gray-400" data-tw-name data-tw-hint="JPG or PNG">JPG or PNG</span>
                </div>
            </div>
        </div>

        <%-- Personal information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
            <p class="text-sm text-gray-500 mb-6">Everything here is saved together with the Create Customer button.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Email --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="tw-input w-full" placeholder="Enter their email" autocomplete="email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="CreateCustomer"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="CreateCustomer"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Full name --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter their full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="CreateCustomer"
                        ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Phone --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" placeholder="e.g. 09 123 456 789" autocomplete="tel" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ValidationGroup="CreateCustomer"
                        ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Gender --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Gender <span class="text-gray-400 font-normal">(optional)</span></label>
                    <asp:DropDownList ID="ddlGender" runat="server" CssClass="tw-input w-full">
                        <asp:ListItem Value="" Text="-- Select --" />
                        <asp:ListItem Value="Male" Text="Male" />
                        <asp:ListItem Value="Female" Text="Female" />
                        <asp:ListItem Value="Other" Text="Other" />
                    </asp:DropDownList>
                </div>

                <%-- Default pickup address (full width) --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Default Pickup Address <span class="text-gray-400 font-normal">(optional)</span></label>
                    <asp:TextBox ID="txtDefaultAddress" runat="server" TextMode="MultiLine" Rows="2"
                        CssClass="tw-input tw-textarea w-full" placeholder="Speeds up future bookings" />
                </div>
            </div>
        </div>

        <%-- Password. There is no password on the edit form, because it is hashed at
             creation and never stored in the clear. --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Password</h2>
            <p class="text-sm text-gray-500 mb-6">The customer signs in with this password.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="tw-input w-full"
                        placeholder="At least 8 characters and a number" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ValidationGroup="CreateCustomer"
                        ErrorMessage="Password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword" ValidationGroup="CreateCustomer"
                        ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Min 8 characters and include a number"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input w-full"
                        placeholder="Re-enter the password" autocomplete="new-password" />
                    <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword"
                        ValidationGroup="CreateCustomer" ErrorMessage="Passwords do not match"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
            </div>
        </div>

        <div class="flex flex-wrap items-center gap-3">
            <asp:Button ID="btnCreate" runat="server" Text="Create Customer" OnClick="btnCreate_Click"
                CssClass="tw-btn-primary" ValidationGroup="CreateCustomer" />
            <a href="CustomerManagement.aspx" class="tw-btn-outline">Cancel</a>
        </div>
    </div>
</asp:Content>
