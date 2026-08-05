import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/friend/repayment_input.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/image/image_service.dart';
import '../friend_routes.dart';

class RepaymentFormController extends BaseController {
  RepaymentFormController(this._friends, this._images);

  final FriendService _friends;
  final ImageService _images;

  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<String> imagePaths = <String>[].obs;
  final RxDouble remainingBalance = 0.0.obs;

  int? _transactionId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is RepaymentFormArgs) {
      _transactionId = args.transactionId;
      _loadRemaining();
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    noteController.dispose();
    super.onClose();
  }

  Future<void> _loadRemaining() async {
    final id = _transactionId;
    if (id == null) return;
    remainingBalance.value = await _friends.remainingBalance(id);
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

  Future<void> addFromGallery() async {
    final remaining = 5 - imagePaths.length;
    if (remaining <= 0) return;
    imagePaths.addAll(await _images.pickFromGallery(maxImages: remaining));
  }

  Future<void> addFromCamera() async {
    if (imagePaths.length >= 5) return;
    final path = await _images.pickFromCamera();
    if (path != null) imagePaths.add(path);
  }

  void removeImage(int index) => imagePaths.removeAt(index);

  RepaymentInput _buildInput() {
    return RepaymentInput(
      amount: double.parse(amountController.text.trim()),
      date: selectedDate.value,
      note: noteController.text,
      imagePaths: imagePaths.toList(),
    );
  }

  Future<void> save() async {
    final id = _transactionId;
    if (id == null) return;
    await runGuarded(() async {
      final result = await _friends.addRepayment(id, _buildInput());
      if (result.success) {
        ErrorHandler.showSuccess('friends_repayment_added'.tr);
        Get.back(result: true);
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
