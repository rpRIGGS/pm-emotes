# PM Emotes — current implementation and completion plan (2026-11-11)

Branch: `development/powermoves-nui`. This document supersedes earlier plans for a temporary custom NUI shell. The active page is `client/NUI/nopixel/index.html`, using the NoPixel-style compiled UI with the RPEmotes Lua engine. Do not restart a branding redesign or substitute a temporary menu.

## Confirmed source implementation
- POWERMOVES white / RP blue (`#0438ff`) branding is in place; the oversized PM placeholder is removed. No branding work is pending.
- Animation catalogs, search, favorites, ten saved quick slots, emote execution, shared/group support, preview clone, and optional WebP bridge have source integrations. **Source integration is not verified FiveM behavior or complete reference parity.**
- Quick-slot moves swap occupied slots; persisted slots survive temporarily missing packs or permissions; commands wait for catalog readiness.
- Menu focus/preview cleanup and asynchronous catalog rebuild generation guards are implemented.
- Both GitHub workflows passed on `a4dbe53f`. Later changes require their own checks.

## Priority order — no feature work before reconciliation
1. **Document and verify reference feature parity:** inventory the original NoPixel categories and interactions against the active compiled frontend, Lua RPC dispatcher and RPEmotes features. Identify gaps explicitly; do not infer parity from file presence.
2. **Seating/placement reconciliation:** compare the original 213-model reference offsets and heading conventions against `client/PMSeating.lua`. User's actual FiveM tests: player partially below floor; after a correction, player faced backward. Mark **known failing**, not complete. Do not guess a generic seat-height/heading fix before comparison.
3. **Menu-selected sitting emote placement:** verify that selecting a sitting emote in the active NUI starts the existing `client/Placement.lua` ghost placement workflow, allows position/rotation on chairs, desks and other surfaces, and correctly confirms/cancels. Existing placement Lua alone does not establish this feature.
4. Reconcile other feature gaps found in step 1; validate end-to-end menu callbacks and gameplay paths.
5. Audit manifest, packaged assets, dependencies and installation. Produce one versioned test ZIP, then run the server acceptance checklist. AutoShot-generated WebP files are optional and **not** a blocker.

## Completion criteria
- Feature-parity matrix with evidence and explicit statuses.
- All menu-to-gameplay transitions accounted for, including sit placement and shared/group interactions.
- Both automated workflows green on the final SHA and a ZIP built from that SHA.
- FiveM acceptance completed separately; CI cannot prove seating coordinates, orientation, animations or camera behavior.

## Scope boundaries
QBCore remains the framework; preserve RPEmotes exports and existing engine. No ox_inventory migration. PM AutoShot is a separate project: its WebP assets can be dropped into the documented preview path when available. Do not change this project to depend on PM AutoShot at runtime.
