<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="TripWay.Driver.ProfilePage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Driver Profile</h2>
            <p class="text-sm text-gray-500">Your details, vehicle, KYC documents and password.</p>
        </div>

        <asp:Panel ID="pnlProfileMsg" runat="server" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
            <asp:Label ID="lblProfileMsg" runat="server" />
        </asp:Panel>

        <%-- Identity card --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Default photo placeholder (initials) --%>
                    <span id="imgDefaultPhoto" runat="server" class="absolute inset-0 size-20 rounded-2xl bg-amber-500/10 text-amber-600 flex items-center justify-center">
                        <span class="text-2xl font-bold"><asp:Label ID="lblAvatar" runat="server" /></span>
                    </span>
                    <asp:Image ID="imgProfilePhoto" runat="server" Visible="false" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
                    <%-- Live preview of the selected photo, drawn over the stored one --%>
                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                </span>

                <%-- Edit photo button (bottom-right corner) --%>
                <button type="button" data-tw-pick
                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-amber-600 hover:border-amber-200"
                    title="Change profile photo" aria-label="Change profile photo">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                    </svg>
                </button>

                <%-- Hidden picker; the button above opens it and the shared script previews the result --%>
                <asp:FileUpload ID="fuProfilePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
            </div>

            <div class="min-w-0 flex-1">
                <h1 class="text-lg font-bold text-gray-900 truncate" id="lblName" runat="server"></h1>
                <p class="text-sm text-gray-500 truncate" id="lblEmail" runat="server"></p>
                <div class="flex flex-wrap items-center gap-2 mt-1.5">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Driver</span>
                    <span class="inline-flex px-2.5 py-0.5 rounded-full text-[11px] font-bold" id="lblKycPill" runat="server"></span>
                    <span class="text-xs text-gray-400" id="lblJoined" runat="server"></span>
                </div>
                <%-- Saving the photo on its own, so the driver does not have to resubmit the whole form --%>
                <asp:Button ID="btnSavePhoto" runat="server" Text="Save Photo" OnClick="btnSavePhoto_Click"
                    CausesValidation="false" CssClass="tw-btn-outline inline-flex items-center justify-center !h-9 !px-3 !text-xs mt-3" />
            </div>

            <asp:LinkButton ID="lnkToggleOnline" runat="server" OnClick="lnkToggleOnline_Click" CausesValidation="false" Style="display:none" />
            <label class="inline-flex items-center gap-2.5 cursor-pointer select-none">
                <input type="checkbox" class="sr-only peer" <%= IsOnlineNow ? "checked='checked'" : "" %>
                    onchange='__doPostBack("<%= lnkToggleOnline.UniqueID %>","")' />
                <span class="relative w-9 h-5 rounded-full bg-gray-300 transition-colors duration-150 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-blue-200 peer-checked:bg-emerald-500 after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:size-4 after:rounded-full after:bg-white after:shadow-sm after:transition-transform after:duration-150 peer-checked:after:translate-x-4"></span>
                <asp:Label ID="lblOnlineText" runat="server" CssClass="text-sm font-medium text-gray-900" />
            </label>
        </div>

        <%-- Personal information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
            <p class="text-sm text-gray-500 mb-6">Your changes are saved together with the Save Changes button.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Full name --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter your full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName" ValidationGroup="Profile"
                        ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Phone --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" placeholder="Enter your phone number" />
                </div>

                <%-- Payment account (full width) --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Payment Account <span class="text-gray-400 font-normal">(KPay / WavePay / bank)</span></label>
                    <asp:TextBox ID="txtPaymentAccount" runat="server" CssClass="tw-input w-full" placeholder="Enter your payment account" />
                </div>
            </div>

            <div class="pt-4">
                <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click" CssClass="tw-btn-primary" ValidationGroup="Profile" />
            </div>
        </div>

        <%-- Vehicle & licensing --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Vehicle &amp; Licensing</h2>
            <p class="text-sm text-gray-500 mb-6">Keep your vehicle reference and registered documents up to date.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Type</label>
                    <asp:TextBox ID="txtVehicleType" runat="server" CssClass="tw-input w-full" ReadOnly="true" />
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Seat Capacity</label>
                    <asp:TextBox ID="txtSeatCapacity" runat="server" TextMode="Number" CssClass="tw-input w-full" />
                </div>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Plate Number</label>
                    <asp:TextBox ID="txtPlate" runat="server" CssClass="tw-input w-full" />
                </div>
            </div>

            <div class="border-t border-gray-100 pt-5 mt-5">
                <h3 class="text-sm font-bold text-gray-900 mb-1">Registered KYC Documents</h3>
                <p class="text-xs text-gray-400 mb-3">Click any document to view it full size.</p>
                <div class="grid grid-cols-2 gap-3 md:grid-cols-4">
                    <asp:Repeater ID="rptDocs" runat="server">
                        <ItemTemplate>
                            <button type="button" class="group block w-full cursor-pointer text-left"
                                <%# DocAttrs(Eval("Src"), Eval("Label"), Eval("FileName"), Eval("IsPdf")) %>>
                                <span class="relative block h-24 overflow-hidden rounded-xl border border-gray-200 bg-gray-50 transition-all group-hover:border-blue-400 group-hover:shadow-md">
                                    <asp:Image runat="server" ImageUrl='<%# Eval("Src") %>'
                                        Visible='<%# Convert.ToBoolean(Eval("IsImage")) %>'
                                        CssClass="size-full object-cover transition-transform group-hover:scale-105"
                                        onerror="this.style.display='none';var f=this.parentNode.querySelector('[data-fb]');if(f)f.style.display='flex';" />
                                    <span data-fb="1" class="absolute inset-0 items-center justify-center text-gray-300 transition-colors group-hover:text-blue-500"
                                        style='<%# Convert.ToBoolean(Eval("IsImage")) ? "display:none" : "display:flex" %>'>
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                        </svg>
                                    </span>
                                </span>
                                <span class="mt-1.5 block truncate px-1 text-center text-xs font-semibold text-gray-700"><%# Server.HtmlEncode(Convert.ToString(Eval("Label"))) %></span>
                            </button>
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Panel ID="pnlNoDocs" runat="server" Visible="false" CssClass="col-span-2 md:col-span-4">
                        <p class="text-sm text-gray-400 text-center py-6"><asp:Literal ID="litEmpty" runat="server" /></p>
                    </asp:Panel>

                    <%-- Live preview of a newly picked document. Every picker below points at
                         this tile with data-tw-share-preview, so one tile previews all four.
                         It carries no data-tw-input: it only receives the picked file. --%>
                    <div id="kycPreviewTile" data-tw-upload data-tw-preview-tile class="hidden">
                        <span data-tw-cover class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                            <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                </svg>
                            </span>
                            <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                        </span>
                        <span class="mt-1.5 block text-center">
                            <span class="block text-[11px] font-bold uppercase tracking-wide text-blue-500">New, not saved</span>
                            <span class="block truncate px-1 text-xs font-semibold text-gray-700" data-tw-name data-tw-hint="New upload">New upload</span>
                        </span>
                    </div>
                </div>
                <p class="text-xs text-gray-400 mt-3">Need to update a document? Pick the new file below and save &mdash; your KYC returns to Pending for a re-check.</p>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 border-t border-gray-100 pt-5 mt-5">
                <%-- NRC photo --%>
                <div data-tw-upload data-tw-share-preview="kycPreviewTile">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Photo</label>
                    <asp:FileUpload ID="fuNrcPhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                    <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                                class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                </div>

                <%-- License photo --%>
                <div data-tw-upload data-tw-share-preview="kycPreviewTile">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">License Photo</label>
                    <asp:FileUpload ID="fuLicensePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                    <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                                class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                </div>

                <%-- Vehicle photo --%>
                <div data-tw-upload data-tw-share-preview="kycPreviewTile">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Photo</label>
                    <asp:FileUpload ID="fuVehiclePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                    <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                                class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                </div>

                <%-- Registration document (accepts PDF too) --%>
                <div data-tw-upload data-tw-share-preview="kycPreviewTile">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Reg. Document</label>
                    <asp:FileUpload ID="fuRegDoc" runat="server" data-tw-input accept=".jpg,.jpeg,.png,.pdf" CssClass="hidden" />
                    <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                                class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                </div>
            </div>
        </div>

        <%-- Change password --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Change Password</h2>
            <p class="text-sm text-gray-500 mb-6">Uses its own button only.</p>

            <asp:Panel ID="pnlPwdMsg" runat="server" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm">
                <asp:Label ID="lblPwdMsg" runat="server" />
            </asp:Panel>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" CssClass="tw-input w-full" placeholder="Enter your current password" AutoCompleteType="None" />
                    <asp:RequiredFieldValidator ID="rfvCurrentPassword" runat="server" ControlToValidate="txtCurrentPassword" ValidationGroup="ChangePassword"
                        ErrorMessage="Current password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" CssClass="tw-input w-full" placeholder="At least 8 characters and a number" AutoCompleteType="None" />
                    <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationGroup="ChangePassword"
                        ErrorMessage="New password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revNewPassword" runat="server" ControlToValidate="txtNewPassword" ValidationGroup="ChangePassword"
                        ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Min 8 characters and include a number"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input w-full" placeholder="Re-enter your new password" AutoCompleteType="None" />
                    <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" ValidationGroup="ChangePassword"
                        ErrorMessage="Please confirm your new password" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:CompareValidator ID="cmpConfirmPassword" runat="server" ControlToCompare="txtNewPassword" ControlToValidate="txtConfirmPassword" ValidationGroup="ChangePassword"
                        ErrorMessage="Passwords do not match" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div class="flex items-end sm:col-span-2">
                    <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" OnClick="btnChangePassword_Click" CssClass="tw-btn-outline" ValidationGroup="ChangePassword" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>