# Master Plan: Corporate Ladder Tycoon

Single source of truth for "what is the next step". Every session starts by
reading the **Now** block, does that step, ticks it, and moves the pointer.

- `[OWNER]` = phone-sized step only the owner can do (accounts, money, ID,
  approvals, secrets, testing on a real phone).
- `[CLAUDE]` = Claude does it in a cloud session and pushes to
  `claude/*` branches, then the owner merges the PR from the GitHub app.
- **Done when** = the check that closes the step. No step is done without it.

---

## Now

> **Current step: 1.1** (owner) and **2.1** (Claude) can run in parallel.
> Last updated: 2026-11-04, after Phase 0.

---

## Phase 0: Foundation and skills (done)

- [x] 0.1 `[CLAUDE]` Read the handoff doc ("Salaryman Climb: Game Plan and
  Handoff") and the repo.
- [x] 0.2 `[CLAUDE]` Write this plan in `docs/MASTER_PLAN.md`.
- [x] 0.3 `[CLAUDE]` Write `.gitignore` (secrets), `CLAUDE.md` (session rules) and project skills in
  `.claude/skills/`:
  | Skill | Covers |
  | --- | --- |
  | `godot-engine` | Godot 4 project layout, autoloads, headless test and export |
  | `gdscript-style` | Coding style, static typing, naming, lint and format gates |
  | `dependency-security` | Pinning, checksums, plugin review, Actions hardening, secrets |
  | `token-economy` | Rules to keep sessions short and cheap |
  | `asset-licensing` | Asset intake, license manifest, CREDITS.md, credits screen |
  | `android-release` | Keystore, Play App Signing, AAB, version codes, CI workflow |
  | `admob-ads` | Ad placement rules, test IDs, consent (UMP), policy |
  | `localization` | en / ja / id strings, CSV translations, font fallback |
  | `idle-economy` | Big-number math, cost curves, prestige, offline cap |
  | `phone-handoff` | How to ask the owner for things in phone-sized steps |
- [x] 0.4 `[CLAUDE]` Check the current Play tester rule (see Facts below).
- Done when: files merged to `main`.

## Phase 1: Owner accounts (phone, about 1 to 2 hours total)

- [ ] 1.1 `[OWNER]` Merge the Phase 0 PR in the GitHub app.
- [ ] 1.2 `[OWNER]` Create a Google Play Console **personal** developer account
  ($25, ID verification). Note the account creation date.
  Done when: the Play Console home screen opens. Send Claude: "Play account ready".
- [ ] 1.3 `[OWNER]` In Play Console, open the "Test and release" area and
  screenshot the text that describes production access requirements. Send it.
  Done when: Claude confirms the exact current tester rule and updates Facts.
- [ ] 1.4 `[OWNER]` Create an AdMob account (same Google account), add payment
  profile later. Do **not** create the app yet (it is linked after the Play
  listing exists).
- [ ] 1.5 `[OWNER]` Start recruiting at least 14 testers (12 required plus
  2 spare): Gmail address + Android phone + promise to keep the app installed
  14 days and open it a few times. Collect emails in a private note, not in
  the repo.
- [ ] 1.6 `[OWNER]` Decide the final title (D-1 below). Reply with one name.
- [ ] 1.7 `[OWNER]` Decide languages for v1 (D-2 below).

## Phase 2: Design doc (approval gate)

- [ ] 2.1 `[CLAUDE]` Write `docs/DESIGN.md` using the `idle-economy` and
  `admob-ads` skills: ranks, upgrade table with costs and growth rates,
  coworker table, prestige formula, overtime and stamina, nomikai event,
  offline cap, ad rules and cooldowns, save format, settings, credits screen.
  Include a simulated progression table (time to each rank) produced by a
  script in `tools/sim/` so the numbers are tested, not guessed.
- [ ] 2.2 `[OWNER]` Read the doc summary on the phone, reply "approve" or
  list changes. Done when: owner approval is recorded in Decisions.

## Phase 3: Godot project skeleton and CI

- [ ] 3.1 `[CLAUDE]` Pin the Godot version (latest stable 4.x at that time,
  verify on godotengine.org, record SHA-512 of the export templates).
- [ ] 3.2 `[CLAUDE]` Create the project: `project.godot`, folder layout from
  the `godot-engine` skill, portrait 1080x1920 base, autoloads
  (`GameState`, `SaveSystem`, `Economy`, `Ads`, `Clock`), a placeholder main
  scene.
- [ ] 3.3 `[CLAUDE]` Add tests (GUT or gdUnit4, pinned) for economy math and
  save/load. Add `gdtoolkit` lint + format check.
- [ ] 3.4 `[CLAUDE]` Add `.github/workflows/ci.yml`: on PR, run lint, format
  check, headless tests, and export a **debug APK** as a workflow artifact.
  All actions pinned to full commit SHAs; `permissions: contents: read`.
- [ ] 3.5 `[CLAUDE]` Add `.github/dependabot.yml` (github-actions weekly) and
  a secret-scan step (gitleaks, pinned).
- [ ] 3.6 `[OWNER]` In repo Settings on the phone browser: enable Dependabot
  alerts, secret scanning and push protection; protect `main` (require PR and
  green CI). Claude sends the exact taps.
- Done when: a PR shows a green CI run and a downloadable debug APK.
- [ ] 3.7 `[OWNER]` Download the debug APK on the phone, install, confirm it
  opens. Reply "APK opens" or a screenshot of the error.

## Phase 4: Signing and release pipeline

- [ ] 4.1 `[CLAUDE]` Explain the key choice (D-3). Recommended: Claude
  generates an **upload key** in the session; Google holds the real app
  signing key through Play App Signing, so a lost upload key can be reset by
  Play support (not fatal, but slow).
- [ ] 4.2 `[OWNER]` Add 4 repository secrets from the phone browser
  (Settings > Secrets and variables > Actions): `UPLOAD_KEYSTORE_B64`,
  `UPLOAD_KEYSTORE_PASSWORD`, `UPLOAD_KEY_ALIAS`, `UPLOAD_KEY_PASSWORD`.
  Save the same 4 values in a password manager as the backup.
- [ ] 4.3 `[CLAUDE]` Add `.github/workflows/release.yml`: manual dispatch or
  tag `v*`, builds a signed **AAB**, version code from run number, uploads it
  as a short-retention artifact. Secrets only in that job, never echoed.
- [ ] 4.4 `[OWNER]` Run the workflow from the GitHub app, confirm green.
- Done when: a signed AAB artifact exists and `apksigner`/`jarsigner` verify
  step in CI passes.

## Phase 5: Build the game (vertical slices, each one a PR the owner tests)

Each slice: Claude builds it with tests, CI gives a debug APK, owner plays
5 to 10 minutes on the train and replies with what feels wrong.

- [ ] 5.1 Tap to work, yen counter, big-number formatting, autosave.
- [ ] 5.2 Upgrades (desk, coffee, PC...) with cost curve from DESIGN.md.
- [ ] 5.3 Coworkers (idle income), buy x1 / x10 / max.
- [ ] 5.4 Ranks and promotion with prestige reset and permanent bonus.
- [ ] 5.5 Overtime button and stamina.
- [ ] 5.6 Nomikai timed event.
- [ ] 5.7 Offline earnings with cap and return popup.
- [ ] 5.8 Settings (sound, language, reset save), credits screen from
  `assets/LICENSES.csv`.
- [ ] 5.9 Localization pass (all strings through `tr()`), Japanese font check.
- [ ] 5.10 Art and audio pass (Kenney packs, recolored), app icon, splash.
- [ ] 5.11 Ads with **test IDs only**: rewarded x3 placements, interstitial
  after promotion with cooldown, consent (UMP) flow, no-fill handling.
- [ ] 5.12 Balance pass: re-run `tools/sim/`, tune, owner plays one full
  intern-to-CEO run.

## Phase 6: Store setup and closed test

- [ ] 6.1 `[CLAUDE]` Write privacy policy (en/ja/id) and host on GitHub Pages.
- [ ] 6.2 `[OWNER]` Allow Claude to use a `<username>.github.io` repo for the
  developer website (needed for `app-ads.txt`), or enable Pages on this repo.
- [ ] 6.3 `[CLAUDE]` Write store listing text (title, short and full
  description in en/ja/id), generate screenshots headless, feature graphic.
- [ ] 6.4 `[OWNER]` Create the app in Play Console, paste listing, fill Data
  safety (Claude gives answers), content rating questionnaire (Claude gives
  answers), target audience 13+ (avoid Families policy).
- [ ] 6.5 `[OWNER]` Create the AdMob app, link to Play listing, create
  1 interstitial + 3 rewarded units, send Claude the app ID and unit IDs.
- [ ] 6.6 `[CLAUDE]` Put real ad IDs in the release config only (debug keeps
  test IDs), add `app-ads.txt`.
- [ ] 6.7 `[OWNER]` Upload the AAB to Internal testing, install via the
  Play link, sanity check.
- [ ] 6.8 `[OWNER]` Promote to Closed testing, add the tester email list,
  send testers the opt-in link. Start the 14-day clock; note the date here.
- [ ] 6.9 `[CLAUDE]` During the 14 days: ship 1 to 2 fix updates from tester
  feedback (shows active testing).
- [ ] 6.10 `[OWNER]` Day 15+: apply for production access, answer the
  questionnaire (Claude drafts answers).

## Phase 7: Launch and run

- [ ] 7.1 `[OWNER]` Release to production (staged rollout 20% then 100%).
- [ ] 7.2 `[CLAUDE]` Weekly: read owner-sent screenshots of Play vitals and
  AdMob, propose one change.
- [ ] 7.3 `[CLAUDE]` Monthly: dependency and security review
  (`dependency-security` skill), Godot patch updates.

## Phase 8: Game 2 and onward

- [ ] 8.1 `[CLAUDE]` Extract a template repo (autoloads, CI, release, ads,
  l10n, licensing) so game 2 starts at Phase 2.
- [ ] 8.2 Each new app needs its own closed test on a personal account.
  Plan testers early.

---

## Decisions (open = needs owner reply)

| ID | Question | Options | Recommendation | Status |
| --- | --- | --- | --- | --- |
| D-1 | Final title | Corporate Ladder Tycoon / Salaryman Climb / other | Corporate Ladder Tycoon (matches repo; Claude proposes a Japanese store title for approval) | open |
| D-2 | v1 languages | en+ja / en+ja+id | en+ja+id if owner proofreads id; else add id in an update | open |
| D-3 | Upload key creation | Claude generates in session / owner generates elsewhere | Claude generates; owner stores secrets + backup | open |
| D-4 | Repo visibility | public (free Actions) / private (2,000 min/month) | public; never commit secrets or tester emails | decided: public |

## Facts (verified, with date)

- 2026-11-04: Personal Play developer accounts created after 2023-11-13 must
  run a closed test with **at least 12 testers opted in for 14 continuous
  days** before applying for production; it applies per new app, not to
  updates. Organization accounts are exempt. Source: third-party summaries;
  confirm against Play Console text in step 1.3.
- 2026-11-04: Maintained Godot 4 AdMob plugin: `cengiz-pz/godot-android-admob-plugin`
  (MIT, v6.x, Godot 4.4+). Re-check before step 5.11.
- 2026-11-04: Correction to the handoff doc: with Play App Signing (default
  for new apps), the key in GitHub secrets is the **upload key**. Losing it
  is recoverable through an upload-key reset; still back it up.

## Owner requests log

Keep only open items here; delete when answered.

- Steps 1.2 to 1.7.
