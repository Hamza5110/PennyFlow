# Software Requirements Specification

Expense Tracker — Offline-First Flutter Application

Document Standard: IEEE 29148 / IEEE 830

Version: 1.0

Date: August 5, 2026

Status: Draft for Development

*Prepared for: Flutter Development Team*

# Table of Contents

# 1. Revision History

| Version | Date | Author | Description |
| --- | --- | --- | --- |
| 0.1 | 2026-08-05 | Product Owner | Initial draft compiled from project requirements brief |
| 1.0 | 2026-08-05 | Business Analyst | Full SRS generated: functional, non-functional, architecture, diagrams, schema |

# 2. Introduction

This Software Requirements Specification (SRS) describes the functional and non-functional requirements for the Expense Tracker application, an offline-first personal finance mobile app built with Flutter. The document follows the structure and intent of IEEE 29148 (successor to IEEE 830) and is written to be implementation-ready: a Flutter developer should be able to begin coding directly from the specifications, schema, and diagrams contained here.

The application allows an individual user to record expenses and income, track money lent to or borrowed from friends, manage budgets, view statistics, generate reports, and safely back up and restore all data via the user's own Google Drive account. Because the app will initially be distributed as a sideloaded APK rather than through the Google Play Store, the SRS also specifies a custom in-app update mechanism.

# 3. Purpose

The purpose of this document is to:
- Define the complete functional scope of the Expense Tracker MVP so that development, QA, and design proceed from a single source of truth.

- Specify non-functional constraints (performance, security, reliability, usability) that the implementation must satisfy.

- Provide the data model, workflows, and diagrams necessary to design the Isar database schema, GetX architecture, and Google Drive backup/restore pipeline without further clarification.

- Establish acceptance criteria that QA and the product owner can use to verify the delivered application against this specification.

# 4. Scope

The product is a single Flutter codebase producing an Android APK (Material Design 3, offline-first, GetX state management, Isar local database). It supports multiple local user profiles on a single device, Google Sign-In for backup ownership, and Google Drive AppData Folder as the sole cloud backup destination — there is no dedicated backend server.

In scope for the MVP:
- Expense, income, and friend-lending transaction management with receipt images

- Categories, payment accounts, budgets, recurring transactions, and reminders

- Search, filtering, statistics/charts, and PDF/Excel/CSV report export

- Manual and automatic Google Drive backup and restore

- Optional app lock (PIN / biometric)

- A custom, non-Play-Store, in-app APK update mechanism sourced from GitHub Releases

Out of scope for the MVP (see Section 32 — Future Roadmap):
- OCR receipt scanning, AI categorization, voice entry

- Multi-device real-time sync, shared/family wallets, bill splitting

- iOS, web, and desktop clients

- Bank API integration and QR payment import

# 5. Intended Audience

| Audience | Use of this document |
| --- | --- |
| Flutter Developer(s) | Primary implementers; use functional requirements, schema, diagrams, and API/service architecture directly for coding |
| QA / Tester | Derive test cases from Functional Requirements, Use Cases, and Acceptance Criteria |
| Product Owner | Validate scope, sign off on acceptance criteria, prioritize roadmap |
| UI/UX Designer | Use UI Screen List, Navigation Flow, and User Stories to design screens |
| Future Maintainers | Use Database Schema, ERD, and Architecture sections to onboard quickly |

# 6. Definitions and Acronyms

| Term | Definition |
| --- | --- |
| SRS | Software Requirements Specification |
| MVP | Minimum Viable Product — the initial release scope |
| FR | Functional Requirement |
| NFR | Non-Functional Requirement |
| Offline-first | Architecture where the app is fully usable without network access; the network is used only for optional backup/restore and update checks |
| Isar | A NoSQL, embedded local database for Flutter/Dart used as the app's primary data store |
| GetX | A Flutter library providing state management, dependency injection, and route management |
| AppData Folder | A hidden, per-app folder in the user's Google Drive, accessible only to the application that created it |
| APK | Android Application Package — the installable file format for Android apps |
| Sideloading | Installing an APK manually, outside the Google Play Store |
| Friend Ledger | The set of Money Given / Money Received records tracked per friend, including partial repayments |
| Soft delete | Marking a record as deleted (moved to Trash) without immediately removing it from the database |
| Recurring Transaction | A transaction template that automatically generates new expense/income entries on a schedule |

# 7. Product Perspective

The Expense Tracker is a new, standalone mobile application. It is not a component of an existing system, but it is designed to be extensible toward a future family of clients (web dashboard, iOS, desktop) that would share the same conceptual data model.

## 7.1 System Context

The application runs entirely on-device. The only external systems it talks to are Google's own services, used strictly as utilities rather than as a backend:
- Google Sign-In — establishes the user's identity for backup ownership.

- Google Drive API (AppData scope) — stores/retrieves a single hidden backup bundle per Google account.

- GitHub Releases (or equivalent static host) — publishes new APK versions and release notes for the in-app updater.

+-------------------------+          +----------------------+
|   Expense Tracker App   |  HTTPS   |  Google Sign-In /     |
|   (Flutter, Android)    +--------->+  Google Drive AppData |
|                         |          |  (backup/restore)    |
|  - Isar local DB        |          +----------------------+
|  - Local image storage  |
|  - GetX state/routing   |          +----------------------+
|  - flutter_local_notif. |  HTTPS   |  GitHub Releases API  |
|                         +--------->+  (APK + changelog)   |
+-------------------------+          +----------------------+

## 7.2 User Perspective

A single installed APK supports multiple local profiles (Section 9), each with its own isolated data partition inside the same Isar database instance and its own Google account for backup. This satisfies the requirement to share the APK with friends and family while keeping each person's financial data private on that device.

# 8. Product Functions

At a high level the product performs the following functions, each elaborated fully in Sections 13 (Functional Requirements) and the Application Modules referenced throughout this document:

| # | Function | Summary |
| --- | --- | --- |
| 1 | Transaction Management | Create/edit/delete/duplicate/search/filter expenses and income, with receipts, tags, and locations |
| 2 | Friend Money Tracking | Track money given/received per friend with partial repayment and pending balance calculation |
| 3 | Categorization & Accounts | Custom categories and multiple payment accounts, each with running balances |
| 4 | Budgeting | Category budgets and period envelopes (total + funding split) with progress and threshold notifications |
| 5 | Statistics & Reporting | Interactive charts and PDF/Excel/CSV export |
| 6 | Recurring Transactions & Reminders | Auto-generate scheduled transactions and notify on due dates |
| 7 | Backup & Restore | Manual/automatic Google Drive backup of DB, images, and settings; full restore after reinstall |
| 8 | Security | Optional PIN/biometric app lock |
| 9 | In-App Update | Check, download, and install new APK versions outside the Play Store |

# 9. User Classes and Characteristics

| User Class | Characteristics | Access |
| --- | --- | --- |
| Primary User (Profile Owner) | The person who installed the app and owns a local profile; typically non-technical, wants a fast, simple daily-use tool | Full access to their own profile's data, settings, backup, and update controls |
| Secondary/Shared-Device User | Family/friend using the same physical device under a different local profile after receiving the shared APK | Full access to their own profile only; profiles are isolated from each other on the same device |
| App Administrator (Developer) | The developer distributing the APK and publishing GitHub Releases | No in-app role; interacts only via the update-hosting mechanism, outside the app itself |

Note: there is no client-server multi-user concept in the MVP. "Multiple users" means multiple independent local profiles on one device, each authenticated to its own Google account for backup — not shared or synchronized data between people.

# 10. Operating Environment

| Layer | Requirement |
| --- | --- |
| OS | Android 8.0 (API 26) minimum; target/compile against the latest stable Android API |
| Runtime | Flutter (latest stable channel), Dart null-safety enabled |
| Local Database | Isar (embedded NoSQL database) |
| Lightweight Settings | SharedPreferences |
| Network | Required only for Google Sign-In, Drive backup/restore, and update checks; all core features work fully offline |
| Distribution | Sideloaded APK (not on Google Play Store at launch); GitHub Releases as the update source |
| Device Storage | Local file system for compressed receipt images; app must function on devices with limited storage and degrade gracefully near capacity |

# 11. Design Constraints

- Must use Flutter with GetX for state management, dependency injection, and navigation — no alternative state management library.

