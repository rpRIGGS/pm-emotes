# PM Emotes — local FiveM smoke test

Install the **development/powermoves-nui** branch as a complete resource, not only the modified files. Keep the upstream resource name and all original streamed assets. Do not run this fork alongside a second copy of RPEmotes.

## In-game sequence
1. Open the emote menu. Confirm the category rail, emote list, and transparent character-preview panel appear.
2. Select a standard looping emote, then a prop emote. Check clone animation and attached props; ensure your actual player remains unchanged.
3. Change emotes quickly and close/reopen the menu. Confirm no orphan clone, props, or scripted camera.
4. Test search, favorites (including reopening), keybinds, walks, moods, emojis, and custom categories.
5. Start placement from an emote's context menu. The scripted preview camera must end **before** ghost placement begins.
6. Try shared/group emotes. Closing the menu must restore gameplay camera.
7. Stop/restart the resource while the menu is open. Camera and clone must be cleaned up.
8. Test keyboard and mouse navigation; the menu must not trap input after closing.

## Known visual validation
The GTA scripted camera renders behind the transparent NUI panel, not inside an HTML 3D canvas. Final camera framing, ped ground placement on sloped terrain, and streamed prop animations must be validated in FiveM. The preview camera currently shows a nearby local clone and changes the game camera while the menu is open; it does **not** teleport the player.

## Temporary branding
Replace the text treatment with the supplied transparent PowerMoves Roleplay logo later. The accent is `#0438FF`; `--pm-gray` is provisional.

## Debugging
Report the first F8 client error, if any, plus the action that caused it. If the menu opens but the clone is not visible, check camera composition and preview-ped creation first. No third-party preview runtime is required.
