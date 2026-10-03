<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="TripWay.LoginPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="min-h-[70vh] flex items-center justify-center py-8 px-4">
        <div class="bg-white rounded-2xl shadow-sm w-full max-w-md p-8">
            <div class="mb-6 flex items-center gap-3">
                <img src='<%= ResolveUrl("~/Images/logo.jpeg") %>' alt="TripWay" class="size-12 rounded-xl object-contain shrink-0" />
                <div>
                    <h2 class="text-lg font-bold text-gray-900 leading-tight">Login</h2>
                    <p class="text-sm text-gray-400">Welcome back to TripWay</p>
                </div>
            </div>

            <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
                <asp:Label ID="lblMessage" runat="server" />
            </asp:Panel>

            <div class="space-y-4">
                <div class="flex flex-col gap-1.5">
                    <label for="txtEmail" class="text-sm text-gray-900 font-bold">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine"
                        CssClass="tw-input"
                        placeholder="Enter your email address" autocomplete="email" />
                    <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                        ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <div class="flex flex-col gap-1.5">
                    <label for="txtPassword" class="text-sm text-gray-900 font-bold">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                        CssClass="tw-input"
                        placeholder="Enter your password" autocomplete="current-password" />
                    <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword"
                        ErrorMessage="Password is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <label class="flex items-center gap-2 text-sm text-gray-900 cursor-pointer select-none">
                    <asp:CheckBox ID="chkRemember" runat="server" CssClass="size-4 accent-blue-600" />
                    Remember me
                </label>

                <div class="pt-2">
                    <asp:Button ID="btnLogin" runat="server" Text="Login to your Account" OnClick="btnLogin_Click"
                        CssClass="tw-btn-primary w-full justify-center" />
                </div>
            </div>

            <p class="text-sm text-gray-500 mt-6 text-center">
                Don't have an account?
                <a href="Register.aspx" class="text-blue-600 hover:underline font-medium">Register here</a>
            </p>
        </div>
    </div>
</asp:Content>