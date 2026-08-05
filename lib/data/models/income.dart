import 'package:isar_community/isar.dart';

part 'income.g.dart';

@collection
class Income {
  Id id = Isar.autoIncrement;

  late double amount;

  /// Predefined key (salary, freelance, …) or free-text custom source (FR-036).
  @Index()
  late String source;

  @Index()
  late int accountId;

  @Index()
  late DateTime date;

  String? notes;

  List<String> imagePaths = [];

  @Index()
  bool isDeleted = false;

  DateTime? deletedAt;

  int? recurringTemplateId;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late int profileId;
}
