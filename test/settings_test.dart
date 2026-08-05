import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/constants/settings_constants.dart';

void main() {
  group('SettingsConstants', () {
    test('supported currencies include PKR and USD', () {
      expect(SettingsConstants.supportedCurrencyCodes, contains('PKR'));
      expect(SettingsConstants.supportedCurrencyCodes, contains('USD'));
    });

    test('theme options include system light and dark', () {
      expect(SettingsConstants.themeOptions.length, 3);
    });
  });
}
