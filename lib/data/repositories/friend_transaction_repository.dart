import 'package:isar_community/isar.dart';

import '../models/friend_transaction.dart';
import 'isar_base_repository.dart';

class FriendTransactionRepository extends IsarBaseRepository<FriendTransaction> {
  FriendTransactionRepository(super.db);

  @override
  IsarCollection<FriendTransaction> get collection => isar.friendTransactions;

  Future<List<FriendTransaction>> findActiveByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(false)
            .sortByDateDesc()
            .findAll(),
      );

  Future<List<FriendTransaction>> findActiveByFriend(int friendId) => runRead(
        () => collection
            .filter()
            .friendIdEqualTo(friendId)
            .isDeletedEqualTo(false)
            .sortByDateDesc()
            .findAll(),
      );

  Future<List<FriendTransaction>> findDeletedByProfile(int profileId) =>
      runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .isDeletedEqualTo(true)
            .sortByDeletedAtDesc()
            .findAll(),
      );

  Future<int> countActiveByFriend(int friendId) => runRead(
        () => collection
            .filter()
            .friendIdEqualTo(friendId)
            .isDeletedEqualTo(false)
            .count(),
      );
}