- Must use Isar as the primary local database; SharedPreferences is reserved strictly for lightweight settings (theme, locale, toggles), not transactional data.

- No dedicated backend server and no Firebase Storage — cloud backup must use only the Google Drive AppData folder via the user's own Google account.

- Because the AppData folder is hidden from the user's normal Drive view, the app is the only way to inspect or manage the backup; the app must therefore expose backup status, size, and last-backup-time in Settings.

- The app must not depend on the Google Play Store for updates; APK download and install must be handled in-app using Android's package installer intents.

- Material Design 3 must be used throughout for visual consistency.

- Charting must use fl_chart; notifications must use flutter_local_notifications; these are fixed technical choices, not merely suggestions.

# 12. Assumptions and Dependencies

## 12.1 Assumptions

- Users have (or will create) a Google account; backup/restore is unavailable without one, but the app remains fully usable offline without it.

- Users installing the shared APK understand it comes from outside the Play Store and will grant "install unknown apps" permission when prompted.

- A single physical device is used by at most a handful of local profiles; there is no requirement to support dozens of concurrent profiles.

- Currency is single-currency per profile (no live exchange-rate conversion in the MVP).

## 12.2 Dependencies

| Dependency | Purpose | Risk if unavailable |
| --- | --- | --- |
| google_sign_in / googleapis (Dart) | Google authentication and Drive API access | Backup/restore disabled; core app unaffected |
| isar / isar_flutter_libs | Local persistence | App cannot function — core dependency |
| fl_chart | Statistics visualizations | Dashboard/statistics screens degrade to tables |
| flutter_local_notifications | Reminders and budget alerts | Reminders silently unavailable |
| GitHub Releases API (or chosen static host) | In-app update source | Update checks fail gracefully; manual sideload still possible |
| pdf / excel / csv export packages | Report generation | Report screen disabled with a clear message |

# 13. Functional Requirements

Requirements are grouped by module. Priority: M = Must-have (MVP blocker), S = Should-have, C = Could-have (nice to have in MVP).

## 13.1 Dashboard (FR-001 – FR-014)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-001 | The dashboard shall display total expenses, total income, and current balance for the selected period. | M |
| FR-002 | The dashboard shall display total money lent, total money borrowed, pending amount to receive, and pending amount to pay. | M |
| FR-003 | The dashboard shall display today's spending and this month's spending. | M |
| FR-004 | The dashboard shall list the most recent transactions (default 5–10, configurable) with quick navigation to details. | M |
| FR-005 | The dashboard shall render a monthly spending chart (fl_chart) summarizing the last 6–12 months. | M |
| FR-006 | The dashboard shall show budget progress bars for active envelopes and category budgets, color-coded (normal / warning / exceeded), with envelopes listed first. | M |
| FR-007 | The dashboard shall provide a floating Quick Add button to create an expense in under 3 taps. | M |
| FR-008 | The dashboard shall recompute all summary figures immediately after any transaction is added, edited, or deleted (no manual refresh). | M |
| FR-009 | The dashboard shall allow the user to switch the summary period (Today / This Week / This Month / Custom). | S |
| FR-010 | The dashboard shall display balances broken down per payment account. | S |

## 13.2 Expense Management (FR-015 – FR-034)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-015 | The system shall allow creation of an expense with amount, category, payment method/account, date, time, notes, tags, location, and receipt images. | M |
| FR-016 | Amount shall be a required positive decimal value validated before save (see Section 30). | M |
| FR-017 | The system shall allow editing of any field of an existing expense, recording an updated-at timestamp. | M |
| FR-018 | The system shall support soft-deleting an expense, moving it to Trash rather than immediate permanent removal. | M |
| FR-019 | The system shall allow duplicating an existing expense to speed up entry of similar transactions. | M |
| FR-020 | The system shall allow attaching multiple receipt images to a single expense. | M |
| FR-021 | Receipt images shall be compressed before being written to local storage. | M |
| FR-022 | The system shall allow full-text/field search across expenses (Section 9 — Search). | M |
| FR-023 | The system shall allow filtering expenses by date range, category, payment method, and tags (Section 10 — Filters). | M |
| FR-024 | The system shall allow the user to restore a soft-deleted expense from Trash. | M |
| FR-025 | The system shall allow the user to permanently delete an expense from Trash, which also removes its associated local receipt images. | M |
| FR-026 | The system shall record created-date and updated-date for every expense automatically (not user-editable). | M |
| FR-027 | Deleting an expense shall automatically release its allocation against any budget it counted toward. | S |

## 13.3 Income Management (FR-035 – FR-044)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-035 | The system shall allow creation of income records with amount, source, date, note, and optional images. | M |
| FR-036 | The source field shall support predefined options (Salary, Freelance, Bonus, Gift, Refund, Business Income) plus a free-text custom source. | M |
| FR-037 | The system shall support create, edit, soft-delete, restore, and permanent-delete for income records, mirroring expense lifecycle rules. | M |
| FR-038 | The dashboard and statistics modules shall compute Savings = Total Income − Total Expense for the selected period. | M |
| FR-039 | Income records shall be included in per-account balance calculations. | M |

## 13.4 Friend Money Tracker (FR-045 – FR-062)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-045 | The system shall allow creating a friend-money transaction of type Money Given or Money Received. | M |
| FR-046 | Each friend transaction shall capture friend name (or link to a saved Friend entity), amount, date, due date, notes, images, and status. | M |
| FR-047 | Status shall be one of Pending, Completed, or Partially Paid, and shall be system-derived from repayment records where possible rather than freely editable once repayments exist. | M |
| FR-048 | The system shall support recording partial repayments against a friend transaction, reducing the remaining balance and updating status automatically. | M |
| FR-049 | The system shall compute and expose, per friend, the net pending balance (amount they owe the user minus amount the user owes them). | M |
| FR-050 | The system shall compute and expose, app-wide, total pending amount to receive and total pending amount to pay. | M |
| FR-051 | The dashboard and friend detail screen shall update automatically whenever a repayment is recorded, with no manual recalculation step. | M |
| FR-052 | The system shall allow filtering friend transactions by friend, status (Pending/Completed), and date range. | M |
| FR-053 | The system shall allow soft-delete, restore, and permanent-delete of friend transactions and their repayment history together, as a unit. | M |
| FR-054 | The system shall allow attaching receipt/screenshot images (e.g., EasyPaisa, JazzCash, bank transfer) to a friend transaction or to an individual repayment. | M |

## 13.5 Categories (FR-063 – FR-070)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-063 | The system shall ship with default categories: Food, Fuel, Shopping, Rent, Bills, Entertainment, Grocery, Medical, Education, Investment, Family, Other. | M |
| FR-064 | The system shall allow creating, editing, and deleting custom categories with a name, color, and icon. | M |
| FR-065 | A category in use by one or more transactions shall not be hard-deleted; the system shall either block deletion or offer to reassign affected transactions to another category first. | M |
| FR-066 | Category name shall be unique per profile (case-insensitive). | S |

## 13.6 Payment Accounts (FR-071 – FR-078)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-071 | The system shall support multiple payment accounts, e.g., Cash, Bank Account, EasyPaisa, JazzCash, Credit Card. | M |
| FR-072 | Every expense and income record shall be associated with exactly one payment account. | M |
| FR-073 | The system shall allow creating, editing, archiving, and deleting custom payment accounts. | M |
| FR-074 | The system shall display a computed running balance per payment account, derived from its transactions (opening balance + income − expenses). | M |
| FR-075 | An account with existing transactions shall not be hard-deleted; it may be archived instead. | M |

## 13.7 Budgets (FR-079 – FR-088)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-079 | The system shall allow creating a category budget scoped to a specific category with a target amount and selectable period (monthly, 7 days, 15 days, 3 months, or custom). | M |
| FR-080 | The system shall compute spent and remaining amounts for each active budget in real time as matching expenses are added, edited, or deleted. | M |
| FR-081 | The system shall send a local notification when spending reaches a configurable warning threshold (default 80%) of a budget. | M |
| FR-082 | The system shall send a local notification when a budget is exceeded (100%+). | M |
| FR-083 | Auto-repeating budgets shall roll into the next period when the current cycle ends. | M |
| FR-084 | The system shall allow editing or deleting a budget without affecting historical expense data. | S |
| FR-085 | The system shall allow creating a budget envelope with a total amount for a selectable period (7 days, 15 days, monthly, 3 months, or custom range). Expenses in that period count toward the envelope total; category is chosen per expense and is not pre-allocated on the envelope. | M |
| FR-086 | The system shall allow splitting envelope funding across payment accounts (e.g. Cash, Bank, JazzCash) that sum exactly to the total, and optionally post matching income entries when the envelope (or a new auto-repeat cycle) starts. | M |
| FR-087 | The system shall compute envelope spent/remaining (total and per funding account) in real time and send warning/exceeded notifications like category budgets. | M |
| FR-088 | Category budgets and envelopes shall coexist; the dashboard shall show active envelopes before category budget progress. | S |

