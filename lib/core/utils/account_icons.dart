import 'package:flutter/material.dart';

import '../constants/payment_account_types.dart';

abstract final class AccountIcons {
  static IconData fromType(String type) {
    switch (type) {
      case PaymentAccountTypes.cash:
        return Icons.payments_outlined;
      case PaymentAccountTypes.bank:
        return Icons.account_balance_outlined;
      case PaymentAccountTypes.easypaisa:
      case PaymentAccountTypes.jazzcash:
        return Icons.phone_android_outlined;
      case PaymentAccountTypes.creditCard:
        return Icons.credit_card_outlined;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}
