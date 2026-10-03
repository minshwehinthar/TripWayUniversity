/*
 * TripMap - the one map every TripWay trip page draws with.
 *
 * Four pages each used to carry their own private copy of this drawing code, which is how
 * they slowly drifted apart: some showed the road distance, some drew the travelled GPS
 * trail as a fallback route line, some had no legend. The differences that actually matter
 * are options here, so the map looks and behaves the same everywhere again.
 *
 * Requires Leaflet and tripway-route.js to be loaded first.
 *
 * Usage:
 *   TripMap.render({
 *       el: 'mapActive',          // id of the map container
 *       path: P,                  // server trip JSON: { pickup, drop, stops, path }
 *       me: ME,                   // optional [lat, lng] - the driver's own position
 *       meLabel: 'You',           // text inside the driver pin
 *       driveToPickup: true,      // driver pages: also route the driver's approach leg
 *       roadColor: '#007AFF',
 *       roadTarget: 'spnRoad',    // optional span id that gets the "by road" summary
 *       zoom: 14,
 *       fallback: [16.890, 97.633]
 *   });
 *
 * Draws the pickup / stop / destination markers, the itinerary as real driving directions,
 * the route the vehicle has already driven, and the driver's position.
 */
(function (global) {
    'use strict';

    var TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    var DEFAULT_ZOOM = 14;
    var DEFAULT_FALLBACK = [16.890, 97.633];
    var DEFAULT_ROAD_COLOR = '#007AFF';
    var APPROACH_COLOR = '#1d4ed8';
    var TRAVELLED_COLOR = '#7c3aed';

    function dotIcon(html) {
        return L.divIcon({ className: '', html: html });
    }

    function endpointIcon(color) {
        return dotIcon('<span class="block size-4 rounded-full ' + color +
            ' border-2 border-white shadow"></span>');
    }

    function stopIcon(index) {
        return dotIcon('<span class="flex items-center justify-center size-5 rounded-full ' +
            'bg-blue-500 text-white text-[10px] font-bold border-2 border-white shadow">' +
            index + '</span>');
    }

    function meIcon(label) {
        return dotIcon('<span class="flex items-center justify-center size-5 rounded-full ' +
            'bg-gray-900 text-white text-[9px] font-bold border-2 border-white shadow">' +
            label + '</span>');
    }

    // "12.4 km by road · ~35m" - the line TripRoute's onRoad callback hands back.
    function formatRoad(info) {
        if (!info) return '';
        var km = typeof info.km === 'number' ? info.km : 0;
        var mins = info.minutes || 0;
        var drive = mins >= 60
            ? Math.floor(mins / 60) + 'h ' + (mins % 60) + 'm'
            : mins + 'm';
        return km.toFixed(1) + ' km by road · ~' + drive;
    }

    // Stops arrive as the full itinerary, so the middle entries are the real stops and
    // the two ends are the pickup and the destination.
    function stopPoints(stops) {
        var out = [];
        if (!stops || stops.length <= 2) return out;
        for (var i = 1; i < stops.length - 1; i++) out.push({ point: stops[i], index: i + 1 });
        return out;
    }

    // A package trip ends on its last place, so the destination and the final stop are the
    // same spot. Only one marker may be drawn there.
    function sameSpot(a, b) {
        if (!a || !b) return false;
        return Math.abs(a[0] - b[0]) < 0.000001 && Math.abs(a[1] - b[1]) < 0.000001;
    }

    // The order a car actually drives it: pickup -> stops -> destination.
    function itinerary(path) {
        var ordered = [];
        var stops = stopPoints(path.stops);
        if (path.pickup) ordered.push(path.pickup);
        for (var i = 0; i < stops.length; i++) ordered.push(stops[i].point);
        var lastStop = stops.length ? stops[stops.length - 1].point : null;
        if (path.drop && !sameSpot(path.drop, lastStop)) ordered.push(path.drop);
        return ordered;
    }

    function render(opts) {
        opts = opts || {};
        var el = document.getElementById(opts.el);
        if (!el || !global.L) return null;

        var path = opts.path || {};
        var map = L.map(el).setView(opts.fallback || DEFAULT_FALLBACK, opts.zoom || DEFAULT_ZOOM);
        L.tileLayer(TILE_URL, { maxZoom: 19 }).addTo(map);

        var pts = [];
        function keep(point) { if (point) pts.push(point); }

        if (path.pickup) {
            L.marker(path.pickup, { icon: endpointIcon('bg-emerald-500') }).addTo(map);
            keep(path.pickup);
        }
        var stops = stopPoints(path.stops);
        var lastStop = stops.length ? stops[stops.length - 1].point : null;
        if (path.drop && !sameSpot(path.drop, lastStop)) {
            L.marker(path.drop, { icon: endpointIcon('bg-rose-500') }).addTo(map);
            keep(path.drop);
        }
        for (var s = 0; s < stops.length; s++) {
            L.marker(stops[s].point, { icon: stopIcon(stops[s].index) }).addTo(map);
            keep(stops[s].point);
        }

        function onRoad(info) {
            if (opts.roadTarget) {
                var target = document.getElementById(opts.roadTarget);
                if (target) target.textContent = formatRoad(info);
            }
            if (typeof opts.onRoad === 'function') opts.onRoad(info);
        }

        // Real driving directions rather than a ruler line between the pins. TripRoute
        // keeps a dashed guide if every routing host fails, so there is always a line.
        TripRoute.create(map, itinerary(path), {
            color: opts.roadColor || DEFAULT_ROAD_COLOR,
            weight: 4,
            onRoad: onRoad
        });

        if (path.path && path.path.length > 1) {
            // Where the vehicle has already been, kept separate from the planned route.
            L.polyline(path.path, {
                color: TRAVELLED_COLOR, weight: 3, opacity: 0.7, dashArray: '4 6'
            }).addTo(map);
            for (var g = 0; g < path.path.length; g++) keep(path.path[g]);
        }

        if (opts.me) {
            L.marker(opts.me, { icon: meIcon(opts.meLabel || 'D') }).addTo(map);
            keep(opts.me);
            if (opts.driveToPickup && path.pickup) {
                // The road the driver still has to cover to reach the pickup.
                TripRoute.create(map, [opts.me, path.pickup], {
                    color: APPROACH_COLOR, weight: 3, opacity: 0.85, dashArray: '7 7', fit: false
                });
            }
        }

        if (pts.length) map.fitBounds(L.latLngBounds(pts).pad(0.25));
        return map;
    }

    global.TripMap = {
        render: render,
        formatRoad: formatRoad,
        itinerary: itinerary
    };
})(window);
