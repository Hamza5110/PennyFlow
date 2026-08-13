#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

: "${ENV:=production}"
: "${GITHUB_OWNER:=Hamza5110}"
: "${GITHUB_REPO:=PennyFlow}"

echo "==> SpendVault release build (ENV=$ENV)"

flutter pub get
dart run flutter_launcher_icons
dart run flutter_native_splash:create
flutter test -j 1

BUILD_ARGS=(
  "build" "apk" "--release"
  "--dart-define=ENV=${ENV}"
  "--dart-define=GITHUB_OWNER=${GITHUB_OWNER}"
  "--dart-define=GITHUB_REPO=${GITHUB_REPO}"
)

if [[ -n "${GOOGLE_SERVER_CLIENT_ID:-}" ]]; then
  BUILD_ARGS+=("--dart-define=GOOGLE_SERVER_CLIENT_ID=${GOOGLE_SERVER_CLIENT_ID}")
fi

flutter "${BUILD_ARGS[@]}"

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK_PATH" ]]; then
  echo "==> Release APK ready: $APK_PATH"
  ls -lh "$APK_PATH"
else
  echo "Build finished but APK not found at $APK_PATH" >&2
  exit 1
fi
