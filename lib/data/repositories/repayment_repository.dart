import 'package:isar_community/isar.dart';

import '../models/repayment.dart';
import 'isar_base_repository.dart';

class RepaymentRepository extends IsarBaseRepository<Repayment> {
  RepaymentRepository(super.db);

  @override
  IsarCollection<Repayment> get collection => isar.repayments;

  Future<List<Repayment>> findByTransaction(int transactionId) => runRead(
        () => collection
            .filter()
            .friendTransactionIdEqualTo(transactionId)
            .sortByDateDesc()
            .findAll(),
      );

  Future<double> sumByTransaction(int transactionId) => runRead(() async {
        final repayments = await findByTransaction(transactionId);
        return repayments.fold<double>(0, (sum, r) => sum + r.amount);
      });

  /// Batch repayment totals keyed by friend transaction id.
  Future<Map<int, double>> sumByTransactionIds(List<int> transactionIds) =>
      runRead(() async {
        if (transactionIds.isEmpty) return {};
        final idSet = transactionIds.toSet();
        final repayments = await collection.where().findAll();
        final totals = <int, double>{};
        for (final repayment in repayments) {
          if (!idSet.contains(repayment.friendTransactionId)) continue;
          totals[repayment.friendTransactionId] =
              (totals[repayment.friendTransactionId] ?? 0) + repayment.amount;
        }
        return totals;
      });

  Future<void> deleteByTransaction(int transactionId) => db.writeTxn(() async {
        final repayments = await collection
            .filter()
            .friendTransactionIdEqualTo(transactionId)
            .findAll();
        for (final repayment in repayments) {
          await collection.delete(repayment.id);
        }
      });
}
