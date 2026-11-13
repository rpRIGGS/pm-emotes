# PM Emotes — Server test and acceptance handoff

Updated: 2026-11-13

## Current milestone

The current build is at the **install and live-test** handoff. The shipped NUI uses the approved PowerMoves dark/blue layout and retains the RPEmotes Lua routes for menu data, playback, search, favorites, keybinds, group emotes, placement, cancel, and the in-game preview ped. Direct card actions, compact/draggable mode, scroll restoration, and supported-emote position adjustment are also wired. The optional selected-emote consumer for the separate Windows EmotePreviewer export is isolated from gameplay. Source regression checks validate callback/message contracts and preview lifecycle; only FiveM can confirm NUI behavior, animations, multiplayer sync, and CEF rendering.

## Install / smoke-test sequence

1. Deploy the current `rpRIGGS/pm-emotes` resource build to the development server, keeping a backup of the installed version and local config. Check resource naming, fxmanifest paths and dependencies against the actual deployment.
2. Start the resource and inspect server console, client F8 and NUI console for startup errors. Record exact errors rather than assuming a successful start means feature readiness.
3. Open and close the emote menu. Confirm POWERMOVES is white and RP is PM Blue #0438ff; check the complete layout, category names including any custom categories, card list, count, selected-emote panel and no missing/overlapping controls.
4. Exercise every NUI interaction: category changes and per-category scroll restoration; live filtering and server search; A–Z/Z–A; quick and sidebar Favorites; favorite/unfavorite from cards, the right-click popover, and the preview panel; keyboard and mouse navigation; keybind set/clear; emoji menu; cursor toggle; compact mode, dragging, and reset; Escape/back/close; and Cancel Emote. Confirm focus returns to gameplay correctly.
5. Exercise the gameplay routes from the NUI: ordinary emote click and Use Emote; Place from both the card action/right-click popover and preview panel; Adjust Position on supported loop/stuck emotes (move each axis, rotate, Save, then separately Cancel and confirm transform restoration); group-emote request; Expressions and Walk Styles reset; prop/scenario/shared/specialized playback; in-game preview ped; and cancellation. With a second client, confirm saved position changes are visible to other players. Check animations, prop attachment/cleanup and restrictions; record unavailable catalog items rather than removing them.
6. Test seating and placement across multiple chair types and heights. The source audit found no chair-model-indexed 213-model alignment table in this repository: placement uses the camera aim point, generic ped-height offsets and optional per-emote placement metadata. A source correction makes the committed player position match the lowered position shown by the placement preview. This corrects the source-level preview/commit mismatch but does not establish chair alignment. Check first-use floor clipping, floating above chairs, repeat-use offsets, rotation, cancellation/get-up and collision. Previous live tests reported both too-low and too-high seating; acceptance remains pending FiveM retest.
7. Repeat menu, search, emote playback and in-game preview checks with **no external animated-preview files installed**. Missing external previews must leave the placeholder usable and must not affect ordinary RPEmotes behavior.
8. Install a sample EmotePreviewer export as described in `EMOTE-PREVIEWER-INTEGRATION.md`; confirm identity mapping, selected-only APNG playback, missing/failed-media fallback, cleanup on selection/navigation/close, and ordinary emote playback in FiveM CEF.
9. Record observed results and exact reproduction steps, including game model/prop name, placement coordinates where useful, screenshots/logs and tested commit SHA. Fix any issues in cohesive batches, update this handoff and retest.

## Acceptance gates

- Resource starts with no fatal errors.
- Complete branded NUI is usable; categories, search, sort, favorites, keybinds and menu controls work; navigation/selection does not leave stale overlays.
- All NUI gameplay actions reach the expected RPEmotes path, and representative animations/props/cancellation/cleanup work in FiveM. Position adjustment saves/replicates and cancel restores the transform.
- Seating aligns across representative supported chair models; no clipping/floating regression.
- Absence of externally generated animated previews does not affect normal menu, gameplay preview/placement or playback.
- All failures are documented and fixed before calling the build production-ready.

## Scope boundaries

This document records a **testing handoff**, not a claim that the features above have passed. See `development-reference/EMOTE-PREVIEWER-INTEGRATION.md` for the superseding architecture decision. The root README contains a short project-specific status note; detailed decisions remain under `development-reference/`. Do not block PM Emotes live acceptance on EmotePreviewer.
