/* Project-wide toaster. Same behaviour as react-hot-toast's
   <Toaster position="top-right" reverseOrder={false} />: a fixed top-right stack,
   oldest first (reverseOrder false), auto dismiss, click to close.
   Hover or focus a toast to hold it open while it is read.

   Raised for what a person just did, never for a message the server already put on the
   page: TwToast.success('Saved.') after a save, TwToast.error('Refused.') on a refusal.
   Usage: TwToast.success('Saved.'); TwToast.error('Pick a package.'); */
(function () {
    var MAX_VISIBLE = 3;
    var DURATION = 4000;
    var colors = {
        success: '#059669',
        error: '#dc2626',
        info: '#2563eb',
        warning: '#d97706',
        loading: '#6b7280'
    };
    var paths = {
        success: '<path d="M4.5 8.75l2.5 2.5 6-6" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>',
        error: '<path d="M6 6l4 4M10 6l-4 4" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>',
        info: '<path d="M8 7.25v3.5M8 5.4v.2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>',
        warning: '<path d="M8 5.25v3.5M8 11.4v.2" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>',
        loading: '<path d="M8 2.5a5.5 5.5 0 1 0 5.5 5.5" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/>'
    };
    var stack = null;
    var seq = 0;

    function injectStyles() {
        if (document.getElementById('twToastStyles')) return;
        var css = '.tw-toast-stack{position:fixed;top:1rem;right:1rem;z-index:1200;display:flex;' +
            'flex-direction:column;gap:.5rem;width:min(22rem,calc(100vw - 2rem));pointer-events:none}' +
            '.tw-toast{pointer-events:auto;position:relative;overflow:hidden;display:flex;gap:.625rem;' +
            'align-items:flex-start;padding:.75rem .875rem;background:#fff;color:#111827;font-size:.8125rem;' +
            'line-height:1.4;border:1px solid #e5e7eb;border-radius:.75rem;box-shadow:0 10px 25px -6px rgba(0,0,0,.2);' +
            'cursor:pointer;animation:twToastIn .18s ease-out}' +
            '.tw-toast.is-loading{cursor:default}' +
            '.tw-toast.out{animation:twToastOut .15s ease-in forwards}' +
            '.tw-toast-icon{flex:none;margin-top:.0625rem}' +
            '.tw-toast-text{flex:1;min-width:0;word-break:break-word}' +
            '.tw-toast-close{flex:none;color:#9ca3af;font-size:1rem;line-height:1;padding:.0625rem .125rem}' +
            '.tw-toast-close:hover{color:#374151}' +
            '.tw-toast-bar{position:absolute;left:0;bottom:0;height:2px;width:100%;transform-origin:left}' +
            '@keyframes twToastIn{from{opacity:0;transform:translateX(1.25rem)}to{opacity:1;transform:none}}' +
            '@keyframes twToastOut{to{opacity:0;transform:translateX(1.25rem)}}' +
            '@keyframes twToastBar{from{transform:scaleX(1)}to{transform:scaleX(0)}}' +
            '@keyframes twToastSpin{to{transform:rotate(360deg)}}' +
            '.tw-toast-spin{animation:twToastSpin .7s linear infinite}' +
            '@media (prefers-reduced-motion: reduce){.tw-toast,.tw-toast.out{animation:none}' +
            '.tw-toast-bar{animation:none!important;opacity:.5}}';
        var style = document.createElement('style');
        style.id = 'twToastStyles';
        style.appendChild(document.createTextNode(css));
        document.head.appendChild(style);
    }

    function container() {
        if (stack && stack.parentNode) return stack;
        injectStyles();
        stack = document.createElement('div');
        stack.id = 'twToaster';
        stack.className = 'tw-toast-stack';
        stack.setAttribute('aria-live', 'polite');
        stack.setAttribute('role', 'status');
        document.body.appendChild(stack);
        return stack;
    }

    function el(tag, className, html) {
        var node = document.createElement(tag);
        if (className) node.className = className;
        if (html != null) node.innerHTML = html;
        return node;
    }

    function build(kind, message, duration) {
        var box = el('div', 'tw-toast' + (kind === 'loading' ? ' is-loading' : ''));
        var icon = el('span', 'tw-toast-icon', '<svg viewBox="0 0 16 16" width="16" height="16" ' +
            'style="color:' + colors[kind] + '">' + paths[kind] + '</svg>');
        if (kind === 'loading') icon.firstChild.setAttribute('class', 'tw-toast-spin');
        box.appendChild(icon);
        box.appendChild(el('span', 'tw-toast-text', ''));
        box.lastChild.textContent = message == null ? '' : String(message);
        var close = el('button', 'tw-toast-close', '&times;');
        close.type = 'button';
        close.setAttribute('aria-label', 'Close');
        box.appendChild(close);
        if (duration > 0) {
            var bar = el('span', 'tw-toast-bar', '');
            bar.style.background = colors[kind];
            bar.style.animation = 'twToastBar ' + duration + 'ms linear forwards';
            box.appendChild(bar);
        }
        return box;
    }

    /* One entry per live toast: the dismiss timer, the time still left on it, and its
       countdown bar. Held here rather than on the node so a dismissal in flight can be
       cancelled, and so a paused toast remembers where it had got to. */
    var live = {};

    function arm(id) {
        var m = live[id];
        if (!m) return;
        if (m.timer) clearTimeout(m.timer);
        m.since = Date.now();
        m.timer = setTimeout(function () { dismiss(id); }, m.left);
        if (m.bar) m.bar.style.animationPlayState = 'running';
    }

    /* Hovering or tabbing to a toast holds it open, countdown bar included, and leaves the
       remaining time for when the pointer leaves. Without this the toast is gone while it is
       being read, which is what made a 4s toast feel like it lasted a second: the time is the
       same either way, it is just no longer spent before the message has been read. */
    function hold(id, on) {
        var m = live[id];
        if (!m || m.timer === undefined) return;
        if (on) {
            if (!m.timer) return;                     /* already held */
            clearTimeout(m.timer);
            m.timer = null;
            m.left -= Math.max(0, Date.now() - m.since);
            if (m.bar) m.bar.style.animationPlayState = 'paused';
        } else {
            if (m.timer) return;                     /* already running */
            if (m.left <= 0) { dismiss(id); return; }
            arm(id);
        }
    }

    function dismiss(id) {
        var box = document.getElementById('tw-toast-' + id);
        if (!box) return;
        var m = live[id];
        if (m) {
            if (m.timer) clearTimeout(m.timer);
            delete live[id];
        }
        /* Idempotent. The class swap used to run unconditionally and its own replace() then
           matched the tw-toast inside the tw-toast it had just written, growing the class
           list by one out on every extra call. */
        if (box.className.indexOf(' out') !== -1) return;
        box.className = box.className.replace('tw-toast', 'tw-toast out');
        setTimeout(function () { if (box.parentNode) box.parentNode.removeChild(box); }, 160);
    }

    function show(message, kind, duration) {
        kind = colors[kind] ? kind : 'info';
        if (duration == null) duration = kind === 'loading' ? 0 : DURATION;
        var id = ++seq;
        var box = build(kind, message, duration);
        box.id = 'tw-toast-' + id;
        var host = container();
        host.appendChild(box);                 /* reverseOrder false: oldest stays on top */

        /* Trim to MAX_VISIBLE toasts that are actually on screen.

           dismiss() marks a box and unhooks it 160ms later, so a fading toast is still a
           child and counting it as live is what made this overrun: sizing the trim off
           children.length treated every box already on its way out as occupying a slot,
           so a burst of toasts ate the live ones too and the newest was dismissed the
           instant it appeared. Counted on what is painted instead.

           The guard bounds the passes. Each one marks a single box as fading, so the live
           count strictly falls and this ends well inside the bound; the loop cannot wedge
           the tab the way the children.length version did. */
        for (var pass = MAX_VISIBLE + 2; pass > 0; pass--) {
            var victim = null, onScreen = 0;
            for (var c = 0; c < host.children.length; c++) {
                if (host.children[c].className.indexOf(' out') === -1) {
                    onScreen++;
                    if (!victim) victim = host.children[c];        /* oldest still shown */
                }
            }
            if (onScreen <= MAX_VISIBLE || !victim) break;
            dismiss(victim.id.replace('tw-toast-', ''));
        }

        if (duration > 0) {
            live[id] = { left: duration, since: Date.now(), timer: null, bar: box.querySelector('.tw-toast-bar') };
            arm(id);
            box.addEventListener('mouseenter', function () { hold(id, true); });
            box.addEventListener('mouseleave', function () { hold(id, false); });
            box.addEventListener('focusin', function () { hold(id, true); });
            box.addEventListener('focusout', function () { hold(id, false); });
        }
        box.addEventListener('click', function () {
            if (kind !== 'loading') dismiss(id);
        });
        return id;
    }

    /* Deliberately no longer reads the [data-tw-toast] message panels on load.

       It used to, which turned every message the server set into a floating toast that came
       and went on its own. That is wrong for those panels: they are the page's standing
       message, set by the postback that just happened, and someone landing on the page again
       or refreshing should still find it there. Auto-raising them meant the message was only
       ever up for the length of one toast and then gone, with nothing left on the page.

       They are ordinary markup now. There is no CSS rule for [data-tw-toast], so each one
       renders inline where the page put it and stays until the next postback replaces it,
       and the attribute is left on the panels purely as a marker of what they are.

       Toasts are for the things a person just did: TwToast.success on a save, TwToast.error
       on a refusal. Those are raised by the code handling the action, so they only ever
       appear in reply to one, and never on a plain page load. */

    window.TwToast = {
        success: function (m, d) { return show(m, 'success', d); },
        error: function (m, d) { return show(m, 'error', d); },
        info: function (m, d) { return show(m, 'info', d); },
        warning: function (m, d) { return show(m, 'warning', d); },
        loading: function (m) { return show(m, 'loading', 0); },
        dismiss: dismiss,
        dismissAll: function () {
            var host = container();
            for (var i = 0; i < host.children.length; i++) {
                dismiss(host.children[i].id.replace('tw-toast-', ''));
            }
        },
        update: function (id, message, kind) {
            var box = document.getElementById('tw-toast-' + id);
            if (!box) return id;
            var m = live[id];
            if (m && m.timer) { clearTimeout(m.timer); m.timer = null; }
            var label = box.querySelector('.tw-toast-text');
            if (label) label.textContent = message == null ? '' : String(message);
            if (kind) {
                box.className = box.className.replace('is-loading', '');
                var icon = box.querySelector('.tw-toast-icon svg');
                if (icon) {
                    icon.removeAttribute('class');
                    icon.style.color = colors[kind];
                    icon.innerHTML = paths[kind];
                }
                var bar = box.querySelector('.tw-toast-bar');
                if (bar) bar.remove();
                if (kind !== 'loading') {
                    var next = el('span', 'tw-toast-bar', '');
                    next.style.background = colors[kind];
                    next.style.animation = 'twToastBar ' + DURATION + 'ms linear forwards';
                    box.appendChild(next);
                    /* A new message on the same toast is a new countdown from the top, and
                       the replacement bar is the one hold() has to pause. Built fresh rather
                       than reusing the old entry because a toast updated out of loading never
                       had one: it was created with no timer. */
                    live[id] = { left: DURATION, since: Date.now(), timer: null, bar: next };
                    arm(id);
                    box.addEventListener('mouseenter', function () { hold(id, true); });
                    box.addEventListener('mouseleave', function () { hold(id, false); });
                    box.addEventListener('focusin', function () { hold(id, true); });
                    box.addEventListener('focusout', function () { hold(id, false); });
                } else {
                    delete live[id];
                }
            }
            return id;
        },
        promise: function (work, messages) {
            messages = messages || {};
            var id = show(messages.loading || 'Working...', 'loading');
            return Promise.resolve(work).then(function (value) {
                TwToast.update(id, typeof messages.success === 'function' ? messages.success(value) : messages.success, 'success');
                return value;
            }, function (err) {
                TwToast.update(id, typeof messages.error === 'function' ? messages.error(err) : (messages.error || 'Something went wrong.'), 'error');
                throw err;
            });
        }
    };
})();
