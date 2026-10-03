/* Project-wide toaster. Same behaviour as react-hot-toast's
   <Toaster position="top-right" reverseOrder={false} />: a fixed top-right stack,
   oldest first (reverseOrder false), auto dismiss, click to close.
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

    var timers = {};

    function dismiss(id) {
        var box = document.getElementById('tw-toast-' + id);
        if (!box) return;
        if (timers[id]) { clearTimeout(timers[id]); delete timers[id]; }
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
        while (host.children.length > MAX_VISIBLE) dismiss(host.children[0].id.replace('tw-toast-', ''));
        if (duration > 0) timers[id] = setTimeout(function () { dismiss(id); }, duration);
        box.addEventListener('click', function () {
            if (kind !== 'loading') dismiss(id);
        });
        return id;
    }

    /* The pages already set their message panel server side on load and after every
       postback. Those panels are hidden by CSS and read here, so every ShowMessage in the
       project becomes a toast without touching its code behind. */
    function kindFrom(el) {
        var given = el.getAttribute('data-tw-toast');
        if (given && colors[given]) return given;
        var cls = el.className || '';
        if (/bg-(red|rose)-/.test(cls)) return 'error';
        if (/bg-(green|emerald)-/.test(cls)) return 'success';
        if (/bg-(amber|yellow|orange)-/.test(cls)) return 'warning';
        return 'info';
    }

    function fromServerPanels() {
        var panels = document.querySelectorAll('[data-tw-toast]');
        for (var i = 0; i < panels.length; i++) {
            var panel = panels[i];
            if (panel.getAttribute('data-tw-sent') === '1') continue;
            panel.setAttribute('data-tw-sent', '1');
            var text = (panel.textContent || '').replace(/\s+/g, ' ').trim();
            if (text) show(text, kindFrom(panel));
        }
    }

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
            if (timers[id]) { clearTimeout(timers[id]); delete timers[id]; }
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
                    timers[id] = setTimeout(function () { dismiss(id); }, DURATION);
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
        },
        fromServerPanels: fromServerPanels
    };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', fromServerPanels);
    } else {
        fromServerPanels();
    }
})();
