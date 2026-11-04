---
name: godot-engine
description: Godot 4 conventions for this project - folder layout, autoloads, scenes vs logic, headless tests, Android export from CI. Use for any Godot scene, script, project setting, or export task.
---

# Godot engine

## Version
- One pinned Godot 4.x stable version, recorded in `docs/MASTER_PLAN.md` Facts
  and in CI as `GODOT_VERSION`. Same version for editor, tests and export
  templates. Upgrade only in a dedicated PR (patch versions monthly).
- No C#/.NET build: GDScript only (smaller APK, simpler CI).

## Layout
```
project.godot
src/
  core/        # pure logic, no Node dependencies: economy.gd, big_number.gd, prestige.gd
  autoload/    # GameState, SaveSystem, Economy, Ads, Clock
  ui/          # scenes + their scripts, one folder per screen
  data/        # .tres resources / .json tables (upgrades, coworkers, ranks)
assets/        # art, audio, fonts (see asset-licensing skill)
locale/        # translations.csv (see localization skill)
addons/        # third-party plugins, pinned (see dependency-security)
tests/         # unit tests mirroring src/
tools/sim/     # balance simulators (headless scripts)
```

## Rules
- Logic lives in `src/core` as `RefCounted` classes with static typing so it
  is unit-testable headless. UI scripts only read state and emit intents.
- Data-driven: upgrade/coworker/rank tables in `src/data`, never hardcoded in UI.
- Autoloads are the only singletons. Communicate with signals, not
  `get_node("../..")`.
- Time: all time reads go through the `Clock` autoload (injectable in tests).
  Use `Time.get_unix_time_from_system()`; clamp negative deltas (clock changes).
- Save: `user://save.json` with `version` field + migration function; write to
  `save.tmp` then rename (atomic). Autosave on change (debounced 2 s) and on
  `NOTIFICATION_APPLICATION_PAUSED` / `WM_CLOSE_REQUEST`.
- Mobile: portrait, `stretch mode = canvas_items`, aspect `expand`, base
  1080x1920; respect safe area (`DisplayServer.get_display_safe_area()`).
  Renderer: `gl_compatibility` (widest device support).
- Keep APK small: import textures compressed (ETC2/ASTC), audio as OGG,
  exclude `tests/`, `tools/`, `docs/` in export filters.

## Headless commands (CI and local)
```bash
godot --headless --import                          # first import
godot --headless -s addons/gut/gut_cmdln.gd -gexit # tests (if GUT)
godot --headless --export-debug "Android" build/game-debug.apk
godot --headless --export-release "Android AAB" build/game.aab
```
`export_presets.cfg` is committed; passwords/keystore paths come from env
vars `GODOT_ANDROID_KEYSTORE_RELEASE_PATH` / `_USER` / `_PASSWORD`, never the file.

## Verify before claiming done
- Tests green headless, export succeeds, no new warnings in `--headless --quit` run.
