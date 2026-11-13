import { createPreviewLibrary } from "./preview-library.js";
import { createPreviewIdentityResolver } from "./preview-identity.js";

/** Selected-only media consumer. Never changes the gameplay preview ped. */
export function createPreviewPanel({ root = document, manifestUrl = "previews/manifest.json" } = {}) {
  const panel = root.querySelector("#pm-preview-panel");
  const image = root.querySelector("#pm-preview-image");
  const placeholder = root.querySelector("#pm-preview-placeholder");
  const label = root.querySelector("#pm-preview-label");
  const library = createPreviewLibrary({ base: "./" });
  let resolver = null;
  let generation = 0;
  let manifestRequest = 0;
  let selected = null;
  let visible = false;

  function clearImage() {
    library.unmount(image);
    image.hidden = true;
    placeholder.hidden = false;
  }
  function reset() {
    generation++;
    selected = null;
    visible = false;
    clearImage();
    label.textContent = "Preview unavailable";
    panel.hidden = true;
  }
  async function initialize() {
    const token = ++manifestRequest;
    try {
      const response = await fetch(manifestUrl, { cache: "no-cache" });
      if (!response.ok) throw new Error("Preview manifest unavailable");
      const manifest = await response.json();
      const candidate = createPreviewIdentityResolver(manifest);
      // A later close/rebuild must invalidate this asynchronous response.
      if (token !== manifestRequest) return false;
      library.install(manifest);
      resolver = candidate;
      if (visible && selected) render(selected);
      return true;
    } catch (_) {
      if (token === manifestRequest) {
        resolver = null;
        library.clear();
        clearImage();
      }
      return false;
    }
  }
  function render(button) {
    const identity = resolver?.resolve(button.dataset.emoteid) ?? null;
    clearImage();
    if (!identity) return;
    if (!library.mount(image, identity.source, identity.category, identity.command)) return;
    const token = generation;
    const originalLoad = image.onload;
    image.onload = (event) => {
      originalLoad?.(event);
      if (token === generation && !image.hidden) placeholder.hidden = true;
    };
    const originalError = image.onerror;
    image.onerror = (event) => {
      originalError?.(event);
      if (token === generation) placeholder.hidden = false;
    };
  }
  function select(button) {
    if (!button?.dataset?.emoteid || !button.dataset.emotetype ||
        button.dataset.emoteid === "_reset" || button.dataset.emotetype === "Emojis") {
      reset();
      return;
    }
    const identityKey = JSON.stringify([button.dataset.emotetype, button.dataset.emoteid]);
    if (visible && selected?.key === identityKey) return;
    generation++;
    visible = true;
    selected = { key: identityKey, dataset: { ...button.dataset } };
    panel.hidden = false;
    label.textContent = button.dataset.label || button.dataset.emoteid;
    render(selected);
  }
  return { initialize, select, hide: reset, reset };
}
