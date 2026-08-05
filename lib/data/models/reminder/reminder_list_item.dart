import 'package:equatable/equatable.dart';

import '../reminder.dart';

class ReminderListItem extends Equatable {
  const ReminderListItem({
    required this.reminder,
    required this.subtitle,
    required this.isOverdue,
  });

  final Reminder reminder;
  final String subtitle;
  final bool isOverdue;

  @override
  List<Object?> get props => [reminder, subtitle, isOverdue];
}
