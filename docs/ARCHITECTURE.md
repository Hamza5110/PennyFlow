# PennyFlow Architecture

**Status:** Foundation (no business features yet)  
**Stack:** Flutter · GetX · Isar Community · Material 3  
**Source of truth (product):** [`Expense_Tracker_SRS.md`](./Expense_Tracker_SRS.md)

Every future feature **must** follow this document. If a change conflicts with the SRS, update the SRS first, then this architecture doc, then code.

---

## 1. Goals

| Goal | How we achieve it |
| --- | --- |
| Offline-first | Isar is the system of record; network is optional (backup / update only) |
| Maintainable | Feature modules + clean layering (UI → Controller → Service → Repository → DB) |
| Testable | Business logic in services; repositories isolatable; controllers stay thin |
| Scalable | Feature-first folders; DI via GetX bindings; schema registry + migrations |
| Practical Clean Architecture | Separation of concerns without over-abstracting for a single offline app |

---

## 2. Folder Structure

```
lib/
├── main.dart                          # Entry — calls AppInitializer then runApp
├── app/
│   ├── penny_flow_app.dart            # GetMaterialApp shell
│   ├── app_initializer.dart           # Ordered bootstrap (env, storage, DB, settings)
│   ├── bindings/
│   │   └── initial_binding.dart       # App-wide DI assertions / sync deps
│   ├── config/
│   │   ├── app_config.dart            # Runtime config + OAuth scopes
│   │   └── env_config.dart            # --dart-define ENV / GitHub release host
│   ├── routes/
│   │   ├── app_routes.dart            # Route name constants
│   │   └── app_pages.dart             # GetPage table
│   └── theme/
│       ├── app_colors.dart            # Brand + semantic color tokens
│       ├── app_typography.dart        # Plus Jakarta Sans + JetBrains Mono
│       └── app_theme.dart             # Material 3 ThemeData (light/dark)
├── core/
│   ├── base/
│   │   ├── base_controller.dart       # Thin GetxController helpers
│   │   ├── base_repository.dart       # Typed DB error wrapping
│   │   └── base_service.dart          # ServiceResult guard mixin
│   ├── constants/
│   │   ├── app_constants.dart
│   │   ├── storage_keys.dart
│   │   └── validation_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart         # Typed exceptions + Failure
│   │   ├── error_handler.dart         # Global + UI error surfacing
│   │   └── service_result.dart        # SRS §26.1 result envelope
│   ├── extensions/
│   ├── logging/
│   │   └── app_logger.dart
│   ├── utils/
│   └── widgets/                       # Reusable UI primitives only
├── data/
│   ├── local/database/
│   │   ├── isar_database.dart         # Single Isar owner (GetxService)
│   │   └── isar_schemas.dart          # Schema registry
│   ├── models/                        # Isar collections + shared enums
│   └── repositories/                  # Data access only
├── services/                          # Business + infrastructure services
│   ├── settings/
│   └── storage/
├── modules/                           # Feature UI (view / controller / binding)
│   └── splash/                        # Bootstrap gate only (foundation)
└── localization/
    ├── app_translations.dart
    └── locales/
        ├── en_us.dart
        └── ur_pk.dart                 # Prepared; not fully productized yet

assets/
├── images/
├── icons/
└── fonts/                             # Optional; google_fonts used at runtime

docs/
├── Expense_Tracker_SRS.md
└── ARCHITECTURE.md                    # This file
```

### Module layout (every feature)

```
lib/modules/<feature>/
├── bindings/<feature>_binding.dart
├── controllers/<feature>_controller.dart
├── views/<feature>_view.dart
└── widgets/                           # Feature-private widgets (optional)
```

Supporting layers for that feature:

```
lib/data/models/<entity>.dart
lib/data/repositories/<entity>_repository.dart
lib/services/<feature>/<feature>_service.dart
```

---

## 3. Layer Responsibilities

```
┌─────────────────────────────────────────────┐
│  Views (Flutter widgets)                    │  UI only
├─────────────────────────────────────────────┤
│  Controllers (GetX)                         │  UI state, navigation, glue
├─────────────────────────────────────────────┤
│  Services                                   │  Business rules, orchestration
├─────────────────────────────────────────────┤
│  Repositories                               │  CRUD / queries / transactions
├─────────────────────────────────────────────┤
│  Isar / SharedPreferences / SecureStorage   │  Persistence
└─────────────────────────────────────────────┘
```

### Controllers

- Extend `BaseController`.
- Hold **reactive UI state** (`Rx`, form flags, selected filters).
- Call **services** only — never Isar, never repositories.
- Stay lightweight: no domain math, no backup logic, no report generation.
- Use `runGuarded` / `unwrapResult` for loading + error UX.

### Services

