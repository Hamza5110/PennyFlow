# PennyFlow

**Track every penny, manage every moment.**

Offline-first personal finance app for Android (Flutter). See the product specification and architecture before writing features:

- [`docs/Expense_Tracker_SRS.md`](docs/Expense_Tracker_SRS.md) — requirements
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — project foundation & coding rules

## Stack

- Flutter (stable) + Material 3
- GetX (state, routing, DI)
- Isar Community (local DB)
- Google Sign-In + Drive AppData (backup — not implemented yet)
- `flutter_local_notifications`

## Status

**Foundation only.** Core structure, theme, DI, database bootstrap, settings, and splash are in place. Business modules (expenses, budgets, friends, …) are intentionally not implemented yet.

## Getting started

```bash
flutter pub get
dart run build_runner build   # after changing @collection models
flutter run --dart-define=ENV=development \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

Google Sign-In requires an OAuth 2.0 Web client ID (`GOOGLE_SERVER_CLIENT_ID`) configured in [Google Cloud Console](https://console.cloud.google.com/) with the Drive AppData scope.

## Project layout (summary)

```
lib/app/        # App shell, theme, routes, config, bootstrap
lib/core/       # Base classes, errors, logging, utils, shared widgets
lib/data/       # Isar, models, repositories
lib/services/   # Business & infrastructure services
lib/modules/    # Feature UI (splash only for now)
lib/localization/
```

Follow [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for every new feature.
