# PM Emotes — FiveM acceptance notes (2026-11-11)

Active branch: `development/powermoves-nui`. For a packaged server test, use the **PM Emotes release validation** workflow artifact `pm-emotes-server-test`, which contains `pm-emotes-server-test.zip` with the top-level `pm-emotes/` resource folder. Do not use the older `pm-emotes-fivem` artifact instructions as the current deployment path. Keep all streamed assets; ensure only one RPEmotes provider is active.

**Status:** source checks passed through `a4dbe53f`; no claim of full feature parity or in-game acceptance. See `tests/SERVER_ACCEPTANCE.md` for the full test sequence.

## Known user-reported failures — must reproduce and resolve
- Automatic nearby seating (`/pmsit`): first test placed the player partly under furniture/floor; a later correction resulted in backward orientation. Current `client/PMSeating.lua` uses a model-dimension-derived Z height instead of the reference's per-model Z values. Do not mark the 213-model system working merely because models are registered.
- Menu-selected sit emote placement: required to choose a sitting animation in the active NUI and place/rotate it onto a chair, desk or other surface. `client/Placement.lua` exists, but the active NoPixel menu-to-placement interaction still needs verification.

## Required acceptance
Open/close/reopen F4; catalog search/categories; favorites persistence; ten quick-slot save/swap/clear/restart; default keybind collision avoidance; hover clone and prop/camera cleanup; emotes, dances, walks, expressions, shared/group interactions; automatic chair position and heading on representative models; menu-selected sitting placement confirm/cancel; resource stop while open.

Optional PM AutoShot WebP previews are not a prerequisite for this acceptance. The current bridge must degrade gracefully when those files are absent.
