import 'package:equatable/equatable.dart';

/// Form input for creating or updating a recurring template.
class RecurringTemplateInput extends Equatable {
  const RecurringTemplateInput({
    required this.transactionType,
    required this.amount,
    required this.accountId,
    required this.frequency,
    required this.startDate,
    this.categoryId,
    this.source,
    this.notes,
    this.isActive = true,
  });

  final String transactionType;
  final double amount;
  final int? categoryId;
  final String? source;
  final int accountId;
  final String frequency;
  final DateTime startDate;
  final String? notes;
  final bool isActive;

  @override
  List<Object?> get props => [
        transactionType,
        amount,
        categoryId,
        source,
        accountId,
        frequency,
        startDate,
        notes,
        isActive,
      ];
}
