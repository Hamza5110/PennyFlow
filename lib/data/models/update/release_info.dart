import 'package:equatable/equatable.dart';

/// GitHub release metadata for in-app updates (SRS §28.1).
class ReleaseInfo extends Equatable {
  const ReleaseInfo({
    required this.version,
    required this.releaseNotes,
    required this.apkDownloadUrl,
    required this.apkFileName,
    required this.apkSizeBytes,
    this.apkAssetApiUrl = '',
    this.isForced = false,
    this.publishedAt,
  });

  factory ReleaseInfo.fromGitHubJson(Map<String, dynamic> json) {
    final tag = (json['tag_name'] as String? ?? '').replaceFirst(RegExp(r'^[vV]'), '');
    final body = json['body'] as String? ?? '';
    final labels = (json['labels'] as List<dynamic>? ?? [])
        .map((label) => (label as Map<String, dynamic>)['name'] as String? ?? '')
        .toList();
    final assets = json['assets'] as List<dynamic>? ?? [];
    final apkAsset = assets
        .map((asset) => asset as Map<String, dynamic>)
        .firstWhere(
          (asset) => (asset['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
          orElse: () => <String, dynamic>{},
        );

    final forcedByLabel = labels.any(
      (name) => name.toLowerCase().contains('force-update'),
    );
    final forcedByBody = body.toLowerCase().contains('[force-update]');

    return ReleaseInfo(
      version: tag,
      releaseNotes: body.trim(),
      apkDownloadUrl: apkAsset['browser_download_url'] as String? ?? '',
      apkAssetApiUrl: apkAsset['url'] as String? ?? '',
      apkFileName: apkAsset['name'] as String? ?? 'spendvault.apk',
      apkSizeBytes: int.tryParse('${apkAsset['size']}') ?? 0,
      isForced: forcedByLabel || forcedByBody,
      publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
    );
  }

  final String version;
  final String releaseNotes;
  final String apkDownloadUrl;
  /// GitHub Releases API asset URL (`Accept: application/octet-stream`).
  final String apkAssetApiUrl;
  final String apkFileName;
  final int apkSizeBytes;
  final bool isForced;
  final DateTime? publishedAt;

  bool get hasApk => downloadUrlCandidates.isNotEmpty;

  /// Preferred download sources. API asset URL first — browser URLs 404 when
  /// HTTP clients forward GitHub `Accept` headers onto the CDN redirect.
  List<String> get downloadUrlCandidates {
    final urls = <String>[];
    if (apkAssetApiUrl.isNotEmpty) urls.add(apkAssetApiUrl);
    if (apkDownloadUrl.isNotEmpty && apkDownloadUrl != apkAssetApiUrl) {
      urls.add(apkDownloadUrl);
    }
    return urls;
  }

  @override
  List<Object?> get props => [
        version,
        releaseNotes,
        apkDownloadUrl,
        apkAssetApiUrl,
        apkFileName,
        apkSizeBytes,
        isForced,
        publishedAt,
      ];
}
