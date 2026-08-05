import 'package:get/get.dart';

import '../../core/base/base_service.dart';
import '../../core/constants/income_sources.dart';
import '../../data/models/dashboard/dashboard_period.dart';
import '../../data/models/dashboard/dashboard_summary.dart';
import '../../data/models/dashboard/dashboard_transaction.dart';
import '../../data/models/dashboard/budget_progress.dart';
import '../../data/models/dashboard/monthly_spending_point.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../settings/settings_service.dart';

/// Dashboard business logic backed by real expense/income data (Phase 5).
class DashboardService extends GetxService with BaseService {
  DashboardService(this._repository, this._settings);

  final DashboardRepository _repository;
  final SettingsService _settings;

  Future<DashboardSummary> getSummary(DashboardPeriod period) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) {
      return const DashboardSummary(
        totalExpense: 0,
        totalIncome: 0,
        balance: 0,
        moneyLent: 0,
        moneyBorrowed: 0,
        pendingReceive: 0,
        pendingPay: 0,
        todaySpending: 0,
        monthSpending: 0,
      );
    }
    return _repository.getSummary(profileId, period);
  }

  Future<List<DashboardTransaction>> getRecentTransactions() async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    final items = await _repository.getRecentTransactions(profileId);
    return items.map(_localizeTransaction).toList();
  }

  Future<List<MonthlySpendingPoint>> getMonthlySpending({int months = 6}) async {
    final profileId = _settings.activeProfileId;
    if (profileId == null) return [];
    return _repository.getMonthlySpending(profileId, months: months);
  }

  Future<List<BudgetProgress>> getBudgetProgress() =>
      _repository.getBudgetProgress();

  DashboardTransaction _localizeTransaction(DashboardTransaction item) {
    if (item.kind != DashboardTransactionKind.income) return item;
  final source = item.subtitle;
    final label = IncomeSources.isPredefinedKey(source)
        ? (IncomeSources.labelKeys[source]?.tr ?? source)
        : source;
    final title = item.title == source ? label : item.title;
    return DashboardTransaction(
      kind: item.kind,
      recordId: item.recordId,
      amount: item.amount,
      title: title,
      subtitle: label,
      colorHex: item.colorHex,
      accountName: item.accountName,
      date: item.date,
    );
  }
}
