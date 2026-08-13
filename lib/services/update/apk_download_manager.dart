import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../data/models/update/release_info.dart';
import '../../data/models/update/update_progress.dart';

/// Resumable APK downloader with pause/resume support (FR-171–FR-172).
///
/// GitHub release downloads 302 to a CDN. Forwarding GitHub `Accept` / `Range`
/// headers onto that redirect is a common cause of HTTP 404, so redirects are
/// followed manually and Range is only sent to the final host.
class ApkDownloadManager {
  ApkDownloadManager({http.Client? client}) : _client = client ?? http.Client();

  static const _userAgent = 'SpendVault';
  static const _maxAttempts = 4;
  static const _maxRedirects = 8;
  static const _connectTimeout = Duration(seconds: 60);

  final http.Client _client;
  final _log = AppLogger.instance;

  bool _paused = false;
  bool _cancelled = false;
  ReleaseInfo? _activeRelease;
  File? _activeFile;

  bool get isPaused => _paused;

  void pause() => _paused = true;

  void resume() => _paused = false;

  void cancel() {
    _cancelled = true;
    _paused = false;
  }

  Future<void> download({
    required ReleaseInfo release,
    required File target,
    required void Function(UpdateProgress progress) onProgress,
  }) async {
    _activeRelease = release;
    _activeFile = target;
    _cancelled = false;
    _paused = false;

    final urls = release.downloadUrlCandidates;
    if (urls.isEmpty) {
      throw const UpdateException(
        message: 'No APK download URL in this release',
        code: 'UPDATE_APK_MISSING',
      );
    }

    var received = 0;
    if (await target.exists()) {
      received = await target.length();
    } else {
      await target.parent.create(recursive: true);
      await target.create();
    }

    final total = release.apkSizeBytes > 0 ? release.apkSizeBytes : received;
    var lastTick = DateTime.now();
    var lastReceived = received;
    var allowRange = received > 0;

    onProgress(
      UpdateProgress(
        phase: UpdateDownloadPhase.downloading,
        receivedBytes: received,
        totalBytes: total,
      ),
    );

    Object? lastError;
    var urlIndex = 0;

    for (var attempt = 0; attempt < _maxAttempts && !_cancelled; attempt++) {
      while (_paused && !_cancelled) {
        onProgress(
          UpdateProgress(
            phase: UpdateDownloadPhase.paused,
            receivedBytes: received,
            totalBytes: total,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (_cancelled) break;

      if (attempt > 0) {
        final delay = Duration(milliseconds: 400 * pow(2, attempt - 1).toInt());
        _log.w(
          'Retrying APK download attempt ${attempt + 1}/$_maxAttempts '
          'after ${delay.inMilliseconds}ms',
        );
        await Future<void>.delayed(delay);
      }

      final url = urls[urlIndex % urls.length];
      try {
        received = await _downloadOnce(
          url: url,
          githubAssetApi: _isGithubAssetApiUrl(url),
          target: target,
          resumeFrom: allowRange ? received : 0,
          expectedTotal: total,
          onBytes: (value, resolvedTotal, speed) {
            received = value;
            onProgress(
              UpdateProgress(
                phase: UpdateDownloadPhase.downloading,
                receivedBytes: value,
                totalBytes: resolvedTotal,
                speedBytesPerSecond: speed,
              ),
            );
          },
          lastTick: lastTick,
          lastReceived: lastReceived,
          onSpeedSample: (tick, sampledReceived) {
            lastTick = tick;
            lastReceived = sampledReceived;
          },
        );

        if (release.apkSizeBytes > 0 && received < release.apkSizeBytes) {
          lastError = const UpdateException(
            message: 'Download incomplete',
            code: 'UPDATE_DOWNLOAD_INCOMPLETE',
          );
          allowRange = true;
          continue;
        }

        lastError = null;
        break;
      } on UpdateException catch (error) {
        lastError = error;
        if (error.code == 'UPDATE_DOWNLOAD_CANCELLED') rethrow;

        _log.w(
          'APK download failed from $url: ${error.message}',
          error: error,
        );

        final status = _statusFromMessage(error.message);
        final rangeRejected = allowRange &&
            (status == 404 || status == 416 || status == 400);
        if (rangeRejected) {
          allowRange = false;
          received = 0;
          lastReceived = 0;
          if (await target.exists()) {
            await target.writeAsBytes([], flush: true);
          }
          _log.w('Range resume rejected ($status); restarting download');
          continue;
        }

        if (_isRetryableStatus(status) || status == 0) {
          urlIndex++;
          continue;
        }
        rethrow;
      } catch (error, stackTrace) {
        lastError = error;
        _log.w(
          'APK download I/O failed from $url',
          error: error,
          stackTrace: stackTrace,
        );
        urlIndex++;
      }
    }

    if (_cancelled) {
      throw const UpdateException(
        message: 'Download cancelled',
        code: 'UPDATE_DOWNLOAD_CANCELLED',
      );
    }

    if (lastError != null) {
      if (lastError is UpdateException) throw lastError;
      throw UpdateException(
        message: 'Download failed. Check your connection and try again.',
        code: 'UPDATE_DOWNLOAD_FAILED',
        cause: lastError,
      );
    }

    if (release.apkSizeBytes > 0 && received != release.apkSizeBytes) {
      throw const UpdateException(
        message: 'Downloaded file size mismatch',
        code: 'UPDATE_SIZE_MISMATCH',
      );
    }

    _activeRelease = null;
    _activeFile = null;
  }

  Future<int> _downloadOnce({
    required String url,
    required bool githubAssetApi,
    required File target,
    required int resumeFrom,
    required int expectedTotal,
    required void Function(int received, int total, double speed) onBytes,
    required DateTime lastTick,
    required int lastReceived,
    required void Function(DateTime tick, int received) onSpeedSample,
  }) async {
    var received = resumeFrom;
    if (resumeFrom == 0 && await target.exists()) {
      await target.writeAsBytes([], flush: true);
    }

    final response = await _openDownload(
      start: Uri.parse(url),
      resumeFrom: resumeFrom,
      githubAssetApi: githubAssetApi,
    );

    if (response.statusCode != 200 && response.statusCode != 206) {
      await response.stream.drain();
      throw UpdateException(
        message: 'Download failed (${response.statusCode})',
        code: 'UPDATE_DOWNLOAD_FAILED',
      );
    }

    if (response.statusCode == 200 && received > 0) {
      received = 0;
      lastReceived = 0;
      await target.writeAsBytes([], flush: true);
    }

    final resolvedTotal =
        response.contentLength != null && response.contentLength! > 0
            ? received + response.contentLength!
            : (expectedTotal > 0 ? expectedTotal : received);

    final sink = target.openWrite(mode: FileMode.append);
    try {
      await for (final chunk in response.stream) {
        while (_paused && !_cancelled) {
          await Future<void>.delayed(const Duration(milliseconds: 200));
        }
        if (_cancelled) break;

        sink.add(chunk);
        received += chunk.length;

        final now = DateTime.now();
        final elapsedMs = now.difference(lastTick).inMilliseconds;
        var speed = 0.0;
        if (elapsedMs >= 500) {
          speed = ((received - lastReceived) * 1000) / elapsedMs;
          onSpeedSample(now, received);
          lastTick = now;
          lastReceived = received;
        }

        onBytes(received, resolvedTotal, speed);
      }
    } finally {
      await sink.close();
    }

    if (_cancelled) {
      throw const UpdateException(
        message: 'Download cancelled',
        code: 'UPDATE_DOWNLOAD_CANCELLED',
      );
    }

    return received;
  }

  Future<http.StreamedResponse> _openDownload({
    required Uri start,
    required int resumeFrom,
    required bool githubAssetApi,
  }) async {
    var current = start;

    for (var hop = 0; hop < _maxRedirects; hop++) {
      final request = http.Request('GET', current);
      request.followRedirects = false;
      request.headers['User-Agent'] = _userAgent;

      final isEntryHost = _isGithubEntryHost(current);
      if (hop == 0 && githubAssetApi && isEntryHost) {
        request.headers['Accept'] = 'application/octet-stream';
      }

      if (resumeFrom > 0 && !isEntryHost) {
        request.headers['Range'] = 'bytes=$resumeFrom-';
      }

      _log.i(
        'APK GET $current hop=$hop range=${request.headers['Range'] ?? 'none'}',
      );

      final response =
          await _client.send(request).timeout(_connectTimeout);

      if (response.statusCode >= 300 && response.statusCode < 400) {
        final location = response.headers['location'];
        await response.stream.drain();
        if (location == null || location.isEmpty) {
          throw UpdateException(
            message: 'Download failed (${response.statusCode})',
            code: 'UPDATE_DOWNLOAD_FAILED',
          );
        }
        current = current.resolve(location);
        continue;
      }

      return response;
    }

    throw const UpdateException(
      message: 'Download failed (too many redirects)',
      code: 'UPDATE_DOWNLOAD_FAILED',
    );
  }

  Future<void> retryLastDownload({
    required void Function(UpdateProgress progress) onProgress,
  }) async {
    final release = _activeRelease;
    final file = _activeFile;
    if (release == null || file == null) {
      throw const UpdateException(
        message: 'No download to retry',
        code: 'UPDATE_RETRY_UNAVAILABLE',
      );
    }
    _cancelled = false;
    await download(release: release, target: file, onProgress: onProgress);
  }

  static bool _isGithubAssetApiUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return uri.host == 'api.github.com' &&
        uri.path.contains('/releases/assets/');
  }

  static bool _isGithubEntryHost(Uri uri) {
    final host = uri.host;
    return host == 'github.com' ||
        host == 'api.github.com' ||
        host.endsWith('.github.com');
  }

  static bool _isRetryableStatus(int status) {
    return status == 403 ||
        status == 404 ||
        status == 408 ||
        status == 425 ||
        status == 429 ||
        status >= 500;
  }

  static int _statusFromMessage(String message) {
    final match = RegExp(r'\((\d{3})\)').firstMatch(message);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }
}
