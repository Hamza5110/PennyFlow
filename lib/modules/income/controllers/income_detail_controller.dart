import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/income/income_list_item.dart';
import '../../../services/income/income_service.dart';
import '../income_routes.dart';

class IncomeDetailController extends BaseController {
  IncomeDetailController(this._incomes);

  final IncomeService _incomes;

  final Rxn<IncomeListItem> item = Rxn<IncomeListItem>();
  int? _incomeId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is IncomeDetailArgs) {
      _incomeId = args.incomeId;
      load();
    }
  }

  Future<void> load() async {
    final id = _incomeId;
    if (id == null) return;

    await runGuarded(() async {
      final income = await _incomes.getById(id);
      if (income == null) {
        ErrorHandler.showError('income_not_found'.tr);
        Get.back<void>();
        return;
      }
      final items = await _incomes.listActive();
      item.value = items.firstWhere(
        (e) => e.income.id == id,
        orElse: () => IncomeListItem(
          income: income,
          sourceLabel: _incomes.sourceLabel(income.source),
          sourceColorHex: '#64748B',
          accountName: 'Unknown',
        ),
      );
    }, showErrorSnackbar: false);
  }

  void edit() {
    final id = _incomeId;
    if (id == null) return;
    Get.toNamed<void>(
      AppRoutes.incomeForm,
      arguments: IncomeFormArgs(incomeId: id),
    )?.then((_) => load());
  }

  Future<void> duplicate() async {
    final id = _incomeId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _incomes.duplicate(id);
      if (result.success) {
        ErrorHandler.showSuccess('income_duplicated'.tr);
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> delete() async {
    final id = _incomeId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _incomes.softDelete(id);
      if (result.success) {
        ErrorHandler.showSuccess('income_deleted'.tr);
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
