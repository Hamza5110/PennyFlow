# PennyFlow

**Track every penny, manage every moment.**

Offline-first personal finance app for Android, built with Flutter. PennyFlow keeps your expenses, income, budgets, and friend ledger on-device with optional Google Drive backup and GitHub-based in-app updates.

## Features

- Expense and income tracking with categories, accounts, receipts, and trash
- Dashboard, statistics, budgets, recurring transactions, and reminders
- Friends ledger with repayments and balance tracking
- Reports (PDF, CSV, Excel) and global search
- Google Drive AppData backup and restore
- PIN / biometric app lock
- In-app APK updates via GitHub Releases
- English and Urdu localization, light/dark themes

## Documentation

| Document | Purpose |
|----------|---------|
| [`docs/Expense_Tracker_SRS.md`](docs/Expense_Tracker_SRS.md) | Product requirements |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Code structure and conventions |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Signed APK build and release checklist |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history |

## Requirements

- Flutter stable (Dart SDK ^3.12)
- Android SDK for APK builds
- Google Cloud OAuth Web client ID (optional, for Drive backup)

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after @collection model changes
dart run flutter_launcher_icons                            # regenerate launcher icons
dart run flutter_native_splash:create                      # regenerate native splash

flutter run --dart-define=ENV=development \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

## Testing

```bash
flutter test -j 1
flutter analyze
```

Isar integration tests download the native core on first run (`test/support/isar_test_helper.dart`).

## Release APK

See [`docs/RELEASE.md`](docs/RELEASE.md) for keystore setup and the full checklist.

```bash
chmod +x scripts/build_release_apk.sh
GOOGLE_SERVER_CLIENT_ID=your-id.apps.googleusercontent.com ./scripts/build_release_apk.sh
```

**Version:** `1.0.0+1` · **Application ID:** `com.pennyflow.app`

## Project layout

```
lib/app/        # App shell, theme, routes, config
lib/core/       # Base classes, errors, logging, shared widgets
lib/data/       # Isar models and repositories
lib/services/   # Business and infrastructure services
lib/modules/    # Feature UI (GetX modules)
lib/localization/
```

## License

PennyFlow is released under the [MIT License](LICENSE). Third-party package licenses are available in **Settings → Open-source licenses**.
