# SpendVault Release Guide

This document describes how to produce a signed release APK for distribution outside the Play Store (SRS §28).

## Prerequisites

- Flutter stable SDK (see `pubspec.yaml` for Dart SDK constraint)
- Android SDK with build-tools installed
- A release keystore (`.jks`) — create once:

```bash
keytool -genkey -v \
  -keystore android/keystore/spendvault-release.jks \
  -alias spendvault \
  -keyalg RSA -keysize 2048 -validity 10000
```

## Configure signing

1. Copy `android/key.properties.example` to `android/key.properties`
2. Fill in keystore paths and passwords
3. **Never commit** `key.properties` or `*.jks` files

If you already have a keystore (for example `pennyflow-release.jks`), keep using it — point `key.properties` at that file. Only generate a new keystore if you do not already have one.

Release builds use the release keystore when `android/key.properties` exists; otherwise they fall back to the debug keystore (local testing only).

The application ID is now `com.spendvault.app`. Register a new **Android** OAuth client with that package name (the previous `com.pennyflow.app` client will not match).

## Google Sign-In (required for release)

Debug and release APKs use **different signing certificates**. Google OAuth validates package name + SHA-1, so both fingerprints must be registered.

1. Print fingerprints:

```bash
# Debug (this machine)
keytool -list -v \
  -keystore ~/.android/debug.keystore \
  -alias androiddebugkey \
  -storepass android -keypass android

# Release keystore
keytool -list -v \
  -keystore android/keystore/spendvault-release.jks \
  -alias spendvault

# Or from a built/published APK
apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk
```

2. In [Google Cloud Console → Credentials](https://console.cloud.google.com/apis/credentials):
   - Keep your existing **Web** client ID (used as `GOOGLE_SERVER_CLIENT_ID`)
   - Create/update an **Android** OAuth client:
     - Package name: `com.spendvault.app`
     - Add **both** debug and release SHA-1 fingerprints
3. Wait a few minutes after saving, then reinstall the release APK and retry sign-in

Symptom of a missing release SHA-1: `ApiException: 10` / `DEVELOPER_ERROR` (works in debug, fails on GitHub release APK).

## Build defines

| Define | Required | Description |
|--------|----------|-------------|
| `ENV` | Yes | `production` for release builds |
| `GOOGLE_SERVER_CLIENT_ID` | For backup | OAuth 2.0 Web client ID |
| `GITHUB_OWNER` | For updates | GitHub org/user hosting releases |
| `GITHUB_REPO` | For updates | GitHub repository name (currently `PennyFlow` until the repo is renamed) |

## Build steps

Run the helper script from the repository root:

```bash
chmod +x scripts/build_release_apk.sh
GOOGLE_SERVER_CLIENT_ID=your-id.apps.googleusercontent.com \
  ./scripts/build_release_apk.sh
```

Or manually:

```bash
flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter test -j 1
flutter build apk --release \
  --dart-define=ENV=production \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-id.apps.googleusercontent.com \
  --dart-define=GITHUB_OWNER=Hamza5110 \
  --dart-define=GITHUB_REPO=PennyFlow
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## GitHub release checklist

1. Bump `version` in `pubspec.yaml` (semver + build number)
2. Update `CHANGELOG.md`
3. Tag the release: `git tag v1.0.0`
4. Create a GitHub Release with notes from the changelog
5. Attach `app-release.apk` as a release asset
6. Add `[force-update]` to release notes only when a mandatory upgrade is required

## Versioning

- **versionName** (`1.0.0`) — user-visible semver in Settings → About
- **versionCode** (`+1` in pubspec) — monotonic integer for Android updates
- **Application ID** — `com.spendvault.app` (do not change after first public release)

## QA before shipping

- [ ] Cold start → splash → home/profile setup
- [ ] Add expense, income, friend transaction
- [ ] Backup and restore on a second device/emulator
- [ ] App lock PIN + biometric unlock
- [ ] In-app update detects a newer GitHub release
- [ ] Urdu locale and dark theme smoke test
