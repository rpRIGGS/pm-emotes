# PM Emotes NUI and RPEmotes function parity

Reviewed: November 13, 2026

## Scope

PM Emotes uses the approved PowerMoves-branded dark NUI and keeps the existing RPEmotes Lua implementation as the gameplay backend. The reference used for this comparison is `ogidevs/rpemotes-reborn` on `main` at `12a3fc2a9c171413affd3ec91d27dffec3b8e816`, including its `App.jsx`, `EmoteCard.jsx`, `ContextMenu.jsx`, `Gizmo.jsx`, `client/EmoteMenu.lua`, and `client/PedPositioning.lua`.

## Function mapping

| Reference function | PM Emotes implementation |
| --- | --- |
| All emotes, custom categories, category counts | Existing RPEmotes queue and dynamic category construction; scenario and sitting/laying categories are additionally populated from catalog data. |
| Favorites and direct favorite action | Existing RPEmotes KVP-backed favorites and callback; favorite action on each NUI card and selected-emote panel. |
| Search and sorting | Existing live filter and RPEmotes server search; A–Z/Z–A list sorting. |
| Per-category scroll restoration | NUI stores and restores each category's scroll position in local storage. |
| Play emote from a card | Direct card action and the RPEmotes `ROUTE_EMOTE` callback. |
| Place emote | Direct card and selected-panel actions call the existing RPEmotes placement flow. The existing right-click menu action remains. |
| Adjust an eligible emote's position | Direct action is exposed only for non-shared emotes with loop/stuck flags. A screen-positioned axis gizmo and bounded sliders update the active player's position and heading; Save keeps the adjusted position, Cancel restores its starting transform. Other clients receive a validated server relay of the final transform. |
| Bind, replace, and clear keybinds | Existing RPEmotes right-click popover and keybind menu call the existing KVP-backed callbacks. |
| Shared/group emotes | Existing RPEmotes shared-emote menu and group request path remain active. |
| Expressions, walks, emojis, props, scenarios and other emote types | Existing RPEmotes catalog and callbacks remain the source of truth; expression/walk reset actions remain available. |
| Compact and draggable menu, reset layout, Escape close | Branded NUI compact toggle, draggable header, stored layout, reset action, and existing close/focus handling. |
| Animated selection preview | PM Emotes intentionally replaces the reference's per-card local WebP frame loading with the separately generated, selected-only APNG panel. Producer files stay optional; missing media leaves the placeholder. |

## Important boundaries

- The position editor provides a screen-positioned gizmo plus sliders. It does not include the reference's right-mouse camera-control gesture; verify that the branded editor is usable at the intended server resolution and camera setup.
- EmotePreviewer remains a separate Windows application. FiveM only reads its manifest and APNG assets.
- Source tests assert callback/message wiring and deterministic NUI helpers. They do not prove FiveM CEF rendering, network synchronization, animation compatibility, or the quality of position adjustments in-game.
- NoPixel code is a behavior reference, not a replacement for RPEmotes. QBCore/RPEmotes permissions, catalog behavior, keybind storage, prop lifecycle, and group synchronization continue to use this resource's existing implementation.

## Source checks

Run `node --test tests/*.test.mjs` from the repository root. The tests cover NUI card actions and escaping, RPEmotes callback registration and menu messages, plus preview manifest identity, fallback, stale-request handling, and image lifecycle.

Live acceptance is recorded in [SERVER-TEST-ACCEPTANCE.md](SERVER-TEST-ACCEPTANCE.md). In particular, verify the new position editor with multiple supported loop/stuck emotes and multiple clients, and separately retest the reported seating floor-clipping/floating on the target server.
