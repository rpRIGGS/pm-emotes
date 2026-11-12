// Run with: node tests/autoshot_bridge.test.cjs
// Exercise the actual browser bridge without external packages or FiveM.
const fs = require("node:fs");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const source = fs.readFileSync("client/NUI/nopixel/assets/pm-autoshot-bridge.js", "utf8");
const events = {};
const listeners = {};
const dispatched = [];

const element = {
  style: {}, attributes: {},
  setAttribute(key, value) { this.attributes[key] = value; },
  getAttribute(key) { return this.attributes[key] ?? null; },
  removeAttribute(key) { delete this.attributes[key]; },
  addEventListener(name, callback) { listeners[name] = callback; },
  set src(value) { this.attributes.src = value; },
  get src() { return this.attributes.src; }
};
const window = {
  addEventListener(name, callback) { events[name] = callback; },
  dispatchEvent(event) { dispatched.push(event); events[event.type]?.(event); }
};
const context = {
  document: {
    createElement: () => element,
    body: {appendChild: () => {}},
    addEventListener(name, callback) { events["document:" + name] = callback; }
  },
  window,
  Object, Map, String, Event: class {constructor(type) {this.type = type;}},
  CustomEvent: class {constructor(type, args) {this.type = type; this.detail = args.detail;}},
  fetch: async () => ({
    ok: true,
    json: async () => ({version: 1, entries: {
      "Emotes:wave": "previews/wave.webp",
      "Emotes:unsafe": "https://evil.example/unsafe.webp",
      "Emotes:traversal": "previews/../unsafe.webp"
    }})
  })
};
vm.createContext(context);
vm.runInContext(source, context);
setImmediate(() => {
  const bridge = window.PMAutoShotNoPixel;
  assert.equal(bridge.ready, true, "manifest should load");
  assert.ok(dispatched.some(event => event.type === "pm-autoshot-manifest-ready"), "NUI must be notified when the optional manifest finishes loading");
  assert.equal(bridge.hasPreview({emoteType:"Emotes",value:"wave"}), true);
  assert.equal(bridge.hasPreview({emoteType:"Emotes",value:"unsafe"}), false);
  assert.equal(bridge.hasPreview({emoteType:"Emotes",value:"traversal"}), false);
  assert.equal(bridge.show({emoteType:"Emotes",value:"wave"}), true);
  assert.equal(element.src, "../previews/wave.webp");
  assert.equal(element.style.display, "block");
  listeners.error();
  assert.ok(dispatched.some(event => event.type === "pm-autoshot-preview-failed" && event.detail.key === "Emotes:wave"), "failed WebP must notify NUI to restore live preview");
  assert.equal(bridge.hasPreview({emoteType:"Emotes",value:"wave"}), false);
  assert.equal(element.style.display, "none");
  assert.equal(bridge.show({emoteType:"Emotes",value:"missing"}), false);
  // Menu close must clear the visible preview even without a mouseleave.
  assert.equal(bridge.show({emoteType:"Emotes",value:"unsafe"}), false);
  assert.equal(element.style.display, "none");
  events.message?.({data:{event:"emotes:closeUI"}});
  assert.equal(element.style.display, "none");
  assert.equal(element.getAttribute("src"), null);
  assert.equal(bridge.show({emoteType:"Emotes",value:"wave"}), false, "failed preview must stay disabled for the session");
  console.log("PASS: PM AutoShot bridge manifest, path security, hover, error fallback, close cleanup");
  // The integration must remain optional when AutoShot has not been installed.
  const missingOverlay = {
    style: {}, attributes: {},
    setAttribute(k,v) {this.attributes[k]=v;},
    getAttribute(k) {return this.attributes[k] ?? null;},
    removeAttribute(k) {delete this.attributes[k];},
    addEventListener() {},
    set src(v) {this.attributes.src=v;},
    get src() {return this.attributes.src;}
  };
  const missingWindow = {addEventListener() {}, dispatchEvent() {}};
  const missingContext = {
    document: {
      createElement: () => missingOverlay,
      body: {appendChild() {}},
      addEventListener() {}
    },
    window: missingWindow, Object, Map, String,
    Event: class {constructor(type) {this.type=type;}},
    CustomEvent: class {constructor(type, args) {this.type=type; this.detail=args.detail;}},
    fetch: async () => ({ok:false})
  };
  vm.createContext(missingContext);
  vm.runInContext(source, missingContext);
  setImmediate(() => {
    assert.equal(missingWindow.PMAutoShotNoPixel.ready, true);
    assert.equal(missingWindow.PMAutoShotNoPixel.show({emoteType:"Emotes",value:"wave"}), false);
    assert.equal(missingOverlay.style.display, "none");
    console.log("PASS: Missing AutoShot manifest leaves normal preview fallback available");
  });
});