- Use `BaseService` mixin.
- Own validation, orchestration, and cross-repo workflows.
- Return `ServiceResult<T>` for expected outcomes (SRS §26.1).
- May call other services (e.g. ExpenseService → BudgetService / BudgetEnvelopeService).
- Must not import widgets or depend on controllers.

### Repositories

- Extend `BaseRepository` / `IsarBaseRepository<T>`.
- Own persistence and query details only.
- Wrap reads/writes so failures become `DbException` / `DbWriteException`.
- Soft-delete / restore rules are coordinated by services but executed via repository methods.

### Views

- Stateless / `GetView` preferred.
- Bind to controller observables with `Obx` / `GetX`.
- No business logic; no direct service/repository access.
- Use shared widgets from `core/widgets` before inventing new ones.

---

## 4. State Management Rules (GetX)

1. **One controller per screen/flow** (or tightly coupled flow), registered via that module’s `Bindings`.
2. **App-wide singletons** (DB, settings, secure storage) are `permanent: true` and registered in `AppInitializer`.
3. Prefer `Get.lazyPut` for feature controllers; prefer `Get.putAsync` for async infrastructure.
4. Use `Rx` / `.obs` for UI state. Do not mirror entire database collections into memory without pagination/watchers.
5. Prefer Isar watchers / streams (via services) for live lists when implementing features — controllers subscribe, they don’t poll.
6. Never use `Get.put` inside `build()`.
7. Reset feature controllers when leaving long-lived nested navigators if memory matters (`fenix: true` only when intentional).

---

## 5. Dependency Injection Strategy

| Lifetime | Examples | Registration |
| --- | --- | --- |
| App singleton | `IsarDatabase`, `LocalStorageService`, `SecureStorageService`, `SettingsService` | `AppInitializer` via `Get.putAsync(..., permanent: true)` |
| App binding check | Asserts infrastructure is present | `InitialBinding` |
| Feature scoped | Controllers, feature services/repos | `*Binding` with `Get.lazyPut` |

**Rules**

- Constructor-inject collaborators where practical (`SettingsService(LocalStorageService)`).
- Resolve with `Get.find<T>()` only at composition roots (bindings / controllers), not deep inside widgets.
- Feature bindings own their graph — do not register expense deps in `InitialBinding`.

---

## 6. Database Strategy

