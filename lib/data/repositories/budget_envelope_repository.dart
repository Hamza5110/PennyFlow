import 'package:isar_community/isar.dart';

import '../models/budget_envelope.dart';
import 'isar_base_repository.dart';

class BudgetEnvelopeRepository extends IsarBaseRepository<BudgetEnvelope> {
  BudgetEnvelopeRepository(super.db);

  @override
  IsarCollection<BudgetEnvelope> get collection => isar.budgetEnvelopes;

  Future<List<BudgetEnvelope>> findByProfile(int profileId) => runRead(
        () => collection.filter().profileIdEqualTo(profileId).findAll(),
      );
}
