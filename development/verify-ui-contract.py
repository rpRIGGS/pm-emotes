#!/usr/bin/env python3
"""Validate the PowerMoves frontend-to-RPEmotes integration contract."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
lua = (root / "client/NUI/EmoteMenuNUI.lua").read_text()
main = (root / "client/NUI/js/main.js").read_text()
utils = (root / "client/NUI/js/utils.js").read_text()
classes = (root / "client/NUI/js/classes.js").read_text()
html = (root / "client/NUI/index.html").read_text()
engine = (root / "client/EmoteMenu.lua").read_text()
manifest = (root / "fxmanifest.lua").read_text()

callbacks = set(re.findall(r'RegisterNUICallback\([\'"]([A-Z_]+)[\'"]', lua))
required = {
    "NUI_READY", "INITIAL_DATA_LOADED", "LOCALES_LOADED", "CLOSE_MENU",
    "SEARCH_BAR_FOCUS", "CANCEL_EMOTE", "ROUTE_EMOTE", "FAVORITE_EMOTE",
    "KEYBIND_EMOTE", "PREVIEW_EMOTE", "SEARCH_EMOTES", "PLAY_SOUND_FRONTEND",
    "GET_LOCALES"
}
assert required <= callbacks, f"Missing RPEmotes NUI callbacks: {required - callbacks}"
for name in required:
    assert name in (main + utils + classes) or name in {"SEARCH_BAR_FOCUS"}, f"Frontend does not call {name}"

assert 'TriggerEvent("rpemotes:internal:loadEmoteDataToNUI"' in engine
assert 'TriggerEvent("rpemotes:internal:sendMenuDataToNUI")' in engine
assert 'TriggerEvent("rpemotes:internal:sendKeybindsDataToNUI"' in engine
assert 'AddEmoteToNUIQueue(' in engine
assert 'NUIEmoteCategories = {}' in lua
assert 'NUIEmoteType[data.emoteType]' in lua
assert 'SendNUIMessage(dataForMenu)' in lua
assert 'RouteEmoteToFunction(data.emoteName, data.emoteType, 1)' in lua
assert 'ToggleFavoriteEmote(' in lua and 'GetFavoriteEmotes()' in lua
assert 'EmoteBindStart(' in lua and 'DeleteEmoteBind(' in lua
assert 'StartNewPlacement(' in lua and 'OnGroupEmoteRequest(' in lua
assert 'PMPreviewCharacterEmote(' in lua and 'PMCloseCharacterPreview()' in lua
assert 'document.createDocumentFragment()' in main
assert 'button.disabled = true' in main
assert 'document.querySelectorAll(".pm-dynamic-category")' in main
assert 'data-action="openMenu"' in html
assert 'class="pm-preview-panel"' in html
assert "'client/NUI/EmoteMenuNUI.lua'" in manifest
print(f"PowerMoves UI integration contract verified: {len(required)} engine callbacks, catalog, navigation, preview, favorites, binds, placement, groups.")
