# PM Emotes — experimental manifest adapter (Milestone 4)

`client/NUI/js/preview-library.js` is a standalone, unactivated ES module implementing the first consumer contract for EmotePreviewer's version-1 manifest. It validates immutable relative media paths, indexes by the **full** source/category/command identity (never command alone), resolves paths relative to the installed NUI library, and lazy-loads only the selected preview. Missing media falls back to a placeholder, and stale image callbacks are ignored.

**Activation is deliberately deferred** pending actual FiveM Chromium APNG verification and an audited mapping between the producer catalog's source/category/command and PM Emotes' `data-emoteid`/`data-emotetype`. Do not wire this module into the approved NoPixel NUI or change the existing in-game preview ped until that mapping and playback are verified.

Installation contract: copy the producer's `manifest.json` and `previews/` tree under the chosen NUI directory; register these in `fxmanifest.lua` when activating. Keep paths and filenames exactly as exported. The adapter does not read the filesystem, render GTA assets, or alter RPEmotes callbacks.
