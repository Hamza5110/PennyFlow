import 'package:isar_community/isar.dart';

import '../models/category.dart';
import 'isar_base_repository.dart';

class CategoryRepository extends IsarBaseRepository<Category> {
  CategoryRepository(super.db);

  @override
  IsarCollection<Category> get collection => isar.categorys;

  Future<List<Category>> findByProfile(int profileId) => runRead(
        () => collection
            .filter()
            .profileIdEqualTo(profileId)
            .sortByName()
            .findAll(),
      );

  Future<Category?> findByName(int profileId, String name) => runRead(
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
