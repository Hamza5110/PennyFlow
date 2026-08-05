import 'package:isar_community/isar.dart';

part 'category.g.dart';

@collection
class Category {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('profileId')], caseSensitive: false)
  late String name;

  late String colorHex;

  late String iconKey;

  bool isDefault = false;

  @Index()
  late int profileId;
}
