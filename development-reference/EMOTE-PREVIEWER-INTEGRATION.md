# EmotePreviewer — animated preview integration handoff

Recorded: 2026-11-12
Source: PowerMoves Development — [EmotePreviewer](https://github.com/rpRIGGS/EmotePreviewer)
Status: **Approved replacement for PM AutoShot; final media integration deferred pending exporter format and manifest validation.**

## Responsibility boundary

- **PM Emotes:** consume preview manifest in existing NUI; match original emote identifiers; render preview or placeholder; handle missing/failed media; load efficiently.
- **EmotePreviewer (Windows desktop tool):** scan existing RPEmotes-based PM Emotes catalog; render animations; generate media; track incremental changes; export media and versioned manifest/package.
- Do not implement exporter/rendering inside PM Emotes. Do not redesign the NUI as part of this handoff.

## Integration requirements

1. **Stable identity:** manifest associates each preview with its original emote ID/command and category/type as needed to avoid collisions. Generated filenames are not authoritative identifiers.
2. **Media format undecided:** APNG is being implemented and evaluated, but is **not approved** as the final FiveM NUI format. Do not assume existing WebP preview handling is the final contract.
3. **Fallback:** display a standard placeholder when a manifest entry is absent, media is missing, or loading/decoding fails. Normal emote playback must continue unaffected.
4. **Incremental updates:** adding or replacing individual media/manifest entries must not require rebuilding the entire library or NUI.
5. **Manifest-driven paths:** consume exporter-provided ID-to-media-path mapping; do not derive paths solely from filenames.
6. **Performance:** avoid decoding or playing thousands of animations at once. Load only necessary/visible previews and limit active playback to the selected/highlighted emote, with cleanup when focus/menu changes.

## Exporter status reported in handoff

- Automated catalog batch processing exists at source-code level.
- APNG export exists but is not FiveM NUI-validated.
- Incremental classification covers new, changed, failed, unchanged and removed emotes.
- Versioned persistent preview index is under development.
- Windows rendering, media compatibility and final output structure remain unverified.

## Superseded architecture and cleanup

The 2026-11-12 decision **abandons PM AutoShot**, rather than adding another optional exporter. The legacy `client/NUI/js/autoshot-previews.js`, its HTML script hook, the legacy preview asset declaration in `fxmanifest.lua`, and the old PM AutoShot development reference have been removed. No AutoShot WebP or manifest assumptions carry forward as requirements. Preserve the approved NoPixel-style NUI and all unrelated RPEmotes functionality, including **in-game emote preview and placement**. Do not add a replacement overlay or generation pipeline before the exporter contract is approved.

## Gate before final integration

Obtain and validate a sample exporter package and manifest schema (including category/ID identity, path rules, versioning and update/removal behavior), then test APNG or selected format in the FiveM NUI for display, failure fallback, performance and stale-media cleanup. Only then authorize final media integration. Continue current PM Emotes live server testing and existing priorities independently.
