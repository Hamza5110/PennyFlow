import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/friend_constants.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/friend.dart';
import '../../../data/models/friend/friend_transaction_input.dart';
import '../../../data/models/friend_transaction.dart';
import '../../../services/friend/friend_service.dart';
import '../../../services/image/image_service.dart';
import '../friend_routes.dart';

class FriendTransactionFormController extends BaseController {
  FriendTransactionFormController(this._friends, this._images);

  final FriendService _friends;
  final ImageService _images;

  final amountController = TextEditingController();
  final notesController = TextEditingController();

  final RxList<Friend> friendOptions = <Friend>[].obs;
  final RxnInt selectedFriendId = RxnInt();
  final RxString selectedType = FriendTransactionTypes.given.obs;
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rxn<DateTime> selectedDueDate = Rxn<DateTime>();
  final RxList<String> imagePaths = <String>[].obs;

  int? _transactionId;
  bool get isEditing => _transactionId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FriendTransactionFormArgs) {
      _transactionId = args.transactionId;
      if (args.friendId != null) selectedFriendId.value = args.friendId;
      if (args.type != null) selectedType.value = args.type!;
    }
    _bootstrap();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    await runGuarded(() async {
      final friends = await _friends.listFriends();
      friendOptions.assignAll(friends.map((f) => f.friend));

      if (_transactionId != null) {
        final txn = await _friends.getTransactionById(_transactionId!);
        if (txn == null) {
          ErrorHandler.showError('friends_transaction_not_found'.tr);
          Get.back<void>();
          return;
        }
        _populate(txn);
      } else if (selectedFriendId.value == null && friendOptions.isNotEmpty) {
        selectedFriendId.value = friendOptions.first.id;
      }
    }, showErrorSnackbar: false);
  }

  void _populate(FriendTransaction txn) {
    amountController.text = txn.amount.toStringAsFixed(2);
    notesController.text = txn.notes ?? '';
    selectedFriendId.value = txn.friendId;
    selectedType.value = txn.type;
    selectedDate.value = txn.date;
    selectedDueDate.value = txn.dueDate;
    imagePaths.assignAll(txn.imagePaths);
  }

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> pickDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDueDate.value ?? selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) selectedDueDate.value = picked;
  }

  void clearDueDate() => selectedDueDate.value = null;

  Future<void> addFromGallery() async {
    final remaining = AppConstants.maxImagesPerTransaction - imagePaths.length;
    if (remaining <= 0) return;
    imagePaths.addAll(await _images.pickFromGallery(maxImages: remaining));
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

  FriendTransactionInput _buildInput() {
    return FriendTransactionInput(
      friendId: selectedFriendId.value!,
      type: selectedType.value,
      amount: double.parse(amountController.text.trim()),
      date: selectedDate.value,
      dueDate: selectedDueDate.value,
      notes: notesController.text,
      imagePaths: imagePaths.toList(),
    );
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = _buildInput();
      final result = isEditing
          ? await _friends.updateTransaction(_transactionId!, input)
          : await _friends.createTransaction(input);
      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing
              ? 'friends_transaction_updated'.tr
              : 'friends_transaction_created'.tr,
        );
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
