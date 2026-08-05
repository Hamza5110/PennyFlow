import 'package:isar_community/isar.dart';

part 'expense.g.dart';

@collection
class Expense {
  Id id = Isar.autoIncrement;

  late double amount;

  @Index()
  late int categoryId;

  @Index()
  late int accountId;

  @Index()
  late DateTime date;

  String? notes;

  List<String> tags = [];

  String? location;

  List<String> receiptImagePaths = [];

  @Index()
  bool isDeleted = false;

  DateTime? deletedAt;

  int? recurringTemplateId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late int profileId;
}
