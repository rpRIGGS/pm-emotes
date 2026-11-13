# EmotePreviewer — producer/consumer integration

Updated: 2026-11-13

Status: **The producer/consumer contract and PM Emotes NUI source integration are implemented. Real exported-media and FiveM CEF acceptance tests remain outstanding.**

## Responsibility boundary

- **EmotePreviewer** is a separate Windows desktop application. It reads the PM Emotes resource catalog and the user's GTA V Legacy files, previews supported catalog entries, and exports APNG files plus a manifest and producer-side index/report.
- **PM Emotes** consumes an installed manifest and media in its existing NUI. It maps menu commands conservatively, shows the selected/highlighted preview or a placeholder, and leaves emote gameplay and the existing in-game ped preview/placement behavior alone.
- Preview rendering and generation do not run inside FiveM. PM AutoShot was retired.

## Export and install contract

EmotePreviewer produces `manifest.json` at the export root, with `schemaVersion: 1`, `format: "experimental-apng"`, and entries containing `id`, `source`, `category`, `command`, `format: "apng"`, and an immutable media path such as `previews/<stem>/<runId>/preview.png`. Exports also contain `preview-index.json` and `report.json`; PM Emotes consumes the manifest and preview files, not the producer index/report.

To install a sample export for acceptance testing:

1. Copy the export root `manifest.json` to `client/NUI/previews/manifest.json`.
2. Copy the exported `previews/` directory into `client/NUI/`, preserving all names and relative paths.
3. Ensure the server resource includes the updated `fxmanifest.lua` entries and restart the resource.

The `fxmanifest.lua` already declares `client/NUI/previews/manifest.json` and `client/NUI/previews/**/*.png`. The NUI requests `previews/manifest.json`; absent media is nonfatal and leaves the placeholder active.

## Consumer behavior and identity

`main.js` initializes `preview-panel.js` at NUI startup. The panel loads only the selected/highlighted preview and releases image requests on selection changes, navigation, menu rebuild and close. Missing, ambiguous or failed entries retain the placeholder. Normal emote playback and the in-game ped preview/placement flow remain separate.

Producer identity is the full `source/category/command` tuple. The existing NUI menu supplies an emote command and menu type, but menu type is not a verified producer category. `preview-identity.js` therefore resolves a command only when it maps to exactly one manifest entry; duplicates intentionally receive no animated preview instead of risking a mismatched animation.

## Verification boundary and remaining acceptance

The exporter source was checked at `rpRIGGS/EmotePreviewer` commit `a3d5f9e` (November 13, 2026). Its publication code writes the version-1 `experimental-apng` manifest and the same `previews/<stem>/<runId>/preview.png` path pattern accepted here. The entry's identity and `format: "apng"` fields match; capture profile, frame count, duration, dimensions, publication ID and note are additional fields the consumer safely ignores. No contract mismatch required a producer change. The adapter and its regression tests validate the source-level schema, path rules, identity behavior, fallback and lifecycle. That does **not** establish GTA-backed capture quality or animated APNG playback in FiveM Chromium/CEF. No real export is bundled in this repository, and no FiveM playback is claimed as verified.

Run `node --test tests/preview-*.test.mjs` from the repository root. For desktop/server acceptance, install a real export, inspect identity resolution across duplicate commands, confirm APNG animation and fallback in FiveM, verify cleanup and performance, and confirm ordinary emotes plus the existing in-game preview/placement still work.

See [PREVIEW-IDENTITY-RECONCILIATION.md](PREVIEW-IDENTITY-RECONCILIATION.md), [PREVIEW-MANIFEST-ADAPTER.md](PREVIEW-MANIFEST-ADAPTER.md), and [SERVER-TEST-ACCEPTANCE.md](SERVER-TEST-ACCEPTANCE.md).
