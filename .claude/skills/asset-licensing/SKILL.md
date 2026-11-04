---
name: asset-licensing
description: Intake and license tracking for every art, audio and font asset (Kenney CC0, OpenGameArt, Pixabay, Google Fonts), the assets/LICENSES.csv manifest, CREDITS.md and the in-game credits screen. Use whenever adding, replacing or removing any asset.
---

# Asset licensing

## Allowed licenses
- CC0 / public domain: preferred (Kenney.nl).
- CC-BY 3.0/4.0: allowed, attribution required in credits.
- SIL OFL 1.1 (fonts), Apache-2.0 (fonts): allowed; keep license text.
- Pixabay Content License: allowed for use inside the game; never
  redistribute the raw file standalone.
- **Rejected**: CC-BY-NC (non-commercial; ads = commercial), CC-BY-ND if we
  modify, CC-BY-SA (share-alike conflicts with proprietary), "free for personal
  use", unknown or missing license, ripped/fan assets, anything resembling an
  existing game's characters or style.
- AI-generated art: only if the tool's terms allow commercial use; record tool
  and terms URL; still original prompts, no "in the style of <game/artist>".

## Intake steps (same commit as the asset)
1. Download only from the original author page. Save the license file/text
   to `assets/licenses/<pack-name>.txt`.
2. Place files under `assets/<type>/<pack-name>/` keeping only files used.
3. Add a row to `assets/LICENSES.csv`:
   `path,author,source_url,license,license_url,modified,attribution_text,date_added`
4. Regenerate `CREDITS.md` and the credits screen data from the CSV
   (`tools/gen_credits.py`), never by hand.
5. If modified (recolor, crop), set `modified=yes`.

## Checks
- CI step: every file under `assets/` (except `licenses/`, `.import`) has a
  CSV row; every CSV row's path exists. Fail otherwise.
- Japanese font must cover kana + common kanji (e.g. Noto Sans JP, OFL);
  subset it to reduce APK size, keep OFL text.

## Look
- Recolor and combine packs with the game palette so it does not look like
  other Kenney-based games. Flat shapes drawn in code/SVG count as original.
