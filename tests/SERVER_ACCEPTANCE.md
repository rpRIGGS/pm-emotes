# PM Emotes — FiveM server acceptance checklist

Branch: `development/powermoves-nui`

## Install / startup
1. Download the **pm-emotes-server-test** artifact from a successful GitHub Actions run, extract `pm-emotes-server-test.zip` directly into the resources directory. The archive already contains the `pm-emotes/` folder; do not add another nested folder.
2. Ensure the resource starts after framework dependencies. Remove or stop any duplicate rpemotes provider before testing.
3. Confirm F8/server consoles contain no Lua parse errors, missing NUI assets, or NUI callback timeouts.
4. Press F4 after joining. The NoPixel-inspired PowerMoves RP animation menu must open with white POWERMOVES and blue RP branding.

## Animation catalog and search
- Confirm every expected base emote category, custom dance pack, synchronized emote and prop category is populated.
- Search a known animation by name, clear search, change category, and reopen F4.
- Confirm no duplicate tiles in All/Search when an animation is also a favorite.
- Verify restricted emotes are absent/unplayable for users lacking permission.
- Hover an animation: preview uses a cloned ped, not the player. Move rapidly between tiles and confirm the latest hover wins.
- Close with Escape, reopen, and confirm no lingering camera, clone, or attached preview prop.
- Test the same preview in an interior and on an elevated floor.

## Favorites and quick slots
- Favorite an emote, unfavorite it, favorite it again, close/reopen, and verify the state.
- Drag an animation into each quick slot 0–9. Move a slot, clear a slot, reopen F4, and verify saved positions.
- Restart the resource and reconnect: saved slots should remain.
- Bind a quick-slot command in FiveM key bindings and confirm it works with the menu closed.
- Confirm default quick-slot keys do **not** steal the QBCore inventory number hotbar.
- Change an emote catalog and confirm saved slots resolve by stable animation identity rather than stale category indices.

## Gameplay interactions
- Play normal, dance, prop, expression and walk-style animations; cancel each.
- Request/accept/reject a shared synchronized animation with a second player.
- Test group emotes, placement interactions, and the existing 213-model seating flow.
- **Known failing:** test nearby seating on several chair models for correct height, position, and facing; prior FiveM tests clipped below the floor and then faced backward. Reconcile original model offsets before treating this as passed. Stand up and verify no stranded focus, camera, collision, or scenario prop.
- Select a **sitting emote in the active NoPixel NUI**, launch manual ghost placement, position and rotate it on a chair, desk or another surface, then confirm and cancel in separate tests. The existence of `client/Placement.lua` alone does not establish this menu feature.
- Try F4 rapidly during initial loading, close/reopen quickly, and restart the resource while the menu is open.

## Exit criteria
- GitHub Actions release-validation job passes.
- No F8 errors or NUI callback failures across the above cases.
- No duplicated preview props, leaked cameras, missing textures, or stuck cursor.
- No unexpected inventory keybind collisions.
- Only after these pass should the test ZIP be treated as a release candidate.

The automated workflow verifies source syntax and integration contracts; it **cannot** certify in-game behavior. Record FiveM failures with exact F8 output and reproduction steps.

## Manual placement — new active NoPixel menu path

On a **placed** tile or an emote/dance whose ID contains `sit`, click **PLACE** (or right-click the tile). Verify that the NUI closes and the live preview camera is released, the ghost ped appears, the player can adjust position/rotation on a chair or countertop, and confirm/cancel restore normal gameplay. Confirm that ordinary left-click still plays the emote, that unavailable/restricted emotes cannot be placed, and that the menu does not reopen unexpectedly. This is source-implemented but **not yet FiveM-accepted**.

Automatic nearby seating (`/pmsit`) is a **separate feature**, with known floor-clipping and backward-facing reports; it is not fixed by the menu placement change.

## Automatic chair seating — targeted regression matrix

This is **separate from manual PLACE**. Use `/pmsit` and `/pmstand` at a supported chair. The current source hypothesis is `boundsMax.z + reference verticalOffset` for height and `chairHeading + 180 + reference headingOffset` for facing. **These transforms are not confirmed reference-runtime equivalents and must be checked in FiveM.**

1. Test a picnic bench (`prop_picnictable_01`, reference Z -0.5, heading 0): player should sit on the seat surface, not sink through it or face the back.
2. Test an ordinary office/dining chair (for example `v_res_fa_chair01`, reference Z -0.68, forward 0.07) and a chair with reference heading -180: verify both height and facing, not just scenario start.
3. Test a rotated chair at 90 and 270 degrees. Facing must follow chair rotation and any model-specific heading adjustment.
4. Test chair occupancy with a second player using a scenario: refuse occupied seat without displacing either ped.
5. Test `/pmstand`, movement interruption, vehicle/death rejection and resource stop; verify no stuck seating state.
6. Record chair model, heading, observed vertical/facing error and F8 messages for any failure. Do **not** declare all 213 models correct based on a few samples.

