import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../data/models/update/release_info.dart';
import '../../data/models/update/update_progress.dart';

/// Resumable APK downloader with pause/resume support (FR-171–FR-172).
class ApkDownloadManager {
  ApkDownloadManager({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

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

    onProgress(
      UpdateProgress(
        phase: UpdateDownloadPhase.downloading,
        receivedBytes: received,
        totalBytes: total,
      ),
    );

    while (!_cancelled) {
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

      final request = http.Request('GET', Uri.parse(release.apkDownloadUrl));
      if (received > 0) {
        request.headers['Range'] = 'bytes=$received-';
      }

      final streamed = await _client
          .send(request)
          .timeout(AppConstants.networkTimeout);

      if (streamed.statusCode != 200 && streamed.statusCode != 206) {
        throw UpdateException(
          message: 'Download failed (${streamed.statusCode})',
          code: 'UPDATE_DOWNLOAD_FAILED',
        );
      }

      if (streamed.statusCode == 200 && received > 0) {
        received = 0;
        await target.writeAsBytes([], flush: true);
      }

      final resolvedTotal =
          streamed.contentLength != null && streamed.contentLength! > 0
              ? received + streamed.contentLength!
              : total;

      final sink = target.openWrite(mode: FileMode.append);
      try {
        await for (final chunk in streamed.stream) {
          while (_paused && !_cancelled) {
            onProgress(
              UpdateProgress(
                phase: UpdateDownloadPhase.paused,
                receivedBytes: received,
                totalBytes: resolvedTotal,
              ),
            );
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
            lastTick = now;
            lastReceived = received;
          }

          onProgress(
            UpdateProgress(
              phase: UpdateDownloadPhase.downloading,
              receivedBytes: received,
              totalBytes: resolvedTotal,
              speedBytesPerSecond: speed,
            ),
          );
        }
      } finally {
        await sink.close();
      }

      if (_cancelled) break;

      if (release.apkSizeBytes > 0 && received < release.apkSizeBytes) {
        continue;
      }
      break;
    }

    if (_cancelled) {
      throw const UpdateException(
        message: 'Download cancelled',
        code: 'UPDATE_DOWNLOAD_CANCELLED',
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
}
