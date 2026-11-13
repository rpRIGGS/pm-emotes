import { createPreviewLibrary } from "./preview-library.js";
import { createPreviewIdentityResolver } from "./preview-identity.js";

// Experimental Milestone 4 consumer. Media is produced by the Windows EmotePreviewer.
// No GTA rendering, capture, encoding or gameplay callbacks occur here.
export function createPreviewPanel({ root = document, manifestUrl = "previews/manifest.json" } = {}) {
  const panel = root.querySelector("#pm-preview-panel");
  const image = root.querySelector("#pm-preview-image");
  const placeholder = root.querySelector("#pm-preview-placeholder");
  const label = root.querySelector("#pm-preview-label");
  const library = createPreviewLibrary({ base: "./" });
  let resolver = null;
  let generation = 0;
  let current = null;
  function reset() {
    generation++;
    current = null;
    library.unmount(image);
    placeholder.hidden = false;
    label.textContent = "Preview unavailable";
    panel.hidden = true;
  }
  async function initialize() {
    const token = ++generation;
    try {
      const response = await fetch(manifestUrl, { cache: "no-cache" });
      if (!response.ok) throw new Error("Preview manifest unavailable");
      const manifest = await response.json();
      const candidate = createPreviewIdentityResolver(manifest);
      library.install(manifest);
      if (token !== generation) return false;
      resolver = candidate;
      return true;
    } catch (_) {
      if (token === generation) { resolver = null; library.clear(); }
      return false;
    }
  }
  function select(button) {
    if (!button?.dataset?.emoteid || !button.dataset.emotetype || button.dataset.emoteid === "_reset") {
      reset(); return;
    }
    const identityKey = button.dataset.emotetype + ":" + button.dataset.emoteid;
    if (identityKey === current) return;
    current = identityKey;
    generation++;
    panel.hidden = false;
    placeholder.hidden = false;
    label.textContent = button.dataset.label || button.dataset.emoteid;
    library.unmount(image);
    const identity = resolver?.resolve(button.dataset.emoteid) ?? null;
    if (!identity) return;
    const mounted = library.mount(image, identity.source, identity.category, identity.command);
    if (!mounted) return;
    // A successful image load hides the placeholder; errors retain it.
    const token = generation;
    const originalOnload = image.onload;
    image.onload = (event) => {
      originalOnload?.(event);
      if (token === generation && !image.hidden) placeholder.hidden = true;
    };
    const originalOnerror = image.onerror;
    image.onerror = (event) => {
      originalOnerror?.(event);
      if (token === generation) placeholder.hidden = false;
    };
  }
  function hide() { reset(); }
  return { initialize, select, hide, reset };
}
