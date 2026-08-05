import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/expense/expense_input.dart';
import '../../../data/models/payment_account.dart';
import '../../../services/category/category_service.dart';
import '../../../services/expense/expense_service.dart';
import '../../../services/image/image_service.dart';
import '../../../services/payment_account/payment_account_service.dart';
import '../../../services/settings/settings_service.dart';
import '../expense_routes.dart';

class ExpenseFormController extends BaseController {
  ExpenseFormController(
    this._expenses,
    this._categories,
    this._accounts,
    this._images,
    this._settings,
  );

  final ExpenseService _expenses;
  final CategoryService _categories;
  final PaymentAccountService _accounts;
  final ImageService _images;
  final SettingsService _settings;

  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final locationController = TextEditingController();
  final tagsController = TextEditingController();

  final RxList<Category> categories = <Category>[].obs;
  final RxList<PaymentAccount> accounts = <PaymentAccount>[].obs;
  final RxnInt selectedCategoryId = RxnInt();
  final RxnInt selectedAccountId = RxnInt();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<TimeOfDay> selectedTime = TimeOfDay.now().obs;
  final RxList<String> imagePaths = <String>[].obs;

  int? _expenseId;
  bool get isEditing => _expenseId != null;

  String get currencyCode => _settings.currencyCode.value;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ExpenseFormArgs) {
      _expenseId = args.expenseId;
    }
    _bootstrap();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    locationController.dispose();
    tagsController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      categories.assignAll(await _categories.getCategories());
      accounts.assignAll(await _accounts.getActiveAccounts());

      if (_expenseId != null) {
        final expense = await _expenses.getById(_expenseId!);
        if (expense == null) {
          ErrorHandler.showError('expense_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(expense);
      } else if (categories.isNotEmpty && selectedCategoryId.value == null) {
        selectedCategoryId.value = categories.first.id;
      }
      if (accounts.isNotEmpty && selectedAccountId.value == null) {
        selectedAccountId.value = accounts.first.id;
      }
    }, showErrorSnackbar: false);
  }

  void _populate(Expense expense) {
    amountController.text = expense.amount.toStringAsFixed(2);
    notesController.text = expense.notes ?? '';
    locationController.text = expense.location ?? '';
    tagsController.text = expense.tags.join(', ');
    selectedCategoryId.value = expense.categoryId;
    selectedAccountId.value = expense.accountId;
    selectedDate.value = expense.date;
    selectedTime.value = TimeOfDay.fromDateTime(expense.date);
    imagePaths.assignAll(expense.receiptImagePaths);
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

  List<String> _parseTags() {
    return tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  DateTime _combinedDateTime() {
    final date = selectedDate.value;
    final time = selectedTime.value;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  ExpenseInput _buildInput() {
    return ExpenseInput(
      amount: double.parse(amountController.text.trim()),
      categoryId: selectedCategoryId.value!,
      accountId: selectedAccountId.value!,
      date: _combinedDateTime(),
      notes: notesController.text,
      tags: _parseTags(),
      location: locationController.text,
      receiptImagePaths: imagePaths.toList(),
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _expenses.update(_expenseId!, input)
          : await _expenses.create(input);

      if (result.success) {
        ErrorHandler.showSuccess(
          isEditing ? 'expense_updated'.tr : 'expense_created'.tr,
        );
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
