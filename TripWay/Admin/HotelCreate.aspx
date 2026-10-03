<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="HotelCreate.aspx.cs" Inherits="TripWay.Admin.HotelCreatePage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-3xl space-y-6">

        <%-- No Cancel up here: Save and Cancel sit together under the form, so there is one
             place to finish or abandon the hotel and nothing to trip over at the top. --%>
        <div>
            <h1 class="text-lg font-semibold text-gray-900 mb-1">New Hotel</h1>
            <p class="text-sm text-gray-500">Hotels are shown on the customer booking page with a button that routes the trip to the hotel.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <%-- Logo --%>
        <div data-tw-upload class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Logo</h2>
            <p class="text-sm text-gray-500 mb-6">Shown next to the hotel on the booking page. JPG or PNG, up to 4 MB. Optional — the hotel name is used when there is no logo.</p>

            <div class="flex items-center gap-5">
                <div class="relative shrink-0">
                    <span data-tw-cover class="relative block size-20">
                        <%-- A new hotel cannot have a stored logo yet, so unlike the edit form
                             this tile is just the placeholder with a live preview on top. --%>
                        <span id="imgDefaultLogo" runat="server" class="absolute inset-0 size-20 rounded-2xl bg-emerald-600/10 text-emerald-600 flex items-center justify-center">
                            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-10">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M2.25 21h19.5m-18-18v18m10.5-18v18m6-13.5V21M6.75 6.75h.75m-.75 3h.75m-.75 3h.75m3-6h.75m-.75 3h.75m-.75 3h.75M6.75 21v-3.375c0-.621.504-1.125 1.125-1.125h3.75c.621 0 1.125.504 1.125 1.125V21" />
                            </svg>
                        </span>
                        <%-- Live preview of the picked logo, drawn over the placeholder --%>
                        <img data-tw-preview alt="Hotel logo preview" class="hidden absolute inset-0 size-20 rounded-2xl object-cover" />
                    </span>

                    <%-- Change logo button (bottom-right corner of the tile) --%>
                    <button type="button" data-tw-pick
                        class="absolute -bottom-1.5 -right-1.5 inline-flex size-7 items-center justify-center rounded-full bg-white text-gray-600 shadow-md border border-gray-200 hover:text-emerald-600 hover:border-emerald-200"
                        title="Change hotel logo" aria-label="Change hotel logo">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4">
                            <path stroke-linecap="round" stroke-linejoin="round" d="m16.862 4.487 1.687-1.688a1.875 1.875 0 1 1 2.652 2.652L6.832 19.82a4.5 4.5 0 0 1-1.897 1.13l-2.685.8.8-2.685a4.5 4.5 0 0 1 1.13-1.897l12.681-12.68Z" />
                        </svg>
                    </button>

                    <%-- Hidden picker; the buttons above open it and the shared script previews the result --%>
                    <asp:FileUpload ID="fuLogo" runat="server" data-tw-input accept=".jpg,.jpeg,.png" CssClass="hidden" />
                </div>

                <div class="min-w-0 flex-1">
                    <div class="flex items-center gap-2.5">
                        <button type="button" data-tw-pick
                            class="tw-btn-outline inline-flex items-center justify-center gap-1.5 !h-9 !px-3 !text-xs">Change logo</button>
                        <span data-tw-name data-tw-hint="JPG or PNG" class="truncate text-xs text-gray-400">JPG or PNG</span>
                    </div>
                </div>
            </div>
        </div>

        <%-- Hotel information --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <h2 class="text-base font-semibold text-gray-900 mb-1">Hotel Information</h2>
            <p class="text-sm text-gray-500 mb-6">Your changes are saved together with the Create Hotel button.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <%-- Name --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Hotel Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="tw-input w-full" MaxLength="150" placeholder="Enter the hotel name" />
                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Address --%>
                <div class="sm:col-span-2">
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Address / Location</label>
                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="2" CssClass="tw-input tw-textarea w-full" MaxLength="300" placeholder="Enter the hotel address" />
                </div>

                <%-- Phone --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Phone</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="tw-input w-full" MaxLength="40" placeholder="Enter the hotel phone" />
                </div>

                <%-- Email --%>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="tw-input w-full" MaxLength="150" placeholder="Enter the hotel email" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="Enter a valid email address"
                        CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>

                <%-- Visibility --%>
                <div class="sm:col-span-2">
                    <label class="flex items-center gap-2 text-sm text-gray-700">
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                        Active — show this hotel on the customer booking page
                    </label>
                </div>
            </div>
        </div>

        <%-- Location --%>
        <div class="bg-white rounded-lg shadow-sm p-6">
            <div class="flex flex-wrap items-start justify-between gap-2 mb-1">
                <h2 class="text-base font-semibold text-gray-900">Location</h2>
                <button type="button" id="btnUseMyLocation" class="tw-btn-outline">Use my location</button>
            </div>
            <p class="text-sm text-gray-500 mb-6">Click the map to drop the hotel pin and the address is looked up for it. Anything you type in the address box is kept and never replaced. The booking page routes the customer's trip to this point.</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 sm:gap-5">
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Latitude</label>
                    <asp:TextBox ID="txtLat" runat="server" CssClass="tw-input w-full" placeholder="16.890000" />
                    <asp:RequiredFieldValidator ID="rfvLat" runat="server" ControlToValidate="txtLat" ErrorMessage="Latitude is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-900 mb-1.5">Longitude</label>
                    <asp:TextBox ID="txtLng" runat="server" CssClass="tw-input w-full" placeholder="97.633000" />
                    <asp:RequiredFieldValidator ID="rfvLng" runat="server" ControlToValidate="txtLng" ErrorMessage="Longitude is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
            </div>
            <div id="mapHotel" class="h-80 w-full rounded-xl border border-gray-200 mt-5"></div>
        </div>

        <%-- Finish or abandon: the only two buttons on the page --%>
        <div class="flex items-center gap-2">
            <asp:Button ID="btnSave" runat="server" Text="Create Hotel" OnClick="btnSave_Click" CssClass="tw-btn-primary" />
            <a href="HotelManagement.aspx" class="tw-btn-outline">Cancel</a>
        </div>
    </div>

    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="<%= ResolveUrl("~/Scripts/tw-place.js") %>"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var mapEl = document.getElementById('mapHotel');
            if (!mapEl || typeof L === 'undefined') return;

            var latInput = document.getElementById('<%= txtLat.ClientID %>');
            var lngInput = document.getElementById('<%= txtLng.ClientID %>');
            var map = L.map(mapEl).setView([16.890, 97.633], 13);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
            var marker = null;

            function currentLatLng() {
                var la = parseFloat(latInput.value), ln = parseFloat(lngInput.value);
                if (isNaN(la) || isNaN(ln)) return null;
                return [la, ln];
            }

            function setCoord(lat, lng) {
                latInput.value = Number(lat).toFixed(6);
                lngInput.value = Number(lng).toFixed(6);
                if (marker) { marker.setLatLng([lat, lng]); }
                else {
                    marker = L.marker([lat, lng], {
                        icon: L.divIcon({ className: '', html: '<span class="block size-5 rounded-full bg-blue-600 border-2 border-white shadow"></span>' })
                    }).addTo(map);
                }
                /* The coordinates are already in the boxes, so the address lookup can read them
                   straight back. TripPlace only writes into an address box that is empty or that
                   it filled itself, so a hotel whose address was typed by hand is left alone. */
                if (typeof TripPlace !== 'undefined') TripPlace.refresh();
            }

            if (typeof TripPlace !== 'undefined') {
                TripPlace.bind({
                    address: document.getElementById('<%= txtAddress.ClientID %>'),
                    getLatLng: currentLatLng,
                    limit: 300
                });
            }

            map.on('click', function (e) { setCoord(e.latlng.lat, e.latlng.lng); });

            // Typing coordinates by hand should move the pin too.
            [latInput, lngInput].forEach(function (input) {
                input.addEventListener('change', function () {
                    var ll = currentLatLng();
                    if (!ll) return;
                    if (marker) { marker.setLatLng(ll); map.setView(ll, Math.max(map.getZoom(), 15)); }
                });
            });

            var meBtn = document.getElementById('btnUseMyLocation');
            if (meBtn && navigator.geolocation) {
                meBtn.addEventListener('click', function () {
                    navigator.geolocation.getCurrentPosition(function (pos) {
                        setCoord(pos.coords.latitude, pos.coords.longitude);
                        map.setView([pos.coords.latitude, pos.coords.longitude], 15);
                    }, function () { });
                });
            } else if (meBtn) {
                meBtn.disabled = true;
                meBtn.classList.add('opacity-50', 'cursor-not-allowed');
            }
        });
    </script>
</asp:Content>
