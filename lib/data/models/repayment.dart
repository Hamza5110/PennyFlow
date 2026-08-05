import 'package:isar_community/isar.dart';

part 'repayment.g.dart';

@collection
class Repayment {
  Id id = Isar.autoIncrement;

  @Index()
  late int friendTransactionId;

  late double amount;

  late DateTime date;

  String? note;

  List<String> imagePaths = [];

  DateTime createdAt = DateTime.now();
}
