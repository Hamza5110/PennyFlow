import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/base/base_controller.dart';
import '../../../core/constants/recurring_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/recurring/recurring_list_item.dart';
import '../../../services/recurring/recurring_service.dart';
import '../recurring_routes.dart';

class RecurringListController extends BaseController {
  RecurringListController(this._recurring);

  final RecurringService _recurring;

  final RxString filterType = RecurringTransactionTypes.expense.obs;
  final RxList<RecurringListItem> items = <RecurringListItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    await runGuarded(() async {
      await _recurring.processDueTemplates();
      items.assignAll(
        await _recurring.listTemplates(transactionType: filterType.value),
      );
    }, showErrorSnackbar: false);
  }

  Future<void> changeFilter(String type) async {
    filterType.value = type;
    await loadTemplates();
  }

  void openAdd() {
    Get.toNamed<void>(
      AppRoutes.recurringForm,
      arguments: RecurringFormArgs(transactionType: filterType.value),
    )?.then((_) => loadTemplates());
  }

  void openEdit(RecurringListItem item) {
    Get.toNamed<void>(
      AppRoutes.recurringForm,
      arguments: RecurringFormArgs(templateId: item.template.id),
    )?.then((_) => loadTemplates());
  }

  Future<void> toggleActive(RecurringListItem item) async {
    await runGuarded(() async {
      final result = item.template.isActive
          ? await _recurring.pause(item.template.id)
          : await _recurring.resume(item.template.id);
      if (result.success) {
        await loadTemplates();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> deleteTemplate(RecurringListItem item) async {
    await runGuarded(() async {
      final result = await _recurring.delete(item.template.id);
      if (result.success) {
        ErrorHandler.showSuccess('recurring_deleted'.tr);
        await loadTemplates();
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
