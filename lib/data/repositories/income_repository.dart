import 'package:isar_community/isar.dart';

import '../models/income.dart';
import 'isar_base_repository.dart';

class IncomeRepository extends IsarBaseRepository<Income> {
  IncomeRepository(super.db);

  @override
  IsarCollection<Income> get collection => isar.incomes;

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
