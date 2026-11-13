# Dependencies

Every third-party tool or library, pinned. See the `dependency-security`
skill for the intake checklist. Game assets are tracked separately in
`assets/LICENSES.csv`.

| Dependency | Version | Used for | Source | Integrity pin | License | Checked |
| --- | --- | --- | --- | --- | --- | --- |
| Godot Engine (Linux editor, headless) | 4.7.2-stable | Import, tests, export (CI only) | github.com/godotengine/godot releases | SHA-512 in `ci.yml` (from official SHA512-SUMS.txt) | MIT | 2026-11-04 |
| Godot export templates | 4.7.2-stable | Android runtime shipped in the APK | same release | SHA-512 in `ci.yml` | MIT (+ bundled third-party notices, all permissive) | 2026-11-04 |
| gdtoolkit (+ transitive deps) | 4.5.0 | GDScript lint and format (dev only) | PyPI | hashes in `requirements-dev.txt`; pip-audit clean | MIT | 2026-11-04 |
| gitleaks | 8.30.1 | Secret scan in CI (dev only) | github.com/gitleaks/gitleaks releases | SHA-256 in `ci.yml` | MIT | 2026-11-04 |
| actions/checkout | v7.0.1 | CI | GitHub | commit SHA in `ci.yml` | MIT | 2026-11-04 |
| actions/setup-python | v7.1.0 | CI | GitHub | commit SHA | MIT | 2026-11-04 |
| actions/cache | v6.1.0 | CI | GitHub | commit SHA | MIT | 2026-11-04 |
| actions/upload-artifact | v7.0.2 | CI | GitHub | commit SHA | MIT | 2026-11-04 |
| actions/download-artifact | v8.0.2 | CI (publish test build) | GitHub | commit SHA | MIT | 2026-11-08 |

Test framework: none. `tests/run_tests.gd` is our own ~60-line runner, so no
third-party test addon ships with or builds the game.
