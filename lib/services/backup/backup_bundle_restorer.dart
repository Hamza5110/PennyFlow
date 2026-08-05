import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/backup_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/backup_checksum_utils.dart';
import '../../data/models/backup/backup_manifest.dart';
import '../image/image_service.dart';
import '../settings/settings_service.dart';
import '../storage/local_storage_service.dart';
import 'backup_snapshot_codec.dart';

/// Restores a verified backup bundle into local storage (FR-144, FR-147).
class BackupBundleRestorer {
  BackupBundleRestorer(
    this._codec,
    this._settings,
    this._storage,
    this._images,
  );

  final BackupSnapshotCodec _codec;
  final SettingsService _settings;
  final LocalStorageService _storage;
  final ImageService _images;
  final _uuid = const Uuid();

  Future<BackupManifest> validate(File bundleFile) async {
    final extracted = await _extractBundle(bundleFile);
    try {
      return _readAndVerifyManifest(extracted);
    } finally {
      if (await extracted.exists()) {
        await extracted.delete(recursive: true);
      }
    }
  }

  Future<BackupManifest> restore({
    required File bundleFile,
    required int targetProfileId,
    required bool overwrite,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.05);
    final extracted = await _extractBundle(bundleFile);
    try {
      final manifest = await _readAndVerifyManifest(extracted);
      onProgress?.call(0.25);

      final dataFile = File(p.join(extracted.path, BackupConstants.dataFileName));
      final snapshot =
          jsonDecode(await dataFile.readAsString()) as Map<String, dynamic>;
      await _restoreReceiptImages(extracted, snapshot);
      onProgress?.call(0.55);

      await _codec.importProfile(
        snapshot,
        profileId: targetProfileId,
        overwrite: overwrite,
      );
      onProgress?.call(0.8);

      final settingsFile =
          File(p.join(extracted.path, BackupConstants.settingsFileName));
      if (await settingsFile.exists()) {
        final settings =
            jsonDecode(await settingsFile.readAsString()) as Map<String, dynamic>;
        await _applySettings(settings);
      }
      onProgress?.call(1);
      return manifest;
    } finally {
      if (await extracted.exists()) {
        await extracted.delete(recursive: true);
      }
    }
  }

  Future<BackupManifest> _readAndVerifyManifest(Directory extracted) async {
    final manifestFile =
        File(p.join(extracted.path, BackupConstants.manifestFileName));
    if (!await manifestFile.exists()) {
      throw const BackupException(
        message: 'Backup manifest is missing',
        code: 'BACKUP_INVALID',
      );
    }

    final manifest = BackupManifest.fromJson(
      BackupChecksumUtils.decodeJsonFile(manifestFile),
    );

    if (manifest.schemaVersion > AppConstants.databaseSchemaVersion) {
      throw BackupException(
        message:
            'Backup requires a newer app version (schema ${manifest.schemaVersion})',
        code: 'BACKUP_SCHEMA_TOO_NEW',
      );
    }

    final dataFile = File(p.join(extracted.path, BackupConstants.dataFileName));
    if (!await dataFile.exists()) {
      throw const BackupException(
        message: 'Backup data is missing',
        code: 'BACKUP_INVALID',
      );
    }

    final settingsFile =
        File(p.join(extracted.path, BackupConstants.settingsFileName));
    final receiptsDir =
        Directory(p.join(extracted.path, BackupConstants.receiptsFolderName));

    final contentChecksum = BackupChecksumUtils.sha256OfBytes([
      ...await dataFile.readAsBytes(),
      if (await settingsFile.exists()) ...await settingsFile.readAsBytes(),
      ...await _collectReceiptBytes(receiptsDir),
    ]);
    if (contentChecksum != manifest.sha256.toLowerCase()) {
      throw const BackupException(
        message: 'Backup integrity check failed',
        code: 'BACKUP_CHECKSUM_MISMATCH',
      );
    }

    return manifest;
  }

