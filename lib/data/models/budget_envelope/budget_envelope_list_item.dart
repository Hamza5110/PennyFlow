import 'package:equatable/equatable.dart';

import '../../../core/utils/budget_period_utils.dart';
import '../budget_envelope.dart';

class EnvelopeFundingProgress extends Equatable {
  const EnvelopeFundingProgress({
    required this.accountId,
    required this.accountName,
    required this.funded,
    required this.spent,
  });

  final int accountId;
  final String accountName;
  final double funded;
  final double spent;

  double get remaining => (funded - spent).clamp(0, double.infinity);

  double get ratio => funded <= 0 ? 0 : spent / funded;

  @override
  List<Object?> get props => [accountId, accountName, funded, spent];
}

/// Envelope with computed spent/remaining for list and dashboard.
class BudgetEnvelopeListItem extends Equatable {
  const BudgetEnvelopeListItem({
    required this.envelope,
    required this.spent,
    required this.window,
    required this.fundingProgress,
  });

  final BudgetEnvelope envelope;
  final double spent;
  final BudgetPeriodWindow window;
  final List<EnvelopeFundingProgress> fundingProgress;

  double get target => envelope.totalAmount;

  double get remaining => (target - spent).clamp(0, double.infinity);

  double get ratio => target <= 0 ? 0 : spent / target;

  @override
  List<Object?> get props => [envelope, spent, window, fundingProgress];
}
