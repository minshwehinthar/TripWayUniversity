<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TripRequests.aspx.cs" Inherits="TripWay.Driver.TripRequestsPage" MasterPageFile="~/Site.Master" %>
<%@ MasterType VirtualPath="~/Site.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="space-y-6">
        <div class="flex flex-wrap items-end justify-between gap-3">
            <div>
                <h1 class="text-xl font-bold text-gray-900">Trip Requests</h1>
                <p class="text-sm text-gray-400">New jobs matching your vehicle appear here in real time.</p>
            </div>
            <div class="flex items-center gap-2">
                <a href="ActiveTrip.aspx" class="tw-btn-outline">My Active Trip</a>
                <button type="button" onclick="refreshNow()" class="tw-btn-outline">Refresh</button>
            </div>
        </div>

        <asp:Panel ID="pnlKycBanner" runat="server" Visible="false" CssClass="p-4 rounded-xl bg-amber-50 border border-amber-200 flex items-center gap-3">
            <span class="size-10 rounded-xl bg-amber-500 text-white flex items-center justify-center font-bold">!</span>
            <div>
                <p class="text-sm font-bold text-amber-900">Your KYC status is <asp:Label ID="lblKycState" runat="server" />.</p>
                <p class="text-xs text-amber-700">You can only accept trips after an admin approves your documents.</p>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlBusy" runat="server" Visible="false" CssClass="p-4 rounded-xl bg-blue-50 border border-blue-200 flex items-center gap-3">
            <span class="size-10 rounded-xl bg-blue-600 text-white flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-5"><path stroke-linecap="round" stroke-linejoin="round" d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12"/></svg></span>
            <div>
                <p class="text-sm font-bold text-blue-900">You already have an active trip.</p>
                <p class="text-xs text-blue-700">Finish your current trip before accepting new requests.</p>
            </div>
        </asp:Panel>

        <div id="pnlLoading" class="bg-white rounded-2xl shadow-sm p-10 text-center text-gray-400">Listening for new trip requests…<p id="pollErr" class="hidden mt-4 text-sm font-semibold text-rose-600"></p></div>

        <div id="requestList" class="grid md:grid-cols-2 gap-4"></div>
        <div id="pnlEmpty" class="hidden bg-white rounded-2xl shadow-sm p-10 text-center text-gray-400">No trip requests right now. New jobs will appear automatically.</div>
    </div>

    <%-- Leaflet and the shared OSRM helper. No map is shown on this page: they are here so the
         cards can be given real road distance and drive time, which a straight line cannot
         produce. --%>
    <script src="<%= ResolveUrl("~/Scripts/leaflet.js") %>"></script>
    <link rel="stylesheet" href="<%= ResolveUrl("~/Styles/leaflet/leaflet.css") %>" />
    <script src="<%= ResolveUrl("~/Scripts/tripway-route.js") %>"></script>
    <script>
        var API = '<%= ResolveUrl("~/Handlers/TripApi.ashx") %>';
        var DETAIL_URL = '<%= ResolveUrl("~/Driver/RequestDetail.aspx") %>';
        var AVG_SPEED_KMH = 25, ROAD_FACTOR = 1.3, DEFAULT_ETA = 10;
        var haveLocation = false, myLat = 0, myLng = 0;
        var pollFails = 0;
        var lastRequests = {};

        // ---- road distance / drive time on every card ------------------------
        // The cards rebuild every 5s from the poll, so these numbers cannot come from a
        // request per card per poll: that is one OSRM call every 5 seconds per open tab,
        // against a free public service that rate-limits. Instead one off-screen map does the
        // routing and answers are cached, so a re-render is a dictionary lookup.
        var roadCache = {}, roadPending = {}, roadFailed = {}, roadMap = null;
        var ROAD_TTL_MS = 60000;

        function notePollIssue(msg) {
            pollFails++;
            var e = document.getElementById('pollErr');
            if (e && pollFails === 4) { e.textContent = 'Still waiting… ' + (msg || ''); e.classList.remove('hidden'); }
        }
        function clearPollIssue() {
            var e = document.getElementById('pollErr');
            if (e) e.classList.add('hidden');
            pollFails = 0;
        }

        function esc(s) { if (s == null) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;'); }
        function fmtKs(v) { return 'MMK ' + Number(v).toLocaleString('en-US'); }
        function hav(a, b) {
            var R = 6371, dLat = (b[0]-a[0])*Math.PI/180, dLng = (b[1]-a[1])*Math.PI/180;
            var s = Math.sin(dLat/2)*Math.sin(dLat/2) + Math.cos(a[0]*Math.PI/180)*Math.cos(b[0]*Math.PI/180)*Math.sin(dLng/2)*Math.sin(dLng/2);
            return R*(2*Math.atan2(Math.sqrt(s), Math.sqrt(1-s)));
        }
        function clampEta(m) {
            m = Math.round(Number(m) || 0);
            if (m < 1) m = 1;
            if (m > 180) m = 180;
            return m;
        }
        // Same formula as TripHelper.EstimateArrivalMinutes: road factor over an average city speed.
        function autoEta(km) { return clampEta(Math.ceil((km * ROAD_FACTOR) / AVG_SPEED_KMH * 60)); }
        function distanceKm(r) { return haveLocation ? hav([myLat, myLng], [r.lat, r.lng]) : null; }
        function etaFor(r) {
            var km = distanceKm(r);
            if (km !== null) return autoEta(km);
            if (r.etaSuggested > 0) return r.etaSuggested;
            return DEFAULT_ETA;
        }
        /* ---- road routing ---------------------------------------------------
           Coords are rounded to 3 decimals (~110m) for the cache key so ordinary GPS jitter
           does not turn into a fresh OSRM call on every 5s poll, while a driver who has
           genuinely moved still gets a new route. */
        function roadKey(r) {
            return [myLat.toFixed(3), myLng.toFixed(3),
                    Number(r.lat).toFixed(3), Number(r.lng).toFixed(3)].join('|');
        }

        // Leaflet needs a sized element to exist as a map even when nothing is drawn on it.
        // This one is parked off-screen and every line is cleared as soon as it reports.
        function roadMapFor() {
            if (roadMap) return roadMap;
            if (typeof L === 'undefined' || typeof TripRoute === 'undefined') return null;
            var host = document.createElement('div');
            host.style.cssText = 'position:absolute;left:-9999px;top:0;width:320px;height:320px;';
            document.body.appendChild(host);
            roadMap = L.map(host, { zoomControl: false, attributionControl: false, interactive: false });
            return roadMap;
        }

        function roadFor(r) {
            if (!haveLocation) return null;
            var hit = roadCache[roadKey(r)];
            return hit && hit.km != null && (Date.now() - hit.at) < ROAD_TTL_MS ? hit : null;
        }

        // Local clock, because this number is for the driver looking at their own handset.
        function clockAfter(minutes) {
            try {
                return new Date(Date.now() + minutes * 60000)
                    .toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
            } catch (e) { return ''; }
        }

        // Returns the cached answer, or null when one has to be fetched. Marks the key pending
        // synchronously so the paint pass right after this never flashes "unavailable" for a
        // request that is merely in flight.
        function requestRoad(r) {
            if (!haveLocation) return null;
            var toLat = Number(r.lat), toLng = Number(r.lng);
            if (!isFinite(toLat) || !isFinite(toLng)) return null;

            var known = roadFor(r);
            if (known) return known;

            var map = roadMapFor();
            var key = roadKey(r);
            if (!map || roadPending[key]) return null;
            /* A failure is remembered only until the TTL, not for the rest of the shift: one
               dropped request from a busy public server should not cost this pickup its road
               figures for the whole day, and retrying once a minute still cannot hammer it. */
            if (roadFailed[key] && (Date.now() - roadFailed[key]) < ROAD_TTL_MS) return null;
            roadPending[key] = true;

            var line = null;
            line = TripRoute.create(map, [[myLat, myLng], [toLat, toLng]], {
                color: '#1d4ed8', weight: 3, opacity: 0.9, fit: false, guide: false,
                onRoad: function (info) {
                    delete roadPending[key];
                    delete roadFailed[key];
                    roadCache[key] = { km: info.km, minutes: Math.max(1, info.minutes), at: Date.now() };
                    if (line) line.clear();
                    paintRoad();
                },
                onFail: function () {
                    delete roadPending[key];
                    roadFailed[key] = Date.now();
                    paintRoad();
                }
            });
            return null;
        }

        /* What the card shows in the road strip. Falls back to the straight-line estimate, and
           says so, rather than either showing nothing or passing off a ruler distance as a
           road distance. */
        function roadText(r) {
            var road = requestRoad(r);
            if (road) {
                var when = clockAfter(road.minutes);
                return '<b>' + road.km.toFixed(1) + ' km</b> along the road'
                     + ' &middot; ' + road.minutes + ' min drive'
                     + (when ? ' &middot; arrive by ' + when : '');
            }
            if (!haveLocation) return 'Waiting for your location to route';
            var km = distanceKm(r);
            if (km === null) return 'Pickup has no coordinates yet';
            var key = roadKey(r);
            if (roadPending[key]) return 'Routing along the road\u2026';
            return '\u2248 ' + km.toFixed(1) + ' km straight \u00b7 ~' + etaFor(r)
                 + ' min (road routing unavailable)';
        }

        // Called after every render and after every routing answer. Requests first so the text
        // sees the just-set pending flag, then paints.
        function paintRoad() {
            for (var id in lastRequests) {
                if (!Object.prototype.hasOwnProperty.call(lastRequests, id)) continue;
                var cell = document.querySelector('[data-road="' + id + '"]');
                if (cell) cell.innerHTML = roadText(lastRequests[id]);
            }
        }

        function avatar(r, extra) {
            var cls = 'size-11 rounded-full object-cover shrink-0 ring-2 ring-white ' + (extra || '');
            if (r.customerPhoto) return '<img src="' + esc(r.customerPhoto) + '" alt="" class="' + cls + '" onerror="this.replaceWith(twSkeletonAvatar())" />';
            return twSkeletonAvatar();
        }
        /* Keeps the photo's size and ring, so the row does not jump when there is no
           photo to show. */
        function twSkeletonAvatar() {
            return '<span class="tw-skeleton tw-skeleton-avatar size-11 shrink-0 ring-2 ring-white"></span>';
        }

        function refreshNow() {
            fetch(API + '?action=requests', { credentials: 'same-origin' })
                .then(function (r) { return r.json(); })
                .then(function (j) {
                    if (!j.ok) { notePollIssue(j.message || j.error); return; }
                    clearPollIssue();
                    render(j);
                })
                .catch(function () { notePollIssue('Could not reach the server.'); });
        }

        function render(j) {
            var list = j.requests || [];
            var listBox = document.getElementById('requestList');
            if (j.kyc) {
                document.getElementById('pnlLoading').classList.add('hidden');
                listBox.innerHTML = '';
                document.getElementById('pnlEmpty').classList.remove('hidden');
                return;
            }

            lastRequests = {};
            for (var i = 0; i < list.length; i++) lastRequests[list[i].trip] = list[i];

            document.getElementById('pnlLoading').classList.add('hidden');
            if (list.length === 0) {
                listBox.innerHTML = '';
                document.getElementById('pnlEmpty').classList.remove('hidden');
                return;
            }
            document.getElementById('pnlEmpty').classList.add('hidden');

            var h = '';
            for (var i2 = 0; i2 < list.length; i2++) {
                var r = list[i2];
                var km = distanceKm(r);
                h += '<div class="tw-card" data-trip="' + r.trip + '">';

                h += '<div class="flex items-start gap-3 mb-3">' + avatar(r);
                h += '<div class="min-w-0 flex-1"><div class="font-bold text-gray-900 truncate">' + esc(r.customer) + '</div>';
                h += '<div class="text-xs text-gray-400 flex flex-wrap items-center gap-x-2">' +
                     '<span>' + esc(r.customerPhone || 'No phone') + '</span>' +
                     (r.customerGender ? '<span>· ' + esc(r.customerGender) + '</span>' : '') +
                     (r.customerSince ? '<span>· Member since ' + esc(r.customerSince) + '</span>' : '') +
                     '</div></div>';
                h += '<div class="text-right"><div class="text-lg font-bold text-gray-900">' + fmtKs(r.fare) + '</div>' +
                     '<div class="text-xs text-gray-400">' + esc(r.payment || 'Cash') + '</div></div></div>';

                h += '<div class="flex flex-wrap items-center gap-1.5 mb-3">' +
                     '<span class="tw-badge text-xs">' + esc(r.service) + '</span>' +
                     '<span class="tw-badge text-xs">' + esc(r.vehicle) + '</span>' +
                     (r.package ? '<span class="tw-badge text-xs">' + esc(r.package) + '</span>' : '') +
                     '<span class="tw-badge text-xs">#' + r.trip + '</span></div>';

                h += '<div class="space-y-1 text-sm text-gray-600 mb-3">' +
                     '<div class="flex items-start gap-2"><span class="size-2.5 rounded-full bg-emerald-500 shrink-0 mt-1"></span><span class="min-w-0">' + esc(r.pickup) + '</span></div>' +
                     '<div class="flex items-start gap-2"><span class="size-2.5 rounded-full bg-rose-500 shrink-0 mt-1"></span><span class="min-w-0">' + esc(r.dropoff || '—') + '</span></div>' +
                     '</div>';

                // Road figures land here. Painted by paintRoad() once the strip is in the DOM.
                h += '<div class="flex flex-wrap items-center gap-x-1.5 rounded-lg bg-blue-50 px-2.5 py-1.5 text-xs font-semibold text-blue-700 mb-3" data-road="' + r.trip + '"></div>';

                h += '<div class="flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-gray-400 mb-3">' +
                     '<span>⏱ ' + esc(r.requestedAgo || '') + '</span>' +
                     '<span>' + (km !== null ? '\u2248 ' + km.toFixed(1) + ' km straight' : '📍 tap details for the map') + '</span>' +
                     (r.stops > 2 ? '<span>' + (r.stops - 2) + ' stops</span>' : '') +
                     (r.tripKm > 0 ? '<span>Trip ' + Number(r.tripKm).toFixed(1) + ' km</span>' : '') +
                     '</div>';

                h += '<div class="flex items-center justify-between gap-2 pt-3 border-t border-gray-100">' +
                     '<a href="' + DETAIL_URL + '?id=' + r.trip + '" class="tw-btn-outline" title="View full request details">View Detail</a>' +
                     '<button type="button" data-job="' + r.trip + '" onclick="openAcceptDialog(' + r.trip + ')" class="tw-btn-primary">Accept Job</button>' +
                     '</div></div>';
            }
            listBox.innerHTML = h;
            paintRoad();
        }

        function openAcceptDialog(tripId) {
            var r = lastRequests[tripId];
            if (!r) return;
            var km = distanceKm(r);
            var eta = etaFor(r);
            // The card may already hold a road answer by the time this dialog opens; prefer it
            // over the ruler estimate so the two screens do not disagree about the same trip.
            var road = roadFor(r);
            var etaLine = road
                ? 'Road route: about ' + road.minutes + ' min (' + road.km.toFixed(1)
                  + ' km along the road).'
                : (km !== null
                    ? 'Straight-line estimate: about ' + eta + ' min (' + km.toFixed(1)
                      + ' km as the crow flies at ' + AVG_SPEED_KMH + ' km/h).'
                    : (r.etaSuggested > 0
                        ? 'Estimate from your last location: about ' + r.etaSuggested + ' min. Adjust it if you know better.'
                        : 'We could not read your location, so confirm the minutes manually.'));
            var html =
                '<div class="flex items-start gap-3 mb-5">' + avatar(r, 'size-12') +
                '<div><h3 class="text-lg font-bold text-gray-900">' + esc(r.customer) + '</h3>' +
                '<p class="text-sm text-gray-400 mt-0.5">' + esc(r.service) + ' · ' + esc(r.vehicle) + ' · #' + r.trip + '</p></div></div>' +
                '<div class="tw-detail-grid mb-4">' +
                '<div><div class="tw-detail-label">Pickup</div><div class="tw-detail-value">' + esc(r.pickup) + '</div></div>' +
                '<div><div class="tw-detail-label">Destination</div><div class="tw-detail-value">' + esc(r.dropoff || '—') + '</div></div>' +
                '<div><div class="tw-detail-label">Fare</div><div class="tw-detail-value font-bold text-gray-900">' + fmtKs(r.fare) + '</div></div>' +
                '<div><div class="tw-detail-label">Payment</div><div class="tw-detail-value">' + esc(r.payment || 'Cash') + '</div></div>' +
                '</div>' +
                '<div class="rounded-xl bg-blue-50 border border-blue-200 p-4">' +
                '<label class="tw-detail-label mb-1 block" for="etaInput">Time to reach the pickup point (minutes)</label>' +
                '<div class="flex items-center gap-2">' +
                '<button type="button" onclick="bumpEta(-1)" class="tw-btn-outline px-3">−</button>' +
                '<input id="etaInput" type="number" min="1" max="180" value="' + eta + '" class="tw-input text-center text-lg font-bold" data-autofocus />' +
                '<button type="button" onclick="bumpEta(1)" class="tw-btn-outline px-3">+</button>' +
                '</div>' +
                '<p class="text-xs text-blue-700 mt-2">' +
                etaLine +
                ' The customer sees this countdown on their Active Trip and Trip Detail pages, and as a record on their Trip History.</p>' +
                '<div class="flex justify-end gap-2 mt-4">' +
                '<button type="button" onclick="appCloseModal()" class="tw-btn-outline">Cancel</button>' +
                '<button type="button" onclick="acceptJob(' + tripId + ')" class="tw-btn-primary">Confirm &amp; Accept</button>' +
                '</div></div>';
            appOpenModal(html);
        }

        function bumpEta(step) {
            var el = document.getElementById('etaInput');
            if (el) el.value = clampEta(parseInt(el.value, 10) + step);
        }

        function acceptJob(tripId) {
            var el = document.getElementById('etaInput');
            var minutes = clampEta(el ? el.value : 10);
            var buttons = document.querySelectorAll('[data-job="' + tripId + '"]');
            for (var i = 0; i < buttons.length; i++) { buttons[i].disabled = true; buttons[i].classList.add('disabled:opacity-50'); }
            fetch(API + '?action=accept&trip=' + tripId + '&eta=' + minutes, { credentials: 'same-origin' })
                .then(function (r) { return r.json(); })
                .then(function (j) {
                    if (j.ok) {
                        appCloseModal();
                        window.location.href = 'ActiveTrip.aspx?trip=' + tripId;
                    } else {
                        appCloseModal();
                        TwToast.error(j.message || 'This job was just taken.');
                        refreshNow();
                    }
                })
                .catch(function () { refreshNow(); });
        }

        document.addEventListener('DOMContentLoaded', function () {
            refreshNow();
            setInterval(refreshNow, 5000);
            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (pos) {
                    haveLocation = true;
                    myLat = pos.coords.latitude;
                    myLng = pos.coords.longitude;
                    refreshNow();
                    // Route against the fresh fix without waiting for the next poll, so the
                    // cards fill in immediately instead of up to 5s later.
                    paintRoad();
                }, function () { });
            }
        });
    </script>
</asp:Content>
