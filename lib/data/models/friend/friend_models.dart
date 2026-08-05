import 'package:equatable/equatable.dart';

import '../../../core/utils/app_date_utils.dart';
import '../friend.dart';
import '../friend_transaction.dart';

class FriendFilter extends Equatable {
  const FriendFilter({
    this.searchQuery = '',
    this.status,
    this.datePeriod,
    this.customRange,
    this.friendId,
  });

  final String searchQuery;
  final String? status;
  final DatePeriod? datePeriod;
  final DateRange? customRange;
  final int? friendId;

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      status != null ||
      datePeriod != null ||
      customRange != null ||
      friendId != null;

  FriendFilter copyWith({
    String? searchQuery,
    String? status,
    DatePeriod? datePeriod,
    DateRange? customRange,
    int? friendId,
    bool clearStatus = false,
    bool clearDate = false,
    bool clearFriend = false,
  }) {
    return FriendFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: clearStatus ? null : (status ?? this.status),
      datePeriod: clearDate ? null : (datePeriod ?? this.datePeriod),
      customRange: clearDate ? null : (customRange ?? this.customRange),
      friendId: clearFriend ? null : (friendId ?? this.friendId),
    );
  }

  static const empty = FriendFilter();

  @override
  List<Object?> get props =>
      [searchQuery, status, datePeriod, customRange, friendId];
}

class FriendListItem extends Equatable {
  const FriendListItem({
    required this.friend,
    required this.netPendingBalance,
    required this.pendingReceive,
    required this.pendingPay,
    required this.transactionCount,
  });

  final Friend friend;
  final double netPendingBalance;
  final double pendingReceive;
  final double pendingPay;
  final int transactionCount;

  @override
  List<Object?> get props =>
      [friend, netPendingBalance, pendingReceive, pendingPay, transactionCount];
}

class FriendTransactionListItem extends Equatable {
  const FriendTransactionListItem({
    required this.transaction,
    required this.friendName,
    required this.remainingBalance,
    required this.repaymentTotal,
  });

  final FriendTransaction transaction;
  final String friendName;
  final double remainingBalance;
  final double repaymentTotal;

  @override
  List<Object?> get props =>
      [transaction, friendName, remainingBalance, repaymentTotal];
}

class FriendLedgerSummary extends Equatable {
  const FriendLedgerSummary({
    required this.moneyLent,
    required this.moneyBorrowed,
    required this.pendingReceive,
    required this.pendingPay,
  });

  final double moneyLent;
  final double moneyBorrowed;
  final double pendingReceive;
  final double pendingPay;

  @override
  List<Object?> get props =>
      [moneyLent, moneyBorrowed, pendingReceive, pendingPay];
}
