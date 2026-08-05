import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/constants/app_constants.dart';
import 'package:penny_flow/core/utils/image_compression_utils.dart';

void main() {
  group('ImageCompressionUtils', () {
    test('nextQuality steps down through quality levels', () {
      expect(
        ImageCompressionUtils.nextQuality(75),
        60,
      );
      expect(
        ImageCompressionUtils.nextQuality(60),
        45,
      );
      expect(
        ImageCompressionUtils.nextQuality(45),
        30,
      );
      expect(
        ImageCompressionUtils.nextQuality(30),
        30,
      );
    });

    test('exceedsMaxSize uses app constant', () {
      expect(
        ImageCompressionUtils.exceedsMaxSize(
          AppConstants.maxImageBytesAfterCompression + 1,
        ),
        isTrue,
      );
      expect(
        ImageCompressionUtils.exceedsMaxSize(
          AppConstants.maxImageBytesAfterCompression,
        ),
        isFalse,
      );
    });
  });
}
