import 'package:equatable/equatable.dart';

class RepaymentInput extends Equatable {
  const RepaymentInput({
    required this.amount,
    required this.date,
    this.note,
    this.imagePaths = const [],
  });

  final double amount;
  final DateTime date;
  final String? note;
  final List<String> imagePaths;

  @override
  List<Object?> get props => [amount, date, note, imagePaths];
}
