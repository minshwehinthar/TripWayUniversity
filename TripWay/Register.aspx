<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="TripWay.RegisterPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="py-8 px-4">
        <div class="mx-auto bg-white rounded-2xl shadow-sm w-full max-w-3xl p-8">
            <div class="mb-6 flex items-center gap-3">
                <img src='<%= ResolveUrl("~/Images/logo.jpeg") %>' alt="TripWay" class="size-12 rounded-xl object-contain shrink-0" />
                <div>
                    <h2 class="text-lg font-bold text-gray-900 leading-tight">Create Account</h2>
                    <p class="text-sm text-gray-400">Join TripWay</p>
                </div>
            </div>

            <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <%-- Role selection: Customer (simple) / Driver (KYC onboarding) --%>
            <div class="flex flex-col gap-1.5 mb-6">
                <label class="text-sm text-gray-900 font-bold">I want to register as</label>
                <asp:DropDownList ID="ddlRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlRole_SelectedIndexChanged"
                    CssClass="tw-input md:max-w-xs">
                    <asp:ListItem Value="Customer" Text="Customer (Book a Trip)" Selected="True" />
                    <asp:ListItem Value="Driver" Text="Driver (Earn by Driving)" />
                </asp:DropDownList>
            </div>

            <%-- ================= Customer fields ================= --%>
            <asp:Panel ID="pnlCustomer" runat="server" CssClass="contents">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-x-5 gap-y-4">
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Full Name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="tw-input" placeholder="Enter your full name" />
                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="txtFullName"
                            ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine" CssClass="tw-input"
                            placeholder="Enter your email" autocomplete="email" />
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                            ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                            CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="tw-input"
                            placeholder="Min 8 characters with a number" autocomplete="new-password" />
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                            ErrorMessage="Password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                        <asp:RegularExpressionValidator ID="revPassword" runat="server" ControlToValidate="txtPassword"
                            ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Password must be at least 8 characters and include a number"
                            CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input"
                            placeholder="Confirm password" autocomplete="new-password" />
                        <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtPassword" ErrorMessage="Passwords do not match"
                            CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input" placeholder="e.g. 09 123 456 789" />
                        <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone"
                            ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Gender <span class="text-gray-400 font-normal">(optional)</span></label>
                        <asp:DropDownList ID="ddlGender" runat="server" CssClass="tw-input">
                            <asp:ListItem Value="" Text="-- Select --" />
                            <asp:ListItem Value="Male" Text="Male" />
                            <asp:ListItem Value="Female" Text="Female" />
                            <asp:ListItem Value="Other" Text="Other" />
                        </asp:DropDownList>
                    </div>
                    <div class="flex flex-col gap-1.5 md:col-span-2">
                        <label class="text-sm text-gray-900 font-bold">Profile Photo <span class="text-gray-400 font-normal">(optional)</span></label>
                        <%-- Picker, button and live preview follow the data-tw-upload contract in
                             Scripts/tw-upload.js, already loaded by Site.Master. The account does
                             not exist yet, so there is no stored photo: the skeleton just sits
                             there until a file is picked, and nothing is uploaded until the form
                             is submitted. The photo group is stacked above the picker rather than
                             beside it, matching the document slots below and keeping the picker
                             in the spot the plain file input used to occupy. --%>
                        <div data-tw-upload class="flex flex-col items-start gap-2">
                            <div class="relative shrink-0">
                                <span data-tw-cover class="relative block size-14">
                                    <span class="tw-skeleton tw-skeleton-avatar absolute inset-0 size-14 rounded-xl"></span>
                                    <img data-tw-preview alt="Profile photo preview" class="hidden absolute inset-0 size-14 rounded-xl object-cover" />
                                </span>
                                <%-- Pencil on the photo, the same control Customer/Profile.aspx uses --%>
                                <button type="button" data-tw-pick
                                    class="absolute -bottom-1.5 -right-1.5 inline-flex size-6 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-blue-600 hover:border-blue-200"
                                    title="Choose profile photo" aria-label="Choose profile photo">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3.5">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                                    </svg>
                                </button>
                                <asp:FileUpload ID="fuProfilePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                            </div>
                            <button type="button" data-tw-pick class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0">
                                    <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                                </svg>
                                Choose photo
                            </button>
                            <span class="block w-full truncate text-xs text-gray-400" data-tw-name data-tw-hint="JPG or PNG, up to 4 MB">JPG or PNG, up to 4 MB</span>
                        </div>
                    </div>
                    <div class="flex flex-col gap-1.5 md:col-span-2">
                        <label class="text-sm text-gray-900 font-bold">Home / Default Pickup Address <span class="text-gray-400 font-normal">(optional)</span></label>
                        <asp:TextBox ID="txtDefaultAddress" runat="server" TextMode="MultiLine" Rows="2"
                            CssClass="tw-input tw-textarea" placeholder="Speeds up future bookings" />
                    </div>
                </div>
            </asp:Panel>

            <%-- ================= Driver (KYC) fields ================= --%>
            <asp:Panel ID="pnlDriver" runat="server" Visible="false" CssClass="contents">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-x-5 gap-y-4">
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Full Name</label>
                        <asp:TextBox ID="txtDriverName" runat="server" CssClass="tw-input" placeholder="Enter your full name" />
                        <asp:RequiredFieldValidator ID="rfvDriverName" runat="server" ControlToValidate="txtDriverName"
                            ErrorMessage="Full name is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Email</label>
                        <asp:TextBox ID="txtDriverEmail" runat="server" TextMode="SingleLine" CssClass="tw-input"
                            placeholder="Enter your email" autocomplete="email" />
                        <asp:RequiredFieldValidator ID="rfvDriverEmail" runat="server" ControlToValidate="txtDriverEmail"
                            ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                        <asp:RegularExpressionValidator ID="revDriverEmail" runat="server" ControlToValidate="txtDriverEmail"
                            ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                            CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Password</label>
                        <asp:TextBox ID="txtDriverPassword" runat="server" TextMode="Password" CssClass="tw-input"
                            placeholder="Min 8 characters with a number" autocomplete="new-password" />
                        <asp:RequiredFieldValidator ID="rfvDriverPassword" runat="server" ControlToValidate="txtDriverPassword"
                            ErrorMessage="Password is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                        <asp:RegularExpressionValidator ID="revDriverPassword" runat="server" ControlToValidate="txtDriverPassword"
                            ValidationExpression="^(?=.*[0-9]).{8,}$" ErrorMessage="Password must be at least 8 characters and include a number"
                            CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Confirm Password</label>
                        <asp:TextBox ID="txtDriverConfirmPassword" runat="server" TextMode="Password" CssClass="tw-input"
                            placeholder="Confirm password" autocomplete="new-password" />
                        <asp:CompareValidator ID="cvDriverPassword" runat="server" ControlToValidate="txtDriverConfirmPassword"
                            ControlToCompare="txtDriverPassword" ErrorMessage="Passwords do not match"
                            CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Phone Number</label>
                        <asp:TextBox ID="txtDriverPhone" runat="server" CssClass="tw-input" placeholder="e.g. 09 123 456 789" />
                        <asp:RequiredFieldValidator ID="rfvDriverPhone" runat="server" ControlToValidate="txtDriverPhone"
                            ErrorMessage="Phone number is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">NRC Number</label>
                        <asp:TextBox ID="txtNrc" runat="server" CssClass="tw-input" placeholder="e.g. 12/KAPY(N)123456" />
                        <asp:RequiredFieldValidator ID="rfvNrc" runat="server" ControlToValidate="txtNrc"
                            ErrorMessage="NRC is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5" data-tw-upload>
                        <label class="text-sm text-gray-900 font-bold">NRC Photo (front &amp; back)</label>
                        <%-- One slot per document, and unlike the pickers on the profile pages
                             it is never hidden: the skeleton holds the 4:3 box from the start, so
                             the four documents read as four waiting slots rather than appearing
                             one at a time. Each keeps its own slot so the four picks stay side by
                             side instead of overwriting one shared preview. --%>
                        <div data-tw-preview-tile>
                            <span data-tw-cover class="tw-skeleton relative block w-full tw-skeleton-media overflow-hidden rounded-xl border-2 border-dashed border-blue-300">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="NRC photo preview" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>
                        <asp:FileUpload ID="fuNrcPhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                            </svg>
                            Choose file
                        </button>
                        <span class="block truncate text-xs text-gray-400" data-tw-name data-tw-hint="No file chosen">No file chosen</span>
                        <asp:RequiredFieldValidator ID="rfvNrcPhoto" runat="server" ControlToValidate="fuNrcPhoto"
                            ErrorMessage="NRC photo is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Driver License Number</label>
                        <asp:TextBox ID="txtLicenseNumber" runat="server" CssClass="tw-input" placeholder="License number" />
                        <asp:RequiredFieldValidator ID="rfvLicenseNumber" runat="server" ControlToValidate="txtLicenseNumber"
                            ErrorMessage="License number is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5" data-tw-upload>
                        <label class="text-sm text-gray-900 font-bold">Driver License Photo</label>
                        <div data-tw-preview-tile>
                            <span data-tw-cover class="tw-skeleton relative block w-full tw-skeleton-media overflow-hidden rounded-xl border-2 border-dashed border-blue-300">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="Driver license preview" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>
                        <asp:FileUpload ID="fuLicensePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                            </svg>
                            Choose file
                        </button>
                        <span class="block truncate text-xs text-gray-400" data-tw-name data-tw-hint="No file chosen">No file chosen</span>
                        <asp:RequiredFieldValidator ID="rfvLicensePhoto" runat="server" ControlToValidate="fuLicensePhoto"
                            ErrorMessage="License photo is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Vehicle Type</label>
                        <asp:DropDownList ID="ddlVehicleType" runat="server" CssClass="tw-input"
                            data-tw-seats="txtSeatCapacity" />
                        <asp:RequiredFieldValidator ID="rfvVehicleType" runat="server" ControlToValidate="ddlVehicleType"
                            InitialValue="" ErrorMessage="Vehicle type is required" CssClass="text-xs text-red-500"
                            Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Vehicle Plate Number</label>
                        <asp:TextBox ID="txtPlateNumber" runat="server" CssClass="tw-input" placeholder="e.g. 9K/1234" />
                        <asp:RequiredFieldValidator ID="rfvPlateNumber" runat="server" ControlToValidate="txtPlateNumber"
                            ErrorMessage="Plate number is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5" data-tw-upload>
                        <label class="text-sm text-gray-900 font-bold">Vehicle Photo</label>
                        <div data-tw-preview-tile>
                            <span data-tw-cover class="tw-skeleton relative block w-full tw-skeleton-media overflow-hidden rounded-xl border-2 border-dashed border-blue-300">
                                <span data-tw-fallback class="absolute inset-0 items-center justify-center text-blue-300" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                </span>
                                <img data-tw-preview alt="Vehicle photo preview" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>
                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                        <button type="button" data-tw-pick class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                            </svg>
                            Choose file
                        </button>
                        <span class="block truncate text-xs text-gray-400" data-tw-name data-tw-hint="No file chosen">No file chosen</span>
                        <asp:RequiredFieldValidator ID="rfvVehiclePhoto" runat="server" ControlToValidate="fuVehiclePhoto"
                            ErrorMessage="Vehicle photo is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5" data-tw-upload>
                        <label class="text-sm text-gray-900 font-bold">Vehicle Registration Document (photo)</label>
                        <%-- The only picker here that also takes a PDF, so the fallback chip is
                             what a picked PDF shows instead of a broken image. --%>
                        <div data-tw-preview-tile>
                            <span data-tw-cover class="tw-skeleton relative block w-full tw-skeleton-media overflow-hidden rounded-xl border-2 border-dashed border-blue-300">
                                <span data-tw-fallback class="absolute inset-0 flex-col items-center justify-center gap-1 text-blue-400" style="display:none">
                                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-8">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m0 12.75h7.5m-7.5 3H12M10.5 2.25H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
                                    </svg>
                                    <span class="text-[11px] font-bold uppercase tracking-wide">Document</span>
                                </span>
                                <img data-tw-preview alt="Registration document preview" class="hidden absolute inset-0 size-full object-cover" />
                            </span>
                        </div>
                        <asp:FileUpload ID="fuRegDoc" runat="server" data-tw-input accept=".jpg,.jpeg,.png,.pdf" CssClass="hidden" />
                        <button type="button" data-tw-pick class="tw-btn-outline w-full justify-center !h-9 !px-3 !text-xs">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 16.5v2.25A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75V16.5M16.5 12 12 16.5m0 0L7.5 12m4.5 4.5V3" />
                            </svg>
                            Choose file
                        </button>
                        <span class="block truncate text-xs text-gray-400" data-tw-name data-tw-hint="JPG, PNG or PDF, up to 4 MB">JPG, PNG or PDF, up to 4 MB</span>
                        <asp:RequiredFieldValidator ID="rfvRegDoc" runat="server" ControlToValidate="fuRegDoc"
                            ErrorMessage="Registration document is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Seat Capacity</label>
                        <asp:TextBox ID="txtSeatCapacity" runat="server" TextMode="Number" CssClass="tw-input"
                            placeholder="Filled in from the vehicle type, editable" />
                    </div>
                    <div class="flex flex-col gap-1.5 md:col-span-2">
                        <label class="text-sm text-gray-900 font-bold">Bank / KPay / WavePay Account <span class="text-gray-400 font-normal">(optional, reference only)</span></label>
                        <asp:TextBox ID="txtPaymentAccount" runat="server" CssClass="tw-input" placeholder="e.g. KPay 09xxxxxxxxx" />
                    </div>
                </div>
                <div class="mt-4 p-3 rounded-lg bg-blue-50 text-blue-700 text-xs border border-blue-100">
                    Your driver account starts in <strong>Pending</strong> status. An admin must approve your KYC documents
                    (NRC, license, vehicle) before you can go online and accept trips.
                </div>
            </asp:Panel>

            <div class="pt-6">
                <asp:Button ID="btnRegister" runat="server" Text="Create My Account" OnClick="btnRegister_Click"
                    CssClass="tw-btn-primary w-full justify-center" />
            </div>

            <p class="text-sm text-gray-500 mt-6 text-center">
                Already have an account?
                <a href="Login.aspx" class="text-blue-600 hover:underline font-medium">Login here</a>
            </p>
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