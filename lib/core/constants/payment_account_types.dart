/// Payment account type keys (FR-071).
abstract final class PaymentAccountTypes {
  static const String cash = 'cash';
  static const String bank = 'bank';
  static const String easypaisa = 'easypaisa';
  static const String jazzcash = 'jazzcash';
  static const String creditCard = 'credit_card';
  static const String custom = 'custom';

  static const List<String> predefinedKeys = [
    cash,
    bank,
    easypaisa,
    jazzcash,
    creditCard,
  ];

  static const Map<String, String> labelKeys = {
    cash: 'account_type_cash',
    bank: 'account_type_bank',
    easypaisa: 'account_type_easypaisa',
    jazzcash: 'account_type_jazzcash',
    creditCard: 'account_type_credit_card',
    custom: 'account_type_custom',
  };

  static bool isPredefinedKey(String type) => predefinedKeys.contains(type);
}
