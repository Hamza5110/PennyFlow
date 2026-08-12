import 'package:flutter_test/flutter_test.dart';
import 'package:penny_flow/core/utils/budget_period_utils.dart';
import 'package:penny_flow/data/models/budget_envelope.dart';
import 'package:penny_flow/data/models/budget_envelope/budget_envelope_input.dart';
import 'package:penny_flow/data/models/budget_envelope/budget_envelope_list_item.dart';
import 'package:penny_flow/data/models/dashboard/budget_progress.dart';
import 'package:penny_flow/data/models/enums/app_enums.dart';

bool fundingSumsToTotal({
  required double total,
  required List<double> parts,
  double epsilon = 0.009,
}) {
  final sum = parts.fold<double>(0, (a, b) => a + b);
  return (sum - total).abs() <= epsilon;
}

void main() {
  group('BudgetEnvelopeInput', () {
    test('equality compares fields without category allocations', () {
      final start = DateTime(2026, 8, 1);
      final end = DateTime(2026, 8, 7, 23, 59, 59, 999);
      final a = BudgetEnvelopeInput(
        totalAmount: 3000,
        periodType: BudgetPeriodType.days7,
        periodStart: start,
        periodEnd: end,
        fundingSplits: const [
          EnvelopeFundingSplitInput(accountId: 1, amount: 2000),
          EnvelopeFundingSplitInput(accountId: 2, amount: 1000),
        ],
        recordFundingAsIncome: true,
      );
      final b = BudgetEnvelopeInput(
        totalAmount: 3000,
        periodType: BudgetPeriodType.days7,
        periodStart: start,
        periodEnd: end,
        fundingSplits: const [
          EnvelopeFundingSplitInput(accountId: 1, amount: 2000),
          EnvelopeFundingSplitInput(accountId: 2, amount: 1000),
        ],
        recordFundingAsIncome: true,
      );
      expect(a, b);
    });
  });

  group('envelope funding sums', () {
    test('funding must match total', () {
      expect(
        fundingSumsToTotal(total: 3000, parts: [2000, 1000]),
        isTrue,
      );
      expect(
        fundingSumsToTotal(total: 3000, parts: [1000, 1000]),
        isFalse,
      );
    });
  });

  group('BudgetEnvelopeListItem', () {
    test('computes ratio from total spent across all expenses', () {
      final envelope = BudgetEnvelope()
        ..totalAmount = 3000
        ..periodType = BudgetPeriodType.days7.name
        ..periodStart = DateTime(2026, 8, 1)
        ..periodEnd = DateTime(2026, 8, 7, 23, 59, 59, 999)
        ..autoRepeat = true
        ..profileId = 1
        ..fundingSplits = [
          EnvelopeFundingSplit()
            ..accountId = 1
            ..amount = 2000,
          EnvelopeFundingSplit()
            ..accountId = 2
            ..amount = 1000,
        ];

      final item = BudgetEnvelopeListItem(
        envelope: envelope,
        spent: 900,
        window: BudgetPeriodUtils.windowForEnvelope(envelope),
        fundingProgress: const [
          EnvelopeFundingProgress(
            accountId: 1,
            accountName: 'Cash',
            funded: 2000,
            spent: 600,
          ),
          EnvelopeFundingProgress(
            accountId: 2,
            accountName: 'JazzCash',
            funded: 1000,
            spent: 300,
          ),
        ],
      );

      expect(item.ratio, 0.3);
      expect(item.remaining, 2100);
      expect(item.fundingProgress.first.remaining, 1400);
    });
  });

  group('BudgetPeriodUtils envelope window', () {
    test('7-day auto-repeat advances for envelopes', () {
      final envelope = BudgetEnvelope()
        ..totalAmount = 3000
        ..periodType = BudgetPeriodType.days7.name
        ..periodStart = DateTime(2026, 8, 1)
        ..periodEnd = DateTime(2026, 8, 7, 23, 59, 59, 999)
        ..autoRepeat = true
        ..profileId = 1;

      final window = BudgetPeriodUtils.windowForEnvelope(
        envelope,
        reference: DateTime(2026, 8, 12),
      );
      expect(window.start, DateTime(2026, 8, 8));
      expect(window.end.day, 14);
    });
  });

  group('BudgetProgress envelope flag', () {
    test('marks envelope rows for dashboard', () {
      const progress = BudgetProgress(
        budgetId: 1,
        categoryName: 'Envelope',
        colorHex: '#0D9488',
        spent: 500,
        target: 3000,
        isEnvelope: true,
      );
      expect(progress.isEnvelope, isTrue);
      expect(progress.remaining, 2500);
    });
  });
}
