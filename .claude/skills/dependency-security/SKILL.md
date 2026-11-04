---
name: dependency-security
description: Supply-chain and vulnerability checks for every dependency (Godot binaries, export templates, addons/plugins, AdMob SDK, Python dev tools, GitHub Actions) plus secret handling. Use whenever adding, updating or reviewing a dependency, workflow or secret, and in the monthly review.
---

# Dependency security

## Intake checklist (run for EVERY new or updated dependency)
1. Need: can 30 lines of our own code replace it? Prefer that.
2. Source: official repo/release only. Record URL, exact version, and the
   SHA-256/512 in `DEPENDENCIES.md` (create it on first use).
3. License: MIT, BSD, Apache-2.0, MPL-2.0, zlib, CC0 OK. **No GPL/AGPL/LGPL
   code** (proprietary game). Record license in `DEPENDENCIES.md`.
4. Health: last release < 12 months, open security issues, maintainer count.
5. Advisories: check GitHub Security Advisories / OSV for the package and
   version (`https://osv.dev`, `pip-audit` for Python tools).
6. Review: skim the diff of what goes into `addons/` (no network calls,
   no `OS.execute`, no obfuscated code). For Android plugins, read the
   `.gdap`/AAR manifest permissions; reject unexpected permissions.
7. Pin: exact version. Vendor addons into `addons/` (committed) so builds do
   not fetch at build time.

## CI / GitHub Actions hardening
- Pin every action to a full commit SHA with a version comment:
  `uses: actions/checkout@<40-char-sha> # v4.x.x`.
- Top-level `permissions: contents: read`; widen per job only if needed.
- Download Godot + templates by exact URL and verify checksum
  (`sha512sum -c`) before use; fail the job on mismatch.
- No `pull_request_target`. Release secrets only in the release job, only on
  `workflow_dispatch` or tags from `main`.
- Never `echo` secrets; decode keystore to `$RUNNER_TEMP`, delete in `always()` step.
- Dependabot for `github-actions` (and `pip` for dev tools), weekly.
- gitleaks (pinned) runs on every PR.

## Secrets
- Allowed only in GitHub Actions secrets and the owner's password manager.
- `.gitignore` must cover: `*.keystore`, `*.jks`, `*.p12`, `.env*`,
  `export_credentials.cfg`, `android/build/`, `.godot/`.
- If a secret is ever committed: tell the owner immediately, rotate it, then
  purge history. Do not just delete the file.

## Monthly review (Phase 7.3)
- Dependabot/OSV alerts, Godot patch release notes (security fixes),
  AdMob/Play Services SDK version vs Play policy minimums, target API level
  deadline for Play. Summarize in 5 lines for the owner.
