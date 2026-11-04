---
name: gdscript-style
description: GDScript coding style for this repo - static typing, naming, file order, comments, lint and format gates (gdtoolkit). Use when writing or reviewing any .gd file.
---

# GDScript style

Base: official Godot GDScript style guide. Enforced by `gdtoolkit`
(`gdlint`, `gdformat --check`), pinned in `requirements-dev.txt`.

## Must
- Static types everywhere: `var gold: float = 0.0`, `func cost(level: int) -> float:`.
  Use `:=` only when the type is obvious from the right side.
- Enable in project settings: `debug/gdscript/warnings/untyped_declaration = error`
  (or warn), `unsafe_*` = warn.
- Naming: `snake_case` vars/funcs/files, `PascalCase` classes/nodes,
  `CONSTANT_CASE` consts, signals past tense (`promoted`, `upgrade_bought`).
  Private members start with `_`.
- File order: `class_name`, `extends`, doc comment, signals, enums, consts,
  `@export`, public vars, private vars, `@onready`, `_init/_ready`, public
  funcs, private funcs.
- One class per file; files under ~300 lines; functions under ~40 lines.
- Numbers: money as `float` via the big-number helper (see idle-economy);
  never compare floats with `==` (use `is_equal_approx`).
- No magic numbers in logic: constants or data tables.
- User-facing strings only via `tr("KEY")` (see localization).
- Comments explain *why*; `##` doc comments on public functions in `src/core`.
- Errors: `push_error` + safe fallback; never crash on a bad save, fall back to
  backup and log.

## Must not
- No `get_node` paths across scenes; no global state outside autoloads.
- No `await` in core logic; no `OS.delay_*`.
- No commented-out code, no `print` left in (use a `Log` helper gated by debug).

## Tests
- Every `src/core` function has a unit test; bug fixes add a failing test first.
- Test names: `test_<unit>_<behaviour>`.

## Gate before push
```bash
gdformat --check src tests tools && gdlint src tests tools
```
