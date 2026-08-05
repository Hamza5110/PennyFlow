import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/category_icons.dart';
import 'package:penny_flow/data/models/category/category_input.dart';

void main() {
  group('CategoryIcons', () {
    test('palette and icon keys are non-empty', () {
      expect(CategoryIcons.colorPalette, isNotEmpty);
      expect(CategoryIcons.availableKeys, isNotEmpty);
    });

    test('default category icons resolve', () {
      expect(CategoryIcons.fromKey('restaurant'), isNotNull);
      expect(CategoryIcons.fromKey('unknown_key'), isNotNull);
    });

    test('parses hex colors', () {
      final color = CategoryIcons.parseColor('#F97316');
      expect(color.toARGB32(), greaterThan(0));
    });
  });

  group('CategoryInput', () {
    test('equality compares fields', () {
      const a = CategoryInput(
        name: 'Food',
        colorHex: '#F97316',
        iconKey: 'restaurant',
      );
      const b = CategoryInput(
        name: 'Food',
        colorHex: '#F97316',
        iconKey: 'restaurant',
      );
      expect(a, b);
    });
  });
}
