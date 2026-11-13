import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const source = await readFile(new URL("../client/NUI/js/preview-library.js", import.meta.url), "utf8");
const { createPreviewLibrary } = await import("data:text/javascript;base64," + Buffer.from(source).toString("base64"));
globalThis.document = { baseURI: "https://cfx-nui-pm-emotes/client/NUI/index.html" };
const item = (command, category = "dances") => ({
  id: "rpemotes:" + category + ":" + command,
  source: "rpemotes", category, command, format: "apng",
  media: "previews/stem/run123/preview.png",
});
const manifest = (entries) => ({ schemaVersion: 1, format: "experimental-apng", entries });
const image = () => ({
  hidden: false, src: "", onload: null, onerror: null,
  removeAttribute(name) { if (name === "src") this.src = ""; },
});
test("rejects unsupported schema and format without replacing installed library", () => {
  const library = createPreviewLibrary();
  library.install(manifest([item("wave")]));
  assert.throws(() => library.install({ schemaVersion: 1, entries: [] }), /Unsupported/);
  assert.equal(library.size, 1);
});
test("identity requires source, category and command, never command alone", () => {
  const library = createPreviewLibrary();
  library.install(manifest([item("wave", "dances"), item("wave", "emotes")]));
  assert.equal(library.size, 2);
  assert.equal(library.lookup("rpemotes", "dances", "wave")?.id, "rpemotes:dances:wave");
  assert.equal(library.lookup("rpemotes", "emotes", "wave")?.id, "rpemotes:emotes:wave");
  assert.equal(library.lookup("rpemotes", "shared", "wave"), null);
});
test("rejects duplicate identities and unsafe traversal paths", () => {
  const library = createPreviewLibrary();
  assert.throws(() => library.install(manifest([item("wave"), item("wave")])), /Duplicate/);
  library.install(manifest([{ ...item("wave"), media: "../escape.png" }]));
  assert.equal(library.size, 0);
});
test("loads selected image, falls back on failure, and invalidates old events", () => {
  const library = createPreviewLibrary({ placeholder: "./placeholder.png" });
  library.install(manifest([item("wave")]));
  const img = image();
  assert.equal(library.mount(img, "rpemotes", "dances", "wave"), true);
  const oldOnload = img.onload;
  assert.match(img.src, /previews\/stem\/run123\/preview.png/);
  library.unmount(img);
  oldOnload();
  assert.equal(img.hidden, true);
  library.mount(img, "rpemotes", "dances", "wave");
  img.onerror();
  assert.equal(img.hidden, true);
  assert.match(img.src, /placeholder.png/);
  img.onload();
  assert.equal(img.hidden, false);
});
test("missing previews use a placeholder and remain isolated per image", () => {
  const library = createPreviewLibrary({ placeholder: "./placeholder.png" });
  library.install(manifest([item("wave")]));
  const a = image(), b = image();
  library.mount(a, "rpemotes", "dances", "wave");
  library.mount(b, "rpemotes", "dances", "wave");
  a.onload();
  assert.equal(a.hidden, false);
  assert.equal(b.hidden, true);
  assert.equal(library.mount(b, "rpemotes", "dances", "missing"), false);
  b.onload();
  assert.equal(b.hidden, false);
});
