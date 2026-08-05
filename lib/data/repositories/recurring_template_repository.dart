import 'package:isar_community/isar.dart';

import '../models/recurring_template.dart';
import 'isar_base_repository.dart';

class RecurringTemplateRepository extends IsarBaseRepository<RecurringTemplate> {
  RecurringTemplateRepository(super.db);

  @override
  IsarCollection<RecurringTemplate> get collection => isar.recurringTemplates;

  Future<List<RecurringTemplate>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByStartDateDesc()
            .findAll(),
      );

  Future<List<RecurringTemplate>> findDueByProfile(
    int profileId, {
    required DateTime through,
  }) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .isActiveEqualTo(true)
            .nextRunDateLessThan(through, include: true)
            .findAll(),
      );
}
