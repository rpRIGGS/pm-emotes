# PM Emotes — November 10 inventory reconciliation (updated November 11)

This is the **controlling completion checklist**, not a new feature roadmap.
Branch: `development/powermoves-nui`. Keep PM AutoShot work inside the
existing NoPixel NUI scope.

## 1. Resource inventory — source inspected

| Area | Evidence | Status |
| --- | --- | --- |
| Active NoPixel NUI | `fxmanifest.lua` points to `client/NUI/nopixel/index.html`; compiled JS/CSS present | Integrated in source; visual parity not verified |
| Branding | NoPixel page title and compiled UI include POWERMOVES RP and PM blue | Present; in-game visual check pending |
| Emote catalog | `client/NUI/EmoteMenuNUI.lua` builds a shared catalog and exposes `emotes:getEmotes` | Integrated; completeness pending server test |
| Search/categories | Compiled NoPixel UI includes category browsing; catalog maps emote types | Integrated; UX pending server test |
| Favorites | `emotes:getFavorites` / `emotes:setFavorite`, stable animation type and permission checks | Integrated; persistence pending server test |
| Quick slots | Ten persisted slots, `emotes:getQuickEmotes` / `emotes:setQuickEmote`; no default inventory number-key overrides | Integrated; in-game keybind test pending |
| Animation playback | `emotes:play` routes through existing RPEmotes animation engine | Integrated; animation-by-animation test pending |
| Synced/group | Existing shared request and group emote handlers retained | Integrated; two-player test pending |
| Prop/placement | Existing placement and prop handlers retained | Integrated; in-game test pending |
| Live character preview | `client/NUI/PMPreview.lua` clones local ped, creates camera, cleans up on close/stop | Integrated; interior/prop/concurrency tests pending |
| PM AutoShot | Optional version 1 WebP manifest, active NoPixel bridge, live preview fallback | Integrated; capture installer and CEF test pending |
| Seating | `client/PMSeating.lua` model-aware seating plus `/pmsit`, `/pmstand` | Integrated; 213-model coverage/runtime test pending |
| Release validation | `tests/validate_pm_emotes.py`, GitHub Actions syntax checks and ZIP artifact workflow | Authored; successful run not yet confirmed |
| Test ZIP | Workflow packages `pm-emotes-server-test.zip` | **Not yet confirmed built/downloadable** |

## 2. Completion order — no detours

1. **Close integration defects** across the active NoPixel frontend, Lua RPC,
   preview lifecycle, catalog identity, and optional AutoShot assets.
2. **Run the automated release gates** and fix actual failures. A source-only
   review does not count as a successful CI run.
3. **Build and obtain the complete resource ZIP**, with the actual manifest,
   all bundled UI assets, and runtime files. Confirm the archive is accessible.
4. **Test in FiveM** against `tests/SERVER_ACCEPTANCE.md`: F4, categories,
   search, favorites, quick slots, animations, two-player sync, props,
   seating, previews, close/reopen, resource restart, and F8 errors.
5. **Mark complete only after those checks pass.** Keep test failures as
   specific actionable items; do not silently claim runtime verification.

## 3. Release blockers (truthful status)

- No confirmed passing GitHub Actions run/artifact in this review.
- No completed in-server FiveM acceptance pass.
- Visual fidelity to the requested NoPixel reference has not been verified
  by an actual game screenshot.
- PM AutoShot generated captures have not been deployed and observed in CEF.

## 4. Scope discipline

No replacement temporary UI. No migration away from QBCore, qb-inventory,
or the existing RPEmotes animation engine. No new unrelated feature work.
Do not confuse a merged source change with a verified working resource.