## 13.8 Statistics (FR-089 – FR-098)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-089 | The system shall provide charts for daily, weekly, and monthly expenses. | M |
| FR-090 | The system shall provide a category distribution chart (pie/donut) for a selected period. | M |
| FR-091 | The system shall provide an income-vs-expense comparison chart. | M |
| FR-092 | The system shall provide a spending trend line chart across a selectable date range. | M |
| FR-093 | The system shall list top spending categories and the single largest expense for a selected period. | S |
| FR-094 | The system shall compute average daily spending for a selected period. | S |

## 13.9 Search (FR-099 – FR-104)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-099 | The system shall provide a global search across expenses, income, and friend transactions. | M |
| FR-100 | Search shall match on amount, category, friend name, notes, date, payment method, and tags. | M |
| FR-101 | Search results shall update as the user types, with results available within 300 ms for local datasets up to at least 50,000 records. | M |

## 13.10 Filters (FR-105 – FR-110)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-105 | The system shall provide quick date filters: Today, Yesterday, This Week, This Month, Last Month, and a Custom Date Range picker. | M |
| FR-106 | The system shall allow combining a date filter with category, payment method, friend, and status filters simultaneously. | M |
| FR-107 | Applied filters shall persist within a session until explicitly cleared by the user. | S |

## 13.11 Reports (FR-111 – FR-118)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-111 | The system shall generate reports in PDF, Excel, and CSV formats. | M |
| FR-112 | Reports shall include income, expenses, friend balances, category summary, and monthly summary sections as applicable to the selected report type. | M |
| FR-113 | The user shall be able to scope a report to a custom date range before generation. | M |
| FR-114 | Generated report files shall be saved to device storage and be shareable via the Android share sheet. | M |

## 13.12 Receipt Images (FR-119 – FR-124)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-119 | The system shall allow attaching images from camera capture or gallery selection. | M |
| FR-120 | Images shall be compressed to a target size/resolution before being persisted, to control storage and backup size. | M |
| FR-121 | The system shall allow viewing images full-screen with pinch-to-zoom and removing individual images from a transaction. | M |

## 13.13 Recurring Transactions (FR-125 – FR-132)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-125 | The system shall allow marking an expense or income as recurring with a frequency of Daily, Weekly, Monthly, or Yearly. | M |
| FR-126 | The system shall automatically generate new transaction instances from active recurring templates on or shortly after their scheduled date, even if the app was closed and is only opened later. | M |
| FR-127 | The system shall allow pausing, resuming, editing, and deleting a recurring template without altering already-generated historical instances. | M |
| FR-128 | The system shall notify the user when a recurring transaction has been auto-generated. | S |

## 13.14 Reminders (FR-133 – FR-140)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-133 | The system shall support reminder types: Bill Due, Friend Payment Due, Subscription Renewal, Insurance, and Custom Reminder. | M |
| FR-134 | The system shall deliver reminders via local device notifications at the scheduled time, without requiring network access. | M |
| FR-135 | A friend transaction with a due date shall be able to auto-generate a Friend Payment Due reminder. | M |
| FR-136 | The user shall be able to snooze or dismiss a reminder notification. | S |

## 13.15 Backup and Restore (FR-141 – FR-154)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-141 | The system shall support manual, on-demand backup to the signed-in Google account's Drive AppData folder. | M |
| FR-142 | The system shall support automatic scheduled backup (e.g., daily) when enabled in Settings. | M |
| FR-143 | A backup shall include the full Isar database export, compressed receipt images, and app settings. | M |
| FR-144 | The system shall support full restore of a backup after reinstall, triggered by signing in with the same Google account. | M |
| FR-145 | The system shall verify backup integrity (e.g., checksum) after upload and before marking a backup as complete. | M |
| FR-146 | The system shall display last backup timestamp, backup size, and backup status in Settings. | M |
| FR-147 | A failed backup or restore shall not corrupt or partially overwrite existing local data; the system shall retry or roll back safely. | M |
| FR-148 | The system shall allow the user to manually trigger a restore/re-sync from Settings even when local data already exists, with a clear confirmation warning about overwrite. | S |

## 13.16 Authentication (FR-155 – FR-160)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-155 | The system shall support Google Sign-In as the sole authentication method, used only for backup ownership and restore. | M |
| FR-156 | The system shall function fully for all non-backup features when the user is not signed in. | M |
| FR-157 | The system shall allow signing out, which disables auto-backup but retains local data untouched. | M |
| FR-158 | The system shall not implement email/password authentication. | M |

## 13.17 App Lock (FR-161 – FR-166)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-161 | The system shall provide an optional app lock, disabled by default. | M |
| FR-162 | When enabled, the system shall support PIN unlock as a baseline method. | M |
| FR-163 | When device biometric hardware is available, the system shall additionally support fingerprint or face unlock. | S |
| FR-164 | The system shall lock the app after a configurable period of inactivity or when backgrounded, per user setting. | S |

## 13.18 In-App Update System (FR-167 – FR-184)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-167 | The system shall check for updates automatically on app launch (respecting a user-configurable frequency and an off switch). | M |
| FR-168 | The system shall provide a manual "Check for Updates" action in Settings. | M |
| FR-169 | The system shall compare the installed app version against the latest published version and display release notes when an update is available. | M |
| FR-170 | The system shall support both optional updates (user may dismiss/defer) and forced updates (user must update before continuing, flagged by the release metadata). | M |
| FR-171 | The system shall download the new APK within the app, showing progress percentage, download speed, and remaining size. | M |
| FR-172 | The system shall allow pausing, resuming, and retrying a failed download. | M |
| FR-173 | On download completion, the system shall notify the user and launch the Android package installer for the downloaded APK. | M |
| FR-174 | The system shall maintain an in-app update history log (version, date installed). | S |
| FR-175 | The update check shall fail silently/gracefully with no crash when the network or update host is unreachable. | M |

## 13.19 Settings (FR-185 – FR-196)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-185 | Settings shall expose: Theme, Dark Mode, Currency, Notification Settings, Auto Backup, Auto Update Check, Google Account, Export Data, Import Data, Check for Updates, App Version, Privacy Policy, and About. | M |
| FR-186 | Changing Currency shall update all displayed monetary values' symbol/format without altering stored numeric amounts. | M |
| FR-187 | Export Data / Import Data shall provide a full local data export/import independent of the Google Drive backup path, for manual transfer. | S |

## 13.20 Trash (FR-197 – FR-202)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-197 | Soft-deleted expenses, income, and friend transactions shall appear in a unified Trash view. | M |
| FR-198 | Trash items shall be restorable to their original state, including their category/account/friend links. | M |
| FR-199 | The system shall permanently purge Trash items older than a configurable retention period (default 30 days), with user notice. | S |

## 13.21 Favorites / Quick Templates (FR-203 – FR-207)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-203 | The system shall allow saving a transaction as a Favorite template (e.g., "Tea — Rs.100 — Food"). | M |
| FR-204 | Adding a transaction from a Favorite shall pre-fill all fields and require only a single confirmation tap, with the date defaulting to now. | M |

## 13.22 Quick Add (FR-208 – FR-210)

| ID | Requirement | Priority |
| --- | --- | --- |
| FR-208 | The system shall provide a persistent floating action button for Quick Add accessible from the dashboard. | M |
| FR-209 | Quick Add shall allow completing a common expense entry (amount, category, account) in three taps or fewer, excluding numeric input. | M |

# 14. Non-Functional Requirements

