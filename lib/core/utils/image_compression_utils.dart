import '../../core/constants/app_constants.dart';

/// Compression tuning for receipt images (FR-120).
abstract final class ImageCompressionUtils {
  static const List<int> qualitySteps = [75, 60, 45, 30];

  static const int initialQuality = 75;

  static int nextQuality(int current) {
    final index = qualitySteps.indexOf(current);
    if (index < 0 || index >= qualitySteps.length - 1) {
      return qualitySteps.last;
    }
    return qualitySteps[index + 1];
  }

  static bool exceedsMaxSize(int bytes) =>
      bytes > AppConstants.maxImageBytesAfterCompression;
}
