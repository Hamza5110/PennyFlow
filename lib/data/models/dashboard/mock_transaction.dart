import 'package:equatable/equatable.dart';

enum MockTransactionType { expense, income }

/// In-memory transaction used by the Phase 3 mock dashboard repository.
class MockTransaction extends Equatable {
  const MockTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.title,
    required this.categoryName,
    required this.categoryColorHex,
    required this.accountName,
    required this.date,
  });

  final String id;
  final MockTransactionType type;
  final double amount;
  final String title;
  final String categoryName;
  final String categoryColorHex;
  final String accountName;
  final DateTime date;

  bool get isExpense => type == MockTransactionType.expense;

  @override
  List<Object?> get props => [
        id,
        type,
        amount,
        title,
        categoryName,
        categoryColorHex,
        accountName,
        date,
      ];
}
