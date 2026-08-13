import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/backup_constants.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/backup_checksum_utils.dart';
import '../../data/models/backup/backup_manifest.dart';
import '../settings/settings_service.dart';
import '../storage/local_storage_service.dart';
import 'backup_snapshot_codec.dart';

/// Builds a versioned zip backup bundle (FR-143).
class BackupBundleBuilder {
  BackupBundleBuilder(
    this._codec,
    this._settings,
    this._storage,
  );

  final BackupSnapshotCodec _codec;
  final SettingsService _settings;
  final LocalStorageService _storage;
  final _uuid = const Uuid();

  Future<({File bundle, BackupManifest manifest})> build({
    required int profileId,
    String? googleAccountEmail,
    void Function(double progress)? onProgress,
  }) async {
    onProgress?.call(0.1);
    final snapshot = await _codec.exportProfile(profileId);
    final profileName = (snapshot['profile'] as Map<String, dynamic>)['name']
        as String?;

    final workDir = await _createWorkDir();
    try {
      final receiptsDir =
          Directory(p.join(workDir.path, BackupConstants.receiptsFolderName));
      await receiptsDir.create(recursive: true);

      final imageCount = await _copyReceiptImages(
        snapshot: snapshot,
        receiptsDir: receiptsDir,
      );
      onProgress?.call(0.45);

      final settings = _exportSettings();
      final dataFile = File(p.join(workDir.path, BackupConstants.dataFileName));
      await dataFile.writeAsString(jsonEncode(snapshot));

      final settingsFile =
          File(p.join(workDir.path, BackupConstants.settingsFileName));
      await settingsFile.writeAsString(jsonEncode(settings));

      final dataBytes = await dataFile.readAsBytes();
      final settingsBytes = await settingsFile.readAsBytes();
      final receiptBytes = await _collectReceiptBytes(receiptsDir);

      final contentChecksum = BackupChecksumUtils.sha256OfBytes([
        ...dataBytes,
        ...settingsBytes,
        ...receiptBytes,
      ]);

      final manifest = BackupManifest(
        formatVersion: BackupConstants.bundleFormatVersion,
        schemaVersion: AppConstants.databaseSchemaVersion,
        profileId: profileId,
        profileName: profileName,
        googleAccountEmail: googleAccountEmail,
        createdAt: DateTime.now().toUtc(),
        sha256: contentChecksum,
        bundleBytes: 0,
        imageCount: imageCount,
      );

      final manifestFile =
          File(p.join(workDir.path, BackupConstants.manifestFileName));
      await BackupChecksumUtils.writeJsonFile(manifestFile, manifest.toJson());

      final bundleFile = File(
        p.join(
          (await getTemporaryDirectory()).path,
          'spendvault_backup_${profileId}_${_uuid.v4()}.zip',
        ),
      );

      await _zipDirectory(workDir, bundleFile);
      onProgress?.call(1);

      final finalManifest = BackupManifest(
        formatVersion: manifest.formatVersion,
        schemaVersion: manifest.schemaVersion,
        profileId: manifest.profileId,
        profileName: manifest.profileName,
        googleAccountEmail: manifest.googleAccountEmail,
        createdAt: manifest.createdAt,
        sha256: manifest.sha256,
        bundleBytes: await bundleFile.length(),
        imageCount: manifest.imageCount,
      );

      return (bundle: bundleFile, manifest: finalManifest);
    } finally {
      if (await workDir.exists()) {
        await workDir.delete(recursive: true);
      }
    }
  }

  Future<Directory> _createWorkDir() async {
    final dir = Directory(
      p.join(
        (await getTemporaryDirectory()).path,
        'spendvault_backup_build_${_uuid.v4()}',
      ),
    );
    await dir.create(recursive: true);
    return dir;
  }

  Map<String, dynamic> _exportSettings() => {
        StorageKeys.themeMode: _storage.getString(StorageKeys.themeMode),
        StorageKeys.themeVariant: _settings.themeVariant.value.name,
        StorageKeys.localeCode: _settings.localeCode.value,
        StorageKeys.currencyCode: _settings.currencyCode.value,
        StorageKeys.notificationsEnabled: _settings.notificationsEnabled.value,
        StorageKeys.budgetAlertsEnabled: _settings.budgetAlertsEnabled.value,
        StorageKeys.reminderAlertsEnabled: _settings.reminderAlertsEnabled.value,
        StorageKeys.autoUpdateCheckEnabled:
            _settings.autoUpdateCheckEnabled.value,
        StorageKeys.appLockEnabled: _settings.appLockEnabled.value,
        StorageKeys.lockTimeoutMinutes: _settings.lockTimeoutMinutes.value,
      };

  Future<int> _copyReceiptImages({
    required Map<String, dynamic> snapshot,
    required Directory receiptsDir,
  }) async {
    final paths = <String>{};
    for (final raw in snapshot['expenses'] as List<dynamic>) {
      paths.addAll(
        List<String>.from(
          (raw as Map<String, dynamic>)['receiptImagePaths'] as List<dynamic>? ??
              [],
        ),
      );
    }
    for (final raw in snapshot['incomes'] as List<dynamic>) {
      paths.addAll(
        List<String>.from(
          (raw as Map<String, dynamic>)['imagePaths'] as List<dynamic>? ?? [],
        ),
      );
    }
    for (final raw in snapshot['friendTransactions'] as List<dynamic>) {
      paths.addAll(
        List<String>.from(
          (raw as Map<String, dynamic>)['imagePaths'] as List<dynamic>? ?? [],
        ),
      );
    }
    for (final raw in snapshot['repayments'] as List<dynamic>) {
      paths.addAll(
        List<String>.from(
          (raw as Map<String, dynamic>)['imagePaths'] as List<dynamic>? ?? [],
        ),
      );
    }

    var copied = 0;
    for (final originalPath in paths) {
      if (originalPath.isEmpty) continue;
      final source = File(originalPath);
      if (!await source.exists()) continue;

      final fileName = p.basename(originalPath);
      final target = File(p.join(receiptsDir.path, fileName));
      await source.copy(target.path);
      _rewriteImagePaths(snapshot, originalPath, fileName);
      copied++;
    }
    return copied;
  }

  void _rewriteImagePaths(
    Map<String, dynamic> snapshot,
    String originalPath,
    String fileName,
  ) {
    final relative = '${BackupConstants.receiptsFolderName}/$fileName';
    for (final key in [
      'expenses',
      'incomes',
      'friendTransactions',
      'repayments',
    ]) {
      for (final raw in snapshot[key] as List<dynamic>) {
        final map = raw as Map<String, dynamic>;
        final field = key == 'expenses'
            ? 'receiptImagePaths'
            : 'imagePaths';
        final paths = List<String>.from(map[field] as List<dynamic>? ?? []);
        for (var i = 0; i < paths.length; i++) {
          if (paths[i] == originalPath) {
            paths[i] = relative;
          }
        }
        map[field] = paths;
      }
    }
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

  Future<void> _zipDirectory(Directory sourceDir, File targetZip) async {
    final archive = Archive();
    await for (final entity in sourceDir.list(recursive: true)) {
      if (entity is! File) continue;
      final relative = p
          .relative(entity.path, from: sourceDir.path)
          .replaceAll(r'\', '/')
          .replaceFirst(RegExp(r'^/+'), '');
      if (relative.isEmpty || relative.contains('..')) continue;
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw StateError('Failed to encode backup zip');
    }
    await targetZip.writeAsBytes(encoded);
  }
}
