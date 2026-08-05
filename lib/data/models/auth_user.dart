import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Signed-in Google account snapshot (backup ownership only — SRS §13.16).
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  factory AuthUser.fromGoogleAccount(GoogleSignInAccount account) {
    return AuthUser(
      id: account.id,
      email: account.email,
      displayName: account.displayName,
      photoUrl: account.photoUrl,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  String get initials {
    final source = displayName?.trim().isNotEmpty == true
        ? displayName!
        : email;
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
      };

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
