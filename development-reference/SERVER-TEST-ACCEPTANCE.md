# PM Emotes — Server test and acceptance handoff

Updated: 2026-11-13

## Current milestone

The current build is at the **install and live-test** handoff. The obsolete PM AutoShot preview overlay has been retired. A selected-only NUI consumer for the separate Windows EmotePreviewer export is wired into source, but real exported media has not yet been accepted in FiveM CEF. Offline audits and source tests do not establish runtime acceptance.

## Install / smoke-test sequence

1. Deploy the current `rpRIGGS/pm-emotes` resource build to the development server, keeping a backup of the installed version and local config. Check resource naming, fxmanifest paths and dependencies against the actual deployment.
2. Start the resource and inspect server console, client F8 and NUI console for startup errors. Record exact errors rather than assuming a successful start means feature readiness.
3. Open and close the emote menu; confirm the approved POWERMOVES (white) RP (PM Blue #0438ff) branding, full NUI layout, category navigation, search, focus and keyboard controls.
4. Execute and cancel representative ordinary, prop, scenario, shared and specialized emotes; check animations, props, cleanup, and restrictions. Log any unavailable entry without silently removing it.
5. Test the **213-model seating/placement system** on multiple chair types and heights. Specifically check first-use clipping into floor, floating above chair, repeat-use offsets, rotation, cancellation/get-up and collision. Previous live tests reported both too-low and too-high seating; no fix is accepted until live retest.
6. Confirm the menu works with **no externally generated animated-preview package** and the placeholder remains usable. Existing in-game RPEmotes preview and placement functionality must remain available.
7. Install a sample EmotePreviewer export as described in `EMOTE-PREVIEWER-INTEGRATION.md`; confirm identity mapping, selected-only APNG playback, failure fallback, cleanup and ordinary emote playback in FiveM CEF.
8. Record observed results and exact reproduction steps, including game model/prop name, placement coordinates where useful, screenshots/logs and tested commit SHA. Then fix issues in cohesive batches, update this handoff, and retest.

## Acceptance gates

- Resource starts with no fatal errors.
- Complete branded NUI is usable and navigation/selection does not leave stale overlays.
- Representative emote playback and cleanup work in FiveM.
- Seating aligns across representative supported chair models; no clipping/floating regression.
- Absence of externally generated animated previews does not affect normal menu, gameplay preview/placement or playback.
- All failures are documented and fixed before calling the build production-ready.

## Scope boundaries

This document records a **testing handoff**, not a claim that the features above have passed. See `development-reference/EMOTE-PREVIEWER-INTEGRATION.md` for the superseding architecture decision. The root README contains a short project-specific status note; detailed decisions remain under `development-reference/`. Do not block PM Emotes live acceptance on EmotePreviewer.
