import 'package:isar_community/isar.dart';

part 'payment_account.g.dart';

@collection
class PaymentAccount {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('profileId')], caseSensitive: false)
  late String name;

  late String type;

  double openingBalance = 0;

  bool isDefault = false;

  bool isArchived = false;

  @Index()
  late int profileId;
}
