import 'package:flutter_test/flutter_test.dart';
import 'package:spend_vault/data/models/repayment.dart';
import 'package:spend_vault/data/repositories/repayment_repository.dart';

import '../support/isar_test_helper.dart';

void main() {
  late TestIsarHarness harness;
  late RepaymentRepository repository;

  setUp(() async {
    harness = await TestIsarHarness.open();
    repository = RepaymentRepository(harness.db);
  });

  tearDown(() async {
    await harness.dispose();
  });

  Repayment repayment({
    required int transactionId,
    required double amount,
  }) {
    return Repayment()
      ..friendTransactionId = transactionId
      ..amount = amount
      ..date = DateTime(2026, 3, 1);
  }

  group('RepaymentRepository', () {
    test('sumByTransaction totals repayments for one transaction', () async {
      await repository.put(repayment(transactionId: 7, amount: 50));
      await repository.put(repayment(transactionId: 7, amount: 25));
      await repository.put(repayment(transactionId: 8, amount: 10));

      final total = await repository.sumByTransaction(7);
      expect(total, 75);
    });

    test('sumByTransactionIds returns map for multiple transactions', () async {
      await repository.put(repayment(transactionId: 1, amount: 10));
      await repository.put(repayment(transactionId: 1, amount: 5));
      await repository.put(repayment(transactionId: 2, amount: 20));
      await repository.put(repayment(transactionId: 3, amount: 99));

      final totals = await repository.sumByTransactionIds([1, 2, 4]);
      expect(totals[1], 15);
      expect(totals[2], 20);
      expect(totals.containsKey(3), isFalse);
      expect(totals.containsKey(4), isFalse);
    });
  });
}
