<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FAQs.aspx.cs" Inherits="TripWay.FAQsPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-3xl mx-auto space-y-8 py-8">

        <div class="text-center">
            <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-blue-700 border border-blue-200 text-xs font-semibold">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 inline-block align-middle"><path d="M9.87891 7.51884C11.0505 6.49372 12.95 6.49372 14.1215 7.51884C15.2931 8.54397 15.2931 10.206 14.1215 11.2312C13.9176 11.4096 13.6917 11.5569 13.4513 11.6733C12.7056 12.0341 12.0002 12.6716 12.0002 13.5V14.25M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12ZM12 17.25H12.0075V17.2575H12V17.25Z" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg> Help Center
            </span>
            <h1 class="text-3xl sm:text-4xl font-bold text-gray-900 mt-4">Frequently Asked Questions</h1>
            <p class="text-gray-500 mt-3 text-sm">Answers to the most common questions about riding with TripWay.</p>
        </div>

        <div class="space-y-3">
            <details class="bg-white rounded-lg shadow-sm p-5 group" open>
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    How do I create a TripWay account?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Click "Register Now" and choose whether you are a Passenger or a Driver. Fill in your details and submit.
                    New accounts are reviewed by our admin team and must be verified before you can start booking or taking trips.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    How long does account verification take?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Verification is usually completed within a few hours. Drivers must also pass NRC and vehicle checks before
                    they go online. You will receive a notification as soon as your account status changes.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    How do I book a ride?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Log in, pick Point-to-Point, Hourly or a Package, then set your pickup and destination on the map.
                    You get an up-front fare quote before you confirm, and the nearest online driver is matched to your trip.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    How are fares calculated?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Fares use Hpa-An km distances managed by TripWay: a base fare plus a per-kilometre rate, or a per-hour
                    rate for hourly hire. The estimated fare is shown to you before you confirm — there is no surge pricing.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    What payment methods are accepted?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    You can pay by cash, KPay, WavePay or your TripWay wallet at the end of every trip. Choose your preferred
                    method before you ride and switch at any time.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    What services does TripWay offer?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Three ways to travel: Point-to-Point rides anywhere in Hpa-An, Hourly hire for errands and appointments,
                    and Day Tour packages covering places like Kyauk Ka Lat, Kyee Kan and Shweyinhmyaw.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    Can I track my driver live?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Yes. Once a driver accepts your trip you can watch their GPS position on the live map until they arrive
                    and throughout the ride, so you always know where your driver is.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    How much commission do drivers pay?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Zero. TripWay charges drivers 0% commission — every kyat of the fare belongs to the person behind the wheel.
                    Drivers only keep the platform running with a small, transparent wallet top-up when they choose.
                </p>
            </details>

            <details class="bg-white rounded-lg shadow-sm p-5 group">
                <summary class="flex items-center justify-between cursor-pointer select-none font-semibold text-gray-900 text-sm">
                    I have more questions. How do I contact you?
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-3 text-gray-400 group-open:rotate-180 transition-transform inline-block align-middle"><path d="M19.5 8.25L12 15.75L4.5 8.25" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                </summary>
                <p class="text-sm text-gray-500 mt-3 leading-relaxed">
                    Visit our Contact page and send us a message — our support team will get back to you as soon as possible.
                </p>
            </details>
        </div>
    </div>
</asp:Content>