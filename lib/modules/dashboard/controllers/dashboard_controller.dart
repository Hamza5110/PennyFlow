import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../data/models/dashboard/budget_progress.dart';
import '../../../data/models/dashboard/dashboard_period.dart';
import '../../../data/models/dashboard/dashboard_summary.dart';
import '../../../data/models/dashboard/dashboard_transaction.dart';
import '../../../data/models/dashboard/monthly_spending_point.dart';
import '../../../services/dashboard/dashboard_service.dart';
import '../../../services/settings/settings_service.dart';
import '../../expenses/expense_routes.dart';
import '../../income/income_routes.dart';

class DashboardController extends BaseController {
  DashboardController(this._dashboard, this._settings);

  final DashboardService _dashboard;
  final SettingsService _settings;

  final Rx<DashboardPeriod> period = DashboardPeriod.thisMonth.obs;
  final Rxn<DashboardSummary> summary = Rxn<DashboardSummary>();
  final RxList<DashboardTransaction> recentTransactions =
      <DashboardTransaction>[].obs;
  final RxList<MonthlySpendingPoint> monthlySpending =
      <MonthlySpendingPoint>[].obs;
  final RxList<BudgetProgress> budgets = <BudgetProgress>[].obs;

  String get currencyCode => _settings.currencyCode.value;

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    await runGuarded(() async {
      summary.value = await _dashboard.getSummary(period.value);
      recentTransactions.assignAll(await _dashboard.getRecentTransactions());
      monthlySpending.assignAll(await _dashboard.getMonthlySpending());
      budgets.assignAll(await _dashboard.getBudgetProgress());
    }, showErrorSnackbar: false);
  }

  Future<void> changePeriod(DashboardPeriod value) async {
    period.value = value;
    await loadDashboard();
  }

  void onTransactionTap(DashboardTransaction transaction) {
    if (transaction.isExpense) {
      Get.toNamed<void>(
        AppRoutes.expenseDetail,
        arguments: ExpenseDetailArgs(expenseId: transaction.recordId),
      )?.then((_) => loadDashboard());
      return;
    }
    Get.toNamed<void>(
      AppRoutes.incomeDetail,
      arguments: IncomeDetailArgs(incomeId: transaction.recordId),
    )?.then((_) => loadDashboard());
  }
}
