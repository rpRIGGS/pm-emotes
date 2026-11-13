# PM Emotes — experimental manifest adapter (Milestone 4)

`client/NUI/js/preview-library.js` is a standalone, unactivated ES module implementing the first consumer contract for EmotePreviewer's version-1 manifest. It validates immutable relative media paths, indexes by the **full** source/category/command identity (never command alone), resolves paths relative to the installed NUI library, and lazy-loads only the selected preview. Missing media falls back to a placeholder, and stale image callbacks are ignored.

**Milestone 4 source wiring is now present** in `client/NUI/js/preview-panel.js`, `main.js`, `index.html` and `overrides.css`. The preview is a selected-only panel inside the existing NUI. No gameplay preview ped or placement callbacks are modified. FiveM Chromium APNG validation remains Milestone 5; source integration does not imply runtime acceptance.

Installation contract: copy the producer's `manifest.json` and `previews/` tree under the chosen NUI directory; register these in `fxmanifest.lua` when activating. Keep paths and filenames exactly as exported. The adapter does not read the filesystem, render GTA assets, or alter RPEmotes callbacks.


## Verification command

Run `node --test tests/preview-library.test.mjs` from the PM Emotes repository root. This source test uses a lightweight mock image and does not require FiveM or Windows; successful execution is not yet asserted. The panel is imported by `main.js` and preview asset globs are declared in `fxmanifest.lua`. No generated media is bundled. Runtime testing and automated test execution still need verification.

## Source implementation checkpoint — 2026-11-12

The approved NUI now imports `preview-panel.js` from `main.js`; `preview-panel.js` consumes `preview-library.js` and `preview-identity.js`. It shows a single selected/highlighted media element, retains a placeholder for missing/ambiguous/failed previews, and clears media on menu close, menu rebuild, navigation and selection changes. The loader fetches `previews/manifest.json` opportunistically; absence is nonfatal. Preview files are external and are not committed here. Source wiring is present; **automated test execution and FiveM/APNG validation have not been established**. The latter belongs to Milestone 5.
