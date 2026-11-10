# PM Emotes — reference capability inventory

This is an engineering gap inventory against the externally supplied example, not an assertion of parity. The external project is reference-only: do not copy its bundled UI, proprietary assets, or compiled runtime. PM Emotes retains the RPEmotes Reborn engine and implements original NUI integration.

## Comparison baseline

Reference: `lumo073/emotes-nopixel-4.0`, `[QB]/emotes`, tree `86c4e998307800896b702d5baa60798f1ba13be1`.
Target: `rpRIGGS/pm-emotes`, branch `development/powermoves-nui`.

| Capability in reference | Reference evidence | PM Emotes evidence | Classification | Remaining implementation / acceptance |
|---|---|---|---|---|
| Searchable emote catalog | `emotes.js`, NUI dist | `client/AnimationList.lua`, `client/NUI/js/main.js` | Existing engine and menu | Confirm results, category filtering, and no stale results |
| Dances | `dances.js` | `client/AnimationList.lua` dance catalog | Existing equivalent | Compare catalog coverage and animation metadata |
| Synchronized paired animations | `synced.js` | `client/GroupEmote.lua`, `client/Syncing.lua` | Existing equivalent, not identical | Verify request/accept, offsets, cancellation, two-player playback |
| Placed animations | `placed.js` | `client/Placement.lua` | Existing equivalent | Verify positioning, rotation, confirmation, cancellation |
| Walk styles | `walks.js` | `client/Walk.lua`, NUI walks | Existing equivalent | Verify selection, persistence/reset, preview semantics |
| Expressions | `expressions.js` | `client/Expressions.lua`, NUI moods | Existing equivalent | Verify preview and actual player facial override/reset |
| Animal animations | `animals.lua` | `client/AnimationList.lua` animal-tagged entries | Partial catalog equivalent | Audit species, models, playback restrictions and missing actions |
| NUI categories/icons | `nui/dist/*.svg`, compiled UI | `client/NUI/index.html`, `css/overrides.css`, `js/main.js` | Implemented custom interface | Check all categories and responsive presentation |
| Live character preview | Compiled client and NUI | `client/NUI/PMPreview.lua`, `client/Emote.lua` | Implemented but unverified | Verify camera composition, prop lifecycle, ped cleanup, scenario animations |
| Favorites | `nui/dist/favorites.svg`, compiled UI | `client/Favorites.lua`, NUI favorites | Existing equivalent | Confirm persistence, add/remove, search interactions |
| Emote prop support | Animation definitions / compiled client | `client/Emote.lua` | Existing equivalent with new preview fixes | Verify single/dual props, no leak, player props unaffected |
| Additional catalogs / category names | `emotes.js`, `dances.js`, `placed.js`, `synced.js` | RPEmotes catalog categories | NOT inventoried item-by-item | Produce normalized catalog coverage report before claiming 100% parity |
| Keyboard and mouse operation | NUI compiled assets | `client/NUI/js/navigation.js`, `main.js` | Existing plus recent fixes | Browser and FiveM interaction checks |
| Server/network dependencies | `fxmanifest.lua`, `build/cl_main.js`, `build/sv_main.js` | Native RPEmotes Lua client/server | Deliberately different architecture | Do not import npx/eon/NP dependencies; verify equivalent interactions |

## What is **not** established

- No complete catalog-to-catalog ID/animation dictionary comparison has been performed.
- The reference's bundled client JavaScript is compiled; its internal UI callbacks, state transitions, and runtime behaviors have **not** been exhaustively reverse-mapped.
- No FiveM live test of PM's new preview camera, player safety, or prop cleanup has been completed.
- Reference-only features beyond the documented categories have not yet been proven implemented.
- The external example is not a drop-in QBCore dependency: its manifest declares `@npx` and `@eon-sync` dependencies.

## Completion gate

1. Enumerate every reference category and normalize IDs and animation metadata; compare to the target catalog.
2. Identify missing distinct capabilities (not just different names or existing equivalent emotes).
3. Implement the approved equivalents natively in PM Emotes without importing compiled code or external framework dependencies.
4. Audit and validate all NUI callback paths and state transitions.
5. Run static checks and browser interaction checks; then perform a FiveM acceptance pass for camera, sync, placement and props.
6. Add final logo and secondary color without changing runtime behavior.

**Status:** inventory started, feature parity NOT established. Do not report 100% implementation based only on existing RPEmotes modules or a passing syntax check.
