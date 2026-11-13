# PM Emotes — final source audit and server handoff

Audit date: November 13, 2026  
Audited branch: `master`  
Starting commit: `e3f6df0f15f7fe3b94b806a6da31490dbc2a3d40` (`e3f6df0`)

## Source audit

- Reviewed the existing NUI-to-Lua event and callback flow, menu construction, the preview consumer, identity resolver and library, `fxmanifest.lua`, placement flow, emote data, recent history and development references.
- Reconciled the shipped HTML/CSS with the approved PowerMoves dark/blue NUI reference. Added the POWERMOVES white / RP #0438ff lockup, category navigation, list toolbar, selected-emote panel and Use/Place/Favorite actions. Removed the visible `Hiii` custom-category placeholder and updated generated categories to use the same sidebar markup.
- Kept RPEmotes' Lua callback names and message contracts in place. Added source regression checks confirming every NUI callback is registered by Lua, the expected menu hooks and data messages remain, and the expected gameplay routes are wired.
- Kept the existing emote-card click, right-click popover, keyboard navigation, search, dynamic categories, favorites, keybinds, cancel action and in-game preview ped pathways. The new panel's Use/Place/Favorite actions call the same `ROUTE_EMOTE` and `FAVORITE_EMOTE` Lua callbacks.
- Hardened menu switching against the absence of a previously active category button.
- Kept preview generation outside FiveM. PM Emotes consumes `previews/manifest.json` and media if installed; the files are optional. Missing manifest or media leaves the existing placeholder/menu usable.
- `fxmanifest.lua` includes the manifest and nested PNG path. The exporter paths resolve under `client/NUI/previews/` when its `previews/` directory is copied there as documented.
- The selected-only preview panel remains optional and isolated from animation generation and gameplay. No original gameplay callback or unrelated RPEmotes feature was intentionally replaced.
- Corrected a misleading source comment: the consumer is active in `main.js`; FiveM CEF playback acceptance is still pending.
- Added regression coverage for exporter-shaped metadata, changing selection while image callbacks are outstanding, and out-of-order manifest responses.
- Corrected placement destination Z to match the lowered position displayed by the translucent preview ped. This fixes the source-level preview/commit mismatch; it does not establish chair alignment.

## Producer contract review

Reviewed `rpRIGGS/EmotePreviewer` at commit `a3d5f9e`. Its exporter publishes schema version 1, format `experimental-apng`, identity fields `id/source/category/command`, `format: "apng"`, and immutable paths matching `previews/<stem>/<runId>/preview.png`. Additional capture metadata is ignored by PM Emotes. The contracts match, so no producer-side change was warranted.

No real Windows export was available in the PM Emotes repository during this audit. Source compatibility is verified; media presence, capture quality and FiveM APNG playback are not.

## Seating and placement finding

This repository does not contain a chair-model-indexed 213-model alignment table. Its placement flow uses a camera ray, generic ped-height offsets, and emote placement metadata. The prior floor-clipping and floating reports therefore remain runtime acceptance items. The source correction keeps the player destination consistent with the preview; multiple chairs, ped models and elevations must still be tested in FiveM before calling seating resolved.

## Verification

`node --test tests/*.test.mjs` in this repository: **18 passed, 0 failed** (includes the RPEmotes/NUI callback-contract checks).

ES-module syntax checks for the modified NUI JavaScript files and `git diff --check` also passed. These are source-level validations; they do not execute FiveM APIs or CEF rendering.

Coverage includes supported/unsupported manifests, safe paths, duplicate and ambiguous identity handling, missing manifest/media fallback, selected-only lifecycle, stale image callbacks, out-of-order manifest loads, and an exporter-shaped manifest with extra metadata.

Static packaging review: `fxmanifest.lua` declares `client/NUI/previews/manifest.json` and `client/NUI/previews/**/*.png`; no preview package is bundled, preserving the optional fallback path.

No live FiveM server or FiveM CEF runtime was available for this audit. Therefore NUI appearance and interaction, game animation playback/cleanup, APNG playback in CEF, and chair placement alignment remain unaccepted until the exact server checklist is run. Source callback presence verifies wiring, not runtime success.

## Exact remaining server steps

Follow [SERVER-TEST-ACCEPTANCE.md](SERVER-TEST-ACCEPTANCE.md): deploy this commit to the development server; inspect server, F8 and NUI consoles; verify the approved NUI and standard RPEmotes flows; test seating on multiple chair models/heights for clipping, floating, repeat use, rotation and cancel/get-up; then install one real EmotePreviewer export and verify hover/focus display, APNG animation, missing-media fallback, navigation/close cleanup, and ordinary emote playback. Record the server build SHA, chair/prop names, reproduction details and logs before updating the acceptance status.
