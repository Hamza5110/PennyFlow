import 'package:isar_community/isar.dart';

part 'recurring_template.g.dart';

@collection
class RecurringTemplate {
  Id id = Isar.autoIncrement;

  /// `expense` or `income`.
  @Index()
  late String transactionType;

  late double amount;

  @Index()
  int? categoryId;

  /// Income source key or custom label (income templates).
  String? source;

  @Index()
  late int accountId;

  /// `daily` | `weekly` | `monthly` | `yearly`.
  late String frequency;

  String? notes;

  @Index()
  late DateTime startDate;

  @Index()
  DateTime? nextRunDate;

  @Index()
  bool isActive = true;

  @Index()
  bool isDeleted = false;

  DateTime? deletedAt;

  DateTime createdAt = DateTime.now();

  DateTime updatedAt = DateTime.now();

  @Index()
  late int profileId;
}
