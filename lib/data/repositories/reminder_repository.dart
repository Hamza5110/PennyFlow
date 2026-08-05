import 'package:isar_community/isar.dart';

import '../models/reminder.dart';
import 'isar_base_repository.dart';

class ReminderRepository extends IsarBaseRepository<Reminder> {
  ReminderRepository(super.db);

  @override
  IsarCollection<Reminder> get collection => isar.reminders;

  Future<List<Reminder>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByScheduledAt()
            .findAll(),
      );

  Future<List<Reminder>> findPendingByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .isCompletedEqualTo(false)
            .sortByScheduledAt()
            .findAll(),
      );

  Future<Reminder?> findByLinkedFriendTransaction(
    int profileId,
    int transactionId,
  ) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .linkedFriendTransactionIdEqualTo(transactionId)
            .isDeletedEqualTo(false)
            .findFirst(),
      );
}
