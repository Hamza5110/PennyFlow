import 'package:equatable/equatable.dart';

class FriendTransactionInput extends Equatable {
  const FriendTransactionInput({
    required this.friendId,
    required this.type,
    required this.amount,
    required this.date,
    this.dueDate,
    this.notes,
    this.imagePaths = const [],
  });

  final int friendId;
  final String type;
  final double amount;
  final DateTime date;
  final DateTime? dueDate;
  final String? notes;
  final List<String> imagePaths;

  @override
  List<Object?> get props =>
      [friendId, type, amount, date, dueDate, notes, imagePaths];
}
