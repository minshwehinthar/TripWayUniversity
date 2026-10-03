/* TripWay ride chat.
 *
 * Shared by the driver and customer trip pages. The panel markup carries the
 * configuration as data-attributes so no per-page wiring is needed:
 *
 *   <div data-chat data-trip="123" data-api=".../TripApi.ashx" data-me="Driver"
 *        data-base="/TripWay/">
 *     <span data-chat-status></span>
 *     <div data-chat-list></div>
 *     <button data-chat-jump>Latest</button>
 *     <div data-chat-closed></div>
 *     <div data-chat-form>
 *       <textarea data-chat-input></textarea>
 *       <input type="file" data-chat-file accept="image/*" />
 *       <button type="button" data-chat-attach>Attach</button>
 *       <div data-chat-preview></div>
 *       <button type="button" data-chat-send>Send</button>
 *     </div>
 *     <div data-chat-error></div>
 *   </div>
 *
 * The ride status decides everything. The server reports chatOpen with every
 * poll; while it is false the composer is hidden and its controls are disabled,
 * and the reason from the server is shown instead. A send that races the trip
 * finishing is rejected with error "chat_closed", which also flips the panel
 * shut. See ChatIsOpen / ChatClosedReason in Handlers/TripApi.ashx.cs.
 *
 * Photos: the browser downscales the picked image onto a canvas before upload, so a
 * modern phone photo goes over the wire as a few hundred KB of JPEG instead of
 * several MB. The server still re-validates the extension and size.
 */
