---
name: localization
description: Localization for English, Japanese and Indonesian - translation CSV, tr() keys, number and yen formatting, Japanese font fallback, store listing translations. Use for any user-facing text.
---

# Localization

- Languages: `en` (source), `ja`, `id` (confirm D-2 in MASTER_PLAN).
- All strings in `locale/translations.csv` (`keys,en,ja,id`), imported by Godot.
  Keys: `SCREEN_ELEMENT_PURPOSE` in CONSTANT_CASE, e.g. `UPGRADE_BUY_BUTTON`.
- Code uses `tr("KEY")` only; placeholders with `tr("KEY").format({"n": x})`,
  never string concatenation (word order differs in ja).
- Auto-select language from `OS.get_locale_language()`, fallback `en`,
  override in Settings, saved in the save file.
- Number format: one helper for big numbers. en/id: `1.23M`, `4.5B` short-scale letters (same in id for consistency);
  ja: 万/億/兆/京 units (`1.2億`). Currency symbol ¥ in all languages.
- Fonts: Latin UI font + Noto Sans JP (subset) as fallback in the theme;
  check no tofu boxes on a real phone screenshot for every new string.
- Tone: ja uses polite casual game tone; rank names use real Japanese titles
  (新入社員, 主任, 係長, 課長, 部長, 取締役, 社長). id: casual friendly.
- Claude drafts ja/id; mark `needs_review` in a `notes` column until the
  owner or a native tester confirms. Keep strings short (small screens).
- Store listing text lives in `store/<lang>/` (title <= 30 chars, short
  description <= 80 chars).
