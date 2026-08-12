import 'package:equatable/equatable.dart';

import '../enums/app_enums.dart';

class EnvelopeFundingSplitInput extends Equatable {
  const EnvelopeFundingSplitInput({
    required this.accountId,
    required this.amount,
  });

  final int accountId;
  final double amount;

  @override
  List<Object?> get props => [accountId, amount];
}

class BudgetEnvelopeInput extends Equatable {
  const BudgetEnvelopeInput({
    required this.totalAmount,
    required this.periodType,
    required this.periodStart,
    required this.periodEnd,
    required this.fundingSplits,
    this.autoRepeat = true,
    this.warningThreshold = 0.8,
    this.recordFundingAsIncome = false,
  });

  final double totalAmount;
  final BudgetPeriodType periodType;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<EnvelopeFundingSplitInput> fundingSplits;
  final bool autoRepeat;
  final double warningThreshold;

  /// When true, posts income entries for each funding split.
  final bool recordFundingAsIncome;

  @override
  List<Object?> get props => [
        totalAmount,
        periodType,
        periodStart,
        periodEnd,
        fundingSplits,
        autoRepeat,
        warningThreshold,
        recordFundingAsIncome,
      ];
}
