/*
 * TripRoute - shared "drive the real roads" helper for every TripWay map.
 *
 * Draws a line that follows the actual drivable road network between a set of points
 * instead of a straight ruler line. Routing is the free OSRM service, the same one the
 * Leaflet Routing Machine default router calls:
 *
 *   https://router.project-osrm.org/route/v1/driving/<lng,lat>;<lng,lat>?overview=full
 *
 * Path of a request:
 *   1. A direct OSRM/GeoJSON call, walking a list of hosts. This is the normal path and
 *      needs nothing beyond Leaflet itself.
 *   2. A Leaflet Routing Machine router is used instead when the page happens to load one.
 *      It is optional: the plugin is not referenced by any page, because its published
 *      builds expose incompatible OSRM routers (L.Routing.OSRM in v2, L.Routing.OSRMv1 in
 *      v3) and never shipped the L.Routing.osrmv1 name, so depending on it was dead code.
 *
 * A dashed straight line can be shown while the road line is loading (guide: true) and is
 * kept if every host fails, so a map is never left without a line.
 *
 * Every waypoint must be valid or no route is requested at all, so a malformed stop can
 * never produce a road line that quietly skips it.
 *
 * Usage:
 *   var route = TripRoute.create(map, [{lat:..,lng:..},{lat:..,lng:..}], {
 *       color: '#007AFF', weight: 5, guide: true,
 *       onRoad: function (info) { // info.km, info.minutes, info.coordinates }
 *   });
 *   route.set([...newPoints...]);   // redraw for changed points
 *   route.clear();                  // remove line + casing + guide
 *
 * Waypoints may be [lat, lng] arrays (what the trip JSON gives), { lat, lng } objects,
 * { lat, lon } GeoJSON, { latLng: L.LatLng } or L.LatLng instances - see normalizePoint.
 */
