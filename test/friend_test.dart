import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/core/constants/friend_constants.dart';
import 'package:spend_vault/data/models/friend/friend_input.dart';
import 'package:spend_vault/data/models/friend/friend_transaction_input.dart';
import 'package:spend_vault/data/models/friend/repayment_input.dart';

void main() {
  group('FriendTransactionTypes', () {
    test('includes given and received', () {
      expect(FriendTransactionTypes.given, 'given');
      expect(FriendTransactionTypes.received, 'received');
    });
  });

  group('FriendTransactionStatus', () {
    test('includes pending partial and completed', () {
      expect(FriendTransactionStatus.pending, 'pending');
      expect(FriendTransactionStatus.partiallyPaid, 'partially_paid');
      expect(FriendTransactionStatus.completed, 'completed');
    });
  });

  group('FriendInput', () {
    test('equality compares fields', () {
      const a = FriendInput(name: 'Ali', phone: '0300');
      const b = FriendInput(name: 'Ali', phone: '0300');
      expect(a, b);
    });
  });

  group('FriendTransactionInput', () {
    test('equality compares fields', () {
      final date = DateTime(2026, 1, 1);
      final a = FriendTransactionInput(
        friendId: 1,
        type: FriendTransactionTypes.given,
        amount: 500,
        date: date,
      );
      final b = FriendTransactionInput(
        friendId: 1,
        type: FriendTransactionTypes.given,
        amount: 500,
        date: date,
      );
      expect(a, b);
    });
  });

  group('RepaymentInput', () {
    test('equality compares fields', () {
      final date = DateTime(2026, 1, 2);
      final a = RepaymentInput(amount: 100, date: date);
      final b = RepaymentInput(amount: 100, date: date);
      expect(a, b);
    });
  });
}
