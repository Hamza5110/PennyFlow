import 'package:isar_community/isar.dart';

import '../models/friend.dart';
import 'isar_base_repository.dart';

class FriendRepository extends IsarBaseRepository<Friend> {
  FriendRepository(super.db);

  @override
  IsarCollection<Friend> get collection => isar.friends;

  Future<List<Friend>> findByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .sortByName()
            .findAll(),
      );

  Future<Friend?> findByName(int profileId, String name) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .nameEqualTo(name, caseSensitive: false)
            .findFirst(),
      );
}
