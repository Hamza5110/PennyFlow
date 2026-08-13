/// Backup bundle and Google Drive AppData naming (SRS §27).
abstract final class BackupConstants {
  static const int bundleFormatVersion = 1;

  static const String manifestFileName = 'manifest.json';
  static const String dataFileName = 'data.json';
  static const String settingsFileName = 'settings.json';
  static const String receiptsFolderName = 'receipts';

  static const Duration autoBackupInterval = Duration(hours: 24);

  static String driveFileName(int profileId) =>
      'spendvault_profile_${profileId}_backup.zip';
}
