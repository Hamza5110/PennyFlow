import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/friend.dart';
import '../../../data/models/friend/friend_input.dart';
import '../../../services/friend/friend_service.dart';
import '../friend_routes.dart';

class FriendFormController extends BaseController {
  FriendFormController(this._friends);

  final FriendService _friends;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  int? _friendId;
  bool get isEditing => _friendId != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is FriendFormArgs) _friendId = args.friendId;
    _bootstrap();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  Future<void> _bootstrap() async {
    final id = _friendId;
    if (id == null) return;
    await runGuarded(() async {
      final friend = await _friends.getFriendById(id);
      if (friend == null) {
        ErrorHandler.showError('friends_not_found'.tr);
        Get.back<void>();
        return;
      }
      _populate(friend);
    }, showErrorSnackbar: false);
  }

  void _populate(Friend friend) {
    nameController.text = friend.name;
    phoneController.text = friend.phone ?? '';
  }

  Future<void> save() async {
    await runGuarded(() async {
      final input = FriendInput(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
      );
      final result = isEditing
          ? await _friends.updateFriend(_friendId!, input)
          : await _friends.createFriend(input);
      if (result.success) {
        ErrorHandler.popWithSuccess(
          isEditing ? 'friends_updated'.tr : 'friends_created'.tr,
        );
        return;
      } else if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }
}
