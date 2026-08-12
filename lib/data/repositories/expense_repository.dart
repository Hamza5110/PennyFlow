import 'package:isar_community/isar.dart';

import '../../core/constants/app_constants.dart';
import '../models/expense.dart';
import 'isar_base_repository.dart';

class ExpenseRepository extends IsarBaseRepository<Expense> {
  ExpenseRepository(super.db);

  @override
  IsarCollection<Expense> get collection => isar.expenses;

  Future<List<Expense>> findActiveInRange(
    int profileId,
    DateTime start,
    DateTime end,
  ) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .sortByDateDesc()
            .findAll(),
      );

  Future<List<Expense>> findActiveByProfilePaged(
    int profileId, {
    int offset = 0,
    int limit = AppConstants.listPageSize,
    DateTime? start,
    DateTime? end,
    int? categoryId,
    int? accountId,
  }) =>
      runRead(() async {
        if (categoryId == null &&
            accountId == null &&
            start != null &&
            end != null) {
          return collection
              .filter()
              .profileIdEqualTo(profileId)
              .isDeletedEqualTo(false)
              .dateBetween(start, end)
              .sortByDateDesc()
              .offset(offset)
              .limit(limit)
              .findAll();
        }

        var query = collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false);
        if (categoryId != null) {
          query = query.categoryIdEqualTo(categoryId);
        }
        if (accountId != null) {
          query = query.accountIdEqualTo(accountId);
        }
        final results = await query.sortByDateDesc().findAll();
        final filtered = start != null && end != null
            ? results
                .where((e) => e.date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
                    e.date.isBefore(end.add(const Duration(milliseconds: 1))))
                .toList()
            : results;
        final endIndex = (offset + limit).clamp(0, filtered.length);
        final startIndex = offset.clamp(0, filtered.length);
        return filtered.sublist(startIndex, endIndex);
      });

  Future<Map<int, double>> sumActiveByCategoryInMonthBatch({
    required int profileId,
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
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .findAll();
        final totals = <int, double>{};
        for (final expense in expenses) {
          totals[expense.categoryId] =
              (totals[expense.categoryId] ?? 0) + expense.amount;
        }
        return totals;
      });

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
  }) {
    final start = DateTime(year, month);
    final end = DateTime(year, month + 1).subtract(
      const Duration(milliseconds: 1),
    );
    return sumActiveByCategoryInRange(
      profileId: profileId,
      categoryId: categoryId,
      start: start,
      end: end,
    );
  }

  Future<double> sumActiveByCategoryInRange({
    required int profileId,
    required int categoryId,
    required DateTime start,
    required DateTime end,
  }) =>
      runRead(() async {
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(categoryId)
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .findAll();
        return expenses.fold<double>(0, (sum, e) => sum + e.amount);
      });

  Future<double> sumActiveByAccountInRange({
    required int profileId,
    required int accountId,
    required DateTime start,
    required DateTime end,
  }) =>
      runRead(() async {
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .accountIdEqualTo(accountId)
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .findAll();
        return expenses.fold<double>(0, (sum, e) => sum + e.amount);
      });

  Future<double> sumActiveInRange({
    required int profileId,
    required DateTime start,
    required DateTime end,
  }) =>
      runRead(() async {
        final expenses = await collection
            .filter()
            .profileIdEqualTo(profileId)
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

  Future<bool> existsForTemplateOnDate({
    required int profileId,
    required int templateId,
    required DateTime date,
  }) =>
      runRead(() async {
        final start = DateTime(date.year, date.month, date.day);
        final end = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
        final count = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .recurringTemplateIdEqualTo(templateId)
            .isDeletedEqualTo(false)
            .dateBetween(start, end)
            .count();
        return count > 0;
      });
}
