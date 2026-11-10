# PM Emotes — implementation reference

## Scope
Modernize the existing RPEmotes Reborn NUI for PowerMoves RP while retaining the existing emote engine and public exports. This is a QBCore-oriented fork. No external framework runtime or copied third-party compiled frontend is required.

## Branding
- Primary accent: `#0438FF`
- Secondary gray: placeholder until the official color is provided
- Logo: temporary text treatment, replaced with the supplied transparent PowerMoves Roleplay PNG
- The GitHub README banner is independent of the in-game NUI

## Existing code to preserve
- `client/Emote.lua` — animation execution and preview ped handling
- `client/Placement.lua` — transparent ped placement, rotation and confirmation
- `client/Favorites.lua` — persistent favorites
- `client/GroupEmote.lua` and `client/Syncing.lua` — group/shared emotes
- `client/Expressions.lua`, `client/Walk.lua`, `client/AnimationList.lua` — catalog and styles
- `client/NUI/EmoteMenuNUI.lua` — established NUI callback contract
- `client/NUI/js/*.js` — current navigation and message handling (replace only when equivalent behavior is verified)

## Existing NUI callback contract
`NUI_READY`, `INITIAL_DATA_LOADED`, `LOCALES_LOADED`, `CLOSE_MENU`, `SEARCH_BAR_FOCUS`, `CANCEL_EMOTE`, `ROUTE_EMOTE`, `FAVORITE_EMOTE`, `KEYBIND_EMOTE`, `PREVIEW_EMOTE`, `SEARCH_EMOTES`, `PLAY_SOUND_FRONTEND`, `GET_LOCALES`.

## Implementation sequence
1. Create an independent PowerMoves UI theme and branded shell; retain existing callback contract.
2. Rework navigation, categories, search, favorites, and keyboard/controller accessibility without removing existing menu functions.
3. Verify existing preview ped behavior; add a dedicated preview camera/viewing region only if required, with reliable restoration of the gameplay camera.
4. Keep existing ghost placement logic; make menu-to-placement transitions and cancellation consistent.
5. Verify emotes, props, walkstyles, expressions, shared/group emotes, favorites persistence, preview, placement, and cleanup.
6. Update README introduction and imagery without discarding the original feature descriptions, documentation, credits, or license.

## Reference handling
External NUI examples are behavioral/design research only. No runtime dependencies on their framework, SDK, or compiled JavaScript. Implement original PowerMoves styling and use native FiveM APIs and existing RPEmotes callbacks.

## Testing
Code review and static validation can be performed from GitHub. Final character rendering, placement, keybinds, and focus behavior require an in-game test on the user's local FiveM server.
