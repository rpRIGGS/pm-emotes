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

**Current limitation:** PM AutoShot only generates plain dictionary-animation
previews. Props, scenarios, shared, and other specialized emotes are not yet
supported by that capture pipeline. End-to-end testing on a FiveM server is
required before treating the preview system as production-ready.
