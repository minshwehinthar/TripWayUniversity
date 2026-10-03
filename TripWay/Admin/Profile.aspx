<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="TripWay.Admin.ProfilePage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Admin Profile</h2>
            <p class="text-sm text-gray-500">Update your photo, account details and password.</p>
        </div>

        <asp:Panel ID="pnlProfileMsg" runat="server" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
            <asp:Label ID="lblProfileMsg" runat="server" />
        </asp:Panel>

        <%-- Identity card. Same shape as Customer/Profile.aspx so the two profiles read as the
             same screen: the photo is picked here rather than in a form field below, and the
             stored picture is drawn over the placeholder when there is one. --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Shown when the admin has no photo, or has just removed one --%>
                    <span id="imgDefaultPhoto" runat="server" class="absolute inset-0 size-20 rounded-2xl bg-blue-600/10 text-blue-600 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.5 20.25a7.5 7.5 0 0 1 15 0 1.5 1.5 0 0 1-1.5 1.5H6a1.5 1.5 0 0 1-1.5-1.5Z" />
                        </svg>
                    </span>
                    <asp:Image ID="imgProfilePhoto" runat="server" Visible="false" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
                    <%-- Live preview of the picked photo, drawn over the stored one --%>
                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                </span>

                <%-- Edit photo button (bottom-right corner) --%>
                <button type="button" data-tw-pick
                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-blue-600 hover:border-blue-200"
                    title="Change profile photo" aria-label="Change profile photo">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                    </svg>
                </button>

                <%-- Hidden picker; the buttons above open it and the shared script previews the result --%>
                <asp:FileUpload ID="fuProfilePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
            </div>

            <div class="min-w-0 flex-1">
                <h1 class="text-lg font-bold text-gray-900 truncate" id="lblName" runat="server">Admin</h1>
                <p class="text-sm text-gray-500 truncate" id="lblEmail" runat="server"></p>
                <div class="flex items-center gap-2 mt-1.5">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-blue-100 text-blue-700">Admin</span>
                    <span class="text-xs text-gray-400" id="lblJoined" runat="server"></span>
                </div>
                <div class="flex items-center gap-2.5 mt-3">
                    <button type="button" data-tw-pick
                        class="tw-btn-outline inline-flex items-center justify-center gap-1.5 !h-9 !px-3 !text-xs">Change photo</button>
                    <span data-tw-name data-tw-hint="JPG or PNG" class="truncate text-xs text-gray-400">JPG or PNG</span>
                </div>
            </div>
        </div>

        <%-- Profile information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Profile Information</h2>
            <p class="text-sm text-gray-500 mb-6">Your changes, including the photo, are saved together with the Save Profile button.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Full name --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name *</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter your full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="SaveProfile"
                        ErrorMessage="Name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Email --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Email Address *</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="tw-input w-full" placeholder="admin@tripway.com" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="SaveProfile"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="SaveProfile"
                        ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                        ErrorMessage="Enter a valid email address" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Remove photo. Only offered once something is stored, and it deletes the file
                     rather than just forgetting it. --%>
                <div class="sm:col-span-2" id="pnlRemovePhoto" runat="server" Visible="false">
                    <label class="flex items-center gap-2 text-sm text-gray-600">
                        <asp:CheckBox ID="chkRemovePhoto" runat="server" />
                        Remove current photo
                    </label>
                </div>
            </div>

            <div class="pt-4">
                <asp:Button ID="btnSaveProfile" runat="server" Text="Save Profile" OnClick="btnSaveProfile_Click" ValidationGroup="SaveProfile" CssClass="tw-btn-primary" />
            </div>
        </div>

        <%-- Change password --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Change Password</h2>
            <p class="text-sm text-gray-500 mb-6">Keep your administrator account secure by updating your password regularly.</p>

            <asp:Panel ID="pnlPwdMsg" runat="server" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
                <asp:Label ID="lblPwdMsg" runat="server" />
            </asp:Panel>

            <div class="flex flex-col gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Current Password *</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" CssClass="tw-input" placeholder="Enter current password" AutoCompleteType="None" />
                    <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword" ValidationGroup="ChangePassword"
                        ErrorMessage="Current password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">New Password *</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="tw-input" placeholder="At least 8 characters and a number" AutoCompleteType="None" />
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationGroup="ChangePassword"
                            ErrorMessage="New password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationGroup="ChangePassword"
                            ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Min 8 characters and include a number"
                            CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Confirm New Password *</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input" placeholder="Re-enter new password" AutoCompleteType="None" />
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" ValidationGroup="ChangePassword"
                            ErrorMessage="Please confirm your new password" CssClass="text-xs text-red-500" Display="Dynamic" />
                        <asp:CompareValidator ID="cmpConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" ValidationGroup="ChangePassword"
                            ControlToCompare="txtNewPassword" ErrorMessage="Passwords do not match"
                            CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                </div>
                <div>
                    <asp:Button ID="btnChangePassword" runat="server" Text="Update Password" OnClick="btnChangePassword_Click" ValidationGroup="ChangePassword" CssClass="tw-btn-outline" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>