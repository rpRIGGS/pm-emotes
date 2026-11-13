import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
const files = ["preview-library", "preview-identity", "preview-panel"];
const sources = await Promise.all(files.map((name) => readFile(new URL("../client/NUI/js/" + name + ".js", import.meta.url), "utf8")));
const url = (source) => "data:text/javascript;base64," + Buffer.from(source).toString("base64");
const panelSource = sources[2].replace('"./preview-library.js"', JSON.stringify(url(sources[0]))).replace('"./preview-identity.js"', JSON.stringify(url(sources[1])));
const { createPreviewPanel } = await import(url(panelSource));
const element = () => ({ hidden: false, textContent: "", src: "", onload: null, onerror: null,
  removeAttribute(name) { if (name === "src") this.src = ""; } });
function harness() {
  const panel = element(), image = element(), placeholder = element(), label = element();
  const nodes = { "#pm-preview-panel": panel, "#pm-preview-image": image,
    "#pm-preview-placeholder": placeholder, "#pm-preview-label": label };
  globalThis.document = { baseURI: "https://cfx-nui-pm-emotes/client/NUI/index.html" };
  return { controller: createPreviewPanel({ root: { querySelector: (selector) => nodes[selector] } }),
    panel, image, placeholder, label };
}
const entry = (command, category = "emotes", media = `previews/${command}/run123/preview.png`) => ({
  id: "rpemotes:" + category + ":" + command, source: "rpemotes", category, command,
  folder: media.slice(0, media.lastIndexOf("/")), media, format: "apng",
  frameCount: 36, durationSeconds: 3, frameRate: 12, width: 320, height: 320,
});
// Shape emitted by EmotePreviewer, including exporter metadata not needed by the NUI.
const manifest = (entries) => ({ schemaVersion: 1, publicationId: "run123",
  format: "experimental-apng", captureProfile: { width: 320, height: 320, fps: 12 },
  note: "APNG candidate", entries });
const button = (id) => ({ dataset: { emoteid: id, emotetype: "Emotes", label: id } });
test("selected preview loads, releases on hide, and ignores stale image callbacks", async () => {
  const h = harness();
  globalThis.fetch = async () => ({ ok: true, json: async () => manifest([entry("wave")]) });
  assert.equal(await h.controller.initialize(), true);
  h.controller.select(button("wave"));
  assert.match(h.image.src, /preview.png/);
  const oldLoad = h.image.onload;
  h.controller.hide();
  oldLoad();
  assert.equal(h.panel.hidden, true);
  assert.equal(h.image.hidden, true);
  assert.equal(h.image.src, "");
});
test("switching selection ignores the previous image callback", async () => {
  const h = harness();
  globalThis.fetch = async () => ({ ok: true, json: async () =>
    manifest([entry("wave"), entry("dance")]) });
  await h.controller.initialize();
  h.controller.select(button("wave"));
  const staleLoad = h.image.onload;
  h.controller.select(button("dance"));
  assert.match(h.image.src, /dance\/run123\/preview\.png/);
  assert.equal(h.placeholder.hidden, false);
  staleLoad();
  assert.equal(h.placeholder.hidden, false);
  h.image.onload();
  assert.equal(h.placeholder.hidden, true);
  assert.equal(h.label.textContent, "dance");
});
test("missing and ambiguous identities show the placeholder without loading media", async () => {
  const h = harness();
  globalThis.fetch = async () => ({ ok: true, json: async () =>
    manifest([entry("wave"), entry("wave", "shared")]) });
  await h.controller.initialize();
  h.controller.select(button("wave"));
  assert.equal(h.placeholder.hidden, false);
  assert.equal(h.image.src, "");
  h.controller.select(button("unknown"));
  assert.equal(h.placeholder.hidden, false);
  assert.equal(h.image.src, "");
});
test("failed media retains placeholder, successful media hides it", async () => {
  const h = harness();
  globalThis.fetch = async () => ({ ok: true, json: async () => manifest([entry("wave")]) });
  await h.controller.initialize();
  h.controller.select(button("wave"));
  h.image.onerror();
  assert.equal(h.placeholder.hidden, false);
  h.controller.select(button("missing"));
  h.controller.select(button("wave"));
  h.image.onload();
  assert.equal(h.placeholder.hidden, true);
});
test("missing manifest does not break menu preview fallback", async () => {
  const h = harness();
  globalThis.fetch = async () => ({ ok: false });
  assert.equal(await h.controller.initialize(), false);
  h.controller.select(button("wave"));
  assert.equal(h.placeholder.hidden, false);
  assert.equal(h.image.src, "");
});
test("manifest loading after selection updates only the currently selected emote", async () => {
  const h = harness();
  let release;
  globalThis.fetch = () => new Promise((resolve) => { release = resolve; });
  const pending = h.controller.initialize();
  h.controller.select(button("wave"));
  release({ ok: true, json: async () => manifest([entry("wave")]) });
  assert.equal(await pending, true);
  assert.match(h.image.src, /preview.png/);
});
test("a slower obsolete manifest response cannot replace the latest library", async () => {
  const h = harness();
  const requests = [];
  globalThis.fetch = () => new Promise((resolve) => requests.push(resolve));
  const obsolete = h.controller.initialize();
  const current = h.controller.initialize();
  requests[1]({ ok: true, json: async () => manifest([entry("dance")]) });
  assert.equal(await current, true);
  requests[0]({ ok: true, json: async () => manifest([entry("wave")]) });
  assert.equal(await obsolete, false);
  h.controller.select(button("dance"));
  assert.match(h.image.src, /dance\/run123\/preview\.png/);
});
