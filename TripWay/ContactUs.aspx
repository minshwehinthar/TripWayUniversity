<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContactUs.aspx.cs" Inherits="TripWay.ContactUsPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-4xl mx-auto space-y-8 py-8">

        <div class="text-center">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 text-xs font-semibold">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"/></svg> Contact Us
            </span>
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mt-4">We'd love to hear from you</h1>
            <p class="text-gray-500 mt-3 text-sm">Questions, feedback or stuck on a trip? Send us a message — a TripWay support agent will follow up as soon as possible.</p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-5 gap-6">
            <%-- Contact info --%>
            <div class="lg:col-span-2 space-y-4">
                <div class="bg-white p-5 rounded-lg shadow-sm flex items-start gap-3">
                    <span class="inline-flex size-10 rounded-lg bg-blue-100 text-blue-600 items-center justify-center shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/>
  <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                    </span>
                    <div>
                        <h3 class="text-sm font-semibold text-gray-900">Address</h3>
                        <p class="text-sm text-gray-500 mt-0.5">Market Zone, Hpa-An Township,<br />Kayin State, Myanmar.</p>
                    </div>
                </div>
                <div class="bg-white p-5 rounded-lg shadow-sm flex items-start gap-3">
                    <span class="inline-flex size-10 rounded-lg bg-green-100 text-green-600 items-center justify-center shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path d="M2.25 6.75C2.25 15.0343 8.96573 21.75 17.25 21.75H19.5C20.7426 21.75 21.75 20.7426 21.75 19.5V18.1284C21.75 17.6121 21.3987 17.1622 20.8979 17.037L16.4747 15.9312C16.0355 15.8214 15.5734 15.9855 15.3018 16.3476L14.3316 17.6412C14.05 18.0166 13.563 18.1827 13.1223 18.0212C9.81539 16.8098 7.19015 14.1846 5.97876 10.8777C5.81734 10.437 5.98336 9.94998 6.3588 9.6684L7.65242 8.69818C8.01453 8.4266 8.17861 7.96445 8.06883 7.52533L6.96304 3.10215C6.83783 2.60133 6.38785 2.25 5.87163 2.25H4.5C3.25736 2.25 2.25 3.25736 2.25 4.5V6.75Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <div>
                        <h3 class="text-sm font-semibold text-gray-900">Phone / Hotline</h3>
                        <p class="text-sm text-gray-500 mt-0.5">+95 9 123 456 789</p>
                    </div>
                </div>
                <div class="bg-white p-5 rounded-lg shadow-sm flex items-start gap-3">
                    <span class="inline-flex size-10 rounded-lg bg-purple-100 text-purple-600 items-center justify-center shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75"/></svg>
                    </span>
                    <div>
                        <h3 class="text-sm font-semibold text-gray-900">Email</h3>
                        <p class="text-sm text-gray-500 mt-0.5">support@tripway.com</p>
                    </div>
                </div>
                <div class="bg-white p-5 rounded-lg shadow-sm flex items-start gap-3">
                    <span class="inline-flex size-10 rounded-lg bg-yellow-100 text-yellow-600 items-center justify-center shrink-0">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"/></svg>
                    </span>
                    <div>
                        <h3 class="text-sm font-semibold text-gray-900">Working Hours</h3>
                        <p class="text-sm text-gray-500 mt-0.5">9:00 AM – 6:00 PM, daily</p>
                    </div>
                </div>
            </div>

            <%-- Form --%>
            <div class="lg:col-span-3 bg-white p-6 rounded-lg shadow-sm">
                <h2 class="text-lg font-semibold text-gray-900 mb-1">Send a message</h2>
                <p class="text-sm text-gray-500 mb-6">Fill in the form below and we will get back to you as soon as possible.</p>

                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="mb-4 p-3 rounded-lg text-sm bg-green-100 text-green-700 border border-green-200">
                    <asp:Label ID="lblSuccess" runat="server" Text="Your message has been received. We will get back to you shortly." />
                </asp:Panel>

                <div class="flex flex-col gap-5">
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-5">
                        <div>
                            <label class="block text-sm font-bold text-gray-900 mb-1.5">Your Name *</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="tw-input" placeholder="Enter your name" />
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                ErrorMessage="Name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-900 mb-1.5">Email *</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="SingleLine" CssClass="tw-input" placeholder="Enter your email" />
                            <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail"
                                ErrorMessage="Email is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                            <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email"
                                CssClass="text-xs text-red-500" Display="Dynamic" />
                        </div>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Subject *</label>
                        <asp:TextBox ID="txtSubject" runat="server" CssClass="tw-input" placeholder="What is this about?" />
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject"
                            ErrorMessage="Subject is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-900 mb-1.5">Message *</label>
                        <asp:TextBox ID="txtMessage" runat="server" TextMode="MultiLine" Rows="5"
                            CssClass="tw-input tw-textarea" placeholder="Write your message here..." />
                        <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="txtMessage"
                            ErrorMessage="Message is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                    </div>
                    <div>
                        <asp:Button ID="btnSend" runat="server" Text="Send Message" OnClick="btnSend_Click" CssClass="tw-btn-primary" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>