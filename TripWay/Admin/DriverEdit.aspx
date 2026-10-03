<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="DriverEdit.aspx.cs" Inherits="TripWay.Admin.DriverEditPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-2xl space-y-6">

        <div>
            <h2 class="text-lg font-semibold text-gray-900 mb-1">Edit Driver</h2>
            <p class="text-sm text-gray-500">Update the driver photo, personal details, vehicle and registered KYC documents.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Identity card --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6 flex flex-col sm:flex-row items-start sm:items-center gap-5">
            <div class="relative shrink-0">
                <span data-tw-cover class="relative block size-20">
                    <%-- Skeleton holds the avatar box until a photo is picked or stored --%>
                    <span id="imgDefaultPhoto" runat="server" class="tw-skeleton tw-skeleton-avatar absolute inset-0 size-20 rounded-2xl"></span>
                    <asp:Image ID="imgDriverPhoto" runat="server" Visible="false" CssClass="absolute inset-0 size-20 rounded-2xl object-cover" />
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
                <h1 class="text-lg font-bold text-gray-900 truncate" id="lblCardName" runat="server"></h1>
                <p class="text-sm text-gray-500 truncate" id="lblCardEmail" runat="server"></p>
                <div class="flex items-center gap-2 mt-1.5">
                    <span class="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-emerald-100 text-emerald-700">Driver</span>
                    <span class="text-xs text-gray-400">Driver #<asp:Label ID="lblCardId" runat="server" /></span>
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
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Full name --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input w-full" placeholder="Enter your full name" />
                    <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                        ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Phone --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" placeholder="Enter your phone number" />
                    <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                        ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Payment account --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Payment Account <span class="text-gray-400 font-normal">(KPay / WavePay / bank)</span></label>
                    <asp:TextBox ID="txtPaymentAccount" runat="server" CssClass="tw-input w-full" placeholder="Enter your payment account" />
                </div>
            </div>
        </div>

        <script type="text/javascript">
            // Seat capacity follows the chosen vehicle type, filled in here rather than by a
            // postback: a refresh would throw away the photo and documents picked above.
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

        <%-- Vehicle &amp; licensing --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Vehicle &amp; Licensing</h2>
            <p class="text-sm text-gray-500 mb-6">Keep the vehicle reference and registered documents up to date.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Vehicle type --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Type</label>
                    <asp:DropDownList ID="ddlVehicleType" runat="server" CssClass="tw-input w-full"
                        data-tw-seats="txtSeatCapacity" />
                    <asp:RequiredFieldValidator ID="rfvVehicleType" runat="server" ControlToValidate="ddlVehicleType"
                        InitialValue="" ErrorMessage="Select a vehicle type" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Seat capacity --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Seat Capacity</label>
                    <asp:TextBox ID="txtSeatCapacity" runat="server" TextMode="Number" CssClass="tw-input w-full" />
                    <asp:RequiredFieldValidator ID="rfvSeatCapacity" runat="server" ControlToValidate="txtSeatCapacity"
                        ErrorMessage="Seat capacity is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Plate number (full width) --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Plate Number</label>
                    <asp:TextBox ID="txtPlateNumber" runat="server" CssClass="tw-input w-full" placeholder="e.g. 9K/1234" />
                    <asp:RequiredFieldValidator ID="rfvPlateNumber" runat="server" ControlToValidate="txtPlateNumber"
                        ErrorMessage="Plate number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
            </div>

            <div class="border-t border-gray-100 pt-5 mt-5">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                    <%-- NRC number --%>
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Number</label>
                        <asp:TextBox ID="txtNrc" runat="server" CssClass="tw-input w-full" placeholder="e.g. 12/KAPY(N)123456" />
                        <asp:RequiredFieldValidator ID="rfvNrc" runat="server" ControlToValidate="txtNrc"
                            ErrorMessage="NRC number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>

                    <%-- Licence number --%>
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Driver License Number</label>
                        <asp:TextBox ID="txtLicenseNumber" runat="server" CssClass="tw-input w-full" placeholder="e.g. 12/KAPY(N)654321" />
                        <asp:RequiredFieldValidator ID="rfvLicenseNumber" runat="server" ControlToValidate="txtLicenseNumber"
                            ErrorMessage="License number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                </div>

                <%-- One slot per document. Each carries its own hidden input, button and preview
                     tile, so all four picks stay on screen instead of overwriting one preview. --%>
                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4 sm:gap-5 mt-5">
                    <%-- NRC photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Front</label>

                        <div id="kycTileNrc" runat="server" data-tw-preview-tile class="mb-2">
                            <span id="kycCoverNrc" runat="server" data-tw-cover data-tw-has-doc="0" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span id="kycFallbackNrc" runat="server" data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <asp:Image ID="imgNrcDoc" runat="server" data-tw-stored Visible="false"
                                    CssClass="absolute inset-0 size-full object-cover" />
                        <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuNrcPhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                    </div>
                    <%-- The other side of the card, stored in its own column --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">NRC Back</label>

                        <div id="kycTileNrcBack" runat="server" data-tw-preview-tile class="mb-2">
                            <span id="kycCoverNrcBack" runat="server" data-tw-cover data-tw-has-doc="0" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span id="kycFallbackNrcBack" runat="server" data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <asp:Image ID="imgNrcDocBack" runat="server" data-tw-stored Visible="false"
                                    CssClass="absolute inset-0 size-full object-cover" />
                        <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuNrcPhotoBack" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                    </div>

                    <%-- License photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">License Photo</label>

                        <div id="kycTileLicense" runat="server" data-tw-preview-tile class="mb-2">
                            <span id="kycCoverLicense" runat="server" data-tw-cover data-tw-has-doc="0" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span id="kycFallbackLicense" runat="server" data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <asp:Image ID="imgLicenseDoc" runat="server" data-tw-stored Visible="false"
                                    CssClass="absolute inset-0 size-full object-cover" />
                        <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuLicensePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                    </div>

                    <%-- Vehicle photo --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Vehicle Photo</label>

                        <div id="kycTileVehicle" runat="server" data-tw-preview-tile class="mb-2">
                            <span id="kycCoverVehicle" runat="server" data-tw-cover data-tw-has-doc="0" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span id="kycFallbackVehicle" runat="server" data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <asp:Image ID="imgVehicleDoc" runat="server" data-tw-stored Visible="false"
                                    CssClass="absolute inset-0 size-full object-cover" />
                        <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                    </div>

                    <%-- Registration document (accepts PDF too) --%>
                    <div data-tw-upload>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Reg. Document</label>

                        <div id="kycTileReg" runat="server" data-tw-preview-tile class="mb-2">
                            <span id="kycCoverReg" runat="server" data-tw-cover data-tw-has-doc="0" class="relative block h-24 overflow-hidden rounded-xl border-2 border-dashed border-blue-300 bg-blue-50/40">
                                <span id="kycFallbackReg" runat="server" data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <asp:Image ID="imgRegDoc" runat="server" data-tw-stored Visible="false"
                                    CssClass="absolute inset-0 size-full object-cover" />
                        <img data-tw-preview alt="" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>

                        <asp:FileUpload ID="fuRegDoc" runat="server" data-tw-input accept=".jpg,.jpeg,.png,.pdf" CssClass="hidden" />
                        <button type="button" data-tw-pick data-tw-name data-tw-hint="Choose file"
                            class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">Choose file</button>
                    </div>
                </div>
                <p class="text-xs text-gray-400 mt-3">Need to update a document? Pick the new file above and save &mdash; your KYC returns to Pending for a re-check.</p>
            </div>
        </div>

        <%-- Save and Cancel sit below everything, not inside the personal details card where
             they used to be: the document slots are part of the same form and the admin has to
             scroll past every one of them to reach Save, which is also the button that is
             easiest to forget. --%>
        <div class="mt-6 flex flex-wrap items-center gap-3">
            <asp:Button ID="btnSave" runat="server" Text="Save Changes" OnClick="btnSave_Click" CssClass="tw-btn-primary" />
            <a href="DriverDetail.aspx?id=<%= DriverIdParam %>" class="tw-btn-outline">Cancel</a>
        </div>
    </div>
</asp:Content>
