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
                        <asp:FileUpload ID="fuProfilePhoto" runat="server" CssClass="tw-input tw-file" />
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
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">NRC Photo (front &amp; back)</label>
                        <asp:FileUpload ID="fuNrcPhoto" runat="server" CssClass="tw-input tw-file" />
                        <asp:RequiredFieldValidator ID="rfvNrcPhoto" runat="server" ControlToValidate="fuNrcPhoto"
                            ErrorMessage="NRC photo is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Driver License Number</label>
                        <asp:TextBox ID="txtLicenseNumber" runat="server" CssClass="tw-input" placeholder="License number" />
                        <asp:RequiredFieldValidator ID="rfvLicenseNumber" runat="server" ControlToValidate="txtLicenseNumber"
                            ErrorMessage="License number is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Driver License Photo</label>
                        <asp:FileUpload ID="fuLicensePhoto" runat="server" CssClass="tw-input tw-file" />
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
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Vehicle Photo</label>
                        <asp:FileUpload ID="fuVehiclePhoto" runat="server" CssClass="tw-input tw-file" />
                        <asp:RequiredFieldValidator ID="rfvVehiclePhoto" runat="server" ControlToValidate="fuVehiclePhoto"
                            ErrorMessage="Vehicle photo is required" CssClass="text-xs text-red-500" Display="Dynamic" Enabled="false" />
                    </div>
                    <div class="flex flex-col gap-1.5">
                        <label class="text-sm text-gray-900 font-bold">Vehicle Registration Document (photo)</label>
                        <asp:FileUpload ID="fuRegDoc" runat="server" CssClass="tw-input tw-file" />
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