// PM AutoShot bridge for the active PowerMoves NoPixel NUI.
// The optional installer places previews/manifest.json beside the legacy NUI.
// This module is deliberately independent of the legacy button markup.
const entries = new Map();
const overlay = document.createElement("img");
overlay.id = "pm-autoshot-nopixel-preview";
overlay.alt = "Animated emote preview";
overlay.setAttribute("aria-hidden", "true");
Object.assign(overlay.style, {
  position: "fixed", right: "2rem", bottom: "5rem",
  width: "256px", height: "256px", objectFit: "contain",
  pointerEvents: "none", zIndex: "200", display: "none",
  background: "rgba(15,15,20,.75)", border: "1px solid #0438ff",
  borderRadius: "10px"
});
document.body.appendChild(overlay);

let activeKey = null;
let manifestReady = false;
const keyFor = item => String(item?.emoteType ?? "") + ":" + String(item?.value ?? "");
const safeFile = file => typeof file === "string" &&
  /^previews\/[A-Za-z0-9_-]+\.webp$/.test(file);
const previewUrl = item => {
  const file = entries.get(keyFor(item));
  return file ? "../" + file : null;
};

window.PMAutoShotNoPixel = {
  hasPreview(item) { return !!previewUrl(item); },
  show(item) {
    const key = keyFor(item);
    const url = previewUrl(item);
    if (!url) {
      this.hide();
      return false;
    }
    if (activeKey !== key || overlay.getAttribute("src") !== url) {
      overlay.src = url;
      activeKey = key;
    }
    overlay.style.display = "block";
    return true;
  },
  hide() {
    activeKey = null;
    overlay.style.display = "none";
    overlay.removeAttribute("src");
  },
  get ready() { return manifestReady; }
};

overlay.addEventListener("error", () => {
  if (activeKey) entries.delete(activeKey);
  window.PMAutoShotNoPixel.hide();
});

fetch("../previews/manifest.json", {cache: "no-store"})
  .then(response => response.ok ? response.json() : null)
  .then(data => {
    if (data?.version === 1 && data.entries && typeof data.entries === "object") {
      for (const [key, file] of Object.entries(data.entries)) {
        if (safeFile(file)) entries.set(key, file);
      }
    }
  })
  .catch(() => {})
  .finally(() => { manifestReady = true; });

window.addEventListener("message", event => {
  if (event.data?.event === "emotes:closeUI" ||
      (event.data?.type === "OPEN_MENU" && event.data.value === false)) {
    window.PMAutoShotNoPixel.hide();
  }
});
document.addEventListener("keydown", event => {
  if (event.key === "Escape") window.PMAutoShotNoPixel.hide();
});
