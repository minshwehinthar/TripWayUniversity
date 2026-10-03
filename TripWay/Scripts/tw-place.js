/*
 * TripPlace - fills an address box from a point on the map.
 *
 * The hotel create and edit forms both let an admin drop a pin instead of typing an address,
 * and both need the address written out for them. Each form carried its own copy of the
 * Nominatim reverse lookup, which is how the two slowly drifted apart on the timeout, on what
 * counts as a usable address and on the one rule that matters most: a value the admin typed by
 * hand must never be replaced by a lookup.
 *
 * That last rule is the whole design: a value the admin typed by hand is never replaced by a
 * lookup. Typing marks the box data-typed="1", and from then on the map leaves it alone -
 * including on an edit form, where the address arrived from the server rather than from a
 * person and must still follow the pin. Emptying the box clears the mark, because a field
 * cleared on purpose is asking to be filled. Anything this file writes is tagged data-auto="1"
 * purely to say where the value came from.
 *
 * A lookup that fails is not an error the admin can act on: the endpoint may be blocked, the
 * network may be down, or the point may simply have no address. Coordinates are saved either
 * way, so a failure is logged to the console and the field is left as it was, rather than being
 * stamped with an error the form then has to explain.
 *
 * No dependencies.
 *
 * Usage:
 *   TripPlace.bind({
 *       address: document.getElementById('txtAddress'),  // required
 *       getLatLng: function () { return [lat, lng]; },   // required, current map point
 *       limit: 300,                                      // optional, the field's MaxLength
 *       onFilled: function (address) { }                 // optional
 *   });
 *
 * Then call TripPlace.refresh() whenever the point changes, or let bind() wire it to a map:
 *   TripPlace.bind({ ..., map: map, onPick: function (latlng) { ... } });
 */
