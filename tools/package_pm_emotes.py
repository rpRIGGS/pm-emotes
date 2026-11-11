#!/usr/bin/env python3
"""Package PM Emotes as a self-contained FiveM resource ZIP.

Usage: python3 tools/package_pm_emotes.py
The ZIP contains a single pm-emotes/ root directory, ready to extract under
resources/. Only source/runtime assets are included; development metadata is
excluded. Requires no external Python packages.
"""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "dist" / "pm-emotes-server-test.zip"
EXCLUDED_DIRS = {".git", ".github", "dist", "tests", "development", "development-reference",
                 "node_modules", ".vscode", ".idea", "__pycache__"}
EXCLUDED_SUFFIXES = {".pyc", ".log"}
EXCLUDED_FILES = {".DS_Store", "Thumbs.db"}
EXCLUDED_PREFIXES = (".",)
REQUIRED = (
    "fxmanifest.lua",
    "config.lua",
    "client/NUI/nopixel/index.html",
    "client/NUI/nopixel/assets/index-80592477.js",
    "client/NUI/nopixel/assets/index-5495b930.css",
    "client/NUI/nopixel/assets/pm-autoshot-bridge.js",
    "client/NUI/EmoteMenuNUI.lua",
    "client/NUI/PMPreview.lua",
    "client/PMSeating.lua",
    "client/Emote.lua",
)
for name in REQUIRED:
    if not (ROOT / name).is_file():
        sys.exit(f"Missing required runtime file: {name}")

OUTPUT.parent.mkdir(exist_ok=True)
files = sorted(
    path for path in ROOT.rglob("*")
    if path.is_file()
    and not any(part in EXCLUDED_DIRS for part in path.relative_to(ROOT).parts)
    and path.suffix.lower() not in EXCLUDED_SUFFIXES
    and path.name not in EXCLUDED_FILES
    and not path.name.startswith(EXCLUDED_PREFIXES)
)
# Validate literal runtime file declarations before creating a distributable ZIP.
# Wildcard declarations are checked against the runtime files in the archive.
manifest = (ROOT / "fxmanifest.lua").read_text(encoding="utf-8")
file_block = re.search(r"\\bfiles\\s*\\{(.*?)\\}", manifest, flags=re.S)
if not file_block:
    sys.exit("fxmanifest.lua does not declare a files block")
declarations = re.findall(r"['\\\"]([^'\\\"]+)['\\\"]", file_block.group(1))
for declaration in declarations:
    if "*" not in declaration and not (ROOT / declaration).is_file():
        sys.exit(f"Missing fxmanifest runtime asset: {declaration}")

with ZipFile(OUTPUT, "w", compression=ZIP_DEFLATED, compresslevel=6) as archive:
    for path in files:
        archive.write(path, arcname="pm-emotes/" + path.relative_to(ROOT).as_posix())
with ZipFile(OUTPUT) as archive:
    bad = archive.testzip()
    if bad:
        sys.exit(f"ZIP CRC validation failed: {bad}")
    names = set(archive.namelist())
    for required in REQUIRED:
        if "pm-emotes/" + required not in names:
            sys.exit(f"ZIP missing: {required}")
print(f"Packaged {len(files)} runtime files: {OUTPUT}")
print(f"Archive size: {OUTPUT.stat().st_size:,} bytes")
