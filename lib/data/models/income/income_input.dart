import 'package:equatable/equatable.dart';

/// Form / service input for creating or updating income.
class IncomeInput extends Equatable {
  const IncomeInput({
    required this.amount,
    required this.source,
    required this.accountId,
    required this.date,
    this.notes,
    this.imagePaths = const [],
  });

  final double amount;
  final String source;
  final int accountId;
  final DateTime date;
  final String? notes;
  final List<String> imagePaths;

  @override
  List<Object?> get props => [amount, source, accountId, date, notes, imagePaths];
}
