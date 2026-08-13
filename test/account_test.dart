import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/constants/payment_account_types.dart';
import 'package:spend_vault/core/utils/account_icons.dart';
import 'package:spend_vault/data/models/payment_account/payment_account_input.dart';

void main() {
  group('PaymentAccountTypes', () {
    test('predefined keys are recognized', () {
      expect(PaymentAccountTypes.isPredefinedKey(PaymentAccountTypes.cash), isTrue);
      expect(PaymentAccountTypes.isPredefinedKey('wallet'), isFalse);
    });

    test('includes all default account types', () {
      expect(PaymentAccountTypes.predefinedKeys, hasLength(5));
    });
  });

  group('AccountIcons', () {
    test('resolves icons for account types', () {
      expect(AccountIcons.fromType(PaymentAccountTypes.bank), isNotNull);
      expect(AccountIcons.fromType('unknown'), isNotNull);
    });
  });

  group('PaymentAccountInput', () {
    test('equality compares fields', () {
      const a = PaymentAccountInput(
        name: 'Cash',
        type: PaymentAccountTypes.cash,
        openingBalance: 1000,
      );
      const b = PaymentAccountInput(
        name: 'Cash',
        type: PaymentAccountTypes.cash,
        openingBalance: 1000,
      );
      expect(a, b);
    });
  });
}
