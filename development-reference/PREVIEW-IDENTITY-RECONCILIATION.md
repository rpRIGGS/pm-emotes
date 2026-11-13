# Producer/NUI preview identity reconciliation

The live PM Emotes NUI menu receives `emoteName` and `emoteType` from `BUILD_EMOTE_MENUS`. EmotePreviewer publishes `id`, `source`, `category` and `command`. The existing NUI does not supply the producer's original source/category identity.

`preview-identity.js` provides a **conservative bridge**: a command is resolved only when exactly one producer entry matches it (case-insensitively). Any duplicate command is ambiguous and receives the standard placeholder; an explicit verified producer category may disambiguate it. The bridge also reports resolved, missing and ambiguous names for auditing. This avoids silently playing a preview belonging to a different emote.

The adapter and bridge are source-only, unactivated modules. Next activation requires the production manifest, an audit of actual menu commands, and an approved integration of the preview UI into the NoPixel design. FiveM CEF APNG playback remains a Milestone 5 gate.
