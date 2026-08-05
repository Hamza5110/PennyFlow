import 'package:equatable/equatable.dart';

import '../payment_account.dart';

/// Account row enriched with computed balance for list UI (FR-074).
class PaymentAccountListItem extends Equatable {
  const PaymentAccountListItem({
    required this.account,
    required this.balance,
    required this.transactionCount,
  });

  final PaymentAccount account;
  final double balance;
  final int transactionCount;

  @override
  List<Object?> get props => [account, balance, transactionCount];
}
