import 'package:isar_community/isar.dart';

import '../models/payment_account.dart';
import 'isar_base_repository.dart';

class PaymentAccountRepository extends IsarBaseRepository<PaymentAccount> {
  PaymentAccountRepository(super.db);

  @override
  IsarCollection<PaymentAccount> get collection => isar.paymentAccounts;

  Future<List<PaymentAccount>> findByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .sortByName()
            .findAll(),
      );

  Future<List<PaymentAccount>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isArchivedEqualTo(false)
            .sortByName()
            .findAll(),
      );

  Future<List<PaymentAccount>> findArchivedByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isArchivedEqualTo(true)
            .sortByName()
            .findAll(),
      );

  Future<PaymentAccount?> findByName(int profileId, String name) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .nameEqualTo(name, caseSensitive: false)
            .findFirst(),
      );

  Future<int> countByProfile(int profileId) => runRead(
        () => collection.filter().profileIdEqualTo(profileId).count(),
      );
}
