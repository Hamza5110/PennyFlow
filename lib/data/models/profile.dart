import 'package:isar_community/isar.dart';

part 'profile.g.dart';

/// Local user profile (SRS §20.1).
///
/// Each device may hold multiple profiles with isolated data partitions.
@collection
class Profile {
  Id id = Isar.autoIncrement;

  late String name;

  String? googleAccountEmail;

  String currencyCode = 'PKR';

  bool appLockEnabled = false;

  String? pinHash;

  bool biometricEnabled = false;

  DateTime createdAt = DateTime.now();
}
