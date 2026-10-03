/* Keeps the viewport where it was across a WebForms postback.

   Adding or removing a tour stop re-binds the repeater through a postback, which
   replaces the whole document. The browser starts the new document at the top, so
   the list rebuilt correctly but the page appeared to reload under the admin.

   Two things are needed to make this stick, and both were missing at first:

   1. history.scrollRestoration = 'manual'. Left on 'auto', the browser performs its
      own scroll restoration for the new document and undoes whatever we set.
   2. An anchor rather than a bare pixel. Adding a stop changes how tall the page is,
      so the same pixel number no longer points at the same content. The anchor is
      re-found after the postback and the scroll is adjusted by whatever the layout
      shift was, which keeps the section the admin was working on under the cursor.

   The position rides across the round trip in a hidden server control, which has to
   be runat="server": a plain hidden input is re-rendered empty and loses the value.

   Usage: <input type="hidden" runat="server" id="__twScroll" />
          <div id="someStableId" data-tw-anchor>...</div>
          <script src=".../Scripts/tripway-scroll.js"></script> */
(function () {
    // Two script tags on one page must not fight over the same listeners.
    if (window.__twScrollBound) return;
    window.__twScrollBound = true;

    var FIELD = '__twScroll';

    // Restoring is abandoned the moment the admin scrolls for themselves, so the
    // page can never fight a deliberate scroll gesture.
    var userMoved = false;

    function markUserMoved() { userMoved = true; }

    /* The page may scroll on the document or inside a panel, depending on which shell
       is active, so the container is detected instead of assumed. */
    function scroller() {
        var el = document.getElementById('mainContentArea');
        if (!el) return null;
        var oy = window.getComputedStyle(el).overflowY;
        if (/(auto|scroll)/.test(oy) && el.scrollHeight > el.clientHeight + 1) return el;
        return null;
    }

    function currentY() {
        var box = scroller();
        if (box) return box.scrollTop;
        return window.pageYOffset || (document.documentElement && document.documentElement.scrollTop) || 0;
    }

    /* Pipe separated rather than JSON so the value survives the server control's HTML
       encoding without any quoting concerns. */
    function store() {
        var f = document.getElementById(FIELD);
        if (!f) return;
        var box = scroller();
        var anchor = document.querySelector('[data-tw-anchor]');
        f.value = [
            currentY(),
            box ? box.scrollTop : 0,
            box ? box.id : '',
            anchor ? anchor.id : '',
            anchor ? Math.round(anchor.getBoundingClientRect().top) : 0
        ].join('|');
    }

    function restore() {
        if (userMoved) return false;

        var f = document.getElementById(FIELD);
        if (!f) return false;

        var parts = String(f.value || '').split('|');
        if (parts.length < 5) return false;

        var y = parseInt(parts[0], 10);
        if (isNaN(y) || y < 1) return false;

        var box = parts[2] ? document.getElementById(parts[2]) : scroller();
        var anchor = parts[3] ? document.getElementById(parts[3]) : null;
        var wasAt = parseInt(parts[4], 10);

        // Prefer the anchor. It survives the list growing or shrinking, which a raw
        // pixel does not: after adding a stop the rows below have all moved down.
        if (anchor && !isNaN(wasAt)) {
            var shift = Math.round(anchor.getBoundingClientRect().top) - wasAt;
            if (box) box.scrollTop = Math.max(0, parseInt(parts[1], 10) + shift);
            else window.scrollTo(0, Math.max(0, y + shift));
            return true;
        }

        if (box) { box.scrollTop = parseInt(parts[1], 10); return true; }

        window.scrollTo(0, y);
        return true;
    }

    /* Restore is attempted repeatedly because the document is still growing while the
       cover photo and the map tiles load, and a scroll set before that settles gets
       clamped to 0. Stops as soon as one attempt lands on the requested position. */
    function attempt() {
        if (userMoved) return;
        var before = currentY();
        if (!restore()) return;
        if (Math.abs(currentY() - before) < 2) return;
        window.requestAnimationFrame(attempt);
    }

    if ('scrollRestoration' in history) history.scrollRestoration = 'manual';

    // Passive: fires on every scroll frame and must never delay scrolling.
    window.addEventListener('scroll', store, { passive: true });

    // Deliberate gestures only. A scroll event caused by our own restore must not be
    // mistaken for the user giving up on the page.
    ['wheel', 'touchstart', 'keydown', 'mousedown'].forEach(function (evt) {
        window.addEventListener(evt, markUserMoved, { passive: true });
    });

    // Take a final reading as the postback is submitted, since the last scroll event
    // may predate the admin moving the mouse onto the button.
    window.addEventListener('submit', store);

    if (document.readyState === 'complete') attempt();
    else window.addEventListener('load', attempt);

    // A last attempt after images have had time to change the page height.
    window.setTimeout(attempt, 120);
})();
