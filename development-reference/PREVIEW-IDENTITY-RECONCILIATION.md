# Producer/NUI preview identity reconciliation

The live PM Emotes NUI menu receives `emoteName` and `emoteType` from `BUILD_EMOTE_MENUS`. EmotePreviewer publishes `id`, `source`, `category` and `command`. The existing NUI does not supply the producer's original source/category identity.

`preview-identity.js` provides a **conservative bridge**: a command is resolved only when exactly one producer entry matches it (case-insensitively). Any duplicate command is ambiguous and receives the standard placeholder; an explicit verified producer category may disambiguate it. The bridge also reports resolved, missing and ambiguous names for auditing. This avoids silently playing a preview belonging to a different emote.

The adapter and resolver are now connected to the existing NUI through `preview-panel.js` and `main.js`. A unique command maps to its producer identity; ambiguous or absent commands display a placeholder rather than guessing. The menu supplies `data-emoteid` and `data-emotetype`, but the latter is not a verified producer category and is **not** used to disambiguate identities. A real exported manifest is still required for an empirical identity audit. FiveM CEF APNG playback remains a Milestone 5 gate.
