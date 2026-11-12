# PM Emotes — reference capability inventory

## Active callback trace — first reconciliation findings (2026-11-11)

This trace is based on the active source, not assumptions about the original reference.

- The active compiled NoPixel frontend communicates through `PM_NP_RPC`. Its dispatcher handles **ten event names**: `emotes:getEmotes`, `emotes:getFavorites`, `emotes:getQuickEmotes`, `emotes:preview`, `emotes:clearPreview`, `emotes:close`, `emotes:play`, `emotes:setFavorite`, `emotes:moveQuickEmote`, `emotes:setQuickEmote`. **There is no `emotes:place` / placement event in this dispatcher.**
- A legacy `ROUTE_EMOTE` callback **does** support `data.type == 'placement'` and calls `StartNewPlacement(data.emoteName)`, but restricts this path to `EmoteType.PROP_EMOTES`. That does **not** prove the active NoPixel frontend offers a sit-placement action, and the restriction needs examination against the intended sitting-emote catalog.
- `emotes:play` validates a requested catalog item and routes ordinary animations to `RouteEmoteToFunction`; shared animations go to `SendSharedEmoteRequest`. It has **no placement branch**. **Menu-selected sitting emote placement is an identified integration gap pending full frontend trace**, not a verified feature.
- `client/Placement.lua` exposes `StartNewPlacement(emoteName, options)`. The original menu code in `client/EmoteMenu.lua` also has a placement call, but that alone does not make it accessible from the active NoPixel UI.
- `client/PMSeating.lua` holds the model-specific `x/y/z/heading` reference data, but its active `PMToggleNearbySeat` computes Z using `GetModelDimensions` and `math.max(0.0, boundsMax.z - 0.45)`, then adds `config.heading` to the chair entity heading. The imported `config.z` is not used in the active positioning calculation. This is a **specific deviation requiring reference coordinate-space comparison**, not proof of a correct replacement formula.
- The user reported two failed FiveM seating outcomes: below-floor placement and backward-facing placement. Status: **known failing**.

### Next reconciliation tasks

1. Inspect the active compiled frontend for actual placement controls and RPC payloads; map each user action to the dispatcher above.
2. Compare the original reference's seat position and heading transforms to `PMToggleNearbySeat` (including whether Z offsets apply to entity origin, world coordinates, or scenario ped origin).
3. Inventory any other reference actions lacking an active NUI route and update this matrix before gameplay fixes.

**Do not declare reference feature parity or mark sitting placement complete from the presence of Lua modules.**

---

## Reconciliation update — 2026-11-11

**Do not use the older file references and implementation labels below as a current completion claim.** The active UI is `client/NUI/nopixel/index.html` with `assets/index-80592477.js`, `assets/index-5495b930.css` and optional `assets/pm-autoshot-bridge.js`. Its NoPixel RPC adapter is in `client/NUI/EmoteMenuNUI.lua`. The legacy `client/NUI/js/main.js` and earlier custom-NUI plans are not the active frontend.

| Capability | Current source evidence | Reconciled status |
|---|---|---|
| PowerMoves branding | Active HTML/CSS and compiled NUI | Implemented; do not reopen redesign |
| Search, catalog, dances, props, expressions, walks | NoPixel frontend + `PM_NP_RPC` adapter + RPEmotes engine | Integrated; detailed feature-parity and FiveM validation pending |
| Favorites and ten quick slots | `client/Favorites.lua`; NUI RPC; KVP persistence; 0–9 browser mapping | Integrated; automated checks passing, gameplay acceptance pending |
| Live cloned-ped hover | `client/NUI/PMPreview.lua` and NUI preview RPC | Integrated; FiveM camera/prop cleanup acceptance pending |
| Optional preview images | `pm-autoshot-bridge.js` and manifest WebP glob | Optional integration; generated files supplied by separate PM AutoShot project later |
| 213-model nearby seating | `client/PMSeating.lua` | **Known failing in user testing:** floor clipping and backward facing; original offsets/heading need reconciliation |
| Choose sit emote and place on arbitrary furniture/surface | `client/Placement.lua` exists; active NUI route not yet proven | **Not verified; required feature** |
| Shared/group and placement | Existing Lua engine and NUI route | Source integration present; end-to-end feature parity not established |

**Next step is a full reference-to-active-frontend-to-Lua parity audit, before speculative seating fixes.** Compare the original per-model seating coordinates and rotation convention first; then verify menu-selected sit placement wiring. Only after this audit should implementation gaps be prioritized. Automated CI success is not a substitute for a FiveM test.

---


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

## Quantitative catalog audit — 2026-11-10

The figures below come from direct static parsing of the reference's `[QB]/emotes` catalog files and the target's `client/AnimationList.lua`. They are **not** a runtime or behavioral parity percentage.

| Reference catalog | Reference definitions | PM catalog / raw ID overlap | Gap interpretation |
|---|---:|---:|---|
| Regular emotes | 475 entries (471 distinct IDs) | 346 reference IDs found somewhere in PM | At least 129 reference IDs absent by exact name; aliases and animation equivalence still need analysis |
| Dances | 3,889 entries (29 marked disabled) | 120 PM dance entries parsed, 36 matching animation dictionary + clip pairs | 3,853 reference dance pairs not found in PM's dance section by exact pair |
| Synced | 30 entries (29 distinct IDs) | 7 IDs found in PM overall | Paired roles and synchronization must be compared; ID overlap is not feature equivalence |
| Placed | 22 entries | 20 IDs found in PM overall | 2 missing by exact ID; PM's generic placement engine may support equivalent behavior |
| Chair/seat models | 230 prop entries | No comparable prop-model seating table established | **Distinct capability gap:** model-aware seat offsets and sit targeting require dedicated implementation or verified equivalent |
| Walk styles | 50 entries | PM has 139 walk definitions | Must compare movement clipset values rather than labels |
| Expressions | 19 entries | PM has 38 expression definitions | Must compare facial animation values rather than labels |
| Animals | Species-specific Lua actions | PM has 118 animal-emote entries | Species/action mapping not yet normalized |

