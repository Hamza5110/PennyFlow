import 'package:equatable/equatable.dart';

/// Describes a PennyFlow backup bundle (SRS §27.1).
class BackupManifest extends Equatable {
  const BackupManifest({
    required this.formatVersion,
    required this.schemaVersion,
    required this.profileId,
    required this.createdAt,
    required this.sha256,
    required this.bundleBytes,
    this.profileName,
    this.googleAccountEmail,
    this.imageCount = 0,
  });

  factory BackupManifest.fromJson(Map<String, dynamic> json) {
    return BackupManifest(
      formatVersion: json['formatVersion'] as int,
      schemaVersion: json['schemaVersion'] as int,
      profileId: json['profileId'] as int,
      profileName: json['profileName'] as String?,
      googleAccountEmail: json['googleAccountEmail'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sha256: json['sha256'] as String,
      bundleBytes: json['bundleBytes'] as int? ?? 0,
      imageCount: json['imageCount'] as int? ?? 0,
    );
  }

  final int formatVersion;
  final int schemaVersion;
  final int profileId;
  final String? profileName;
  final String? googleAccountEmail;
  final DateTime createdAt;
  final String sha256;
  final int bundleBytes;
  final int imageCount;

  Map<String, dynamic> toJson() => {
        'formatVersion': formatVersion,
        'schemaVersion': schemaVersion,
        'profileId': profileId,
        if (profileName != null) 'profileName': profileName,
        if (googleAccountEmail != null) 'googleAccountEmail': googleAccountEmail,
        'createdAt': createdAt.toIso8601String(),
        'sha256': sha256,
        'bundleBytes': bundleBytes,
        'imageCount': imageCount,
      };

  @override
  List<Object?> get props => [
        formatVersion,
        schemaVersion,
        profileId,
        profileName,
        googleAccountEmail,
        createdAt,
        sha256,
        bundleBytes,
        imageCount,
      ];
}

/// Remote backup metadata from Google Drive AppData.
class BackupRemoteMeta extends Equatable {
  const BackupRemoteMeta({
    required this.fileId,
    required this.fileName,
    required this.sizeBytes,
    required this.modifiedAt,
    this.md5Checksum,
  });

  final String fileId;
  final String fileName;
  final int sizeBytes;
  final DateTime modifiedAt;
  final String? md5Checksum;

  @override
  List<Object?> get props =>
      [fileId, fileName, sizeBytes, modifiedAt, md5Checksum];
}

/// In-progress backup/restore phase for UI (SRS §25.2).
enum BackupPhase {
  idle,
  exporting,
  uploading,
  downloading,
  verifying,
  restoring,
}

class BackupProgress {
  const BackupProgress({
    required this.phase,
    this.percent = 0,
    this.messageKey,
  });

  final BackupPhase phase;
  final double percent;
  final String? messageKey;
}
