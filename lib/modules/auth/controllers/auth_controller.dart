import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/auth_user.dart';
import '../../../services/auth/auth_service.dart';
import '../../../services/backup/backup_service.dart';

/// Google Sign-In screen controller (FR-155 – FR-160).
class AuthController extends BaseController {
  AuthController(this._auth, this._backup);

  final AuthService _auth;
  final BackupService _backup;

  Rxn<AuthUser> get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.isSignedIn;

  Future<void> signInWithGoogle() async {
    await runGuarded(() async {
      final result = await _auth.signInWithGoogle();
      if (result.success) {
        ErrorHandler.showSuccess('auth_sign_in_success'.tr);
        await _offerRestoreIfAvailable();
        return;
      }
      if (result.errorCode == 'AUTH_CANCELLED') return;
      errorMessage.value = result.userMessage;
      if (result.userMessage != null) {
        ErrorHandler.showError(result.userMessage!);
      }
    });
  }

  Future<void> signOut() async {
    await runGuarded(() async {
      final result = await _auth.signOut();
      if (result.success) {
        ErrorHandler.showSuccess('auth_sign_out_success'.tr);
      } else {
        unwrapResult(result);
      }
    });
  }

  void continueWithoutSigningIn() => Get.back<void>();

  Future<void> _offerRestoreIfAvailable() async {
    if (!await _backup.shouldOfferRestore()) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('backup_restore_offer_title'.tr),
        content: Text('backup_restore_offer_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text('common_not_now'.tr),
          ),
          TextButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text('backup_restore'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final result = await _backup.restoreLatest(overwrite: true);
    if (result.success) {
      ErrorHandler.showSuccess('backup_restore_success'.tr);
    } else if (result.userMessage != null) {
      ErrorHandler.showError(result.userMessage!);
    }
  }
}
