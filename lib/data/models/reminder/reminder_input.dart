import 'package:equatable/equatable.dart';

/// Form input for creating or updating a reminder.
class ReminderInput extends Equatable {
  const ReminderInput({
    required this.type,
    required this.title,
    required this.scheduledAt,
    this.notes,
    this.linkedFriendTransactionId,
  });

  final String type;
  final String title;
  final DateTime scheduledAt;
  final String? notes;
  final int? linkedFriendTransactionId;

  @override
  List<Object?> get props =>
      [type, title, scheduledAt, notes, linkedFriendTransactionId];
}
