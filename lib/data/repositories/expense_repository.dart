import 'package:isar_community/isar.dart';

import '../models/expense.dart';
import 'isar_base_repository.dart';

class ExpenseRepository extends IsarBaseRepository<Expense> {
  ExpenseRepository(super.db);

  @override
  IsarCollection<Expense> get collection => isar.expenses;

  Future<List<Expense>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByDateDesc()
            .findAll(),
      );

  Future<List<Expense>> findDeletedByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(true)
            .sortByDeletedAtDesc()
            .findAll(),
      );

  Future<List<Expense>> findRecentByProfile(
    int profileId, {
    int limit = 10,
  }) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByDateDesc()
            .limit(limit)
            .findAll(),
      );

  Future<int> countActiveByCategory(int categoryId, int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(categoryId)
            .isDeletedEqualTo(false)
            .count(),
      );

  Future<void> reassignCategory({
    required int fromCategoryId,
    required int toCategoryId,
    required int profileId,
  }) =>
      db.writeTxn(() async {
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(fromCategoryId)
            .findAll();
        for (final expense in expenses) {
          expense.categoryId = toCategoryId;
          expense.updatedAt = DateTime.now();
          await collection.put(expense);
        }
      });

  Future<int> countActiveByAccount(int accountId, int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .accountIdEqualTo(accountId)
            .isDeletedEqualTo(false)
            .count(),
      );

  Future<double> sumActiveByAccount(int accountId, int profileId) => runRead(
        () async {
          final expenses = await collection
              .filter()
              .profileIdEqualTo(profileId)
              .accountIdEqualTo(accountId)
              .isDeletedEqualTo(false)
              .findAll();
          return expenses.fold<double>(0, (sum, e) => sum + e.amount);
        },
      );

  Future<double> sumActiveByCategoryInMonth({
    required int profileId,
    required int categoryId,
    required int year,
    required int month,
  }) =>
      runRead(() async {
        final start = DateTime(year, month);
        final end = DateTime(year, month + 1).subtract(
          const Duration(milliseconds: 1),
        );
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(categoryId)
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .findAll();
        return expenses.fold<double>(0, (sum, e) => sum + e.amount);
      });

  Future<void> reassignAccount({
    required int fromAccountId,
    required int toAccountId,
    required int profileId,
  }) =>
      db.writeTxn(() async {
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .accountIdEqualTo(fromAccountId)
            .findAll();
        for (final expense in expenses) {
          expense.accountId = toAccountId;
          expense.updatedAt = DateTime.now();
          await collection.put(expense);
        }
      });
}