(function (global) {
    'use strict';

    var DEFAULT_COLOR = '#007AFF';
    var REQUEST_TIMEOUT_MS = 12000;

    // Tried in order. Both are free community servers - self-host OSRM, or add a keyed
    // provider here, before this carries production traffic.
    var ROUTERS = [
        { host: 'OSRM', url: 'https://router.project-osrm.org/route/v1/driving/' },
        { host: 'OSM DE', url: 'https://routing.openstreetmap.de/routed-car/route/v1/driving/' }
    ];

    function isRouteable(points) {
        var norm = normalizePoints(points);
        return !!norm && norm.length >= 2;
    }

    /*
     * Waypoints arrive in several shapes depending on the page, so they are all accepted:
     *   [lat, lng]                       the trip JSON the server builds
     *   { lat, lng } / { lat, lng, ... } the booking screen's own points
     *   { lat, lon }                     GeoJSON spelling
     *   { latLng: L.LatLng }             what Leaflet Routing Machine hands back
     *   L.LatLng                         a Leaflet LatLng instance
     *
     * normalizePoints is strict on purpose: if any waypoint is unusable the whole route is
     * rejected, because quietly dropping one would route the car straight past a stop. The
     * caller then keeps the dashed guide instead of showing a plausible but wrong road line.
     */
    function normalizePoint(p) {
        var lat, lng;

        if (p == null) return null;

        if (typeof p.lat === 'number' || typeof p.lat === 'string') {
            lat = Number(p.lat);
            lng = Number(p.lng != null ? p.lng : p.lon);
        } else if (Array.isArray(p) || (p.length === 2 && typeof p[0] !== 'undefined')) {
            lat = Number(p[0]);
            lng = Number(p[1]);
        } else if (p.latLng) {
            return normalizePoint(p.latLng);
        }

        if (lat == null || lng == null) return null;
        if (!isFinite(lat) || !isFinite(lng)) return null;
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;

        return { lat: lat, lng: lng };
    }

    function normalizePoints(points) {
        if (!points || !points.length) return null;
        var out = [];
        for (var i = 0; i < points.length; i++) {
            var n = normalizePoint(points[i]);
            // Strict: one unusable waypoint rejects the route so the caller can fall back to
            // the dashed guide, rather than routing the driver past a stop that was dropped.
            if (!n) return null;
            out.push(n);
        }
        return out.length ? out : null;
    }

    function toLatLngs(points) {
        var norm = normalizePoints(points) || [];
        var out = [];
        for (var i = 0; i < norm.length; i++) out.push([norm[i].lat, norm[i].lng]);
        return out;
    }

    function RoadLine(map, options) {
        this.map = map;
        this.opts = options || {};
        this.color = this.opts.color || DEFAULT_COLOR;
        this.weight = this.opts.weight || 5;
        this.opacity = this.opts.opacity != null ? this.opts.opacity : 0.9;
        this.dashArray = this.opts.dashArray || null;
        this.guide = this.opts.guide !== false;
        this.fit = this.opts.fit !== false;
        this.onRoad = this.opts.onRoad || null;
        this.onFail = this.opts.onFail || null;
        this.token = 0;
        this.line = null;
        this.casing = null;
        this.guideLine = null;
        this.xhr = null;
        this.timer = null;
    }

    RoadLine.prototype.set = function (points) {
        if (this.timer) { clearTimeout(this.timer); this.timer = null; }
        this.cancel();
        this.token++;

        // Normalised here so every later step works on one shape only.
        var norm = normalizePoints(points);
        if (!this.map || !norm || norm.length < 2) {
            this.removeLayers();
            if (this.onFail) this.onFail();
            return;
        }

        var latlngs = toLatLngs(norm);
        if (this.guide) {
            this.guideLine = L.polyline(latlngs, {
                color: '#94a3b8', weight: 3, opacity: 0.65, dashArray: '5 7'
            }).addTo(this.map);
        }
        if (this.fit) this.map.fitBounds(L.latLngBounds(latlngs).pad(0.25));

        var self = this;
        var token = this.token;
        // Debounced so dragging or tapping through several points does not spam the service.
        this.timer = setTimeout(function () { self.request(norm, token); }, 300);
    };

    RoadLine.prototype.cancel = function () {
        if (this.xhr) { this.xhr.abort(); this.xhr = null; }
    };

    RoadLine.prototype.removeLayers = function () {
        if (this.line) { this.map.removeLayer(this.line); this.line = null; }
        if (this.casing) { this.map.removeLayer(this.casing); this.casing = null; }
        if (this.guideLine) { this.map.removeLayer(this.guideLine); this.guideLine = null; }
    };

    RoadLine.prototype.clear = function () {
        if (this.timer) { clearTimeout(this.timer); this.timer = null; }
        this.cancel();
        this.token++;
        this.removeLayers();
    };

    RoadLine.prototype.succeed = function (latlngs, km, minutes) {
        if (!latlngs || latlngs.length < 2) return false;
        this.removeLayers();

        // A wider white casing under the route keeps the line legible over busy map tiles,
        // so the road line never looks like it disappeared into the background.
        this.casing = L.polyline(latlngs, {
            color: '#ffffff', weight: this.weight + 4, opacity: 0.9,
            lineJoin: 'round', lineCap: 'round'
        }).addTo(this.map);
        if (this.casing.bringToBack) this.casing.bringToBack();

        var style = {
            color: this.color, weight: this.weight,
            opacity: this.opacity, lineJoin: 'round', lineCap: 'round'
        };
        if (this.dashArray) style.dashArray = this.dashArray;
        this.line = L.polyline(latlngs, style).addTo(this.map);
        if (this.line.bringToBack) this.line.bringToBack();
        // The casing is the wider of the two, so push it down again now the route is on top.
        if (this.casing.bringToBack) this.casing.bringToBack();

        if (this.fit) this.map.fitBounds(L.latLngBounds(latlngs).pad(0.2));
        if (this.onRoad) this.onRoad({ km: km, minutes: minutes, coordinates: latlngs });
        return true;
    };

    RoadLine.prototype.failed = function () {
        // Keep the dashed guide: when every host fails it is the only line on the map.
        if (this.line) { this.map.removeLayer(this.line); this.line = null; }
        if (this.onFail) this.onFail();
    };

    // The published plugin renamed its OSRM router between major versions and never shipped
    // the lowercase "osrmv1" name, so all three spellings are accepted. If none is present -
    // or the CDN is blocked - the direct OSRM call in fetch() is the only path, and it works
    // on its own, so the plugin stays entirely optional.
    var ROUTER_NAMES = ['osrmv1', 'OSRMv1', 'OSRM'];

    function getRouterFactory() {
        if (!global.L || !global.L.Routing) return null;
        for (var i = 0; i < ROUTER_NAMES.length; i++) {
            var f = global.L.Routing[ROUTER_NAMES[i]];
            if (typeof f === 'function') return f;
        }
        return null;
    }

    // Step 1: the Leaflet Routing Machine OSRM router, when one is loaded.
    // `points` is already normalised by set().
    RoadLine.prototype.request = function (points, token) {
        var self = this;
        var norm = normalizePoints(points);
        if (!norm || norm.length < 2) { this.failed(); return; }

        var Router = getRouterFactory();
        if (Router) {
            try {
                var router = new Router({ alternatives: false });
                router.route(norm.map(function (p) {
                    return { latLng: global.L.latLng(p.lat, p.lng) };
                }), function (err, routes) {
                    if (token !== self.token) return;
                    var r = err ? null : (routes && routes[0]);
                    if (r && r.coordinates && r.coordinates.length > 1) {
                        var summary = r.summary || {};
                        var km = (summary.totalDistance != null ? summary.totalDistance : 0) / 1000;
                        var minutes = Math.round((summary.totalTime || 0) / 60);
                        if (self.succeed(r.coordinates, km, minutes)) return;
                    }
                    self.fetch(norm, token);
                });
                return;
            } catch (e) {
                // Plugin present but unusable (version skew, blocked request): use OSRM directly.
            }
        }
        this.fetch(norm, token);
    };

    // Step 2: direct OSRM GeoJSON call, walking the host list.
    RoadLine.prototype.fetch = function (points, token) {
        var self = this;
        var norm = normalizePoints(points);
        if (!norm || norm.length < 2) { this.failed(); return; }

        this.cancel();
        // OSRM wants lng,lat pairs; the trip JSON stores lat first.
        var coords = norm.map(function (p) {
            return p.lng.toFixed(6) + ',' + p.lat.toFixed(6);
        }).join(';');
        var attempt = 0;

        function tryNext() {
            if (token !== self.token) return;
            if (attempt >= ROUTERS.length) { self.failed(); return; }
            var host = ROUTERS[attempt++];
            var xhr = new XMLHttpRequest();
            self.xhr = xhr;
            xhr.open('GET', host.url + coords + '?overview=full&geometries=geojson&alternatives=false', true);
            xhr.timeout = REQUEST_TIMEOUT_MS;
            xhr.onload = function () {
                if (token !== self.token) return;
                if (xhr.status !== 200) { tryNext(); return; }
                var json, route, line;
                try { json = JSON.parse(xhr.responseText); } catch (e) { tryNext(); return; }
                route = json && json.routes && json.routes[0];
                line = route && route.geometry && route.geometry.coordinates;
                if (!line || !line.length || !(route.distance > 0)) { tryNext(); return; }
                // GeoJSON is [lng, lat]; Leaflet wants [lat, lng].
                self.succeed(line.map(function (c) { return [c[1], c[0]]; }),
                    route.distance / 1000, Math.round(route.duration / 60));
            };
            xhr.onerror = xhr.ontimeout = function () { if (token === self.token) tryNext(); };
            xhr.send();
        }

        tryNext();
    };

    global.TripRoute = {
        color: DEFAULT_COLOR,
        routers: ROUTERS,
        create: function (map, points, options) {
            var line = new RoadLine(map, options);
            if (points) line.set(points);
            return line;
        },
        isRouteable: isRouteable,
        normalizePoint: normalizePoint,
        latlngs: toLatLngs
    };
})(window);
