#!/usr/bin/env python3
"""Static release gates for the PowerMoves RP NoPixel emote UI.

Run from repository root: python3 tests/validate_pm_emotes.py
Requires no FiveM server. These tests cannot replace in-game smoke testing.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
def read(path):
    p = ROOT / path
    assert p.is_file(), f"Required file missing: {path}"
    return p.read_text(encoding="utf-8")

manifest = read("fxmanifest.lua")
html = read("client/NUI/nopixel/index.html")
js = read("client/NUI/nopixel/assets/index-80592477.js")
css = read("client/NUI/nopixel/assets/index-5495b930.css")
bridge = read("client/NUI/EmoteMenuNUI.lua")
preview = read("client/NUI/PMPreview.lua")
seating = read("client/PMSeating.lua")
autoshot = read("client/NUI/nopixel/assets/pm-autoshot-bridge.js")
emote_engine = read("client/Emote.lua")

checks = []
def check(label, condition):
    checks.append((label, bool(condition)))

check("NoPixel HTML is the active NUI page",
      "ui_page 'client/NUI/nopixel/index.html'" in manifest)
for path in ("client/NUI/EmoteMenuNUI.lua", "client/NUI/PMPreview.lua",
             "client/PMSeating.lua", "client/NUI/nopixel/index.html"):
    check(f"manifest loads {path}", f"'{path}'" in manifest)
for asset in ("index-80592477.js", "index-5495b930.css"):
    check(f"HTML references {asset}", asset in html)
    check(f"asset exists {asset}", (ROOT / "client/NUI/nopixel/assets" / asset).is_file())
check("frontend contains substantive bundled JS", len(js) > 100000)
check("frontend contains substantive bundled CSS", len(css) > 10000)
check("frontend PowerMoves branding", "POWERMOVES" in js and "#0438ff" in js)
check("NUI transparent root", "background: transparent" in html)
check("NoPixel loads AutoShot integration", "pm-autoshot-bridge.js" in html)
check("FiveM registers AutoShot manifest and WebP assets",
      "'client/NUI/previews/*'" in manifest)
check("AutoShot reads deployed manifest", '../previews/manifest.json' in autoshot)
check("AutoShot rejects unsafe preview paths",
      "safeFile(file)" in autoshot and "entries.set(key, file)" in autoshot)
check("AutoShot preserves live preview fallback",
      'window.PMAutoShotNoPixel?.show(pmHoveredItem)' in js and
      'Ge.execute("emotes:preview"' in js)
check("AutoShot clears on menu close", 'emotes:closeUI' in autoshot)
check("AutoShot announces manifest readiness",
      "pm-autoshot-manifest-ready" in autoshot and
      "pm-autoshot-manifest-ready" in js)
check("AutoShot reports missing or corrupt WebP",
      "pm-autoshot-preview-failed" in autoshot and
      "pm-autoshot-preview-failed" in js)
check("AutoShot missing capture falls back to live ped",
      "pmTryHoveredPreview" in js and
      'Ge.execute("emotes:preview"' in js)
check("NoPixel cancels stale hover on close",
      "pmHoveredItem = null" in js and
      "++pmActiveHoverToken" in js)


check("NUI manifest declares preview images",
      "'client/NUI/nopixel/previews/**/*.webp'" in manifest)

rpc = ("emotes:getEmotes", "emotes:getFavorites", "emotes:getQuickEmotes",
       "emotes:play", "emotes:setFavorite", "emotes:setQuickEmote",
       "emotes:preview", "emotes:clearPreview", "emotes:close")
for event in rpc:
    check(f"Lua RPC: {event}", f"event == '{event}'" in bridge)
    check(f"browser RPC: {event}", f'"{event}"' in js)
check("browser RPC adapter", 'post("PM_NP_RPC"' in js)
check("Lua RPC adapter", "RegisterNUICallback('PM_NP_RPC'" in bridge)
check("browser open event", 'Ge.register("emotes:open"' in js)
check("Lua open event", 'event = "emotes:open"' in bridge)
check("browser close event", 'Ge.register("emotes:closeUI"' in js)
check("Lua close event", 'event = "emotes:closeUI"' in bridge)
check("quick slots use all ten slots", "for slot = 0, 9 do" in bridge)
check("quick slots remain unbound by default",
      "RegisterKeyMapping(command" in bridge and "'keyboard', ''" in bridge)
check("quick slot persistence", "SetResourceKvp(quickKvp" in bridge)
check("quick slot restore", "GetResourceKvpString(quickKvp)" in bridge)
check("catalog readiness gate", "npCatalogReady" in bridge)
check("favorite permission gate", "HasEmotePermission(item.value, item.emoteType)" in bridge)
check("frontend hover ownership", "pmActiveHoverToken" in js)
check("preview lifecycle", all(f"function {fn}" in preview for fn in
      ("PMOpenCharacterPreview", "PMPreviewCharacterEmote", "PMCloseCharacterPreview")))
check("preview ped is not networked", "ClonePed(player, heading + 180.0, false, false)" in preview)
check("preview resource-stop cleanup", "onResourceStop" in preview)
check("preview selection generation guard",
      "requestVersion ~= previewPropVersion" in emote_engine)
check("preview props attach to the correct generation",
      "addProps(animOption, nil, ped, nil, true, requestVersion)" in emote_engine)
check("NUI invalidates obsolete preview requests",
      "previewRequestToken" in bridge and "token ~= previewRequestToken" in bridge)
check("favorites retain animation type",
      "emoteType: e.item.emoteType" in js)

check("seating has its own lifecycle", "onResourceStop" in seating)
check("NUI focus release on stop",
      "SetNuiFocus(false, false)" in bridge and "onResourceStop" in bridge)

for label, passed in checks:
    print(("PASS" if passed else "FAIL") + "  " + label)
failed = [label for label, passed in checks if not passed]
print(f"\n{len(checks) - len(failed)}/{len(checks)} checks passed")
if failed:
    sys.exit(1)