- **Engine:** [isar_community](https://pub.dev/packages/isar_community) (maintained Isar 3 fork). Import: `package:isar_community/isar.dart`.
- **Owner:** `IsarDatabase` (single instance, name `penny_flow`).
- **Schema registry:** `IsarSchemas.all` — every new `@collection` must be registered here.
- **Versioning:** `AppMeta.schemaVersion` ↔ `AppConstants.databaseSchemaVersion`. Migrations run in `IsarDatabase._migrate`.
- **Transactions:** All multi-step writes go through `isar.writeTxn` (via repository `runWrite` / `db.writeTxn`).
- **Settings:** SharedPreferences only (theme, locale, toggles, backup meta timestamps). **No transactional data.**
- **Secrets:** `SecureStorageService` only (PIN hash, OAuth tokens).
- **Multi-profile:** Every future business collection includes `profileId`. Queries must always scope by active profile.

### Adding a collection (checklist)

1. Create model in `lib/data/models/` with `@collection` / indexes per SRS §20.
2. `dart run build_runner build`
3. Add `*Schema` to `IsarSchemas.all`
4. Bump `databaseSchemaVersion` and implement migration if needed
5. Create repository + register in feature binding / `AppInitializer`
6. Never access the collection from a controller

Registered business collections include (among others): `Budget`, `BudgetEnvelope`, expenses, incomes, categories, payment accounts, friends ledger, recurring templates, reminders.

---

## 7. Error Handling & Logging

| Layer | Approach |
| --- | --- |
| Forms | `AppValidators` + inline field errors |
| Services | Catch `AppException` → `ServiceResult.failure` |
| Repositories | Map to `DbException` / `DbWriteException` |
| Controllers | `runGuarded` / `unwrapResult` → snackbar via `ErrorHandler` |
| Global | `ErrorHandler.installGlobalHandlers()` in bootstrap |

Logging: use `AppLogger.instance` only. **Never log PINs, tokens, or raw backup payloads.**

---

## 8. Theming & Design Tokens

- Material 3 via `AppTheme.light()` / `AppTheme.dark()`.
- Brand palette: teal/slate finance tones in `AppColors` (not generic purple).
- Typography: Plus Jakarta Sans (UI) + JetBrains Mono (money) via `google_fonts`.
- Semantic colors: `income`, `expense`, `pending`, budget status helpers.
- Theme mode is reactive through `SettingsService.themeMode`.

---

## 9. Routing

- Route names: `AppRoutes`
- Page table: `AppPages.routes`
- Initial route: splash (`AppRoutes.splash`)
- Reserved routes exist for upcoming modules; **do not** add feature screens until scheduled.
- Navigation pattern (SRS §23): bottom nav + FAB — implement inside a future `home` shell module, not ad hoc per feature.

---

## 10. Localization (prepared)

- GetX `Translations` in `AppTranslations`.
- Locales: `en_US`, `ur_PK` (structure ready).
- Use `'key'.tr` for user-facing strings as features land.
- Do not hard-code copy in widgets when a key exists.

---

## 11. Environment Configuration

Build with dart-defines:

```bash
flutter run --dart-define=ENV=development
flutter build apk --dart-define=ENV=production \
  --dart-define=GITHUB_OWNER=your-org \
  --dart-define=GITHUB_REPO=penny_flow
```

`EnvConfig` exposes environment, logging flags, and the GitHub Releases URL used by the future update service.

---

## 12. Settings Management

`SettingsService` is the only API for lightweight preferences:

- Theme, locale, currency code
- Auto-backup / auto-update-check toggles
- Notification toggles
- Last backup metadata
- Active profile id / onboarding flag

Features must not write SharedPreferences keys directly — add methods on `SettingsService` (and keys on `StorageKeys`).

---

## 13. Coding Standards

### Naming

| Kind | Convention | Example |
| --- | --- | --- |
| Files | `snake_case.dart` | `expense_service.dart` |
| Classes | `PascalCase` | `ExpenseService` |
| Controllers | `*Controller` | `DashboardController` |
| Services | `*Service` | `BudgetService`, `BudgetEnvelopeService` |
| Repositories | `*Repository` | `ExpenseRepository` |
| Bindings | `*Binding` | `ExpensesBinding` |
| Views | `*View` | `SplashView` |
| Private members | `_camelCase` | `_settings` |
| Constants | `camelCase` / `SCREAMING` only for true compile-time env | `AppConstants.appName` |
| Route paths | `/kebab-case` | `/app-lock` |

### Style

- `prefer_single_quotes`, trailing commas, `always_declare_return_types` (see `analysis_options.yaml`).
- Prefer composition over inheritance (except thin bases: controller / repository / service mixin).
- SOLID where it clarifies boundaries — don’t create interfaces for every concrete offline service unless mocking requires it.
- No `print()` — use `AppLogger`.
- Keep methods short; extract private helpers rather than 200-line controllers.

### Imports

- Prefer relative imports within a layer; package imports for cross-package / tests.
- No circular imports (views → controllers → services → repositories → models).

---

## 14. Future Feature Integration Guidelines

When implementing a feature from the SRS (expenses, friends, budgets, backup, updates, …):

1. **Read the relevant FR / schema section** in the SRS.
2. **Model first** — Isar collection + indexes + `profileId`.
3. **Repository** — queries needed by the feature; soft-delete helpers if applicable.
4. **Service** — validation (Section 30), orchestration, `ServiceResult`.
5. **Controller + Binding + View** under `modules/<feature>/`.
6. **Register routes** in `AppRoutes` / `AppPages`.
7. **Add localization keys**.
8. **Wire side effects** (category budget + envelope recalc, notifications) via services — not from the view.
9. **Do not** put business logic in widgets or controllers.
10. **Do not** bypass repositories for Isar access.
11. **Keep splash/bootstrap** as the only place for cold-start routing decisions (profile / lock / restore).

### Suggested implementation order (guidance)

1. Profile create/select  
2. Categories + Payment accounts  
3. Expenses + Income  
4. Dashboard shell + bottom nav  
5. Friends + repayments  
6. Budgets (category) + budget envelopes + notifications
7. Search / filters / trash  
8. Statistics + reports  
9. Recurring + reminders  
10. Google Sign-In + Drive backup/restore  
11. App lock  
12. In-app updater  

---

## 15. What This Foundation Explicitly Does *Not* Include

- Expense / income / budget / friend screens or business services  
- Google Drive backup implementation  
- In-app update downloader  
- Chart dashboards  
- Report generation UI  

Dependencies for those features are already declared in `pubspec.yaml` so later work can focus on architecture-compliant implementation.

---

## 16. Quick Reference — Key Types

| Type | Path |
| --- | --- |
| `BaseController` | `lib/core/base/base_controller.dart` |
| `BaseRepository` | `lib/core/base/base_repository.dart` |
| `BaseService` | `lib/core/base/base_service.dart` |
| `ServiceResult<T>` | `lib/core/errors/service_result.dart` |
| `IsarDatabase` | `lib/data/local/database/isar_database.dart` |
| `SettingsService` | `lib/services/settings/settings_service.dart` |
| `AppTheme` | `lib/app/theme/app_theme.dart` |
| `AppPages` | `lib/app/routes/app_pages.dart` |

---

*PennyFlow foundation — August 2026. All subsequent PRs should cite this architecture when introducing modules.*
