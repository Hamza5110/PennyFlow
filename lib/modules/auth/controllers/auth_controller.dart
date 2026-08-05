import 'package:get/get.dart';

import '../../../core/base/base_controller.dart';
import '../../../core/errors/error_handler.dart';
import '../../../data/models/auth_user.dart';
import '../../../services/auth/auth_service.dart';

/// Google Sign-In screen controller (FR-155 – FR-160).
class AuthController extends BaseController {
  AuthController(this._auth);

  final AuthService _auth;

  Rxn<AuthUser> get currentUser => _auth.currentUser;

  bool get isSignedIn => _auth.isSignedIn;

  Future<void> signInWithGoogle() async {
    await runGuarded(() async {
      final result = await _auth.signInWithGoogle();
      if (result.success) {
        ErrorHandler.showSuccess('auth_sign_in_success'.tr);
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
}
