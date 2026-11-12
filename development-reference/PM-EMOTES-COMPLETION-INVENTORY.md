# PM Emotes — controlling completion inventory (reconciled 2026-11-11)

Branch: `development/powermoves-nui`. This is the controlling status checklist. Detailed reference comparisons live in [capability inventory](../development/REFERENCE-CAPABILITY-INVENTORY.md); test procedures in [server acceptance](../tests/SERVER_ACCEPTANCE.md).

## Evidence and statuses

| Area | Source evidence | Status / gate |
|---|---|---|
| Active NUI | `fxmanifest.lua` -> `client/NUI/nopixel/index.html`; compiled assets | Integrated; visual FiveM acceptance pending |
| Branding | POWERMOVES white / RP blue `#0438ff` | Implemented; no redesign pending |
| Catalog / search / dance packs | `EmoteMenuNUI.lua`; `PMDanceCatalog01..05.lua` | Integrated; reference feature coverage and in-game checks pending |
| Favorites and quick slots | Ten active `emotes:*` RPC calls all matched by Lua branches; KVP quick slots | Integrated; persistence/gameplay checks pending |
| Synced / group | `Syncing.lua`, `GroupEmote.lua`, Lua routing | Existing engine; active UI behavior and two-player test pending |
| Live preview | `PMPreview.lua`; hover RPC | Integrated; camera/props/interior checks pending |
| Optional WebP | `pm-autoshot-bridge.js`; preview manifest path | Optional; **not a release blocker** |
| Manual sit emote placement | `Placement.lua` exists, legacy `ROUTE_EMOTE` placement callback exists; active frontend lacks placement RPC | **Confirmed active-menu integration gap**; must expose sit-placement workflow |
| Nearby 213-model seating | `PMSeating.lua`, `/pmsit`, `/pmstand` | **Known failing in user's FiveM tests:** below-floor placement, then backward facing; reference offsets/heading reconciliation required |
| Release CI | Both GitHub workflows green on `a4dbe53f` | Verified at that SHA; latest changes require green runs |
| ZIP | Release workflow packages `pm-emotes-server-test.zip` in `pm-emotes-server-test` artifact | Packaging implemented; obtain final-SHA artifact before test |

## Completed source-level audit

1. Active frontend uses ten `emotes:*` RPC event names, all with matching `PM_NP_RPC` branches. **Name coverage is not behavioral parity.**
2. Lua sends `emotes:open` / `emotes:closeUI`; the active frontend registers both.
3. Legacy-only callbacks including `SIT_NEARBY` and `ROUTE_EMOTE` placement do **not** establish active-menu access.
4. Compiled frontend contains an inherited `__npx_sdk:sockets:init` path; no PowerMoves SDK socket service is supplied. Check harmless fallback rather than introducing a new runtime dependency.
5. Current nearby seating computes height from model dimensions and does not use the per-chair `config.z` values retained in its model table. Do not guess replacement offsets before comparing reference coordinate transforms.

## Next work in order

1. **Finish reference reconciliation:** original seat-coordinate/heading transforms, placed-emote controls and other user-facing reference actions vs active NUI; record precise gaps.
2. **Implement verified gaps in coherent batches:** active-menu sit placement and reference-correct seating behavior, plus any other confirmed missing actions.
3. **Run integration, regression, manifest, package and CI audits** on the final SHA.
4. **Deliver a complete test ZIP**, then conduct FiveM acceptance with user, including reported seating failures. Keep failed scenarios open until corrected.

## Scope guardrails

Keep QBCore, qb-inventory, RPEmotes engine and public exports. Do not substitute a temporary UI or reopen settled branding. PM AutoShot is separate and optional. Do not claim 100% reference parity, live FiveM acceptance or finished seating based solely on source inspection or green CI.
