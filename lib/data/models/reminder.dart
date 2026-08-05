import 'package:isar_community/isar.dart';

part 'reminder.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  /// bill_due | friend_payment_due | subscription_renewal | insurance | custom
  @Index()
  late String type;

  late String title;

  String? notes;

  @Index()
  late DateTime scheduledAt;

  @Index()
  int? linkedFriendTransactionId;

  @Index()
  bool isCompleted = false;

  @Index()
  bool isDeleted = false;

  DateTime? deletedAt;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late int profileId;
}
