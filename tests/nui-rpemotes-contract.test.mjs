import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const read = (path) => readFile(new URL(`../${path}`, import.meta.url), "utf8");

test("PowerMoves NUI keeps the RPEmotes menu structure and branded preview controls", async () => {
  const html = await read("client/NUI/index.html");
  const main = await read("client/NUI/js/main.js");
  const overrides = await read("client/NUI/css/overrides.css");

  for (const selector of [
    "emotes-menu", "search-menu", "favorites-menu", "walkstyles-menu",
    "moods-menu", "emojis-menu", "keybinds-menu", "menu-anchor",
    "sidebar-button-anchor", "search-container", "keybinds-list",
  ]) assert.match(html, new RegExp(`class="[^"]*\\b${selector}\\b`), `${selector} menu hook remains in markup`);

  for (const id of ["emotes-menu-btn", "search-menu-btn", "favorites-menu-btn", "walkstyles-menu-btn", "moods-menu-btn", "keybinds-menu-btn", "emojis-menu-btn", "cancel-emote-btn", "preview-use-emote", "preview-place-emote", "preview-favorite"]) {
    assert.match(html, new RegExp(`id="${id}"`), `${id} control remains in markup`);
  }

  assert.match(html, /POWER<span class="brand-word">MOVES<\/span><span class="brand-rp">RP<\/span>/);
  assert.match(overrides, /--pm-blue:\s*#0438ff/i);
  assert.match(main, /data-action="openMenu"/);
  assert.match(main, /<span class="nav-label">\$\{key\}<\/span>/, "Lua-provided custom category names render in the sidebar");
  assert.match(main, /MENUS = CONTENT_CONTAINER\.querySelectorAll\("\.menu"\)/, "new category menus join the same RPEmotes event handling");
  assert.doesNotMatch(html + main, /Hiii/);
});

test("NUI callback calls are registered by the RPEmotes Lua bridge", async () => {
  const [main, utils, navigation, lua] = await Promise.all([
    read("client/NUI/js/main.js"),
    read("client/NUI/js/utils.js"),
    read("client/NUI/js/navigation.js"),
    read("client/NUI/EmoteMenuNUI.lua"),
  ]);
  const js = `${main}\n${utils}\n${navigation}`;
  const calls = new Set([...js.matchAll(/ExecuteNUICallback\(["']([A-Z_]+)["']/g)].map((match) => match[1]));
  const registrations = new Set([...lua.matchAll(/RegisterNUICallback\(["']([A-Z_]+)["']/g)].map((match) => match[1]));
  for (const callback of calls) assert.ok(registrations.has(callback), `Lua registers NUI callback ${callback}`);

  for (const feature of ["ROUTE_EMOTE", "FAVORITE_EMOTE", "KEYBIND_EMOTE", "SEARCH_EMOTES", "PREVIEW_EMOTE", "CANCEL_EMOTE", "CLOSE_MENU"]) {
    assert.ok(calls.has(feature), `${feature} remains wired from NUI`);
    assert.ok(registrations.has(feature), `${feature} remains registered in Lua`);
  }
});

test("NUI still receives RPEmotes menu data, locales, and keybind updates", async () => {
  const [main, lua] = await Promise.all([
    read("client/NUI/js/main.js"),
    read("client/NUI/EmoteMenuNUI.lua"),
  ]);
  for (const message of ["LOAD_EMOTE_DATA", "BUILD_EMOTE_MENUS", "BUILD_KEYBINDS_MENU", "OPEN_MENU", "TOGGLE_CURSOR_INPUT"]) {
    assert.match(main, new RegExp(`event\\.data\\.type === ["']${message}["']`), `NUI handles ${message}`);
  }
  for (const callback of ["INITIAL_DATA_LOADED", "LOCALES_LOADED", "GET_LOCALES", "NUI_READY"]) {
    assert.match(lua, new RegExp(`RegisterNUICallback\\(["']${callback}["']`), `Lua registers ${callback}`);
  }
  assert.match(lua, /SendNUIMessage\(dataForMenu\)/);
  assert.match(lua, /type = "BUILD_KEYBINDS_MENU"/);
});