## 14.1 Performance

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-001 | Cold start time from tap to interactive dashboard | ≤ 2 seconds on a mid-range device (4 GB RAM) |
| NFR-002 | Scrolling on transaction lists shall remain smooth with no visible jank | 60 fps target, no dropped-frame stutter under normal load |
| NFR-003 | All core features shall operate fully without network connectivity | 100% offline feature parity except backup/restore/update |
| NFR-004 | Database queries for lists/search/filter/statistics shall be indexed for common access patterns (date, category, account, friend) | Result under 300 ms for 50,000+ records |

## 14.2 Security

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-005 | Local Isar database shall be encrypted at rest where the platform/library supports it | Encryption enabled if feasible; documented if not |
| NFR-006 | Google authentication tokens shall be stored using secure platform storage (e.g., Android Keystore-backed secure storage), never in plain SharedPreferences | No plaintext token persistence |
| NFR-007 | Backup archives uploaded to Drive AppData shall not be readable/listable by other apps or by casual Drive browsing (AppData is inherently hidden) | Confirmed via Drive API scope restricted to drive.appdata |
| NFR-008 | PIN codes shall be stored hashed, never in plaintext | Hash + salt, never raw PIN in storage |

## 14.3 Usability

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-009 | UI shall follow Material Design 3 consistently across all screens | Design review checklist pass |
| NFR-010 | Common daily action (add expense) shall require minimal interaction | ≤ 3 taps via Quick Add, excluding numeric entry |
| NFR-011 | Navigation pattern shall remain consistent (bottom navigation + FAB) across modules | No divergent nav patterns between screens |

## 14.4 Reliability

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-012 | App updates/migrations shall not cause data loss | Automatic schema migration with pre-migration backup checkpoint |
| NFR-013 | Backup shall be verified (checksum/integrity check) before being considered successful | Verification step mandatory in backup flow |
| NFR-014 | App shall recover gracefully from an unexpected crash without corrupting the local database | Isar's ACID transaction guarantees leveraged for all writes |

## 14.5 Compatibility

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-015 | Minimum supported Android version | Android 8.0 (API 26)+ |
| NFR-016 | Screen sizes/densities | Responsive layout from small phones to large phablets |

## 14.6 Maintainability & Scalability

| ID | Requirement | Target / Metric |
| --- | --- | --- |
| NFR-017 | Codebase shall be structured (feature-first + GetX bindings) to allow future addition of multi-device sync, shared wallets, OCR, and AI insights without a rewrite | Architecture review against Section 32 roadmap items |
| NFR-018 | Business logic shall be separated from UI (Controllers/Services) to enable unit testing | ≥ 60% unit test coverage target for services/controllers |

# 15. Use Cases

## UC-01: Add Expense

| Field | Detail |
| --- | --- |
| Actor | Primary User |
| Preconditions | App installed, at least one profile exists |
| Trigger | User taps Quick Add or Expenses > Add |
| Main Flow | 1) User taps Add Expense. 2) Enters amount. 3) Selects category and account. 4) Optionally adds date/time, notes, tags, location, images. 5) Taps Save. 6) System validates and persists record. 7) Dashboard and budgets recompute. |
| Alternate Flow | 3a) User selects a Favorite template — fields pre-fill; user only confirms. |
| Exception Flow | Invalid/empty amount — inline validation error shown, save blocked. |
| Postconditions | Expense stored, visible in lists/search/statistics/dashboard immediately. |

## UC-02: Record Friend Repayment

| Field | Detail |
| --- | --- |
| Actor | Primary User |
| Preconditions | A Pending or Partially Paid friend transaction exists |
| Trigger | User opens a friend's ledger and taps Add Repayment |
| Main Flow | 1) User selects a friend transaction. 2) Taps Add Repayment. 3) Enters repayment amount (≤ remaining balance) and optional note/image. 4) Saves. 5) System recalculates remaining balance and status (Partially Paid or Completed). |
| Exception Flow | Repayment amount exceeds remaining balance — validation error, save blocked. |
| Postconditions | Friend balance and dashboard pending totals update automatically. |

## UC-03: Backup Data to Google Drive

| Field | Detail |
| --- | --- |
| Actor | Primary User |
| Preconditions | User signed in with Google account |
| Trigger | Auto-backup schedule fires, or user taps Backup Now |
| Main Flow | 1) System exports Isar database and compressed images into a backup bundle. 2) Uploads bundle to Drive AppData folder. 3) Verifies integrity. 4) Updates last-backup timestamp/status in Settings. |
| Exception Flow | Network unavailable or upload fails — system retries per policy and shows a non-blocking failure notice; local data is untouched. |
| Postconditions | Latest backup bundle stored in Drive AppData, ready for restore. |

## UC-04: Restore After Reinstall

| Field | Detail |
| --- | --- |
| Actor | Primary User |
| Preconditions | A prior backup exists in Drive AppData for the Google account being used |
| Trigger | First launch after reinstall; user signs in with Google |
| Main Flow | 1) User signs in. 2) System detects an existing AppData backup. 3) Prompts user to restore. 4) User confirms. 5) System downloads bundle, verifies integrity, and rebuilds the local database, images, and settings. 6) App opens to a fully restored dashboard. |
| Exception Flow | No backup found — system proceeds with a fresh empty profile. |
| Postconditions | All prior data (transactions, images, settings, budgets, categories) available exactly as before reinstall. |

## UC-05: Check for and Install App Update

| Field | Detail |
| --- | --- |
| Actor | Primary User |
| Preconditions | Network available |
| Trigger | App launch, or manual Check for Updates |
| Main Flow | 1) System queries GitHub Releases for latest version metadata. 2) Compares to installed version. 3) If newer, shows release notes and Update button. 4) User taps Update; APK downloads with progress shown. 5) On completion, system prompts install via Android package installer. 6) User confirms system install dialog. |
| Alternate Flow | Release flagged as forced update — user cannot dismiss the prompt until updated. |
| Exception Flow | Download fails/interrupted — user can retry or resume. |
| Postconditions | Device has the latest APK installed; update history logged. |

# 16. User Stories

| ID | As a... | I want to... | So that... |
| --- | --- | --- | --- |
| US-01 | user | add an expense in a few seconds from a floating button | I don't lose track of small daily spends |
| US-02 | user | attach a photo of my receipt | I have proof and don't need to keep paper receipts |
| US-03 | user | see how much a friend still owes me | I can follow up without checking WhatsApp chats |
| US-04 | user | record a partial repayment from a friend | the remaining balance stays accurate |
| US-05 | user | set a monthly food budget | I get warned before I overspend |
| US-05b | user | set a weekly envelope of 3000 funded as Cash + JazzCash | I can spend freely by category while staying within my total and wallet split |
| US-06 | user | see a chart of spending by category | I understand where my money goes |
| US-07 | user | export my monthly report as PDF | I can share or archive it outside the app |
| US-08 | user | back up my data to Google Drive | I don't lose everything if I get a new phone |
| US-09 | user | restore my data just by signing in again | reinstalling doesn't feel risky |
| US-10 | user | lock the app with a PIN | my financial data stays private if someone picks up my phone |
| US-11 | user | get notified when a new APK version is available | I stay up to date even without the Play Store |
| US-12 | user | undo an accidental delete from Trash | mistakes aren't permanent |
| US-13 | user | mark rent as a recurring expense | I don't have to re-enter it every month |

# 17. System Workflow

The high-level workflow below illustrates how the major modules interact around the local Isar database, which is the single source of truth on-device; Google Drive is a mirror for backup purposes only.

[Quick Add / Forms]        [Recurring Engine]      [Reminder Scheduler]
          |                          |                        |
          v                          v                        v
  +--------------------------------------------------------------+
  |                      Isar Local Database                     |
  |  Transactions | Friends | Categories | Accounts | Budgets ... |
  +--------------------------------------------------------------+
          ^                          ^                        ^
          |                          |                        |
  [Dashboard/Statistics]     [Search & Filters]       [Reports Exporter]
                                                                |
                                                                v
                                              [PDF / Excel / CSV files]
 
  Background/optional path:
  [Isar DB + Images] --(export & compress)--> [Backup Bundle]
        --(upload)--> [Google Drive AppData] --(download)--> [Restore]

# 18. Activity Diagrams (PlantUML)

The following diagrams are provided as PlantUML source. Render with any PlantUML-compatible tool (plugin, CLI, or plantuml.com) to generate the visual diagram.

