import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/constants/settings_constants.dart';

void main() {
  group('SettingsConstants', () {
    test('supported currencies include PKR and USD', () {
      expect(SettingsConstants.supportedCurrencyCodes, contains('PKR'));
      expect(SettingsConstants.supportedCurrencyCodes, contains('USD'));
    });

    test('theme mode options include system light and dark', () {
      expect(SettingsConstants.themeModeOptions.length, 3);
    });

    test('theme variants include multiple palettes', () {
      expect(SettingsConstants.themeVariants.length, greaterThan(1));
    });
  });
}
