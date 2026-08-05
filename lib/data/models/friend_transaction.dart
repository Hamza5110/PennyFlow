import 'package:isar_community/isar.dart';

part 'friend_transaction.g.dart';

@collection
class FriendTransaction {
  Id id = Isar.autoIncrement;

  @Index()
  late int friendId;

  /// `given` = money lent to friend; `received` = money borrowed from friend.
  late String type;

  late double amount;

  @Index()
  late DateTime date;

  DateTime? dueDate;

  String? notes;

  List<String> imagePaths = [];

  /// pending | partially_paid | completed
  @Index()
  late String status;

  @Index()
  bool isDeleted = false;

  DateTime? deletedAt;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late int profileId;
}
