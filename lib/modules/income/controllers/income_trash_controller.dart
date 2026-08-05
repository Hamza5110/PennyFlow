import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/income/income_list_item.dart';
import '../../../services/income/income_service.dart';

class IncomeTrashController extends BaseController {
  IncomeTrashController(this._incomes);

  final IncomeService _incomes;

  final RxList<IncomeListItem> items = <IncomeListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTrash();
  }

  Future<void> loadTrash() async {
    await runGuarded(() async {
      items.assignAll(await _incomes.listTrash());
    }, showErrorSnackbar: false);
  }

  Future<void> restore(IncomeListItem item) async {
    await runGuarded(() async {
      final result = await _incomes.restore(item.income.id);
      if (result.success) {
        ErrorHandler.showSuccess('income_restored'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deletePermanently(IncomeListItem item) async {
    await runGuarded(() async {
      final result = await _incomes.permanentDelete(item.income.id);
      if (result.success) {
        ErrorHandler.showSuccess('income_purged'.tr);
        await loadTrash();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
