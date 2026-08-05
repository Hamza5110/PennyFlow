import 'package:equatable/equatable.dart';

/// Form / service input for creating or updating an expense.
class ExpenseInput extends Equatable {
  const ExpenseInput({
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.notes,
    this.tags = const [],
    this.location,
    this.receiptImagePaths = const [],
  });

  final double amount;
  final int categoryId;
  final int accountId;
  final DateTime date;
  final String? notes;
  final List<String> tags;
  final String? location;
  final List<String> receiptImagePaths;

  ExpenseInput copyWith({
    double? amount,
    int? categoryId,
    int? accountId,
    DateTime? date,
    String? notes,
    List<String>? tags,
    String? location,
    List<String>? receiptImagePaths,
  }) {
    return ExpenseInput(
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      receiptImagePaths: receiptImagePaths ?? this.receiptImagePaths,
    );
  }

  @override
  List<Object?> get props => [
        amount,
        categoryId,
        accountId,
        date,
        notes,
        tags,
        location,
        receiptImagePaths,
      ];
}