window.TripPlace = (function () {
    'use strict';

    /* The one thing that has to change if the service ever moves. An offline server, a
       locked-down network or a blocked host all show up as this single call failing, and
       nothing else here should need editing to point somewhere else. */
    var GEOCODER = 'https://nominatim.openstreetmap.org/reverse';

    /* Nominatim is normally a second or two. Five seconds is long enough that a slow lookup
       still supplies the real address and short enough that a dead request is not mistaken for
       a map that stopped working. */
    var LOOKUP_TIMEOUT = 5000;

    /* Rounded to four decimals, about eleven metres, so nudging a pin within the same street
       does not fire a second request for the same answer. */
    var cache = {};

    var opts = {};

    function cacheKey(lat, lng) {
        return Number(lat).toFixed(4) + ',' + Number(lng).toFixed(4);
    }

    /* display_name is a long comma-separated list of every level, which makes a poor single
       line for a hotel card, so the parts that actually say where it is are picked in order and
       the full string is only the last resort. Duplicates are dropped because Nominatim often
       reports a city and a municipality with the same name. */
    function formatAddress(j, limit) {
        if (!j) return '';

        var a = j.address || {};
        var street = [a.house_number, a.road].filter(Boolean).join(' ');
        var rest = [
            a.suburb || a.neighbourhood || a.quarter,
            a.city || a.town || a.village || a.municipality,
            a.state,
            a.country
        ];

        var parts = [];
        if (street) parts.push(street);
        rest.forEach(function (t) {
            if (t && parts.indexOf(String(t)) === -1) parts.push(String(t));
        });

        if (!parts.length && j.display_name) {
            parts.push(String(j.display_name).split(',')[0].trim());
        }

        var out = parts.join(', ');
        /* The address box is capped server side, and a long enough string is truncated on save
           with nothing to show for it. Cutting here means the admin sees the whole value. */
        return limit > 0 && out.length > limit ? out.slice(0, limit - 1).trim() + '…' : out;
    }

    function reverse(lat, lng, cb, limit) {
        var key = cacheKey(lat, lng);
        if (cache[key] !== undefined) { cb(cache[key]); return; }

        var url = GEOCODER + '?format=json&zoom=18&addressdetails=1'
            + '&lat=' + encodeURIComponent(lat) + '&lon=' + encodeURIComponent(lng);

        /* fetch only rejects on a network error, never on a server that never answers. A hung
           or blocked request would otherwise leave the field reading "Looking up..." for good,
           which is indistinguishable from a broken page. The race settles the callback either
           way so the admin is never left waiting. */
        var settled = false;
        var done = function (address, why) {
            if (settled) return;
            settled = true;
            clearTimeout(timer);
            if (why && window.console && console.warn) {
                console.warn('TripWay: could not look up an address (' + why + '). '
                    + 'The point was still saved; the address can be typed.', lat + ', ' + lng);
            }
            cb(address);
        };
        var timer = setTimeout(function () {
            done('', 'timed out after ' + LOOKUP_TIMEOUT + 'ms');
        }, LOOKUP_TIMEOUT);

        fetch(url)
            .then(function (r) {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.json();
            })
            .then(function (j) {
                var address = formatAddress(j, limit);
                cache[key] = address;
                done(address);
            })
            .catch(function (err) {
                done('', err && err.message ? err.message : 'request failed');
            });
    }

    /* Whether a lookup may overwrite what is in the box. The rule is "the admin has not typed
       here", tracked as data-typed rather than inferred from data-auto. Inferring it is what
       made an edit form refuse to update: the address arrives from the server with no
       data-auto on it, so it looked exactly like a value the admin had typed by hand, and
       clicking the map did nothing. Proving the negative - this box was not touched by a
       person - is the only question worth asking, and an empty box is always fair game
       because there is nothing to lose. */
    function shouldFill(el) {
        if (el.dataset.typed === '1') return false;
        return (el.value || '').trim().length === 0 || el.dataset.auto === '1';
    }

    function refresh() {
        if (!opts.address) return;
        if (!shouldFill(opts.address)) return;

        var ll = opts.getLatLng && opts.getLatLng();
        if (!ll || isNaN(ll[0]) || isNaN(ll[1])) return;

        /* One lookup in flight per field. A second click while the first is still open would
           otherwise race, and the slower of the two would win and leave the address describing
           the point the admin moved away from.
           The counter is bumped unconditionally: guarding the increment on the current value
           leaves it at zero for the first two requests, so those two compare equal and the
           stale answer is free to overwrite the fresh one. */
        opts.token = (opts.token || 0) + 1;
        var token = opts.token;

        reverse(ll[0], ll[1], function (address) {
            if (opts.token !== token) return;

            /* The admin may have started typing while the lookup was in flight. */
            if (!address || !shouldFill(opts.address)) return;

            opts.address.value = address;
            opts.address.dataset.auto = '1';
            if (opts.onFilled) opts.onFilled(address);
        }, opts.limit);
    }

    function bind(options) {
        opts = options || {};
        if (!opts.address) return;
        opts.token = 0;
        if (!opts.limit) opts.limit = 300;

        /* The box is marked as the admin's the moment they type in it, and unmarked again if
           they empty it. Without the mark, a value this file wrote would stay replaceable and
           a later map click would undo a correction; without the unmark, a field cleared on
           purpose would refuse to fill itself again. */
        opts.address.addEventListener('input', function () {
            if (opts.address.dataset.auto) delete opts.address.dataset.auto;
            if ((opts.address.value || '').trim().length === 0) delete opts.address.dataset.typed;
            else opts.address.dataset.typed = '1';
        });

        /* A map handle plus an onPick callback is all it takes for the fill to follow the pin,
           which is what both hotel forms want. Without a map the caller drives refresh(). */
        if (opts.map && opts.onPick) {
            opts.map.on('click', function (e) {
                opts.onPick(e.latlng.lat, e.latlng.lng);
                refresh();
            });
        }
    }

    return {
        bind: bind,
        refresh: refresh,
        reverse: reverse,
        formatAddress: formatAddress
    };
})();