### Important qualification

The reference contains repeated IDs and some disabled animations. Exact ID and dictionary/clip comparisons are intentionally conservative and **cannot** be used as proof of functional equivalence. The dance count includes a large set of GTA clip variants; loading all 3,889 into the NUI without filtering, validation and usability work is **not** automatically desirable.

### Confirmed follow-up work

1. Generate a normalized, machine-readable reference-to-PM coverage map for animation dictionaries, clips, IDs and flags.
2. Implement model-aware chair interaction only after confirming that PM does not already provide equivalent functionality.
3. Audit paired-emote sender/receiver mapping and missing animal actions.
4. Decide which reference dance variants are usable and not disabled, then add missing valid entries with stable PM identifiers and preserved licensing notices.
5. Verify all relevant behaviors in FiveM; a static catalog match cannot prove animations load.

## Implementation update — 2026-11-10

A first substantial dance-catalog implementation has now been committed:
- 1,620 enabled GTA dance clips were appended to the native `RP.Dances` table in `client/AnimationList.lua`.
- 2,212 more enabled dance clips were added in `client/PMDanceCatalog01.lua` through `client/PMDanceCatalog05.lua`, loaded in `fxmanifest.lua` after the base and custom catalogs.
- 3,832 total supplemental dance entries were added. They use stable `pmdance...` IDs and existing RPEmotes animation options.
- Original animation metadata source is MIT licensed; the notice is retained in `development/THIRD-PARTY-NOTICES.md`.
- The supplemental files are now subject to Lua syntax checks in GitHub Actions.

**Important:** this is catalog implementation, not confirmation that all clips stream and play in FiveM. The full reference includes 29 disabled dance entries, which were deliberately excluded. Other catalogs (chair models, synced pairs, animals, etc.) remain to be implemented or mapped individually.

## NUI and workflow parity audit (code-level)

The reference's `[QB]/emotes/fxmanifest.lua` still imports `@npx/client/lib.js`, `@npx/server/lib.js` and `@eon-sync/client/lib.lua`; its QBCore folder therefore does **not** imply that the full implementation is self-contained QBCore. PM must preserve its own working QBCore-compatible backend and avoid those runtime dependencies.

| User-visible workflow | PM implementation path | Verified by inspection | Runtime acceptance still required |
|---|---|---|---|
| Open/close NUI and input focus | `client/NUI/EmoteMenuNUI.lua`, `main.js` | OPEN_MENU, CLOSE_MENU, focus handling present | Open/close from all configured bindings; no stuck controls |
| Category rail and custom categories | `EmoteMenuNUI.lua` `loadEmoteDataToNUI`; `main.js` LOAD_EMOTE_DATA | Dynamic categories present; stable fallback icon added | Custom category creation, order, icon and navigation |
| Search and filtering | `SEARCH_EMOTES`, `HandleEmoteSearch`, `HandleEmoteFilter` | Callback and JS handlers present | Search while navigating, keyboard focus, large catalogs |
| Preview selected emote | `PREVIEW_EMOTE`, `PMPreview.lua`, `Emote.lua` | Clone, camera, playback and cleanup paths present | Camera framing, scenario behavior, fast-switch props |
| Play/cancel/reset | `ROUTE_EMOTE`, `CANCEL_EMOTE` | Callback paths present | Correct playback, reset and cancellation |
| Paired emote initiation | `ROUTE_EMOTE` groupemote, `GroupEmote.lua` | Request path present | Sender/receiver offset, consent, interruption |
| Placement | `ROUTE_EMOTE` placement, `Placement.lua` | Placement entry path present | Position/rotation and cancel/confirm |
| Favorite toggle and persistence | `FAVORITE_EMOTE`, `Favorites.lua` | Serverless KVP favorites present | Rebuild, reload, keyboard and mouse |
| Keybind management | `KEYBIND_EMOTE`, `Keybinds.lua` | Set/clear callbacks present | Persist, overwrite, clear, execute |
| Walk and expression reset | `ROUTE_EMOTE` _reset | Dedicated reset logic present | Persistence and reset |
| Sound and localization | `PLAY_SOUND_FRONTEND`, `GET_LOCALES` | Callback paths present | Missing locale handling |
| Mouse/keyboard navigation | `navigation.js`, `main.js` | Navigation, focus, pointer paths present | Tab, shift, search focus, context menu |
| Model-aware seat interaction | No matching PM chair-prop map identified | **Not implemented / not proven** | Prop lookup, offsets, occupancy, cancel |
| Animal-specific interactions | `AnimationList.lua` animal emotes | Partial catalog | Species restrictions, special native actions |
| Reference UI visual parity | `index.html`, `overrides.css` | Three-panel custom layout present | Browser screenshot, in-game composition and responsive widths |

**Code-inspection status is not functional verification.** A callback existing does not prove the complete end-to-end interaction works. This table is the implementation and acceptance register; do not silently promote any item to complete without its corresponding checks.
