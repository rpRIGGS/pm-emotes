# PM AutoShot integration — active NoPixel NUI

PM Emotes now supports the PM AutoShot capture manifest in the **active**
`client/NUI/nopixel/index.html` interface, not only the legacy
`client/NUI/index.html` interface.

## Asset deployment
PM AutoShot's installer targets `client/NUI/previews/manifest.json` and
`client/NUI/previews/<capture>.webp`. Run the installer from PM AutoShot:

```bash
node tools/install-previews.js /path/to/pm-autoshot /path/to/pm-emotes --dry-run
node tools/install-previews.js /path/to/pm-autoshot /path/to/pm-emotes
```

The PM Emotes resource manifest includes `client/NUI/previews/*`.
No preview files are bundled by default. When absent, the menu still works.

## Runtime behavior
- Hover a NoPixel emote tile: `pm-autoshot-bridge.js` resolves
  `emoteType:value` against the PM AutoShot version 1 manifest.
- If a matching WebP exists, the UI displays the animated capture.
- Otherwise, the existing non-networked character preview is used.
- Moving away, closing F4, or pressing Escape hides the captured preview.
- The bridge validates manifest paths and does not execute arbitrary URLs.
- Playback, synchronized emotes, favorites, and quick slots remain owned by
  PM Emotes; AutoShot is an optional visual integration only.

## Validation
The `tests/validate_pm_emotes.py` gate checks manifest wiring and fallback.
Actual FiveM testing must confirm that deployed files load in CEF, animation
captures match their catalog items, and the preview clears on close.
