<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CreateDriver.aspx.cs" Inherits="TripWay.Admin.CreateDriverPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Create Driver Account</h2>
            <p class="text-sm text-gray-500">Manually create a driver with KYC documents.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Identity card: the same avatar + pencil layout as Driver/Profile.aspx, with no
             Save Photo button because the account does not exist yet --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Default placeholder, hidden by the shared script once a photo is previewed --%>
                    <span class="absolute inset-0 size-20 rounded-2xl bg-amber-500/10 text-amber-600 flex items-center justify-center">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-9">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z" />
                        </svg>
                    </span>
                    <%-- Non-image picks cannot be drawn, so they fall back to a document chip --%>
                    <span data-tw-fallback class="absolute inset-0 size-20 rounded-2xl bg-gray-100 text-gray-400 flex items-center justify-center" style="display:none">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-9">
                            <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                        </svg>
                    </span>
                    <%-- Live preview of the picked photo, drawn over the placeholder --%>
                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                </span>

                <%-- Pencil button in the bottom-right corner, same as the driver profile --%>
                <button type="button" data-tw-pick
                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-amber-600 hover:border-amber-200"
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
                <p class="text-sm text-gray-500 truncate">Optional. The driver can replace it later from their own profile page.</p>
                <span class="block truncate mt-1.5 text-xs font-semibold text-gray-400" data-tw-name data-tw-hint="No photo chosen yet">No photo chosen yet</span>
            </div>
        </div>

        <%-- Personal information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Personal Information</h2>
            <p class="text-sm text-gray-500 mb-6">Leave the status on Pending to review the KYC documents before the driver can go online.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter your full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                        ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="tw-input w-full" placeholder="Enter your email" autocomplete="email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" placeholder="e.g. 09 123 456 789" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                        ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Payment Account <span class="text-gray-400 font-normal">(optional)</span></label>
                    <asp:TextBox ID="txtPaymentAccount" runat="server" CssClass="tw-input w-full" placeholder="e.g. KBZ 09 123 456 789" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="tw-input w-full"
                        placeholder="Min 8 characters with a number" autocomplete="new-password" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                        ErrorMessage="Password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                        ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Password must be at least 8 characters and include a number"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input w-full"
                        placeholder="Confirm password" autocomplete="new-password" />
                    <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword"
                        ControlToCompare="txtPassword" ErrorMessage="Passwords do not match"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
            </div>
        </div>

        <%-- Vehicle &amp; licensing --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Vehicle &amp; Licensing</h2>
            <p class="text-sm text-gray-500 mb-6">Vehicle reference and the KYC documents required before the driver can go online.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Type</label>
                    <asp:DropDownList ID="ddlVehicleType" runat="server" CssClass="tw-input w-full"
                        data-tw-seats="txtSeatCapacity" />
                    <asp:RequiredFieldValidator ID="rfvVehicleType" runat="server" ControlToValidate="ddlVehicleType"
                        InitialValue="" ErrorMessage="Select a vehicle type" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Seat Capacity</label>
                    <asp:TextBox ID="txtSeatCapacity" runat="server" TextMode="Number" CssClass="tw-input w-full"
                        placeholder="Filled in from the vehicle type, editable" />
                </div>

                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Plate Number</label>
                    <asp:TextBox ID="txtPlateNumber" runat="server" CssClass="tw-input w-full" placeholder="e.g. 9K/1234" />
                    <asp:RequiredFieldValidator ID="rfvPlateNumber" runat="server" ControlToValidate="txtPlateNumber"
                        ErrorMessage="Plate number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
            </div>

            <div class="border-t border-gray-100 pt-5 mt-5">
                <h3 class="text-sm font-bold text-gray-900 mb-1">Registered KYC Documents</h3>
                <p class="text-xs text-gray-400 mb-3">These are never shown publicly. All four uploads are required.</p>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Number</label>
                        <asp:TextBox ID="txtNrc" runat="server" CssClass="tw-input w-full" placeholder="e.g. 12/KAPY(N)123456" />
                        <asp:RequiredFieldValidator ID="rfvNrc" runat="server" ControlToValidate="txtNrc"
                            ErrorMessage="NRC is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Driver License Number</label>
                        <asp:TextBox ID="txtLicenseNumber" runat="server" CssClass="tw-input w-full" placeholder="e.g. 12/KAPY(N)654321" />
                        <asp:RequiredFieldValidator ID="rfvLicenseNumber" runat="server" ControlToValidate="txtLicenseNumber"
                            ErrorMessage="License number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                </div>

                <%-- One slot per document. Each carries its own hidden input, button and preview
                     tile, so all four picks stay on screen instead of overwriting one preview. --%>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-5 border-t border-gray-100 pt-5 mt-5">
                    <%-- NRC photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Photo</label>

                        <%-- Live preview for this document only, hidden until a file is picked --%>
                        <div data-tw-preview-tile class="hidden mb-2">
                            <span data-tw-cover class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuNrcPhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                            <asp:RequiredFieldValidator ID="rfvNrcPhoto" runat="server" ControlToValidate="fuNrcPhoto"
                                ErrorMessage="NRC photo is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>

                    <%-- License photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">License Photo</label>

                        <%-- Live preview for this document only, hidden until a file is picked --%>
                        <div data-tw-preview-tile class="hidden mb-2">
                            <span data-tw-cover class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuLicensePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                            <asp:RequiredFieldValidator ID="rfvLicensePhoto" runat="server" ControlToValidate="fuLicensePhoto"
                                ErrorMessage="License photo is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>

                    <%-- Vehicle photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Photo</label>

                        <%-- Live preview for this document only, hidden until a file is picked --%>
                        <div data-tw-preview-tile class="hidden mb-2">
                            <span data-tw-cover class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                            <asp:RequiredFieldValidator ID="rfvVehiclePhoto" runat="server" ControlToValidate="fuVehiclePhoto"
                                ErrorMessage="Vehicle photo is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>

                    <%-- Registration document (accepts PDF too) --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Reg. Document</label>

                        <%-- Live preview for this document only, hidden until a file is picked --%>
                        <div data-tw-preview-tile class="hidden mb-2">
                            <span data-tw-cover class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuRegDoc" runat="server" data-tw-input accept=".jpg,.jpeg,.png,.pdf" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                        <asp:RequiredFieldValidator ID="rfvRegDoc" runat="server" ControlToValidate="fuRegDoc"
                            ErrorMessage="Registration document is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                </div>
            </div>
        </div>

        <div class="flex flex-wrap items-center gap-3">
            <asp:Button ID="btnCreate" runat="server" Text="Create Driver" OnClick="btnCreate_Click" CssClass="tw-btn-primary" />
            <a href="DriverManagement.aspx" class="tw-btn-outline">Cancel</a>
        </div>
    </div>

    <script type="text/javascript">
        // Seat capacity follows the chosen vehicle type, but it is filled in here instead of
        // by a postback: a refresh would throw away every file already picked on this form.
        (function () {
            var type = document.getElementById('<%= ddlVehicleType.ClientID %>');
            var seats = document.getElementById('<%= txtSeatCapacity.ClientID %>');
            if (!type || !seats) return;
            type.addEventListener('change', function () {
                var option = type.options[type.selectedIndex];
                if (option && option.getAttribute('data-max')) seats.value = option.getAttribute('data-max');
            });
        })();
    </script>
</asp:Content>
