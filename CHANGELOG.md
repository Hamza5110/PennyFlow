# Changelog

All notable changes to PennyFlow are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-08-12

### Added

- **Budget envelopes**: period total (e.g. weekly 3000) with Cash / Bank / JazzCash funding split; all expenses in the period count toward the total (no category pre-allocation)
- Envelope periods: 7 days, 15 days, monthly, 3 months, or custom range, with optional auto-repeat and funding posted as income
- Budgets screen: separate Add envelope / Add category budget actions (no bottom sheet); dashboard shows envelopes before category budgets

[1.2.0]: https://github.com/Hamza5110/PennyFlow/releases/tag/v1.2.0


## [1.1.0] - 2026-08-11

### Added

- Flexible budget periods: monthly, 7-day, 15-day, and custom ranges with auto-repeat cycles
- Stronger budget and reminder notification scheduling and delivery
- Report file storage with Android FileProvider / open-file handling

### Fixed

- Google Sign-In on release builds: document registering debug and release SHA-1 fingerprints

### Release

- Force update for installs below 1.1.0 (`[force-update]` in GitHub release notes)

[1.1.0]: https://github.com/Hamza5110/PennyFlow/releases/tag/v1.1.0

## [1.0.0] - 2026-08-06

### Added

- Offline-first expense and income tracking with categories and payment accounts
- Dashboard with period summaries, budget progress, and quick actions
- Friends ledger with repayments and transaction status
- Budgets, recurring templates, and reminders
- Statistics, reports (PDF/CSV/Excel), and global search
- Google Drive AppData backup and restore
- GitHub release in-app update flow with APK download and install
- PIN and biometric app lock with session timeout
- English and Urdu localization with theme and currency settings
- Data export/import and soft-delete trash retention

### Release

- Branded app icon and native splash screen
- Application ID `com.pennyflow.app`
- Open-source licenses screen in Settings
- Release APK build script and signing template

[1.0.0]: https://github.com/Hamza5110/PennyFlow/releases/tag/v1.0.0
