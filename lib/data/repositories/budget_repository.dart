import 'package:isar_community/isar.dart';

import '../models/budget.dart';
import 'isar_base_repository.dart';

class BudgetRepository extends IsarBaseRepository<Budget> {
  BudgetRepository(super.db);

  @override
  IsarCollection<Budget> get collection => isar.budgets;

  Future<List<Budget>> findByProfileAndMonth(
    int profileId,
    int year,
    int month,
  ) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .yearEqualTo(year)
            .monthEqualTo(month)
            .findAll(),
      );

  Future<Budget?> findByCategoryMonth({
    required int profileId,
    required int categoryId,
    required int year,
    required int month,
  }) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(categoryId)
            .yearEqualTo(year)
            .monthEqualTo(month)
            .findFirst(),
      );

  Future<int> countByCategory(int categoryId, int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .categoryIdEqualTo(categoryId)
            .count(),
      );
}
