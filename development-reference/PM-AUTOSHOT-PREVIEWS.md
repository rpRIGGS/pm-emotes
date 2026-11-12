# PM AutoShot animated previews

PM Emotes includes an optional preview overlay in `client/NUI/js/autoshot-previews.js`.
It looks for `client/NUI/previews/manifest.json` and displays the
corresponding animated WebP when an emote button receives focus or hover.

No previews are bundled by default. If the manifest is missing, the normal
emote menu and playback continue unchanged.

## Install captured assets

Run from the PM AutoShot resource folder after generating preview WebP files:

```bash
node tools/install-previews.js /path/to/pm-autoshot /path/to/pm-emotes --dry-run
node tools/install-previews.js /path/to/pm-autoshot /path/to/pm-emotes
```

The installer copies the images, writes the mapping manifest, and ensures the
FiveM resource manifest registers the preview files. Restart PM Emotes.

The overlay uses the emote button's existing `data-emotetype` and
`data-emoteid` values to resolve keys such as `Emotes:wave`. It never
replaces PM Emotes animation playback.

## Integration status — 2026-11-11

PM AutoShot implements ordinary dictionary-animation capture **and** a native PM Emotes playback path for supported prop/scenario entries. Those paths, animated WebP output and the NUI overlay have passed offline source/Node checks, **not** an end-to-end FiveM capture-and-display test. Shared, animal and other specialized entries are not yet fully supported.

**PM Emotes development must not be blocked by PM AutoShot.** Finish its NUI, emote playback, placement, branding and gameplay features without waiting for previews. The overlay is optional and must continue to fail gracefully when a manifest or individual WebP is absent. Bulk preview generation is a separate follow-up operation after a successful one-emote capture and NUI smoke test.

The canonical status and acceptance gates are maintained in `rpRIGGS/pm-autoshot/development-reference/DECISIONS-AND-STATUS.md`; the capture/deployment checklist is in that repository's `development-reference/PREVIEW-DEPLOYMENT.md`. Do not claim production readiness until actual FiveM validation is recorded.

## Task 3 integration contract audit — 2026-11-12

The NUI `BUILD_EMOTE_MENUS` handler renders buttons with `data-emoteid` and `data-emotetype`. The types in `types.lua` use `Emotes`, `Dances`, `Exits`, and `PropEmotes`, matching PM AutoShot's catalog and installer category names. The installer resolves original keys (including spaces and punctuation) from the installed animation catalog rather than reconstructing them from sanitized filenames. Preview manifest keys are `<EmoteType>:<exact emote key>`; values are relative `previews/<sanitized filename>.webp`.

The `client/NUI/previews/*` manifest file declaration is present. The preview manifest itself is intentionally absent until assets are generated. The installer now refuses an incompatible NUI without `js/autoshot-previews.js` and the corresponding script reference. The optional overlay clears stale images when changing buttons or rebuilding menus.

**Offline limitation:** The dynamic NUI render path, the optional manifest fetch, and actual WebP display have not been exercised in FiveM. No installation or live acceptance is authorized by this audit.
