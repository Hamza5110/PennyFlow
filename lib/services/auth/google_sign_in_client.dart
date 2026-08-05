import 'package:google_sign_in/google_sign_in.dart';

import '../../app/config/app_config.dart';
import '../../app/config/env_config.dart';

/// Thin wrapper around [GoogleSignIn] for sign-in flows and testing seams.
class GoogleSignInClient {
  GoogleSignInClient({GoogleSignIn? instance})
      : _googleSignIn = instance ?? _createDefault();

  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _createDefault() {
    final serverClientId = EnvConfig.current.googleServerClientId;
    return GoogleSignIn(
      scopes: AppConfig.googleSignInScopes,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
  }

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<GoogleSignInAccount?> signInSilently({
    bool suppressErrors = true,
  }) =>
      _googleSignIn.signInSilently(suppressErrors: suppressErrors);

  Future<void> signOut() => _googleSignIn.signOut();

  Future<void> disconnect() => _googleSignIn.disconnect();
}