## 18.1 Add Expense Activity

@startuml
start
if (User taps Quick Add?) then (yes)
  :Prefill from Favorite template;
else (no)
  :Open blank Add Expense form;
endif
:Enter amount, category, account;
:Optionally add date, notes, tags,\nlocation, receipt images;
if (Amount valid > 0?) then (no)
  :Show validation error;
  stop
else (yes)
endif
:Compress attached images;
:Persist Expense in Isar;
:Recalculate dashboard totals;
:Recalculate matching budget progress;
if (Budget threshold crossed?) then (yes)
  :Trigger local notification;
endif
stop
@enduml

## 18.2 Backup & Restore Activity

@startuml
start
if (User signed in with Google?) then (no)
  :Prompt Google Sign-In;
endif
if (Backup exists in AppData for account?) then (yes)
  :Prompt user to Restore;
  if (User confirms?) then (yes)
    :Download backup bundle;
    :Verify checksum;
    if (Valid?) then (yes)
      :Rebuild Isar DB, images, settings;
      :Open Dashboard (restored);
    else (no)
      :Show restore failed message;
      :Keep existing/local empty state;
    endif
  else (no)
    :Continue with local data as-is;
  endif
else (no)
  :Continue with fresh empty profile;
endif
stop
@enduml

## 18.3 In-App Update Activity

@startuml
start
:App launch / manual check;
:Fetch latest release metadata from GitHub;
if (Latest > Installed version?) then (no)
  :Show "Up to date";
  stop
else (yes)
endif
:Show release notes + Update button;
if (Release marked forced?) then (yes)
  :Block dismissal until updated;
endif
:User taps Update;
:Download APK (show progress/speed/remaining);
if (Download interrupted?) then (yes)
  :Offer Retry / Resume;
endif
:Download complete -> Notify user;
:Launch Android package installer;
:Log entry in Update History;
stop
@enduml

# 19. Sequence Diagrams (PlantUML)

## 19.1 Add Expense

@startuml
actor User
participant "Add Expense UI" as UI
participant "ExpenseController (GetX)" as Ctrl
participant "ExpenseService" as Svc
participant "Isar DB" as DB
participant "BudgetService" as Budget
participant "BudgetEnvelopeService" as Envelope
 
User -> UI: Fill form + tap Save
UI -> Ctrl: submitExpense(data)
Ctrl -> Ctrl: validate(data)
Ctrl -> Svc: createExpense(data)
Svc -> Svc: compressImages(data.images)
Svc -> DB: put(Expense)
DB --> Svc: id
Svc -> Budget: onExpenseChanged(category, date)
Budget --> Svc: category budget alerts
Svc -> Envelope: onExpenseChanged(date)
Envelope --> Svc: envelope alerts
Svc --> Ctrl: Expense saved
Ctrl --> UI: success, navigate back
Ctrl -> Ctrl: refresh dashboard reactive state
@enduml

## 19.2 Friend Repayment

@startuml
actor User
participant "Friend Ledger UI" as UI
participant "FriendController" as Ctrl
participant "FriendService" as Svc
participant "Isar DB" as DB
 
User -> UI: Add Repayment(amount)
UI -> Ctrl: addRepayment(txnId, amount)
Ctrl -> Svc: validateAmount(txnId, amount)
Svc -> DB: fetch FriendTransaction(txnId)
DB --> Svc: transaction
alt amount > remainingBalance
  Svc --> Ctrl: error(exceedsBalance)
  Ctrl --> UI: show validation error
else amount valid
  Svc -> DB: insert Repayment record
  Svc -> DB: update FriendTransaction.status
  DB --> Svc: ok
  Svc --> Ctrl: updatedBalance, status
  Ctrl --> UI: refresh ledger + dashboard totals
end
@enduml

## 19.3 Backup to Google Drive

@startuml
actor User
participant "Settings UI" as UI
participant "BackupController" as Ctrl
participant "BackupService" as Svc
participant "Isar DB" as DB
participant "Google Drive API" as Drive
 
User -> UI: Tap "Backup Now"
UI -> Ctrl: startBackup()
Ctrl -> Svc: exportBundle()
Svc -> DB: dumpAllCollections()
DB --> Svc: dataset
Svc -> Svc: bundle DB + compressed images + settings
Svc -> Drive: upload(bundle, folder=appDataFolder)
Drive --> Svc: fileId, uploadResult
Svc -> Svc: verifyChecksum(bundle, uploadResult)
alt checksum valid
  Svc --> Ctrl: backupSuccess(timestamp,size)
  Ctrl --> UI: show success + update last backup info
else checksum invalid / upload failed
  Svc --> Ctrl: backupFailed(reason)
  Ctrl --> UI: show retry option, local data untouched
end
@enduml

# 20. Database Schema

The schema below is expressed as Isar collection definitions (Dart-style pseudocode). All collections include an implicit auto-increment Isar id unless noted. Enums are shown inline.

## 20.1 Profile

@Collection()
class Profile {
  Id id = Isar.autoIncrement;
  late String name;
  String? googleAccountEmail;
  String currencyCode = 'PKR';
  bool appLockEnabled = false;
  String? pinHash;
  bool biometricEnabled = false;
  DateTime createdAt = DateTime.now();
}

## 20.2 Category

@Collection()
class Category {
  Id id = Isar.autoIncrement;
  @Index(unique: true, caseSensitive: false, composite: [CompositeIndex('profileId')])
  late String name;
  late String colorHex;
  late String iconKey;
  bool isDefault = false;
  late int profileId;
}

## 20.3 PaymentAccount

@Collection()
class PaymentAccount {
  Id id = Isar.autoIncrement;
  late String name;
  late String type; // cash | bank | easypaisa | jazzcash | credit_card | custom
  double openingBalance = 0;
  bool isArchived = false;
  late int profileId;
}

## 20.4 Expense

@Collection()
class Expense {
  Id id = Isar.autoIncrement;
  late double amount;
  late int categoryId;
  late int accountId;
  @Index()
  late DateTime date;
  String? notes;
  List<String> tags = [];
  String? location;
  List<String> receiptImagePaths = [];
  bool isDeleted = false;
  DateTime? deletedAt;
  int? recurringTemplateId;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  late int profileId;
}

## 20.5 Income

@Collection()
class Income {
  Id id = Isar.autoIncrement;
  late double amount;
  late String source; // enum-like string: salary|freelance|bonus|gift|refund|business|custom
  late int accountId;
  @Index()
  late DateTime date;
  String? notes;
  List<String> imagePaths = [];
  bool isDeleted = false;
  DateTime? deletedAt;
  int? recurringTemplateId;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  late int profileId;
}

## 20.6 Friend

@Collection()
class Friend {
  Id id = Isar.autoIncrement;
  late String name;
  String? phone;
  late int profileId;
}

## 20.7 FriendTransaction

@Collection()
class FriendTransaction {
  Id id = Isar.autoIncrement;
  late int friendId;
  late String type; // given | received
  late double amount;
  @Index()
  late DateTime date;
  DateTime? dueDate;
  String? notes;
  List<String> imagePaths = [];
  late String status; // pending | partially_paid | completed
  bool isDeleted = false;
  DateTime? deletedAt;
  late int profileId;
}

## 20.8 Repayment

@Collection()
class Repayment {
  Id id = Isar.autoIncrement;
  late int friendTransactionId;
  late double amount;
  late DateTime date;
  String? note;
  List<String> imagePaths = [];
}

## 20.9 Budget

@Collection()
class Budget {
  Id id = Isar.autoIncrement;
  late int categoryId;
  late double targetAmount;
  late int year;
  late int month; // 1-12 (kept in sync with periodStart for monthly)
  String periodType = 'monthly'; // monthly | days7 | days15 | months3 | custom
  late DateTime periodStart;
  late DateTime periodEnd;
  bool autoRepeat = true;
  double warningThreshold = 0.8;
  late int profileId;
}

## 20.9b BudgetEnvelope

@Collection()
class BudgetEnvelope {
  Id id = Isar.autoIncrement;
  late double totalAmount;
  String periodType = 'days7'; // monthly | days7 | days15 | months3 | custom
  late DateTime periodStart;
  late DateTime periodEnd;
  bool autoRepeat = true;
  double warningThreshold = 0.8;
  // Funding: list of { accountId, amount } summing to totalAmount
  List<EnvelopeFundingSplit> fundingSplits = [];
  // Legacy unused field kept empty for schema compatibility
  List<EnvelopeCategoryAllocation> categoryAllocations = [];
  late int profileId;
}

