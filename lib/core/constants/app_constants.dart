/// Global app-level constants for SpendVault.
///
/// Keep feature-specific magic numbers in their own modules;
/// only cross-cutting values belong here.
abstract final class AppConstants {
  static const String appName = 'SpendVault';
  static const String appTagline = 'Track every spend, manage every moment.';
  static const String packageName = 'com.spendvault.app';

  /// Schema version persisted in [AppMeta] for migrations.
  static const int databaseSchemaVersion = 11;

  /// Default profile currency (ISO 4217). Presentation only — amounts stored raw.
  static const String defaultCurrencyCode = 'PKR';

  /// Soft-delete trash retention (days). Configurable later via settings.
  static const int trashRetentionDays = 30;

  /// Network / backup retry policy.
  static const int maxNetworkRetries = 3;
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration initialRetryDelay = Duration(seconds: 1);

  /// Search debounce for NFR-101 (results within 300 ms for local datasets).
  static const Duration searchDebounce = Duration(milliseconds: 200);

  /// Image constraints (SRS Section 30).
  static const int maxImagesPerTransaction = 5;
  static const int maxImageBytesAfterCompression = 500 * 1024;

  /// Validation upper bounds (SRS Section 30).
  static const double maxAmount = 100000000;
  static const int maxNotesLength = 500;
  static const int maxTagLength = 20;
  static const int maxTagsPerTransaction = 10;
  static const int maxNameLength = 40;
  static const int maxFriendNameLength = 60;

  /// PIN options for app lock.
  static const List<int> allowedPinLengths = [4, 6];

  /// Bottom-nav recent transactions default count (FR-004).
  static const int defaultRecentTransactionCount = 8;

  /// Budget warning threshold default (FR-081).
  static const double defaultBudgetWarningThreshold = 0.8;

  /// Splash minimum display so branding is visible on fast devices.
  static const Duration splashMinDuration = Duration(milliseconds: 1200);

  /// Paginated list page size (Phase 20).
  static const int listPageSize = 50;

  /// Receipt thumbnail decode / generation size.
  static const int thumbnailMaxDimension = 256;
  static const int thumbnailQuality = 60;

  /// Public Downloads subfolder for exported reports (Downloads/SpendVault/Reports).
  static const String reportsFolderName = 'SpendVault';
  static const String reportsSubfolderName = 'Reports';
  static const String reportsDownloadsPath = 'SpendVault/Reports';
}
