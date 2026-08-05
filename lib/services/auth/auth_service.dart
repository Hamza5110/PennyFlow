import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/base/base_service.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/service_result.dart';
import '../../data/models/auth_user.dart';
import '../profile/profile_service.dart';
import '../settings/settings_service.dart';
import 'auth_session_store.dart';
import 'google_sign_in_client.dart';

/// Google Sign-In for backup ownership and restore (FR-155 – FR-160).
///
/// The app remains fully usable when the user is not signed in (FR-156).
class AuthService extends GetxService with BaseService {
  AuthService(
    this._googleSignIn,
    this._sessionStore,
    this._profiles,
    this._settings,
  );

  final GoogleSignInClient _googleSignIn;
  final AuthSessionStore _sessionStore;
  final ProfileService _profiles;
  final SettingsService _settings;

  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();

  bool get isSignedIn => currentUser.value != null;

  Future<AuthService> init() async {
    await restoreSession();
    return this;
  }

  /// Restores a prior Google session via silent sign-in + secure storage.
  Future<void> restoreSession() async {
    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        await _applySignedInAccount(account);
        return;
      }
    } catch (error, stackTrace) {
      log.w(
        'Silent Google sign-in failed',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final cached = await _sessionStore.read();
    if (cached != null) {
      currentUser.value = cached;
      log.i('Restored cached auth session for ${cached.email}');
    }
  }

  Future<ServiceResult<AuthUser>> signInWithGoogle() async {
    return guard(() async {
      GoogleSignInAccount account;
      try {
        final result = await _googleSignIn.signIn();
        if (result == null) {
          throw const AuthException(
            message: 'Sign-in was cancelled',
            code: 'AUTH_CANCELLED',
          );
        }
        account = result;
      } catch (error, stackTrace) {
        if (error is AuthException) rethrow;
        throw AuthException(
          message: 'Google Sign-In failed. Please try again.',
          cause: error,
          stackTrace: stackTrace,
        );
      }

      return _applySignedInAccount(account);
    });
  }

  Future<ServiceResult<void>> signOut() async {
    return guardVoid(() async {
      try {
        await _googleSignIn.signOut();
      } catch (error, stackTrace) {
        log.w('Google sign-out error', error: error, stackTrace: stackTrace);
      }

      await _sessionStore.clear();
      await _profiles.unlinkGoogleAccount();
      await _settings.setAutoBackupEnabled(false);
      currentUser.value = null;
      log.i('User signed out — auto-backup disabled');
    });
  }

  Future<AuthUser> _applySignedInAccount(GoogleSignInAccount account) async {
    final user = AuthUser.fromGoogleAccount(account);
    await _sessionStore.save(user);

    final linkResult = await _profiles.linkGoogleAccount(email: user.email);
    if (linkResult.isFailure) {
      throw linkResult.exception ??
          AuthException(message: linkResult.userMessage ?? 'Profile link failed');
    }

    currentUser.value = user;
    log.i('Signed in as ${user.email}');
    return user;
  }
}
