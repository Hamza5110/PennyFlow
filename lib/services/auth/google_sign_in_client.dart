import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:googleapis/drive/v3.dart' as drive;

import '../../app/config/app_config.dart';
import '../../app/config/env_config.dart';

/// Thin wrapper around [GoogleSignIn] for sign-in flows and testing seams.
class GoogleSignInClient {
  GoogleSignInClient({GoogleSignIn? instance})
      : _googleSignIn = instance ?? _createDefault();

  final GoogleSignIn _googleSignIn;

  GoogleSignIn get instance => _googleSignIn;

  Future<auth.AuthClient?> authenticatedClient() =>
      _googleSignIn.authenticatedClient();

  Future<drive.DriveApi?> driveApi() async {
    final client = await authenticatedClient();
    if (client == null) return null;
    return drive.DriveApi(client);
  }

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
