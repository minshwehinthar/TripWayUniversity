/*
 * TwEta - ticks the arrival promises that TripHelper paints.
 *
 * TripHelper stamps every live promise with the absolute moment it lands instead of the
 * minutes still to go, so nothing here depends on when the page was rendered or on the
 * clock zone the browser happens to be in:
 *
 *   [data-eta-arrive]       epoch milliseconds the driver promised, or 0 for no promise
 *   [data-eta-done]         label to show once that moment passes ("Arriving now")
 *   [data-eta-template]     countdown label, {0} replaced with the minutes left
 *   [data-eta-late-arrive]  epoch milliseconds, on a line revealed only once passed
 *   [data-eta-late-template]
 *
 * Both kinds are rescanned on a timer rather than only at load. Promises are written into
 * the DOM long after load - the accept handler, the trip poller and the request list all do
 * it - and a chip left reading "Arriving in 12 min" on a tab open all afternoon is worse
 * than showing no countdown at all, because it is confidently wrong.
 *
 * The tick interval is short enough that the label never drifts far from the truth, and the
 * work per tick is a couple of querySelectorAll passes over a handful of elements.
 *
 * No dependencies.
 */
(function (global) {
    'use strict';

    var TICK_MS = 15000;
    var DONE_FALLBACK = 'Arriving now';

    /* Minutes still to wait, rounded up. Rounding down would print "Arriving in 0 min" while
       there was still time on the clock, which reads as broken. */
    function minutesLeft(arriveMs, nowMs) {
        return Math.max(0, Math.ceil((arriveMs - nowMs) / 60000));
    }

    /* Minutes elapsed since the promise, which is the opposite direction and cannot share the
       function above: minutesLeft on a moment that has already passed is always 0, so reusing
       it left the late line reading "Running 0 min behind the promise" forever. Rounded up so
       the line says 1 the moment the promise is missed rather than staying at 0 for a minute. */
    function minutesPast(arriveMs, nowMs) {
        return Math.max(0, Math.ceil((nowMs - arriveMs) / 60000));
    }

    function arrivalMs(el, attribute) {
        var raw = el.getAttribute(attribute);
        var ms = parseInt(raw, 10);
        /* 0 is what EtaArrivalUnixMs returns when no estimate was given, and a negative
           value is impossible. Neither is a promise that has been missed - leaving them
           alone is the only safe reading, because the server already decided this chip had
           nothing to count down. */
        return (!isNaN(ms) && ms > 0) ? ms : 0;
    }

    function fill(el, template, value) {
        if (el && template) el.textContent = template.replace('{0}', value);
    }

    function tickChip(el, nowMs) {
        var arrive = arrivalMs(el, 'data-eta-arrive');
        if (!arrive) return;

        var done = el.getAttribute('data-eta-done');
        if (nowMs >= arrive) {
            var label = done || DONE_FALLBACK;
            if (el.textContent !== label) el.textContent = label;
            return;
        }

        fill(el, el.getAttribute('data-eta-template'), minutesLeft(arrive, nowMs));
    }

    function tickLate(el, nowMs) {
        var arrive = arrivalMs(el, 'data-eta-late-arrive');
        if (!arrive) return;

        /* Hidden until the promise is actually missed, so a driver who is early never sees it
           and it cannot flash before the first tick. */
        if (nowMs < arrive) {
            el.classList.add('hidden');
            return;
        }

        fill(el, el.getAttribute('data-eta-late-template'), minutesPast(arrive, nowMs));
        el.classList.remove('hidden');
    }

    function refresh() {
        var nowMs = Date.now();
        var i, list;

        list = document.querySelectorAll('[data-eta-arrive]');
        for (i = 0; i < list.length; i++) tickChip(list[i], nowMs);

        list = document.querySelectorAll('[data-eta-late-arrive]');
        for (i = 0; i < list.length; i++) tickLate(list[i], nowMs);
    }

    global.TwEta = { refresh: refresh };

    document.addEventListener('DOMContentLoaded', function () {
        refresh();
        setInterval(refresh, TICK_MS);
    });
})(window);