## 20.10 RecurringTemplate

@Collection()
class RecurringTemplate {
  Id id = Isar.autoIncrement;
  late String transactionType; // expense | income
  late double amount;
  int? categoryId;
  late int accountId;
  late String frequency; // daily | weekly | monthly | yearly
  late DateTime startDate;
  DateTime? nextRunDate;
  bool isActive = true;
  late int profileId;
}

## 20.11 Reminder

@Collection()
class Reminder {
  Id id = Isar.autoIncrement;
  late String type; // bill_due | friend_payment_due | subscription_renewal | insurance | custom
  late String title;
  late DateTime scheduledAt;
  int? linkedFriendTransactionId;
  bool isCompleted = false;
  late int profileId;
}

## 20.12 Favorite (Quick Template)

@Collection()
class Favorite {
  Id id = Isar.autoIncrement;
  late String label;
  late double amount;
  late int categoryId;
  late int accountId;
  late int profileId;
}

## 20.13 BackupMeta (SharedPreferences-backed, not Isar)

// Lightweight settings key-value, not a full collection:
last_backup_at: DateTime
last_backup_size_bytes: int
auto_backup_enabled: bool
auto_update_check_enabled: bool
theme_mode: String // light | dark | system
currency_code: String

# 21. Entity Relationship Diagram (ERD)

@startuml
entity Profile {
  * id
  name
  googleAccountEmail
  currencyCode
}
entity Category { * id / name / colorHex / iconKey }
entity PaymentAccount { * id / name / type / openingBalance }
entity Expense { * id / amount / date / categoryId / accountId }
entity Income { * id / amount / date / source / accountId }
entity Friend { * id / name / phone }
entity FriendTransaction { * id / friendId / type / amount / status }
entity Repayment { * id / friendTransactionId / amount / date }
entity Budget { * id / categoryId / targetAmount / periodType / periodStart }
entity BudgetEnvelope { * id / totalAmount / periodType / periodStart / fundingSplits }
entity RecurringTemplate { * id / transactionType / frequency }
entity Reminder { * id / type / scheduledAt }
entity Favorite { * id / label / categoryId / accountId }
 
