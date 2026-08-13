import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../app/config/app_config.dart';
import '../../core/base/base_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/update/release_info.dart';

/// Fetches release metadata from GitHub Releases API (SRS §28.1).
class GitHubReleaseClient with BaseService {
  GitHubReleaseClient({http.Client? client}) : _client = client ?? http.Client();

  static const _headers = {
    'Accept': 'application/vnd.github+json',
    'User-Agent': 'SpendVault',
  };

  final http.Client _client;

  /// Returns `null` when the repository has no published releases yet.
  Future<ReleaseInfo?> fetchLatestRelease() async {
    final latestUrl = AppConfig.instance.updateCheckUrl;
    final response = await _get(latestUrl);

    if (response.statusCode == 200) {
      return _parseRelease(jsonDecode(response.body) as Map<String, dynamic>);
    }

    // `/releases/latest` 404s when there are only pre-releases or drafts.
    if (response.statusCode == 404) {
      log.w('GitHub /releases/latest returned 404; listing recent releases');
      return _fetchFromReleaseList(latestUrl);
    }

    throw UpdateException(
      message: 'Could not check for updates (${response.statusCode})',
      code: 'UPDATE_CHECK_FAILED',
    );
  }

  Future<ReleaseInfo?> _fetchFromReleaseList(String latestUrl) async {
    final listUrl = latestUrl.endsWith('/latest')
        ? latestUrl.replaceFirst(RegExp(r'/latest$'), '')
        : latestUrl;
    final response = await _get('$listUrl?per_page=5');

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw UpdateException(
        message: 'Could not check for updates (${response.statusCode})',
        code: 'UPDATE_CHECK_FAILED',
      );
    }

    final json = jsonDecode(response.body);
    if (json is! List || json.isEmpty) return null;

    for (final item in json) {
      if (item is! Map<String, dynamic>) continue;
      if (item['draft'] == true) continue;
      try {
        return _parseRelease(item);
      } on UpdateException catch (error) {
        if (error.code == 'UPDATE_APK_MISSING') continue;
        rethrow;
      }
    }
    return null;
  }

  ReleaseInfo _parseRelease(Map<String, dynamic> json) {
    final release = ReleaseInfo.fromGitHubJson(json);
    if (!release.hasApk) {
      throw const UpdateException(
        message: 'Latest release does not include an APK asset',
        code: 'UPDATE_APK_MISSING',
      );
    }
    return release;
  }

  Future<http.Response> _get(String url) {
    return _client
        .get(Uri.parse(url), headers: _headers)
        .timeout(AppConstants.networkTimeout);
  }
}
