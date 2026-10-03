/* File pickers with a live preview, shared by the driver and customer profile pages.
   Markup contract:
     <div data-tw-upload>
       <input type="file" data-tw-input accept=".jpg,.png">   (the real control, may be hidden)
       <button type="button" data-tw-pick>Choose file</button>
       <span data-tw-name data-tw-hint="PNG or JPG">PNG or JPG</span>       <span data-tw-cover>                                  (optional)
         ...stored image / placeholder...
         <img data-tw-preview>
        <span data-tw-fallback>                            (optional, shown for non-images)
        </span>
      </div>
    A block can also push its picked file into a preview block elsewhere on the page with
    data-tw-share-preview="<id>", so one shared tile can show the live preview for several
    pickers. That shared block is a [data-tw-upload] of its own and may carry
    data-tw-preview-tile, which is shown only while a file is picked.
   Picking a file only fills in this block, so the user sees exactly what they picked before
   saving. Nothing is uploaded until the page is saved. */
(function () {
    function blockOf(node) {
        return node && node.closest ? node.closest('[data-tw-upload]') : null;
    }

    function clearPreview(block) {
        var img = block.querySelector('[data-tw-preview]');
        if (img) {
            img.style.display = 'none';
            img.removeAttribute('src');
        }
        var fallback = block.querySelector('[data-tw-fallback]');
        if (fallback) fallback.style.display = hasStoredChip(block) ? 'flex' : 'none';

        revealCovered(block);
    }

    /* A profile avatar already shows a stored photo. When a new file is previewed it has to
       sit on top of it, so the cover hides the stored image and puts it back afterwards.
       The first display value is remembered because the server decides what is visible. */
    function revealCovered(block, hide) {
        var cover = block.querySelector('[data-tw-cover]');
        if (!cover) return;

        var children = cover.children;
        for (var i = 0; i < children.length; i++) {
            var el = children[i];
            if (el.hasAttribute('data-tw-preview') || el.hasAttribute('data-tw-fallback')) continue;
            if (el.tagName !== 'IMG' && el.tagName !== 'SPAN') continue;

            if (el.getAttribute('data-tw-display') === null) {
                el.setAttribute('data-tw-display', el.style.display || '');
            }
            el.style.display = hide ? 'none' : el.getAttribute('data-tw-display');
        }
    }

    /* A PDF cannot be drawn into an <img>, so it gets the fallback chip instead of a broken
       image. The file name is still shown so the choice is never ambiguous. */
    function isImage(file) {
        return file && /^image\//i.test(file.type || '');
    }

    /* The hint sits on the label itself, next to the text it stands in for. */
    function hintOf(block, label) {
        if (label && label.hasAttribute('data-tw-hint')) return label.getAttribute('data-tw-hint');
        return block.getAttribute('data-tw-hint') || '';
    }

    /* Several pickers can share one preview block, e.g. the KYC thumbnails that all
       preview into a single tile in the document gallery. */
    function sharedOf(block) {
        var id = block.getAttribute('data-tw-share-preview');
        return id ? document.getElementById(id) : null;
    }

    /* A slot may already show the document that is stored for this driver. The server marks
       the cover with data-tw-has-doc, which survives any client-side fiddling, and the
       stored <img> carries data-tw-stored. Either one means the slot is not empty. */
    function hasStoredImage(block) {
        var cover = block.querySelector('[data-tw-cover]');
        if (!cover) return false;
        if (cover.getAttribute('data-tw-has-doc') === '1') return true;
        var stored = cover.querySelector('[data-tw-stored]');
        return !!(stored && stored.getAttribute('src'));
    }

    /* A stored file that is not a photo (the registration document can be a PDF) cannot be
       drawn into an <img>, so the slot keeps showing the fallback chip instead. */
    function hasStoredChip(block) {
        var cover = block.querySelector('[data-tw-cover]');
        if (!cover) return false;
        var stored = cover.querySelector('[data-tw-stored]');
        return cover.getAttribute('data-tw-has-doc') === '1' && !(stored && stored.getAttribute('src'));
    }

    /* A shared tile is kept out of the layout until something is picked, so an empty
       tile never looks like a missing document. */
    function toggleTile(block, visible) {
        var tile = block.hasAttribute('data-tw-preview-tile')
            ? block : block.querySelector('[data-tw-preview-tile]');
        if (tile) tile.classList.toggle('hidden', !visible && !hasStoredImage(block));
    }

    function show(block, file) {
        var label = block.querySelector('[data-tw-name]');
        var img = block.querySelector('[data-tw-preview]');
        var fallback = block.querySelector('[data-tw-fallback]');

        if (!file) {
            clearPreview(block);
            if (label) label.textContent = hintOf(block, label);
            toggleTile(block, false);
            return;
        }

        if (label) label.textContent = file.name;
        toggleTile(block, true);

        if (!isImage(file)) {
            if (img) {
                img.style.display = 'none';
                img.removeAttribute('src');
            }
            if (fallback) fallback.style.display = 'flex';
            revealCovered(block, true);
            return;
        }

        if (fallback) fallback.style.display = 'none';
        if (!img) return;

        var reader = new FileReader();
        reader.onload = function (e) {
            img.src = e.target.result;
            img.style.display = 'block';
            revealCovered(block, true);
        };
        reader.readAsDataURL(file);
    }

    document.addEventListener('click', function (e) {
        var trigger = e.target && e.target.closest ? e.target.closest('[data-tw-pick]') : null;
        if (!trigger) return;

        var block = blockOf(trigger);
        if (!block) return;

        var input = block.querySelector('[data-tw-input]');
        if (!input) return;

        e.preventDefault();
        input.click();
    });

    document.addEventListener('change', function (e) {
        var input = e.target;
        if (!input || !input.matches || !input.matches('[data-tw-input]')) return;

        var block = blockOf(input);
        if (!block) return;

        var file = input.files && input.files[0] ? input.files[0] : null;
        show(block, file);

        var shared = sharedOf(block);
        if (shared) show(shared, file);
    });
})();
