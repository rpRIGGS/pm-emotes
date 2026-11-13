# PM Emotes — final source audit and server handoff

Audit date: November 13, 2026  
Audited branch: `master`  
Starting commit: `67c3eab67e` (`67c3eab`)

## Source audit

- Reviewed the current NUI preview consumer, its identity resolver and library, the approved NUI markup/styles, `fxmanifest.lua`, placement flow, emote data, recent history and existing development references.
- Kept preview generation outside FiveM. PM Emotes consumes `previews/manifest.json` and media if installed; the files are optional. Missing manifest or media leaves the existing placeholder/menu usable.
- `fxmanifest.lua` includes the manifest and nested PNG path. The exporter paths resolve under `client/NUI/previews/` when its `previews/` directory is copied there as documented.
- The selected-only preview panel remains part of the approved NUI. The POWERMOVES/RP branding and unrelated menu features were not redesigned.
- Corrected a misleading source comment: the consumer is active in `main.js`; FiveM CEF playback acceptance is still pending.
- Added regression coverage for exporter-shaped metadata, changing selection while image callbacks are outstanding, and out-of-order manifest responses.
- Corrected placement destination Z to match the lowered position displayed by the translucent preview ped. This fixes the source-level preview/commit mismatch; it does not establish chair alignment.

## Producer contract review

Reviewed `rpRIGGS/EmotePreviewer` at commit `a3d5f9e`. Its exporter publishes schema version 1, format `experimental-apng`, identity fields `id/source/category/command`, `format: "apng"`, and immutable paths matching `previews/<stem>/<runId>/preview.png`. Additional capture metadata is ignored by PM Emotes. The contracts match, so no producer-side change was warranted.

No real Windows export was available in the PM Emotes repository during this audit. Source compatibility is verified; media presence, capture quality and FiveM APNG playback are not.

## Seating and placement finding

This repository does not contain a chair-model-indexed 213-model alignment table. Its placement flow uses a camera ray, generic ped-height offsets, and emote placement metadata. The prior floor-clipping and floating reports therefore remain runtime acceptance items. The source correction keeps the player destination consistent with the preview; multiple chairs, ped models and elevations must still be tested in FiveM before calling seating resolved.

## Verification

`node --test tests/*.test.mjs` in this repository: **15 passed, 0 failed**.

Coverage includes supported/unsupported manifests, safe paths, duplicate and ambiguous identity handling, missing manifest/media fallback, selected-only lifecycle, stale image callbacks, out-of-order manifest loads, and an exporter-shaped manifest with extra metadata.

Static packaging review: `fxmanifest.lua` declares `client/NUI/previews/manifest.json` and `client/NUI/previews/**/*.png`; no preview package is bundled, preserving the optional fallback path.

FiveM server, CEF APNG playback, and chair placement acceptance were not run in this environment.

## Exact remaining server steps

Follow [SERVER-TEST-ACCEPTANCE.md](SERVER-TEST-ACCEPTANCE.md): deploy this commit to the development server; inspect server, F8 and NUI consoles; verify the approved NUI and standard RPEmotes flows; test seating on multiple chair models/heights for clipping, floating, repeat use, rotation and cancel/get-up; then install one real EmotePreviewer export and verify hover/focus display, APNG animation, missing-media fallback, navigation/close cleanup, and ordinary emote playback. Record the server build SHA, chair/prop names, reproduction details and logs before updating the acceptance status.
