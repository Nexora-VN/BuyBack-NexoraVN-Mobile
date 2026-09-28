import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

class GoogleAuthResult {
  final String? idToken;
  final String? accessToken;
  final String? email;
  final String? displayName;

  GoogleAuthResult({
    this.idToken,
    this.accessToken,
    this.email,
    this.displayName,
  });
}

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  Future<GoogleAuthResult?> signIn() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final account = await _googleSignIn.signIn();
      if (account == null) {
        return null; // Canceled by user
      }

      final auth = await account.authentication;
      return GoogleAuthResult(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
        email: account.email,
        displayName: account.displayName,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
