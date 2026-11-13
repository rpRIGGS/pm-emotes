/**
 * PowerMoves RP — experimental EmotePreviewer manifest consumer.
 * Deliberately not activated until APNG playback is validated in FiveM CEF.
 * This module never changes RPEmotes gameplay or generates media.
 */
export function createPreviewLibrary({ base = "./", placeholder = null } = {}) {
  let byKey = new Map();
  const generations = new WeakMap();
  let revision = 0;
  const safeMedia = (value) => typeof value === "string"
    && /^previews\/[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+\/preview\.png$/.test(value);
  const key = (source, category, command) => JSON.stringify([source, category, command]);
  const validate = (manifest) => {
    if (!manifest || manifest.schemaVersion !== 1 || manifest.format !== "experimental-apng" || !Array.isArray(manifest.entries)) {
      throw new Error("Unsupported preview manifest");
    }
    const next = new Map();
    for (const item of manifest.entries) {
      if (!item || typeof item.id !== "string" || typeof item.source !== "string"
        || typeof item.category !== "string" || typeof item.command !== "string"
        || !safeMedia(item.media) || item.format !== "apng") continue;
      const identity = key(item.source, item.category, item.command);
      if (next.has(identity)) throw new Error("Duplicate preview identity");
      next.set(identity, { id: item.id, media: item.media });
    }
    return next;
  };
  return {
    install(manifest) { byKey = validate(manifest); revision++; return byKey.size; },
    clear() { byKey.clear(); revision++; },
    get size() { return byKey.size; },
    lookup(source, category, command) {
      const item = byKey.get(key(source, category, command));
      if (!item) return null;
      return { ...item, url: new URL(item.media, new URL(base, document.baseURI)).href };
    },
    /**
     * Load only the selected preview. Ignore late image events when selection
     * changes. Missing/failed media always resolves to a placeholder.
     */
    mount(image, source, category, command) {
      const token = (generations.get(image) ?? 0) + 1;
      const activeRevision = revision;
      generations.set(image, token);
      const item = this.lookup(source, category, command);
      image.onload = image.onerror = null;
      image.removeAttribute("src");
      image.hidden = true;
      if (!item) {
        if (placeholder) { image.onload = () => { if (token === generations.get(image) && activeRevision === revision) image.hidden = false; }; image.src = placeholder; }
        return false;
      }
      image.onload = () => { if (token === generations.get(image) && activeRevision === revision) image.hidden = false; };
      image.onerror = () => {
        if (token !== generations.get(image) || activeRevision !== revision) return;
        // Keep a failed image hidden until the fallback itself has loaded.
        // Showing it immediately can expose a broken-image glyph while the
        // placeholder request is still in flight.
        image.hidden = true;
        if (placeholder) {
          image.onerror = null;
          image.onload = () => { if (token === generations.get(image) && activeRevision === revision) image.hidden = false; };
          image.src = placeholder;
        }
      };
      image.src = item.url;
      return true;
    },
    unmount(image) {
      generations.set(image, (generations.get(image) ?? 0) + 1);
      image.onload = image.onerror = null;
      image.removeAttribute("src");
      image.hidden = true;
    },
  };
}
