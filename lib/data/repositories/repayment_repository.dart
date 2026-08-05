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
