#!/usr/bin/env python3
"""Check release ZIP contents after tools/package_pm_emotes.py runs."""
from pathlib import Path
from zipfile import ZipFile
import sys

ROOT = Path(__file__).resolve().parents[1]
archive_path = ROOT / "dist" / "pm-emotes-server-test.zip"
if not archive_path.is_file():
    sys.exit("Missing release ZIP: run tools/package_pm_emotes.py first")

with ZipFile(archive_path) as archive:
    names = archive.namelist()
    if archive.testzip():
        sys.exit("ZIP integrity check failed")
    if not names or any(not name.startswith("pm-emotes/") for name in names):
        sys.exit("ZIP must extract into a single pm-emotes/ resource directory")
    forbidden = (".git/", ".github/", "tests/", "development-reference/",
                 "development/", "dist/", "node_modules/", "tools/")
    for name in names:
        relative = name.removeprefix("pm-emotes/")
        if any(relative.startswith(prefix) for prefix in forbidden):
            sys.exit(f"Development-only file leaked into ZIP: {name}")
    required = (
        "fxmanifest.lua", "config.lua", "client/NUI/nopixel/index.html",
        "client/NUI/nopixel/assets/index-80592477.js",
        "client/NUI/nopixel/assets/index-5495b930.css",
        "client/NUI/nopixel/assets/pm-autoshot-bridge.js",
        "client/NUI/EmoteMenuNUI.lua", "client/NUI/PMPreview.lua",
        "client/PMSeating.lua", "client/Emote.lua",
    )
    missing = [p for p in required if "pm-emotes/" + p not in names]
    if missing:
        sys.exit("ZIP missing runtime files: " + ", ".join(missing))
print(f"PASS: {len(names)} resource files packaged and archive validated")
