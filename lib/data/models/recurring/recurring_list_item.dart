import 'package:equatable/equatable.dart';

import '../recurring_template.dart';

class RecurringListItem extends Equatable {
  const RecurringListItem({
    required this.template,
    required this.label,
    required this.accountName,
  });

  final RecurringTemplate template;
  final String label;
  final String accountName;

  @override
  List<Object?> get props => [template, label, accountName];
}
