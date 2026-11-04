# Corporate Ladder Tycoon: session rules

Idle tycoon for Japanese commuters. Godot 4, Android first, AdMob, local save
only, no backend. Owner is busy and works from a phone: Claude writes all
code; the owner only does phone-sized steps.

## Every session

1. Read the **Now** section of the private Master Plan doc (Claude Docs,
   owner-only): https://claude.ai/artifact/HFXEPmiGMfaXxZAyPm8Cnm
   Read the outline first, then only the section needed. Do that step.
2. Load the skill that matches the work (list below). Do not load all skills.
3. Work on the branch named by the session; push; the owner merges PRs.
4. Before finishing: tick the step in the doc, move the **Now** pointer,
   update Facts / Decisions if anything changed.
5. End the reply with the owner's next phone step, if any (`phone-handoff`).

## Skills (`.claude/skills/`)

| Work | Skill |
| --- | --- |
| Any Godot scene, script, project setting, export | `godot-engine` |
| Writing or reviewing GDScript | `gdscript-style` |
| Adding/updating any dependency, plugin, action, or secret | `dependency-security` |
| Long or repetitive sessions | `token-economy` |
| Adding any art, audio, font | `asset-licensing` |
| Keystore, AAB, CI release workflow, Play upload | `android-release` |
| Ads, consent, ad IDs | `admob-ads` |
| User-facing text | `localization` |
| Numbers, costs, prestige, offline earnings, design doc | `idle-economy` |
| Asking the owner for anything | `phone-handoff` |

## Hard rules

- Plans, design docs, tester data and business notes stay private: in
  Claude Docs or the gitignored `docs/` folder, never pushed (public repo).

- Never commit secrets, keystores, real tester emails, or `.env` files.
- Debug builds use AdMob **test IDs** only. Real IDs only in release config.
- Every asset gets a row in `assets/LICENSES.csv` in the same commit.
- Every dependency is pinned to an exact version (actions to a commit SHA).
- Game logic in pure, testable scripts; tests must pass before pushing.
- License is proprietary (see `LICENSE`); do not add code under GPL/AGPL.
