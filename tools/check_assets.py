"""Fail if any asset file lacks a row in assets/LICENSES.csv, or a row points nowhere.

Also regenerates the asset table in CREDITS.md from the CSV (--write).
Usage: python3 tools/check_assets.py [--write]
"""
import csv
import os
import sys

ROOT = os.path.join(os.path.dirname(__file__), "..")
CSV = os.path.join(ROOT, "assets", "LICENSES.csv")
SKIP_DIRS = {"licenses"}
SKIP_EXT = {".import", ".uid", ".csv"}

rows = list(csv.DictReader(open(CSV, encoding="utf-8")))
listed = {r["path"] for r in rows}
found = set()
for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, "assets")):
    dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
    for name in filenames:
        if os.path.splitext(name)[1] in SKIP_EXT:
            continue
        found.add(os.path.relpath(os.path.join(dirpath, name), ROOT).replace(os.sep, "/"))

errors = [f"no license row: {p}" for p in sorted(found - listed)]
errors += [f"row for missing file: {p}" for p in sorted(listed - found)]
if errors:
    sys.exit("\n".join(errors))

if "--write" in sys.argv:
    path = os.path.join(ROOT, "CREDITS.md")
    text = open(path, encoding="utf-8").read()
    table = ["| Asset | Author | Source | License |", "| --- | --- | --- | --- |"]
    table += [f"| {r['path']} | {r['author']} | {r['source_url']} | {r['license']} |" for r in rows]
    start = text.index("| Asset |")
    end = text.index("\n\n", start)
    open(path, "w", encoding="utf-8").write(text[:start] + "\n".join(table) + text[end:])
print(f"assets ok: {len(rows)} licensed file(s)")
