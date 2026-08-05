import 'package:isar_community/isar.dart';

part 'friend.g.dart';

@collection
class Friend {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('profileId')], caseSensitive: false)
  late String name;

  String? phone;

  @Index()
  late int profileId;
}
