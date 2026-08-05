import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/income_sources.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/income.dart';
import '../../../data/models/income/income_input.dart';
import '../../../data/models/payment_account.dart';
import '../../../services/image/image_service.dart';
import '../../../services/income/income_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/settings/settings_service.dart';
import '../income_routes.dart';

class IncomeFormController extends BaseController {
  IncomeFormController(
    this._incomes,
    this._accounts,
    this._images,
    this._settings,
  );

  final IncomeService _incomes;
  final PaymentAccountService _accounts;
  final ImageService _images;
  final SettingsService _settings;

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final customSourceController = TextEditingController();

  final RxList<PaymentAccount> accounts = <PaymentAccount>[].obs;
  final RxnInt selectedAccountId = RxnInt();
  final RxString selectedSourceKey = IncomeSources.salary.obs;
  final RxBool useCustomSource = false.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final RxList<String> imagePaths = <String>[].obs;

  int? _incomeId;
  bool get isEditing => _incomeId != null;

  String get currencyCode => _settings.currencyCode.value;

  List<({String key, String label})> get sourceOptions => [
        for (final key in IncomeSources.predefinedKeys)
          (key: key, label: IncomeSources.labelKeys[key]!.tr),
        (key: IncomeSources.custom, label: 'income_source_custom'.tr),
      ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is IncomeFormArgs) {
      _incomeId = args.incomeId;
    }
    _bootstrap();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    customSourceController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      accounts.assignAll(await _accounts.getActiveAccounts());

      if (_incomeId != null) {
        final income = await _incomes.getById(_incomeId!);
        if (income == null) {
          ErrorHandler.showError('income_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(income);
      } else if (accounts.isNotEmpty && selectedAccountId.value == null) {
        selectedAccountId.value = accounts.first.id;
      }
    }, showErrorSnackbar: false);
  }

  void _populate(Income income) {
    amountController.text = income.amount.toStringAsFixed(2);
    notesController.text = income.notes ?? '';
    selectedAccountId.value = income.accountId;
    selectedDate.value = income.date;
    selectedTime.value = TimeOfDay.fromDateTime(income.date);
    imagePaths.assignAll(income.imagePaths);

    if (IncomeSources.isPredefinedKey(income.source)) {
      useCustomSource.value = false;
      selectedSourceKey.value = income.source;
    } else {
      useCustomSource.value = true;
      selectedSourceKey.value = IncomeSources.custom;
      customSourceController.text = income.source;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value,
    );
    if (picked != null) selectedTime.value = picked;
  }

  Future<void> addFromGallery() async {
    final remaining = AppConstants.maxImagesPerTransaction - imagePaths.length;
    if (remaining <= 0) return;
    final paths = await _images.pickFromGallery(maxImages: remaining);
    imagePaths.addAll(paths);
  }

  Future<void> addFromCamera() async {
    if (imagePaths.length >= AppConstants.maxImagesPerTransaction) return;
    final path = await _images.pickFromCamera();
    if (path != null) imagePaths.add(path);
  }

  Future<void> removeImage(int index) async {
    if (index < 0 || index >= imagePaths.length) return;
    final path = imagePaths.removeAt(index);
    await _images.deleteImage(path);
  }

  void onSourceChanged(String? key) {
    if (key == null) return;
    selectedSourceKey.value = key;
    useCustomSource.value = key == IncomeSources.custom;
  }

  DateTime _combinedDateTime() {
    final date = selectedDate.value;
    final time = selectedTime.value;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _resolvedSource() {
    if (useCustomSource.value) {
      return customSourceController.text.trim();
    }
    return selectedSourceKey.value;
  }

  IncomeInput _buildInput() {
    return IncomeInput(
      amount: double.parse(amountController.text.trim()),
      source: _resolvedSource(),
      accountId: selectedAccountId.value!,
      date: _combinedDateTime(),
      notes: notesController.text,
      imagePaths: imagePaths.toList(),
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _incomes.update(_incomeId!, input)
          : await _incomes.create(input);

      if (result.success) {
        ErrorHandler.showSuccess(
          isEditing ? 'income_updated'.tr : 'income_created'.tr,
        );
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
