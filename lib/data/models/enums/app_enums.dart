/// Shared enums used across modules.
///
/// Feature-specific enums may live next to their models; keep cross-cutting
/// ones here so repositories/services share a single source of truth.
library;

enum ThemeModeOption { system, light, dark }

enum BackupStatus { idle, exporting, uploading, verifying, success, failed }

enum TransactionLifecycle { active, deleted, purged }

enum FriendTransactionType { given, received }

enum FriendTransactionStatus { pending, partiallyPaid, completed }

enum IncomeSource {
  salary,
  freelance,
  bonus,
  gift,
  refund,
  business,
  custom,
}

enum PaymentAccountType {
  cash,
  bank,
  easypaisa,
  jazzcash,
  creditCard,
  custom,
}

enum RecurringFrequency { daily, weekly, monthly, yearly }

enum ReminderType {
  billDue,
  friendPaymentDue,
  subscriptionRenewal,
  insurance,
  custom,
}

enum SortOrder { ascending, descending }
