import 'dart:io';

import 'package:googleapis/drive/v3.dart' as drive;

import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/backup_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/backup/backup_manifest.dart';
import '../auth/google_sign_in_client.dart';

/// Google Drive AppData backup client (FR-141, FR-144).
class GoogleDriveBackupClient with BaseService {
  GoogleDriveBackupClient(this._googleSignIn);

  final GoogleSignInClient _googleSignIn;

  Future<BackupRemoteMeta?> fetchRemoteMeta(int profileId) async {
    final driveApi = await _requireDriveApi();
    final fileName = BackupConstants.driveFileName(profileId);
    final response = await _withRetry(
      () => driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$fileName' and trashed = false",
        $fields: 'files(id,name,size,modifiedTime,md5Checksum)',
        pageSize: 1,
      ),
    );

    final files = response.files;
    if (files == null || files.isEmpty) return null;

    final file = files.first;
    return BackupRemoteMeta(
      fileId: file.id!,
      fileName: file.name ?? fileName,
      sizeBytes: int.tryParse(file.size ?? '0') ?? 0,
      modifiedAt: file.modifiedTime ?? DateTime.now().toUtc(),
      md5Checksum: file.md5Checksum,
    );
  }

  Future<BackupRemoteMeta> uploadBackup({
    required File bundleFile,
    required int profileId,
  }) async {
    final driveApi = await _requireDriveApi();
    final fileName = BackupConstants.driveFileName(profileId);
    final media = drive.Media(bundleFile.openRead(), await bundleFile.length());

    final existing = await fetchRemoteMeta(profileId);
    late drive.File saved;
    if (existing != null) {
      saved = await _withRetry(
        () => driveApi.files.update(
          drive.File()..name = fileName,
          existing.fileId,
          uploadMedia: media,
          $fields: 'id,name,size,modifiedTime,md5Checksum',
        ),
      );
    } else {
      saved = await _withRetry(
        () => driveApi.files.create(
          drive.File()
            ..name = fileName
            ..parents = ['appDataFolder'],
          uploadMedia: media,
          $fields: 'id,name,size,modifiedTime,md5Checksum',
        ),
      );
    }

    return BackupRemoteMeta(
      fileId: saved.id!,
      fileName: saved.name ?? fileName,
      sizeBytes: int.tryParse(saved.size ?? '0') ?? await bundleFile.length(),
      modifiedAt: saved.modifiedTime ?? DateTime.now().toUtc(),
      md5Checksum: saved.md5Checksum,
    );
  }

  Future<File> downloadBackup({
    required BackupRemoteMeta meta,
    required File targetFile,
  }) async {
    final driveApi = await _requireDriveApi();
    final media = await _withRetry<drive.Media>(
      () async {
        final response = await driveApi.files.get(
          meta.fileId,
          downloadOptions: drive.DownloadOptions.fullMedia,
        );
        if (response is! drive.Media) {
          throw const BackupException(
            message: 'Unexpected Drive download response',
            code: 'BACKUP_DOWNLOAD_FAILED',
          );
        }
        return response;
      },
    );

    final sink = targetFile.openWrite();
    await for (final chunk in media.stream) {
      sink.add(chunk);
    }
    await sink.close();
    return targetFile;
  }

  Future<drive.DriveApi> _requireDriveApi() async {
    final api = await _googleSignIn.driveApi();
    if (api == null) {
      throw const BackupException(
        message: 'Google account is not signed in',
        code: 'BACKUP_NOT_SIGNED_IN',
      );
    }
    return api;
  }

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    var delay = AppConstants.initialRetryDelay;
  Object? lastError;
    for (var attempt = 0; attempt < AppConstants.maxNetworkRetries; attempt++) {
      try {
        return await action().timeout(AppConstants.networkTimeout);
      } catch (error) {
        lastError = error;
        if (attempt == AppConstants.maxNetworkRetries - 1) break;
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }

    throw BackupException(
      message: 'Google Drive request failed',
      cause: lastError,
    );
  }
}