Profile ||--o{ Category : owns
Profile ||--o{ PaymentAccount : owns
Profile ||--o{ Expense : owns
Profile ||--o{ Income : owns
Profile ||--o{ Friend : owns
Profile ||--o{ Budget : owns
Profile ||--o{ BudgetEnvelope : owns
 
Category ||--o{ Expense : categorizes
PaymentAccount ||--o{ Expense : funds
PaymentAccount ||--o{ Income : receives
Category ||--o{ Budget : scopes
PaymentAccount ||--o{ BudgetEnvelope : "funds (split)"
 
Friend ||--o{ FriendTransaction : has
FriendTransaction ||--o{ Repayment : "paid down by"
RecurringTemplate ||--o{ Expense : generates
RecurringTemplate ||--o{ Income : generates
FriendTransaction ||--o{ Reminder : "may trigger"
Category ||--o{ Favorite : templates
PaymentAccount ||--o{ Favorite : templates
@enduml

Cardinality summary: one Profile has many Categories, Accounts, Expenses, Income records, Friends, Budgets, and BudgetEnvelopes. One Friend has many FriendTransactions; one FriendTransaction has many Repayments (supporting partial repayment). One RecurringTemplate generates many Expense or Income instances over time. All foreign keys (categoryId, accountId, friendId, profileId, etc.) are plain integer links resolved at the service layer, consistent with Isar's non-relational, embedded-link model.

# 22. State Diagrams

## 22.1 FriendTransaction Status Lifecycle

@startuml
[*] --> Pending : created (no repayments)
Pending --> PartiallyPaid : repayment < remaining balance
Pending --> Completed : repayment == full amount
PartiallyPaid --> PartiallyPaid : additional partial repayment
PartiallyPaid --> Completed : final repayment closes balance
Completed --> [*]
Pending --> [*] : soft-deleted (Trash)
PartiallyPaid --> [*] : soft-deleted (Trash)
@enduml

## 22.2 Transaction (Expense/Income) Lifecycle

@startuml
[*] --> Active : created
Active --> Active : edited
Active --> Deleted : soft delete (moved to Trash)
Deleted --> Active : restored from Trash
Deleted --> Purged : permanently deleted\n(manually or by retention policy)
Purged --> [*]
@enduml

## 22.3 Backup Job State

@startuml
[*] --> Idle
Idle --> Exporting : backup triggered (manual or scheduled)
Exporting --> Uploading : bundle built
Uploading --> Verifying : upload complete
Verifying --> Success : checksum matches
Verifying --> Failed : checksum mismatch
Uploading --> Failed : network/upload error
Failed --> Idle : retry scheduled / user retries
Success --> Idle
@enduml

## 22.4 In-App Update State

@startuml
[*] --> Checking
Checking --> UpToDate : no newer version
Checking --> UpdateAvailable : newer version found
UpdateAvailable --> Downloading : user taps Update
Downloading --> Paused : user pauses
Paused --> Downloading : user resumes
Downloading --> Failed : network error
Failed --> Downloading : retry
Downloading --> Downloaded : 100% complete
Downloaded --> Installing : installer launched
Installing --> [*] : install accepted by OS
UpToDate --> [*]
@enduml

# 23. Navigation Flow

Splash
  -> (has profile & unlocked?) -> Dashboard
  -> (locked) -> App Lock Screen -> Dashboard
  -> (no profile) -> Create Profile -> Dashboard
 
Bottom Navigation: [Dashboard] [Transactions] [Statistics] [Friends] [More]
 
Dashboard
  -> Quick Add -> Add Expense (modal)
  -> Recent Transaction -> Transaction Detail
  -> Budget Card -> Budget Detail
  -> Notification -> Reminder / Budget context
 
Transactions (Expenses | Income tabs)
  -> Filter / Search -> Filtered List
  -> Item -> Transaction Detail -> Edit / Delete / Duplicate
  -> FAB -> Add Expense / Add Income
  -> Trash icon -> Trash
 
Friends
  -> Friend List -> Friend Detail (ledger, net balance)
  -> Friend Detail -> Add Transaction (Given/Received)
  -> Friend Detail -> Add Repayment
 
Statistics
  -> Chart type tabs (Daily/Weekly/Monthly/Category/Trend)
  -> Export -> Reports (PDF/Excel/CSV)
 
More
  -> Categories -> Add/Edit Category
  -> Accounts -> Add/Edit Account
  -> Budgets -> Add Envelope / Add Category Budget
  -> Budgets -> Edit Envelope (total, period, funding split)
  -> Budgets -> Edit Category Budget
  -> Recurring Transactions -> Add/Edit Template
  -> Reminders -> Add/Edit Reminder
  -> Favorites -> Manage Favorites
  -> Trash
  -> Settings
       -> Theme / Currency / Notifications
       -> Backup & Restore
       -> Google Account
       -> Check for Updates -> Update Detail -> Download -> Install
       -> App Lock
       -> Export/Import Data
       -> Privacy Policy / About

# 24. UI Screen List

| # | Screen | Purpose |
| --- | --- | --- |
| 1 | Splash | Launch, session/lock check, route decision |
| 2 | Create/Select Profile | Create a new local profile or pick an existing one |
| 3 | App Lock (PIN/Biometric) | Unlock gate when app lock is enabled |
| 4 | Dashboard | Financial overview, quick add, budget progress, recent activity |
| 5 | Add/Edit Expense | Expense form with category, account, images, tags |
| 6 | Add/Edit Income | Income form with source, account, images |
| 7 | Transaction Detail | View, edit, delete, duplicate a single transaction |
| 8 | Transactions List (Expenses/Income) | Browse with search and filters |
| 9 | Friends List | All friends with net pending balance |
| 10 | Friend Detail / Ledger | Full history of Given/Received/Repayments for one friend |
| 11 | Add Friend Transaction | Record Money Given / Money Received |
| 12 | Add Repayment | Record a partial or full repayment |
| 13 | Categories | List/add/edit/delete categories |
| 14 | Payment Accounts | List/add/edit/archive accounts with balances |
| 15 | Budgets | List envelopes and category budgets; add/edit each with progress |
| 15a | Add/Edit Envelope | Total, period, funding split (Cash/Bank/JazzCash), optional income posting |
| 15b | Add/Edit Category Budget | Category, target, period, warning threshold |
| 16 | Statistics | Tabs for daily/weekly/monthly/category/trend charts |
| 17 | Reports | Configure and export PDF/Excel/CSV reports |
| 18 | Recurring Transactions | List/add/edit/pause recurring templates |
| 19 | Reminders | List/add/edit reminders |
| 20 | Favorites | Manage quick-add templates |
| 21 | Trash | Restore or permanently delete soft-deleted items |
| 22 | Search | Global search across all transaction types |
| 23 | Settings | Entry point to all settings sub-screens |
| 24 | Backup & Restore | Manual backup, auto-backup toggle, last backup status, restore |
| 25 | Update Available / Update History | Release notes, download progress, install trigger, past updates |
| 26 | About / Privacy Policy | Static informational screens |

# 25. API/Service Architecture

The app follows a feature-first, layered GetX architecture: UI (Views) → Controllers (GetX) → Services (business logic) → Repositories (Isar access). External integrations are isolated behind two services so they can be mocked or replaced later.

## 25.1 Layered Architecture

lib/
  app/
    modules/
      dashboard/ (view, controller, binding)
      expenses/  (view, controller, binding)
      income/
      friends/
      budgets/
      statistics/
      reports/
      settings/
      backup/
      update/
    services/
      expense_service.dart
      income_service.dart
      friend_service.dart
      budget_service.dart
      budget_envelope_service.dart
      recurring_service.dart
      reminder_service.dart
      report_service.dart
      google_auth_service.dart
      google_drive_backup_service.dart
      update_service.dart
      image_service.dart
    repositories/
      isar_repository.dart (generic CRUD base)
      expense_repository.dart ...
      budget_envelope_repository.dart
    data/
      models/ (Isar collections, Section 20)
    core/
      bindings, theming, routing, utils

## 25.2 Google Drive Backup Service (Contract)

class GoogleDriveBackupService {
  Future<AuthResult> signIn();
  Future<void> signOut();
  Future<BackupResult> backupNow();
  Future<RestoreResult> restoreLatest();
  Future<BackupMeta?> getLatestBackupMeta();
  Stream<BackupProgress> progressStream; // percentage, phase
}
// Scope used: https://www.googleapis.com/auth/drive.appdata

## 25.3 In-App Update Service (Contract)

class UpdateService {
  Future<ReleaseInfo?> checkForUpdate(); // queries GitHub Releases API
  Future<void> downloadApk(ReleaseInfo release);
  Future<void> pauseDownload();
  Future<void> resumeDownload();
  Future<void> retryDownload();
  Future<void> installDownloadedApk();
  Stream<DownloadProgress> progressStream; // percent, speed, remainingBytes
  Future<List<UpdateHistoryEntry>> getHistory();
}
// Source: GET https://api.github.com/repos/<owner>/<repo>/releases/latest
// Response mapped to: version, releaseNotes, apkDownloadUrl, isForced (from a
// convention such as a 'forced' label or a marker in the release body)

## 25.4 Report Service (Contract)

class ReportService {
  Future<File> generatePdf(ReportScope scope);
  Future<File> generateExcel(ReportScope scope);
  Future<File> generateCsv(ReportScope scope);
}
class ReportScope {
  DateTime from;
  DateTime to;
  bool includeIncome, includeExpenses, includeFriends, includeCategorySummary;
}

# 26. Error Handling Strategy

| Layer | Strategy |
| --- | --- |
| Form Validation | Inline field-level errors shown immediately on blur/submit; save action disabled until resolved (Section 30). |
| Repository/DB | All writes wrapped in Isar transactions; on failure, transaction is rolled back automatically and a typed exception (e.g., DbWriteException) is surfaced to the service layer. |
| Network (Backup/Update) | All network calls wrapped with timeout + retry (exponential backoff, max 3 attempts) before surfacing a user-facing, non-blocking error banner. Local data/state is never mutated on network failure. |
| Image Handling | Failed compression/attachment shows a per-image error chip; the rest of the transaction can still be saved without that image. |
| Global Uncaught Errors | A top-level Flutter error handler + GetX error binding logs the error locally (for optional bug-report export) and shows a generic "Something went wrong" screen instead of a hard crash where possible. |
| Backup/Restore Conflicts | If a restore is attempted while local data already exists, the user must explicitly confirm overwrite; the previous local state is exported to a temporary safety snapshot first. |

## 26.1 Standard Error Response Shape (internal service layer)

class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? errorCode;   // e.g. VALIDATION_ERROR, NETWORK_ERROR, DB_ERROR
  final String? userMessage; // localized, user-safe message
}

# 27. Backup & Restore Flow

## 27.1 Backup Flow

- Trigger: manual (Settings > Backup Now) or automatic (scheduled, default daily, configurable/off).

- Step 1 — Export: Serialize all Isar collections for the active profile plus compressed receipt images plus settings into a single versioned bundle (e.g., a zip with a manifest.json describing schema version and contents).

- Step 2 — Upload: Upload the bundle to the signed-in Google account's Drive AppData folder, overwriting the previous bundle for that profile (single rolling backup per profile in the MVP, not full version history).

- Step 3 — Verify: Compare a checksum of the uploaded bundle against the local bundle to confirm integrity.

- Step 4 — Record: Persist last-backup timestamp and size to local settings; show status in Settings > Backup & Restore.

- Failure handling: any failure at Steps 1–3 leaves local data completely untouched; the user sees a retry option and, for automatic backups, the system retries on the next scheduled cycle.

## 27.2 Restore Flow

- Trigger: first launch after reinstall once the user signs in with Google, or a manual "Restore" action in Settings.

- Step 1 — Detect: Check Drive AppData for an existing backup bundle tied to the signed-in account.

- Step 2 — Confirm: If local data already exists, warn the user that restoring will overwrite it, and take a temporary local safety snapshot before proceeding.

- Step 3 — Download & Verify: Download the bundle and validate its checksum and schema version.

- Step 4 — Rebuild: Recreate all Isar collections, restore compressed images to local storage, and apply settings.

- Step 5 — Migrate if needed: If the bundle's schema version is older than the current app's schema, run the same migration path used for in-place app updates (Section 14.4 / NFR-012) before exposing data to the UI.

- Failure handling: if verification or rebuild fails, the restore is aborted, the temporary safety snapshot (or the untouched fresh-install state) is preserved, and the user is shown a clear error with a retry option.

# 28. In-App Update Flow

Because the app is distributed outside the Google Play Store, it is fully responsible for its own update lifecycle.

## 28.1 Release Metadata Source

GitHub Releases is used as the update source. Each release publishes: a semantic version tag, release notes (Markdown body), the signed APK as a release asset, and an optional "forced" marker (e.g., a label such as force-update or a flag in a small releases.json manifest also published as a release asset for easier parsing).

## 28.2 Flow Steps

- 1. Check: On launch (subject to a configurable check frequency) and on manual request, fetch the latest release metadata.

- 2. Compare: Parse the installed app's version (from package info) and compare against the latest tag using semantic versioning rules.

- 3. Present: If newer, show a modal/screen with version number, formatted release notes, and an Update action; forced releases remove the dismiss option.

- 4. Download: Stream the APK asset to app-local storage, emitting progress (%), current speed, and remaining bytes to the UI; support pause/resume/retry using HTTP range requests where supported, or a resumable chunked download otherwise.

- 5. Verify: Confirm the downloaded file size/hash matches the expected asset before allowing install, to avoid installing a corrupted APK.

- 6. Install: Invoke Android's package installer via an explicit intent pointing at the downloaded APK (requires the REQUEST_INSTALL_PACKAGES permission and a FileProvider-exposed URI).

- 7. Log: Record the version and install timestamp to the local Update History list, regardless of whether the OS install dialog is ultimately confirmed by the user (the app can only observe that it launched the installer, not the final OS-level result, and should reconcile actual installed version on next launch).

## 28.3 Constraints

- The app must declare and request the REQUEST_INSTALL_PACKAGES permission and guide the user to enable "install unknown apps" for the app if not already granted.

- Update checks must never block core app usage; a failed or slow check must time out and fail silently in the background unless the user explicitly initiated it.

# 29. Security Considerations

| Area | Consideration |
| --- | --- |
| Data at rest | Isar database encrypted where supported; receipt images stored in app-private storage, never on shared/public external storage. |
| Authentication tokens | Google OAuth tokens stored via secure/encrypted platform storage (e.g., flutter_secure_storage backed by Android Keystore), not SharedPreferences. |
| App Lock | PIN stored as a salted hash; biometric unlock delegated to the OS biometric API (no raw biometric data handled by the app). |
| Backup transport | All Google Drive API calls occur over HTTPS; only the drive.appdata OAuth scope is requested — the app cannot see or touch the user's regular Drive files. |
| Backup content | Backup bundles inherit the same at-rest protections as local data where the bundling step keeps encryption; sensitive fields are not logged in plaintext during export. |
| Update integrity | Downloaded APKs are verified by size/hash before install is offered; releases should be signed consistently so Android's own package signature check also protects against tampered updates. |
| Least privilege | Android permissions requested are limited to what each feature needs (camera/gallery for receipts, notifications for reminders, install-packages for updates) and requested contextually, not all at first launch. |
| Multi-profile isolation | Each local profile's data, images, and Google account link are logically partitioned so one profile cannot read another profile's data on a shared device. |

# 30. Data Validation Rules

| Field | Rule |
| --- | --- |
| Amount (Expense/Income/Friend/Repayment) | Required; numeric; strictly greater than 0; max 2 decimal places; reasonable upper bound (e.g., < 100,000,000) to catch input errors. |
| Repayment amount | Required; > 0; must not exceed the remaining balance of the target FriendTransaction. |
| Date | Required; must be a valid date; future dates allowed only for Reminders and recurring schedules, not for historical Expense/Income entry beyond a small grace window (e.g., today) unless explicitly editing a planned entry. |
| Category name | Required; 1–40 characters; unique per profile (case-insensitive). |
| Payment account name | Required; 1–40 characters; unique per profile. |
| Friend name | Required; 1–60 characters. |
| Notes/Tags | Optional; notes capped at 500 characters; tags capped at 20 characters each, max 10 tags per transaction. |
| Images | Max file size after compression target (e.g., 500 KB per image); max 5 images per transaction in the MVP; accepted formats JPEG/PNG. |
| Budget target amount | Required; > 0; one overlapping/auto-repeat category budget per category (editing replaces, does not duplicate). |
| Envelope total | Required; > 0; funding split amounts must sum exactly to the total; one overlapping/auto-repeat envelope per profile. |
| Envelope funding split | At least one account; each account once; amounts > 0. |
| PIN | Exactly 4 or 6 digits (configurable), numeric only, stored hashed, never logged. |
| Recurring frequency/start date | Start date required; frequency required; nextRunDate must always be computed as strictly after startDate/lastRunDate. |

# 31. Acceptance Criteria

The MVP is considered acceptable for release when the following are demonstrably true:
- All Must-have (M) Functional Requirements in Section 13 are implemented and pass manual/automated test cases derived from their Use Cases.

- The app is fully usable — add/edit/delete/search/filter transactions, friend tracking, budgets, statistics — with airplane mode enabled (NFR-003).

- A user can uninstall the app, reinstall it, sign in with the same Google account, and see all previously entered expenses, income, friend balances, categories, accounts, budgets, and images restored correctly (UC-04).

- A simulated new APK release is detected, downloaded with visible progress, and successfully installed via the in-app updater without using the Play Store (UC-05).

- Deleting a transaction moves it to Trash and it can be restored with all original links (category/account/friend) intact (FR-018, FR-024, FR-198).

- A friend transaction correctly transitions Pending → Partially Paid → Completed as repayments are recorded, and the dashboard pending totals reflect this without manual refresh (UC-02, Section 22.1).

- A category budget shows correct spent/remaining amounts and fires a warning notification at the configured threshold and an exceeded notification at 100%+ (FR-081, FR-082).

- A budget envelope tracks all expenses in its period against the total, shows funding-account progress, and can post funding as income on create / auto-repeat cycle (FR-085–FR-087).

- PDF, Excel, and CSV reports generate successfully for a selected date range and open correctly in a standard viewer/spreadsheet app (FR-111–FR-114).

- Enabling App Lock with a PIN requires the PIN (or biometric, if available) on next app open (FR-161–FR-163).

- Cold start time and list scrolling meet the performance targets in Section 14.1 on a mid-range test device.

- No data loss occurs across a simulated app update requiring a schema migration (NFR-012).

# 32. Future Roadmap

The following are explicitly out of scope for the MVP but should be considered when making architectural decisions today, per the scalability constraint in Section 14.6:

| Feature | Notes |
| --- | --- |
| OCR receipt scanning | Auto-extract amount/date/merchant from a captured receipt image |
| AI expense categorization | Suggest a category based on notes/merchant/history |
| Voice expense entry | Add an expense via speech-to-text |
| Currency exchange support | Multi-currency transactions with live/periodic exchange rates |
| Family shared wallets / shared budgets | Multiple people contributing to the same live budget or account |
| Split bills | Divide a single expense across multiple friends |
| Multi-device synchronization | Real-time sync beyond the current single-device-plus-backup model |
| Web Admin Panel | Browser-based dashboard, likely requiring a backend service |
| Desktop Application | Windows/macOS/Linux client sharing the data model |
| Bank API integration | Auto-import transactions from linked bank accounts |
| QR payment import | Parse QR-based payment confirmations directly into a transaction |
| Home-screen Widgets | At-a-glance balance/budget widget |
| Wear OS support | Quick add / glance from a smartwatch |
| iOS support | Port the Flutter app to iOS with App Store distribution and in-app-purchase-compliant update handling |

# 33. Appendix

## 33.1 Requirement ID Ranges

| Range | Module |
| --- | --- |
| FR-001–014 | Dashboard |
| FR-015–034 | Expense Management |
| FR-035–044 | Income Management |
| FR-045–062 | Friend Money Tracker |
| FR-063–070 | Categories |
| FR-071–078 | Payment Accounts |
| FR-079–088 | Budgets |
| FR-089–098 | Statistics |
| FR-099–104 | Search |
| FR-105–110 | Filters |
| FR-111–118 | Reports |
| FR-119–124 | Receipt Images |
| FR-125–132 | Recurring Transactions |
| FR-133–140 | Reminders |
| FR-141–154 | Backup & Restore |
| FR-155–160 | Authentication |
| FR-161–166 | App Lock |
| FR-167–184 | In-App Update System |
| FR-185–196 | Settings |
| FR-197–202 | Trash |
| FR-203–207 | Favorites |
| FR-208–210 | Quick Add |
| NFR-001–004 | Performance |
| NFR-005–008 | Security |
| NFR-009–011 | Usability |
| NFR-012–014 | Reliability |
| NFR-015–016 | Compatibility |
| NFR-017–018 | Maintainability & Scalability |

## 33.2 Suggested Package References (Flutter/Dart)

- State/DI/Routing: get

- Local DB: isar, isar_flutter_libs, isar_generator

- Auth: google_sign_in

- Drive backup: googleapis (drive/v3), extension_google_sign_in_as_googleapis_auth

- Charts: fl_chart

- Notifications: flutter_local_notifications, timezone

- Reports: pdf / printing (PDF), excel (xlsx), csv

- Images: image_picker, flutter_image_compress

- Secure storage: flutter_secure_storage

- Biometrics: local_auth

- HTTP/update: http or dio, package_info_plus, permission_handler

- Install intent: install_plugin or a platform channel to android.content.Intent(ACTION_VIEW) with a FileProvider URI

## 33.3 Glossary Cross-Reference

See Section 6 (Definitions and Acronyms) for all defined terms used throughout this document.

## 33.4 Document Conventions

- MUST/SHALL statements are normative requirements; SHOULD/MAY indicate recommended but non-blocking guidance.

- All PlantUML blocks in Sections 18, 19, and 21–22 are ready to paste into any PlantUML renderer without modification.

- Monetary amounts throughout the schema are stored as raw decimal numbers in the profile's base currency; currency symbol/formatting is a presentation-layer concern only (FR-186).
