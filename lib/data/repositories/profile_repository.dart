import 'package:isar_community/isar.dart';

import '../models/profile.dart';
import 'isar_base_repository.dart';

class ProfileRepository extends IsarBaseRepository<Profile> {
  ProfileRepository(super.db);

  @override
  IsarCollection<Profile> get collection => isar.profiles;

  Future<Profile?> findFirst() => runRead(() => collection.where().findFirst());

  Future<List<Profile>> findAllOrdered() => runRead(
        () => collection.where().sortByCreatedAt().findAll(),
      );

  Future<int> countProfiles() => runRead(() => collection.count());
}
