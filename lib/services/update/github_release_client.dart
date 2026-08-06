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

  final http.Client _client;

  /// Returns `null` when the repository has no published releases yet (404).
  Future<ReleaseInfo?> fetchLatestRelease() async {
    final response = await _client
        .get(
          Uri.parse(AppConfig.instance.updateCheckUrl),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'PennyFlow',
          },
        )
        .timeout(AppConstants.networkTimeout);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw UpdateException(
        message: 'Could not check for updates (${response.statusCode})',
        code: 'UPDATE_CHECK_FAILED',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final release = ReleaseInfo.fromGitHubJson(json);
    if (!release.hasApk) {
      throw const UpdateException(
        message: 'Latest release does not include an APK asset',
        code: 'UPDATE_APK_MISSING',
      );
    }
    return release;
  }
}
