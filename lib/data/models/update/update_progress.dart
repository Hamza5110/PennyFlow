/// Download progress for the in-app updater UI (FR-171).
enum UpdateDownloadPhase {
  idle,
  checking,
  downloading,
  paused,
  verifying,
  readyToInstall,
  installing,
  failed,
}

class UpdateProgress {
  const UpdateProgress({
    required this.phase,
    this.receivedBytes = 0,
    this.totalBytes = 0,
    this.speedBytesPerSecond = 0,
  });

  final UpdateDownloadPhase phase;
  final int receivedBytes;
  final int totalBytes;
  final double speedBytesPerSecond;

  double get percent =>
      totalBytes <= 0 ? 0 : (receivedBytes / totalBytes).clamp(0.0, 1.0);

  int get remainingBytes =>
      totalBytes > receivedBytes ? totalBytes - receivedBytes : 0;
}