  Future<Directory> _extractBundle(File bundleFile) async {
    final bytes = await bundleFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    final targetDir = Directory(
      p.join(
        (await getTemporaryDirectory()).path,
        'pennyflow_restore_${_uuid.v4()}',
      ),
    );
    await targetDir.create(recursive: true);

    for (final file in archive) {
      if (!file.isFile) continue;
      final outFile = File(p.join(targetDir.path, file.name));
      await outFile.parent.create(recursive: true);
      await outFile.writeAsBytes(file.content as List<int>);
    }
    return targetDir;
  }

  Future<List<int>> _collectReceiptBytes(Directory receiptsDir) async {
    if (!await receiptsDir.exists()) return [];

    final files = <File>[];
    await for (final entity in receiptsDir.list()) {
      if (entity is File) files.add(entity);
    }
    files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    final buffer = <int>[];
    for (final file in files) {
      buffer.addAll(await file.readAsBytes());
    }
    return buffer;
  }

  Future<void> _restoreReceiptImages(
    Directory extracted,
    Map<String, dynamic> snapshot,
  ) async {
    final receiptsDir =
        Directory(p.join(extracted.path, BackupConstants.receiptsFolderName));
    if (!await receiptsDir.exists()) return;

    final appReceiptsDir = await _images.receiptsDir();
    final pathMap = <String, String>{};

    await for (final entity in receiptsDir.list()) {
      if (entity is! File) continue;
      final fileName = p.basename(entity.path);
      final target = File(p.join(appReceiptsDir.path, fileName));
      await entity.copy(target.path);
      pathMap['${BackupConstants.receiptsFolderName}/$fileName'] = target.path;
    }

    for (final key in [
      'expenses',
      'incomes',
      'friendTransactions',
      'repayments',
    ]) {
      for (final raw in snapshot[key] as List<dynamic>) {
        final map = raw as Map<String, dynamic>;
        final field = key == 'expenses' ? 'receiptImagePaths' : 'imagePaths';
        final paths = List<String>.from(map[field] as List<dynamic>? ?? []);
        map[field] = paths
            .map((path) => pathMap[path] ?? path)
            .where((path) => path.isNotEmpty)
            .toList();
      }
    }
  }

  Future<void> _applySettings(Map<String, dynamic> settings) async {
    final themeMode = settings[StorageKeys.themeMode] as String?;
    if (themeMode != null) {
      await _storage.setString(StorageKeys.themeMode, themeMode);
    }

    final locale = settings[StorageKeys.localeCode] as String?;
    if (locale != null) {
      await _settings.setLocaleCode(locale);
    }

    final currency = settings[StorageKeys.currencyCode] as String?;
    if (currency != null) {
      await _settings.setCurrencyCode(currency);
    }

    if (settings.containsKey(StorageKeys.notificationsEnabled)) {
      await _settings.setNotificationsEnabled(
        settings[StorageKeys.notificationsEnabled] as bool? ?? true,
      );
    }
    if (settings.containsKey(StorageKeys.budgetAlertsEnabled)) {
      await _settings.setBudgetAlertsEnabled(
        settings[StorageKeys.budgetAlertsEnabled] as bool? ?? true,
      );
    }
    if (settings.containsKey(StorageKeys.reminderAlertsEnabled)) {
      await _settings.setReminderAlertsEnabled(
        settings[StorageKeys.reminderAlertsEnabled] as bool? ?? true,
      );
    }
    if (settings.containsKey(StorageKeys.autoUpdateCheckEnabled)) {
      await _settings.setAutoUpdateCheckEnabled(
        settings[StorageKeys.autoUpdateCheckEnabled] as bool? ?? true,
      );
    }
    if (settings.containsKey(StorageKeys.appLockEnabled)) {
      await _settings.setAppLockEnabled(
        settings[StorageKeys.appLockEnabled] as bool? ?? false,
      );
    }
    if (settings.containsKey(StorageKeys.lockTimeoutMinutes)) {
      await _settings.setLockTimeoutMinutes(
        settings[StorageKeys.lockTimeoutMinutes] as int? ?? 5,
      );
    }
  }
}
