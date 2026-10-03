<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PackageCreate.aspx.cs" Inherits="TripWay.Admin.PackageCreatePage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="max-w-3xl space-y-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">New Package</h1>
            <p class="text-sm text-gray-400">Package details and the stops included in the tour.</p>
        </div>

        <asp:Panel ID="pnlMessage" runat="server" data-tw-toast="1" Visible="false" CssClass="p-3 rounded-lg text-sm bg-red-100 text-red-700 border border-red-200">
            <asp:Label ID="lblMessage" runat="server" />
        </asp:Panel>

        <div class="bg-white rounded-2xl shadow-sm p-6 space-y-4">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div class="flex flex-col gap-1.5 md:col-span-2">
                    <label class="text-sm text-gray-900 font-bold">Package Name</label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="tw-input" MaxLength="150" />
                    <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm text-gray-900 font-bold">Duration (days)</label>
                    <asp:TextBox ID="txtDurationDays" runat="server" TextMode="Number" CssClass="tw-input" />
                    <asp:RequiredFieldValidator ID="rfvDays" runat="server" ControlToValidate="txtDurationDays" ErrorMessage="Required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div class="flex flex-col gap-1.5">
                    <label class="text-sm text-gray-900 font-bold">Fixed Price (MMK)</label>
                    <asp:TextBox ID="txtFixedPrice" runat="server" TextMode="Number" CssClass="tw-input" />
                    <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtFixedPrice" ErrorMessage="Required" CssClass="text-xs text-red-500" Display="Dynamic" />
                </div>
                <div class="md:col-span-2">
                    <label class="flex items-center gap-2 text-sm text-gray-700">
                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                        Active — show this package on the booking page and the home page
                    </label>
                    <p class="text-xs text-gray-400 mt-1">You can hide a package later without deleting it, from the package list or the edit page.</p>
                </div>
            </div>
        </div>

        <div class="bg-white rounded-2xl shadow-sm p-6 space-y-4">
            <h2 class="font-bold text-gray-900">Cover Photo</h2>
            <p class="text-xs text-gray-400">Main image for the package card and the detail page header. JPG or PNG, up to 4 MB.</p>
            <asp:FileUpload ID="fuCover" runat="server" CssClass="block w-full text-sm text-gray-600 file:mr-3 file:rounded-lg file:border-0 file:bg-gray-100 file:px-3 file:py-2 file:text-sm file:font-semibold file:text-gray-700 hover:file:bg-gray-200" />
        </div>

        <div id="stopsAnchor" data-tw-anchor class="bg-white rounded-2xl shadow-sm p-6 space-y-4 scroll-mt-6">
            <div class="flex flex-wrap items-center justify-between gap-3">
                <div>
                    <h2 class="font-bold text-gray-900">Tour Stops</h2>
                    <p class="text-xs text-gray-400">Click the map to drop a pin — the stop name fills in from that spot and you can retype it. Stop 1 is the starting point.</p>
                </div>
                <div class="flex items-center gap-2">
                    <span class="text-xs font-semibold text-gray-500 tabular-nums"><asp:Literal ID="litStopCount" runat="server" /></span>
                    <button type="button" id="btnAddStop" class="tw-btn-outline">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="2" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M12 4.5v15m7.5-7.5h-15" /></svg>
                        Add stop
                    </button>
                    <button type="button" id="btnUseMyLocation" class="tw-btn-outline">Use my location</button>
                </div>
            </div>

            <div id="stopsHint" class="flex items-start gap-2 rounded-lg bg-blue-50 border border-blue-100 px-3 py-2 text-xs text-blue-800">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 shrink-0 mt-0.5"><path stroke-linecap="round" stroke-linejoin="round" d="M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z" /></svg>
                <span><asp:Literal ID="litPickHint" runat="server" Text="Select a stop, then click the map to drop its pin and name it." /></span>
            </div>

            <div id="stopsList" class="space-y-3">
            <asp:Repeater ID="rptPlaces" runat="server">
                <ItemTemplate>
                    <div class="rounded-xl border border-gray-200 bg-white p-4 transition-colors hover:border-gray-300" data-row='<%# Eval("Index") %>'>
                        <div class="flex items-start gap-3">
                            <span class="tw-avatar tw-avatar-blue size-8 shrink-0" data-stop-badge><%# Eval("Index") %></span>
                            <div class="min-w-0 flex-1 space-y-3">
                                <div class="flex items-center gap-2">
                                    <asp:TextBox ID="txtPlaceName" runat="server" CssClass="tw-input font-semibold" placeholder="Stop name — filled in from the map, or type your own" Text='<%# Eval("PlaceName") %>' />
                                    <button type="button" class="tw-action shrink-0" data-pick-row='<%# Eval("Index") %>' title="Pick on map">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="M15 10.5a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/><path stroke-linecap="round" stroke-linejoin="round" d="M19.5 10.5c0 7.142-7.5 11.25-7.5 11.25S4.5 17.642 4.5 10.5a7.5 7.5 0 1 1 15 0Z"/></svg>
                                    </button>
                                    <button type="button" class="tw-action tw-action-danger shrink-0" data-remove-row='<%# Eval("Index") %>' title="Remove this stop">
                                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4 inline-block align-middle"><path stroke-linecap="round" stroke-linejoin="round" d="m14.74 9-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 0 1-2.244 2.077H8.084a2.25 2.25 0 0 1-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 0 0-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 0 1 3.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 0 0-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 0 0-7.5 0"/></svg>
                                    </button>
                                </div>
                                <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                                    <div class="flex flex-col gap-1">
                                        <label class="text-[11px] font-semibold uppercase tracking-wide text-gray-400">Latitude</label>
                                        <asp:TextBox ID="txtLat" runat="server" CssClass="tw-input font-mono text-xs" placeholder="16.866100" Text='<%# Eval("Lat") %>' />
                                    </div>
                                    <div class="flex flex-col gap-1">
                                        <label class="text-[11px] font-semibold uppercase tracking-wide text-gray-400">Longitude</label>
                                        <asp:TextBox ID="txtLng" runat="server" CssClass="tw-input font-mono text-xs" placeholder="96.195100" Text='<%# Eval("Lng") %>' />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            </div>

            <div id="mapPlaces" class="h-80 w-full rounded-xl border border-gray-200"></div>
        </div>

        <div class="flex items-center gap-2">
            <asp:Button ID="btnSave" runat="server" Text="Create Package" OnClick="btnSave_Click" CssClass="tw-btn-primary" />
        </div>
    </div>

                <!-- Scroll position carried across the postback by Scripts/tripway-scroll.js, so
                 adding or removing a stop does not throw the viewport back to the top. -->
            <input type="hidden" runat="server" id="__twScroll" />
            <asp:HiddenField ID="hfStops" runat="server" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-scroll.js") %>"></script>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script>
        (function () {
            'use strict';

            // Must agree with InitialPlaceRows / MaxPlaceRows in PackageCreate.aspx.cs.
            var MIN_STOPS = 2;
            var MAX_STOPS = 12;
            var NAME_HINT = 'Stop name — filled in from the map, or type your own';

            var listEl = document.getElementById('stopsList');
            var mapEl = document.getElementById('mapPlaces');
            if (!listEl) return;

            var hfStops = document.getElementById('<%= hfStops.ClientID %>');
            var countEl = document.getElementById('<%= litStopCount.ClientID %>');
            var hintEl = document.getElementById('<%= litPickHint.ClientID %>');

            var map = null;
            if (mapEl && typeof L !== 'undefined') {
                map = L.map(mapEl).setView([16.890, 97.633], 12);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19 }).addTo(map);
            }

            // fit:false is essential. The route helper reframes the map on every set() unless
            // told not to, which fought with the click handler and made picking feel dead.
            // The no-op fallback keeps coordinate picking working if the script 404s.
            var preview = (window.TripRoute && TripRoute.create)
                ? TripRoute.create(map, [], { color: '#2563eb', weight: 3, opacity: 0.85, fit: false })
                : { set: function () {} };

            // Markers are keyed by a per-row key that never changes, not by the row's
            // position: removing stop 2 renumbers everything below it, and a marker map
            // keyed by position would then move a pin onto a different stop.
            var markers = {};
            var nextKey = 1;
            var activeRow = null;

            /* A pristine copy of a row, taken once and kept. addRow used to clone whichever
               row it found first, which broke on the rebuild path below: that empties the
               list before adding anything, so there was nothing left to clone and the whole
               stops list came back empty after a failed validation. */
            var rowTemplate = null;

            function allRows() {
                return Array.prototype.slice.call(listEl.querySelectorAll('[data-row]'));
            }

            function rowOf(rowIndex) {
                return listEl.querySelector('[data-row="' + rowIndex + '"]');
            }

            /* The textboxes are found by the data-field marker rather than by their generated
               id: inside a Repeater on a Master page that id ends with the naming-container
               separator ("$txtLat"), so an id$="_txtLat" selector matched nothing and the
               picked coordinates never reached the inputs. */
            function fieldIn(row, field) {
                if (!row) return null;
                return row.querySelector('input[data-field="' + field + '"]');
            }

            function input(rowIndex, field) {
                return fieldIn(rowOf(rowIndex), field);
            }

            /* Stamps each textbox with the field it holds. Every part of this script finds a
               textbox by that marker, so this has to run before anything else reads one:
               without it fieldIn() returns null and every map click is ignored in silence.

               The ids are not used, because inside a Repeater on a Master page they end with
               the naming-container separator ("$txtLat"), which is why an id$="_txtLat"
               selector once matched nothing at all. */
            var FIELDS = [['txtPlaceName', 'name'], ['txtLat', 'lat'], ['txtLng', 'lng']];

            function stampFields(row) {
                if (!row) return;
                FIELDS.forEach(function (pair) {
                    var el = row.querySelector('input[id$="' + pair[0] + '"]') ||
                             row.querySelector('input[name$="' + pair[0] + '"]');
                    if (el) el.setAttribute('data-field', pair[1]);
                });
            }

            function stampAll() {
                allRows().forEach(stampFields);
            }

            function placeName(rowIndex) {
                var el = input(rowIndex, 'name');
                return el ? el.value : '';
            }

            function coordOf(row) {
                var lat = fieldIn(row, 'lat'), lng = fieldIn(row, 'lng');
                if (!lat || !lng) return null;
                var la = parseFloat(lat.value), ln = parseFloat(lng.value);
                if (isNaN(la) || isNaN(ln)) return null;
                return [la, ln];
            }

            function coord(rowIndex) {
                return coordOf(rowOf(rowIndex));
            }

            // ---------------------------------------------------------- row management
            // Add and Remove are deliberately NOT postbacks. Posting back replaced the whole
            // document, so the page appeared to reload and jumped to the top every time a
            // stop was added or deleted. Nothing here touches the server; Save posts once.

            /* A clone carries the ids and names of the row it came from, which would produce
               duplicate DOM ids and make the posted fields ambiguous. */
            function stripIds(el) {
                el.removeAttribute('id');
                el.removeAttribute('name');
                var tagged = el.querySelectorAll('[id], [name]');
                for (var i = 0; i < tagged.length; i++) {
                    tagged[i].removeAttribute('id');
                    tagged[i].removeAttribute('name');
                }
            }

            function setValues(row, name, lat, lng) {
                var f = { name: name || '', lat: lat || '', lng: lng || '' };
                Object.keys(f).forEach(function (k) {
                    var el = fieldIn(row, k);
                    if (el) el.value = f[k];
                });
            }

            function addRow(values) {
                if (allRows().length >= MAX_STOPS) return null;
                if (!rowTemplate) return null;

                var row = rowTemplate.cloneNode(true);
                stripIds(row);
                stampFields(row);
                row.setAttribute('data-key', String(nextKey++));
                setValues(row, values && values.name, values && values.lat, values && values.lng);
                listEl.appendChild(row);
                renumber();
                return row;
            }

            function removeRow(row) {
                // Stop 1 is the start of the tour, so it has no remove button and the last
                // two stops are never removable either.
                if (!row) return;
                var rows = allRows();
                if (rows.length <= MIN_STOPS) return;
                if (rows.indexOf(row) === 0) return;

                if (markers[row.getAttribute('data-key')]) {
                    if (map) map.removeLayer(markers[row.getAttribute('data-key')]);
                    delete markers[row.getAttribute('data-key')];
                }

                var wasActive = activeRow === row.getAttribute('data-row');
                row.parentNode.removeChild(row);
                renumber();

                if (wasActive) select('1', false);
                draw();
            }

            /* Numbering is display only and restarts from 1, so the badge, the remove
               buttons and the hint all have to be refreshed after any change. */
            function renumber() {
                var rows = allRows();
                rows.forEach(function (row, i) {
                    row.setAttribute('data-row', String(i + 1));
                    var rm = row.querySelector('[data-remove-row]');
                    if (rm) rm.setAttribute('data-remove-row', String(i + 1));
                    // The pin button carries the stop number too. A clone inherited the
                    // number of the row it was copied from, so without this every added row's
                    // pin button pointed back at stop 1 and pinned to the wrong place.
                    var pick = row.querySelector('[data-pick-row]');
                    if (pick) pick.setAttribute('data-pick-row', String(i + 1));
                    // The number in the badge is server-rendered text, so without this it
                    // would keep showing the position the row had when it was added.
                    var badge = row.querySelector('[data-stop-badge]');
                    if (badge) badge.textContent = String(i + 1);
                });

                if (countEl) countEl.textContent = rows.length === 1 ? '1 stop' : rows.length + ' stops';

                var add = document.getElementById('btnAddStop');
                if (add) {
                    var full = rows.length >= MAX_STOPS;
                    add.disabled = full;
                    add.title = full ? 'A package can have at most ' + MAX_STOPS + ' stops.' : '';
                }

                var first = rows[0];
                if (first) {
                    var rm1 = first.querySelector('[data-remove-row]');
                    if (rm1) rm1.style.display = 'none';
                }
                rows.forEach(function (row, i) {
                    if (i === 0) return;
                    var r = row.querySelector('[data-remove-row]');
                    if (r) r.style.display = '';
                });

                if (activeRow !== null && !rowOf(activeRow)) activeRow = null;
                updateHint(activeRow);
            }

            // ---------------------------------------------------------- naming
            // Reverse geocoding, following Customer/BookTrip.aspx: a small cache so repeated
            // picks do not hammer the public Nominatim instance, and a token per row so a
            // slow reply cannot land after a newer one.
            var nameToken = {};
            var placeCache = {};

            // Nominatim is normally a second or two. Five seconds is long enough that a slow
            // lookup still supplies the real name, and short enough that a dead request is not
            // mistaken for a map that stopped working.
            var LOOKUP_TIMEOUT = 5000;

            /* The only address the page needs, kept in one place because it is the single
               thing that has to change when the lookup service is unreachable. An offline
               server, a locked-down network or a blocked host all show up as this one call
               failing, and nothing here should have to be edited to point somewhere else. */
            var GEOCODER = 'https://nominatim.openstreetmap.org/reverse';

            function placeCacheKey(lat, lng) { return Number(lat).toFixed(4) + ',' + Number(lng).toFixed(4); }

            function reverseLookup(lat, lng, cb) {
                var key = placeCacheKey(lat, lng);
                if (placeCache[key] !== undefined) { cb(placeCache[key]); return; }
                var url = GEOCODER + '?format=json&zoom=14&addressdetails=1'
                    + '&lat=' + encodeURIComponent(lat) + '&lon=' + encodeURIComponent(lng);
                /* fetch only rejects on a network error, never on a server that never answers.
                   A hung or blocked request would otherwise leave the field reading "Looking up
                   the name..." for good with nothing inserted, which is indistinguishable from a
                   broken page. The race settles the callback so the admin is told to type a name. */
                var settled = false;
                var done = function (name, why) {
                    if (settled) return;
                    settled = true;
                    clearTimeout(timer);
                    /* Coordinates are already saved by this point and do not depend on the
                       name, so a failed lookup is logged rather than shown. Putting a message in
                       the field would mark every stop, and an admin cannot act on it: the fix
                       is on the network or the endpoint, not on the form. */
                    if (why && typeof console !== 'undefined' && console.warn) {
                        console.warn('TripWay: could not look up a stop name (' + why + '). '
                            + 'The point was still saved; the name can be typed.', lat + ', ' + lng);
                    }
                    cb(name);
                };
                var timer = setTimeout(function () { done('', 'timed out after ' + LOOKUP_TIMEOUT + 'ms'); }, LOOKUP_TIMEOUT);

                fetch(url)
                    .then(function (r) {
                        if (!r.ok) throw new Error('HTTP ' + r.status);
                        return r.json();
                    })
                    .then(function (j) { placeCache[key] = shortPlaceName(j); done(placeCache[key]); })
                    .catch(function (err) { done('', err && err.message ? err.message : 'request failed'); });
            }

            // display_name is a long comma-separated list, which makes a poor stop name, so the
            // most specific single component is preferred and the full string is the last resort.
            function shortPlaceName(j) {
                if (!j) return '';
                var a = j.address || {};
                var parts = [a.road, a.neighbourhood, a.quarter, a.suburb, a.village, a.town,
                             a.city, a.municipality, a.county];
                for (var i = 0; i < parts.length; i++) {
                    if (parts[i]) return String(parts[i]);
                }
                if (j.display_name) return String(j.display_name).split(',')[0].trim();
                return '';
            }

            /* Keeps the name in step with the point. A name the geocoder supplied is marked
               with data-auto and is refreshed whenever the coordinates move, so picking a new
               spot does not leave the previous spot's name behind. Anything the admin typed
               is left alone for good, which is what makes the field editable. */
            function fillPlaceName(rowIndex, lat, lng) {
                var row = rowOf(rowIndex);
                var el = fieldIn(row, 'name');
                if (!el) return;

                // Only a name we filled in ourselves may be replaced.
                if (el.value.trim().length > 0 && el.dataset.auto !== '1') return;

                var key = row.getAttribute('data-key');
                var token = (nameToken[key] || 0) + 1;
                nameToken[key] = token;

                el.placeholder = 'Looking up the name...';
                reverseLookup(lat, lng, function (name) {
                    if (nameToken[key] !== token) return;
                    el.placeholder = NAME_HINT;
                    if (!name) return;
                    // The admin may have started typing while the lookup was in flight.
                    if (el.value.trim().length > 0 && el.dataset.auto !== '1') return;
                    el.value = name;
                    el.dataset.auto = '1';
                    updateHint(rowIndex);
                });
            }

            // ---------------------------------------------------------- drawing
            function draw() {
                var pts = [];
                allRows().forEach(function (row) {
                    var c = coordOf(row);
                    if (c) pts.push({ key: row.getAttribute('data-key'), latlng: c });
                });
                preview.set(pts.map(function (p) { return p.latlng; }));
                syncMarkers(pts);
                return pts;
            }

            /* Markers are reconciled rather than rebuilt. Rebuilding on every keystroke would
               destroy a marker the admin is in the middle of dragging. */
            function syncMarkers(pts) {
                var seen = {};
                pts.forEach(function (p) {
                    seen[p.key] = true;
                    var m = markers[p.key];
                    if (!m) {
                        if (!map) return;
                        m = L.marker(p.latlng, { draggable: true }).addTo(map);
                        m.bindTooltip('#' + p.key, { direction: 'top', offset: [0, -28] });
                        m.on('dragend', function (e) {
                            var row = rowForKey(p.key);
                            if (!row) return;
                            var ll = e.target.getLatLng();
                            setCoord(row.getAttribute('data-row'), ll.lat, ll.lng);
                        });
                        markers[p.key] = m;
                    } else {
                        var cur = m.getLatLng();
                        if (cur.lat !== p.latlng[0] || cur.lng !== p.latlng[1]) m.setLatLng(p.latlng);
                    }
                });

                Object.keys(markers).forEach(function (k) {
                    if (seen[k]) return;
                    if (map) map.removeLayer(markers[k]);
                    delete markers[k];
                });
            }

            function rowForKey(key) {
                var found = listEl.querySelector('[data-key="' + key + '"]');
                return found || null;
            }

            function fitRoute(pts) {
                if (!map || !pts.length) return;
                var b = L.latLngBounds(pts.map(function (p) { return p.latlng; }));
                map.fitBounds(b.pad(0.25));
            }

            // ---------------------------------------------------------- selection
            function setCoord(rowIndex, lat, lng) {
                var row = rowOf(rowIndex);
                var f = { lat: fieldIn(row, 'lat'), lng: fieldIn(row, 'lng') };
                if (!f.lat || !f.lng) return;

                var isNewPin = !row.__hadPin;
                row.__hadPin = true;
                f.lat.value = Number(lat).toFixed(6);
                f.lng.value = Number(lng).toFixed(6);

                var pts = draw();
                if (isNewPin) fitRoute(pts);
                fillPlaceName(rowIndex, lat, lng);
            }

            function select(rowIndex, panTo) {
                if (rowIndex === null || rowIndex === undefined) return;
                activeRow = String(rowIndex);

                allRows().forEach(function (row) {
                    var on = row.getAttribute('data-row') === activeRow;
                    row.classList.toggle('border-blue-400', on);
                    row.classList.toggle('ring-2', on);
                    row.classList.toggle('ring-blue-100', on);
                    row.classList.toggle('bg-blue-50/40', on);
                });

                updateHint(activeRow);

                // Panning is skipped when the caller is already placing a pin at the
                // centre of the view.
                if (panTo === false) return;
                var pt = coord(activeRow);
                if (pt && map) map.setView(pt, Math.max(map.getZoom(), 14));
            }

            function updateHint(rowIndex) {
                if (!hintEl || rowIndex === null || rowIndex === undefined) return;
                var name = placeName(rowIndex).trim();
                hintEl.textContent = 'Click the map to place stop ' + rowIndex
                    + (name ? ' (' + name + ')' : '') + '.';
            }

            // ---------------------------------------------------------- events
            // Delegated, so rows added later are wired without rebinding anything.
            listEl.addEventListener('click', function (e) {
                var rm = e.target.closest('[data-remove-row]');
                if (rm) {
                    e.preventDefault(); e.stopPropagation();
                    removeRow(rm.closest('[data-row]'));
                    return;
                }
                var pick = e.target.closest('[data-pick-row]');
                if (pick) {
                    e.preventDefault(); e.stopPropagation();
                    select(pick.getAttribute('data-pick-row'));
                    if (mapEl) mapEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
                    return;
                }
                var row = e.target.closest('[data-row]');
                if (row) select(row.getAttribute('data-row'));
            });

            listEl.addEventListener('focusin', function (e) {
                if (!e.target.matches('input[data-field]')) return;
                var row = e.target.closest('[data-row]');
                if (row) select(row.getAttribute('data-row'));
            });

            listEl.addEventListener('input', function (e) {
                var el = e.target;
                if (!el.matches('input[data-field]')) return;

                if (el.dataset.field === 'name') {
                    // Typed by hand from here on, so the geocoder must stop replacing it.
                    if (el.dataset.auto) delete el.dataset.auto;
                    updateHint(activeRow);
                    return;
                }
                draw();
            });

            var addBtn = document.getElementById('btnAddStop');
            if (addBtn) addBtn.addEventListener('click', function () { addRow(); });

            if (map) {
                map.on('click', function (e) {
                    if (!activeRow) {
                        var first = allRows().find(function (r) {
                            var el = fieldIn(r, 'name');
                            return el && el.value.trim().length > 0;
                        });
                        var fallback = allRows()[0];
                        activeRow = first ? first.getAttribute('data-row')
                                           : (fallback ? fallback.getAttribute('data-row') : null);
                    }
                    if (!activeRow) return;

                    // Order matters. Selecting first re-centred the map on the stop's previous
                    // pin, so the click appeared to be ignored. Pin first, then highlight
                    // without moving the camera.
                    setCoord(activeRow, e.latlng.lat, e.latlng.lng);
                    select(activeRow, false);
                });
            }

            var useLoc = document.getElementById('btnUseMyLocation');
            if (useLoc && map) {
                useLoc.addEventListener('click', function () {
                    if (!navigator.geolocation) return;
                    navigator.geolocation.getCurrentPosition(function (pos) {
                        var row = activeRow ? rowOf(activeRow) : allRows()[0];
                        if (!row) return;
                        setCoord(row.getAttribute('data-row'), pos.coords.latitude, pos.coords.longitude);
                        select(row.getAttribute('data-row'), true);
                    });
                });
            }

            // ---------------------------------------------------------- save hand-off
            /* The stops travel to the server in one hidden field rather than as a set of
               server controls per row, which is what allowed Add and Remove to stay off the
               server entirely. encodeURIComponent escapes the field separator; "~" is left
               alone by it, so it is escaped by hand. */
            function encodeField(v) { return encodeURIComponent(v).replace(/~/g, '%7E'); }

            function buildPayload() {
                return allRows().map(function (row) {
                    return ['name', 'lat', 'lng'].map(function (f) {
                        var el = fieldIn(row, f);
                        return encodeField(el ? el.value : '');
                    }).join('|');
                }).join('~');
            }

            if (hfStops) {
                document.addEventListener('submit', function () {
                    hfStops.value = buildPayload();
                });
            }

            // After a postback (a failed validation, say) the server re-renders its own blank
            // rows, so the typed stops are rebuilt from the payload.
            // ---------------------------------------------------------- start
            // Order matters. The rows are stamped first, then the template is captured, then
            // the rebuild runs: the rebuild empties the list and addRow clones from the
            // template, so both steps depend on the markers already being in place.
            stampAll();

            var firstRow = listEl.querySelector('[data-row]');
            if (firstRow) {
                rowTemplate = firstRow.cloneNode(true);
                stripIds(rowTemplate);
                // stripIds removes name as well as id, and with it the only handle left for
                // stamping, so the clone is marked again from the same list.
                stampFields(rowTemplate);
                // The template is a blank row, never a copy of what the first stop holds,
                // so a new stop cannot arrive pre-filled with the first stop's name.
                setValues(rowTemplate, '', '', '');
                var badge = rowTemplate.querySelector('[data-stop-badge]');
                if (badge) badge.textContent = '';
            }

            var sent = hfStops ? String(hfStops.value || '') : '';
            if (sent) {
                listEl.innerHTML = '';
                sent.split('~').forEach(function (rec) {
                    if (!rec) return;
                    var p = rec.split('|');
                    addRow({ name: decodeURIComponent(p[0] || ''),
                             lat: decodeURIComponent(p[1] || ''),
                             lng: decodeURIComponent(p[2] || '') });
                });
            }

            allRows().forEach(function (row) {
                if (!row.getAttribute('data-key')) row.setAttribute('data-key', String(nextKey++));
            });
            renumber();
            draw();
            select('1', false);
        })();
    </script>
</asp:Content>
