---
name: android-release
description: Android build and release for Godot via GitHub Actions - upload keystore, Play App Signing, signed AAB, version codes, target API level, Play tracks (internal, closed, production). Use for any CI build/release workflow, signing, or Play Console upload task.
---

# Android release

## Keys
- Play App Signing is used (default for new apps): Google keeps the app
  signing key; we hold only the **upload key**. Lost upload key = request an
  upload-key reset in Play Console (days, not fatal). Still back it up.
- Upload key: RSA 4096, validity 25+ years, generated with `keytool`:
  `keytool -genkeypair -v -keystore upload.keystore -alias upload -keyalg RSA -keysize 4096 -validity 10000`
- Stored as GitHub secrets: `UPLOAD_KEYSTORE_B64`, `UPLOAD_KEYSTORE_PASSWORD`,
  `UPLOAD_KEY_ALIAS`, `UPLOAD_KEY_PASSWORD`. Owner keeps the same values in a
  password manager. Delete any local copy after the owner confirms backup.

## Workflows
- `ci.yml` (PR + push): lint, format, tests, debug APK (debug keystore
  generated on the runner), artifact retention 7 days.
- `release.yml` (`workflow_dispatch` / tag `v*` on `main`): signed AAB,
  `versionCode = github.run_number + offset`, `versionName` from tag,
  verify signature (`jarsigner -verify`), artifact retention 3 days.
- Cache Godot + templates by version+checksum key. Use Java 17 and the
  Android SDK the pinned Godot version documents.
- Godot export env vars: `GODOT_ANDROID_KEYSTORE_RELEASE_PATH`,
  `GODOT_ANDROID_KEYSTORE_RELEASE_USER`, `GODOT_ANDROID_KEYSTORE_RELEASE_PASSWORD`.

## Play requirements to keep checking (verify current values)
- Target API level: Play's yearly minimum (check before each release).
- AAB only for new apps; 64-bit libs (Godot provides arm64-v8a).
- Privacy policy URL (required with ads), Data safety form, content rating,
  ads declaration "contains ads", target audience 13+.
- Personal accounts: closed test with 12+ testers for 14 continuous days per
  new app before production (see Master Plan Facts for the verified date).

## Tracks
internal (owner only, instant) -> closed (testers, 14 days) -> production
(staged rollout). Every upload needs a higher versionCode.
