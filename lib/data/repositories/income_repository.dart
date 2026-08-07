import 'package:isar_community/isar.dart';

import '../../core/constants/app_constants.dart';
import '../models/income.dart';
import 'isar_base_repository.dart';

class IncomeRepository extends IsarBaseRepository<Income> {
  IncomeRepository(super.db);

  @override
  IsarCollection<Income> get collection => isar.incomes;

  Future<List<Income>> findActiveInRange(
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

  Future<List<Income>> findActiveByProfilePaged(
    int profileId, {
    int offset = 0,
    int limit = AppConstants.listPageSize,
    DateTime? start,
    DateTime? end,
    int? accountId,
  }) =>
      runRead(() async {
        if (accountId == null && start != null && end != null) {
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
        if (accountId != null) {
          query = query.accountIdEqualTo(accountId);
        }
        final results = await query.sortByDateDesc().findAll();
        final filtered = start != null && end != null
            ? results
                .where(
                  (income) =>
                      income.date.isAfter(
                        start.subtract(const Duration(milliseconds: 1)),
                      ) &&
                      income.date.isBefore(
                        end.add(const Duration(milliseconds: 1)),
                      ),
                )
                .toList()
            : results;
        final endIndex = (offset + limit).clamp(0, filtered.length);
        final startIndex = offset.clamp(0, filtered.length);
        return filtered.sublist(startIndex, endIndex);
      });

  Future<List<Income>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByDateDesc()
            .findAll(),
      );

  Future<List<Income>> findDeletedByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(true)
            .sortByDeletedAtDesc()
            .findAll(),
      );

  Future<List<Income>> findRecentByProfile(
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
          final incomes = await collection
              .filter()
              .profileIdEqualTo(profileId)
              .accountIdEqualTo(accountId)
              .isDeletedEqualTo(false)
              .findAll();
          return incomes.fold<double>(0, (sum, e) => sum + e.amount);
        },
      );

  Future<void> reassignAccount({
    required int fromAccountId,
    required int toAccountId,
    required int profileId,
  }) =>
      db.writeTxn(() async {
        final incomes = await collection
            .filter()
            .profileIdEqualTo(profileId)
            .accountIdEqualTo(fromAccountId)
            .findAll();
        for (final income in incomes) {
          income.accountId = toAccountId;
          income.updatedAt = DateTime.now();
          await collection.put(income);
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
