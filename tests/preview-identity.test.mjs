import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
const source = await readFile(new URL("../client/NUI/js/preview-identity.js", import.meta.url), "utf8");
const { createPreviewIdentityResolver } = await import("data:text/javascript;base64," + Buffer.from(source).toString("base64"));
const entry = (id, command, category) => ({ id, command, category, source: "rpemotes", format: "apng" });
const manifest = (entries) => ({ schemaVersion: 1, entries });
test("resolves a unique menu command to its original full producer identity", () => {
  const resolver = createPreviewIdentityResolver(manifest([entry("a", "wave", "emotes")]));
  assert.deepEqual(resolver.resolve("WAVE"), { id: "a", source: "rpemotes", category: "emotes", command: "wave" });
});
test("ambiguous names never select the wrong preview", () => {
  const resolver = createPreviewIdentityResolver(manifest([entry("a", "wave", "emotes"), entry("b", "wave", "shared")]));
  assert.equal(resolver.resolve("wave"), null);
  assert.equal(resolver.resolve("wave", "shared")?.id, "b");
  assert.deepEqual(resolver.audit(["wave", "missing"]).ambiguous[0].candidates, ["a", "b"]);
});
test("invalid or unknown names return no identity", () => {
  const resolver = createPreviewIdentityResolver(manifest([entry("a", "wave", "emotes")]));
  assert.equal(resolver.resolve("missing"), null);
  assert.equal(resolver.resolve(null), null);
  assert.deepEqual(resolver.audit(["wave", "missing"]).missing, ["missing"]);
});
