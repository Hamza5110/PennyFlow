import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/data/models/expense.dart';
import 'package:penny_flow/data/repositories/expense_repository.dart';

import '../support/isar_test_helper.dart';

void main() {
  late TestIsarHarness harness;
  late ExpenseRepository repository;

  setUp(() async {
    harness = await TestIsarHarness.open();
    repository = ExpenseRepository(harness.db);
  });

  tearDown(() async {
    await harness.dispose();
  });

  Expense _expense({
    required int profileId,
    required double amount,
    required DateTime date,
    int categoryId = 1,
    int accountId = 1,
    bool deleted = false,
  }) {
    return Expense()
      ..profileId = profileId
      ..amount = amount
      ..categoryId = categoryId
      ..accountId = accountId
      ..date = date
      ..isDeleted = deleted;
  }

  group('ExpenseRepository', () {
    test('findActiveByProfile returns only active rows for profile', () async {
      await repository.put(
        _expense(profileId: 1, amount: 100, date: DateTime(2026, 3, 1)),
      );
      await repository.put(
        _expense(
          profileId: 1,
          amount: 50,
          date: DateTime(2026, 3, 2),
          deleted: true,
        ),
      );
      await repository.put(
        _expense(profileId: 2, amount: 75, date: DateTime(2026, 3, 3)),
      );

      final results = await repository.findActiveByProfile(1);
      expect(results, hasLength(1));
      expect(results.first.amount, 100);
    });

    test('findActiveInRange filters by date window', () async {
      await repository.put(
        _expense(profileId: 1, amount: 10, date: DateTime(2026, 3, 1)),
      );
      await repository.put(
        _expense(profileId: 1, amount: 20, date: DateTime(2026, 3, 15)),
      );
      await repository.put(
        _expense(profileId: 1, amount: 30, date: DateTime(2026, 4, 1)),
      );

      final results = await repository.findActiveInRange(
        1,
        DateTime(2026, 3, 1),
        DateTime(2026, 3, 31, 23, 59, 59),
      );

      expect(results, hasLength(2));
      expect(results.map((e) => e.amount), containsAll([10.0, 20.0]));
    });

    test('findActiveByProfilePaged returns limited window', () async {
      for (var i = 1; i <= 5; i++) {
        await repository.put(
          _expense(
            profileId: 1,
            amount: i.toDouble(),
            date: DateTime(2026, 3, i),
          ),
        );
      }

      final page = await repository.findActiveByProfilePaged(
        1,
        offset: 0,
        limit: 2,
      );
      expect(page, hasLength(2));
      expect(page.first.amount, greaterThan(page.last.amount));
    });

    test('sumActiveByCategoryInMonthBatch aggregates per category', () async {
      await repository.put(
        _expense(
          profileId: 1,
          amount: 100,
          date: DateTime(2026, 3, 5),
          categoryId: 10,
        ),
      );
      await repository.put(
        _expense(
          profileId: 1,
          amount: 40,
          date: DateTime(2026, 3, 10),
          categoryId: 10,
        ),
      );
      await repository.put(
        _expense(
          profileId: 1,
          amount: 25,
          date: DateTime(2026, 3, 12),
          categoryId: 20,
        ),
      );
      await repository.put(
        _expense(
          profileId: 1,
          amount: 999,
          date: DateTime(2026, 4, 1),
          categoryId: 10,
        ),
      );

      final totals = await repository.sumActiveByCategoryInMonthBatch(
        profileId: 1,
        year: 2026,
        month: 3,
      );

      expect(totals[10], 140);
      expect(totals[20], 25);
    });
  });
}