(function (global) {
    'use strict';

    var POLL_MS = 5000;
    var MAX_EDGE = 1600;          // longest edge kept when downscaling
    var JPEG_QUALITY = 0.82;
    var NEAR_BOTTOM = 60;         // px of slack that still counts as "at the bottom"

    /* Only paths this script could have produced are ever turned into an <img src>.
     * A crafted database value therefore cannot become a javascript: URL or an
     * off-site tracking pixel. */
    var SAFE_PHOTO = /^Uploads\/ChatPhotos\/[A-Za-z0-9._-]+\.(?:jpe?g|png)$/i;

    function esc(value) {
        return String(value == null ? '' : value)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;');
    }

    // Server sends ISO-8601 UTC, so the browser renders it in the viewer's own zone.
    function fmtStamp(raw) {
        if (!raw) return '';
        var d = new Date(raw);
        if (isNaN(d.getTime())) return '';
        try {
            return d.toLocaleString(undefined, { dateStyle: 'short', timeStyle: 'short' });
        } catch (e) {
            return d.toISOString().slice(0, 16).replace('T', ' ');
        }
    }

    function Chat(root) {
        this.root = root;
        this.trip = root.getAttribute('data-trip') || '0';
        this.api = root.getAttribute('data-api') || '';
        this.me = root.getAttribute('data-me') || 'Customer';
        this.base = root.getAttribute('data-base') || '/';
        this.list = root.querySelector('[data-chat-list]');
        this.form = root.querySelector('[data-chat-form]');
        this.input = root.querySelector('[data-chat-input]');
        this.sendBtn = root.querySelector('[data-chat-send]');
        this.uploadBtn = root.querySelector('[data-chat-upload]');
        this.attachBtn = root.querySelector('[data-chat-attach]');
        this.fileInput = root.querySelector('[data-chat-file]');
        this.preview = root.querySelector('[data-chat-preview]');
        this.jumpBtn = root.querySelector('[data-chat-jump]');
        this.closed = root.querySelector('[data-chat-closed]');
        this.error = root.querySelector('[data-chat-error]');
        this.badge = root.querySelector('[data-chat-status]');
        this.isOpen = false;
        this.lastId = 0;
        this.sending = false;
        this.unseen = 0;
        this.photo = null;          // { blob, name, url } once a picture is attached
    }

    Chat.prototype.usable = function () {
        return this.trip !== '0' && !!this.api;
    };

    /* Resolves a stored relative photo path to a same-origin URL, or '' if the value
     * is not one this app could have written. */
    Chat.prototype.photoSrc = function (raw) {
        if (!raw) return '';
        var p = String(raw).replace(/^\/+/, '');
        if (!SAFE_PHOTO.test(p)) return '';
        var base = this.base.charAt(this.base.length - 1) === '/' ? this.base : this.base + '/';
        return base + p;
    };

    /* Single source of truth for the open / locked presentation. */
    Chat.prototype.applyState = function (open, reason) {
        this.isOpen = !!open;

        if (this.isOpen) {
            if (this.form) this.form.classList.remove('hidden');
            if (this.closed) this.closed.classList.add('hidden');
            this.setDisabled(false);
            if (this.input) this.input.placeholder = 'Type a message...';
            if (this.badge) {
                this.badge.textContent = 'Open';
                this.badge.className = 'text-xs font-semibold text-green-600';
            }
        } else {
            if (this.form) this.form.classList.add('hidden');
            if (this.closed) {
                this.closed.textContent = reason || 'Chat is closed for this ride.';
                this.closed.classList.remove('hidden');
            }
            this.setDisabled(true);
            if (this.badge) {
                this.badge.textContent = 'Closed';
                this.badge.className = 'text-xs font-semibold text-gray-400';
            }
        }
    };

    /* Covers the text box, the send button, and the attach controls. */
    Chat.prototype.setDisabled = function (off) {
        if (this.input) this.input.disabled = off;
        if (this.sendBtn) this.sendBtn.disabled = off;
        if (this.uploadBtn) this.uploadBtn.disabled = off;
        if (this.attachBtn) this.attachBtn.disabled = off;
        if (this.fileInput) this.fileInput.disabled = off;
    };

    Chat.prototype.showError = function (text) {
        if (!this.error) return;
        this.error.textContent = text || '';
        this.error.classList.toggle('hidden', !text);
    };

    /* True when the reader has not scrolled away from the newest message. */
    Chat.prototype.nearBottom = function () {
        var n = this.list;
        if (!n) return true;
        return (n.scrollHeight - n.scrollTop - n.clientHeight) <= NEAR_BOTTOM;
    };

    Chat.prototype.scrollToLatest = function () {
        if (!this.list) return;
        this.list.scrollTop = this.list.scrollHeight;
        this.unseen = 0;
        this.showJump(false);
    };

    Chat.prototype.showJump = function (on) {
        if (!this.jumpBtn) return;
        this.jumpBtn.classList.toggle('hidden', !on);
        if (on) this.jumpBtn.textContent = 'Jump to latest (' + this.unseen + ')';
    };

    /* Downscales the picked image and returns a JPEG blob. Falls back to the original
     * file when the browser cannot give us a canvas, so sending never hard-fails. */
    Chat.prototype.shrink = function (file, done) {
        var reader = new FileReader();
        reader.onerror = function () { done(null); };
        reader.onload = function (e) {
            var img = new Image();
            img.onerror = function () { done(null); };
            img.onload = function () {
                var w = img.naturalWidth || img.width;
                var h = img.naturalHeight || img.height;
                if (!w || !h) { done(null); return; }

                var scale = Math.min(1, MAX_EDGE / Math.max(w, h));
                var cw = Math.max(1, Math.round(w * scale));
                var ch = Math.max(1, Math.round(h * scale));

                var canvas = document.createElement('canvas');
                canvas.width = cw;
                canvas.height = ch;
                var ctx = canvas.getContext('2d');
                // JPEG has no alpha channel, so transparent PNGs are flattened onto white
                // rather than turning black.
                ctx.fillStyle = '#ffffff';
                ctx.fillRect(0, 0, cw, ch);
                ctx.drawImage(img, 0, 0, cw, ch);

                if (!canvas.toBlob) { done(file); return; }
                canvas.toBlob(function (blob) {
                    if (!blob) { done(file); return; }
                    done(blob, cw, ch);
                }, 'image/jpeg', JPEG_QUALITY);
            };
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    };

    Chat.prototype.clearPhoto = function () {
        if (this.photo && this.photo.url && this.photo.url.indexOf('blob:') === 0) {
            URL.revokeObjectURL(this.photo.url);
        }
        this.photo = null;
        if (this.preview) {
            this.preview.innerHTML = '';
            // Tailwind's `hidden` and `flex` both set display, so they are toggled as a pair.
            this.preview.classList.add('hidden');
            this.preview.classList.remove('flex');
        }
        if (this.fileInput) this.fileInput.value = '';
    };

    Chat.prototype.showPreview = function () {
        if (!this.preview || !this.photo) return;
        var self = this;
        this.preview.innerHTML = '';

        var thumb = document.createElement('img');
        thumb.src = this.photo.url;
        thumb.alt = 'Attached photo';
        thumb.className = 'size-14 rounded-lg object-cover border border-gray-200';

        var meta = document.createElement('span');
        meta.className = 'text-[11px] text-gray-500';
        meta.textContent = this.photo.size;

        var drop = document.createElement('button');
        drop.type = 'button';
        drop.className = 'ml-auto text-xs font-semibold text-red-600 hover:underline';
        drop.textContent = 'Remove';
        drop.addEventListener('click', function () { self.clearPhoto(); });

        this.preview.appendChild(thumb);
        this.preview.appendChild(meta);
        this.preview.appendChild(drop);
        this.preview.classList.remove('hidden');
        this.preview.classList.add('flex');
    };

    Chat.prototype.pick = function (file) {
        var self = this;
        if (!file) return;
        if (file.type && file.type.indexOf('image/') !== 0) {
            this.showError('Only image files can be attached.');
            if (this.fileInput) this.fileInput.value = '';
            return;
        }
        this.showError('');
        this.shrink(file, function (blob, w, h) {
            if (!blob) {
                self.showError('That image could not be read.');
                return;
            }
            self.clearPhoto();
            self.photo = {
                blob: blob,
                name: 'chat-' + Date.now() + '.jpg',
                url: URL.createObjectURL(blob),
                size: blob.size > 1024 * 1024
                    ? (blob.size / (1024 * 1024)).toFixed(1) + ' MB'
                    : Math.max(1, Math.round(blob.size / 1024)) + ' KB'
            };
            self.showPreview();
        });
    };

    Chat.prototype.render = function (messages) {
        if (!this.list) return;
        var added = false;
        // Decided before mutating the DOM, so the scroll position is only hijacked when the
        // reader was already at the bottom.
        var stick = this.nearBottom();

        for (var i = 0; i < messages.length; i++) {
            var m = messages[i];
            if (m.id <= this.lastId) continue;   // incremental: never rebuild what is on screen
            this.lastId = m.id;
            added = true;

            var mine = m.senderType === this.me;
            var row = document.createElement('div');
            row.className = 'flex ' + (mine ? 'justify-end' : 'justify-start');

            var bubble = document.createElement('div');
            bubble.className = 'max-w-[80%] rounded-xl px-3 py-2 text-sm whitespace-pre-wrap break-words ' +
                (mine ? 'bg-blue-600 text-white' : 'bg-gray-100 text-gray-900');

            var src = this.photoSrc(m.photo);
            if (src) {
                var pic = document.createElement('img');
                pic.src = src;
                pic.alt = 'Shared photo';
                pic.loading = 'lazy';
                pic.className = 'block rounded-lg max-h-64 w-auto cursor-zoom-in ' +
                    (mine ? 'bg-white/10' : 'bg-gray-200');
                pic.addEventListener('click', function () { global.TripChat.zoom(src); });
                bubble.appendChild(pic);
            }

            if (m.text) {
                // textContent, never innerHTML: message bodies are untrusted.
                if (src) {
                    var cap = document.createElement('div');
                    cap.className = src ? 'mt-1.5' : '';
                    cap.textContent = m.text;
                    bubble.appendChild(cap);
                } else {
                    bubble.textContent = m.text;
                }
            }

            row.appendChild(bubble);

            var when = fmtStamp(m.sentAt);
            if (when) {
                var stamp = document.createElement('div');
                stamp.className = 'mt-0.5 text-[11px] text-gray-400';
                stamp.textContent = when;
                row.appendChild(stamp);
            }

            this.list.appendChild(row);
        }

        if (!added) return;
        if (stick) {
            this.scrollToLatest();
        } else {
            this.unseen++;
            this.showJump(true);
        }
    };

    Chat.prototype.load = function () {
        if (!this.usable() || this.root.offsetParent === null) return;   // hidden panel: do not poll
        var self = this;

        fetch(this.api + '?action=chatget&trip=' + encodeURIComponent(this.trip), {
            credentials: 'same-origin',
            cache: 'no-store'
        })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (!d || d.ok !== true) {
                    self.showError(d && d.message ? d.message : 'Chat is unavailable.');
                    return;
                }
                self.showError('');
                self.applyState(d.chatOpen, d.chatClosedReason);
                self.render(d.messages || []);
            })
            .catch(function () {
                self.showError('Cannot reach the server. Retrying...');
            });
    };

    Chat.prototype.hasContent = function () {
        return !!(this.photo || (this.input && (this.input.value || '').trim()));
    };

    Chat.prototype.syncSendState = function () {
        if (!this.sendBtn) return;
        this.sendBtn.disabled = !this.isOpen || this.sending || !this.hasContent();
    };

    Chat.prototype.send = function () {
        if (!this.isOpen || this.sending || !this.usable()) return;
        var text = (this.input.value || '').trim();
        var photo = this.photo;
        if (!text && !photo) return;

        this.sending = true;
        this.setDisabled(true);
        this.syncSendState();
        var self = this;

        var url = this.api;
        var init = { method: 'POST', credentials: 'same-origin' };
        var urlencoded = 'action=chatsend&trip=' + encodeURIComponent(this.trip) +
            '&text=' + encodeURIComponent(text);

        if (photo) {
            // Multipart so the binary travels as a file part; the same action name and the
            // same server-side guard handle both shapes.
            var fd = new FormData();
            fd.append('action', 'chatsend');
            fd.append('trip', this.trip);
            fd.append('text', text);
            fd.append('photo', photo.blob, photo.name);
            init.body = fd;                       // no explicit Content-Type: the browser adds the boundary
        } else {
            init.headers = { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' };
            init.body = urlencoded;
        }

        fetch(url, init)
            .then(function (r) { return r.json(); })
            .then(function (d) {
                if (d && d.ok) {
                    self.input.value = '';
                    self.clearPhoto();
                    self.showError('');
                    self.load();
                    return;
                }
                // The ride can finish while the message is in flight. Trust the server
                // and lock the panel instead of reporting a generic failure.
                if (d && d.error === 'chat_closed') {
                    self.applyState(false, d.message);
                    return;
                }
                self.showError(d && d.message ? d.message : 'Message not sent.');
            })
            .catch(function () {
                self.showError('Cannot reach the server.');
            })
            .then(function () {
                self.sending = false;
                self.setDisabled(!self.isOpen);
                self.syncSendState();
            });
    };

    /* Full-screen view of a shared photo, so a small thumbnail stays readable.
       Matches the shared appOpenModal lightbox: light blur, page still visible,
       same circular close chip. */
    function zoom(src) {
        if (!src) return;
        var box = document.createElement('div');
        box.className = 'fixed inset-0 z-[100] flex items-center justify-center p-4';
        var backdrop = document.createElement('div');
        backdrop.className = 'absolute inset-0 bg-black/45 backdrop-blur-[2px]';
        var img = document.createElement('img');
        img.src = src;
        img.alt = 'Shared photo';
        img.className = 'relative max-h-[85vh] max-w-full rounded-xl object-contain shadow-2xl ring-1 ring-white/15';
        var close = document.createElement('button');
        close.type = 'button';
        close.setAttribute('aria-label', 'Close');
        close.className = 'tw-lb-close';
        close.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" ' +
            'stroke-width="2" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" ' +
            'd="M6 18 18 6M6 6l12 12" /></svg>';
        box.appendChild(backdrop);
        box.appendChild(img);
        box.appendChild(close);
        box.addEventListener('click', function () {
            if (box.parentNode) box.parentNode.removeChild(box);
        });
        document.body.appendChild(box);
    }

    function bind(root) {
        if (root.__tripChat) return root.__tripChat;
        var chat = new Chat(root);
        root.__tripChat = chat;

        if (chat.sendBtn) chat.sendBtn.addEventListener('click', function () { chat.send(); });

        if (chat.attachBtn && chat.fileInput) {
            chat.attachBtn.addEventListener('click', function () { chat.fileInput.click(); });
            chat.fileInput.addEventListener('change', function () {
                var f = chat.fileInput.files && chat.fileInput.files[0];
                chat.pick(f);
            });
        }

        if (chat.jumpBtn) {
            chat.jumpBtn.addEventListener('click', function () { chat.scrollToLatest(); });
        }

        if (chat.list) {
            // Hiding the pill as soon as the reader catches up on their own.
            chat.list.addEventListener('scroll', function () {
                if (chat.nearBottom()) chat.showJump(false);
            });
        }

        if (chat.input) {
            // Enter sends, Shift+Enter makes a new line.
            chat.input.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    chat.send();
                }
            });
            // Grow with the content, up to the CSS max-height.
            chat.input.addEventListener('input', function () {
                chat.input.style.height = 'auto';
                chat.input.style.height = Math.min(chat.input.scrollHeight, 120) + 'px';
                chat.syncSendState();
            });
        }

        // Start closed so the composer is never briefly usable before the first poll.
        chat.applyState(false, 'Loading chat...');
        chat.load();
        setInterval(function () { chat.load(); }, POLL_MS);
        return chat;
    }

    function scan() {
        var nodes = document.querySelectorAll('[data-chat]');
        for (var i = 0; i < nodes.length; i++) bind(nodes[i]);
    }

    global.TripChat = { bind: bind, scan: scan, esc: esc, zoom: zoom };

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', scan);
    } else {
        scan();
    }
})(window);
