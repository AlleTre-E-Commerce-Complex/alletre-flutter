// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';  // To check for platform

class AppleAuthService {
  final FirebaseAuth _appleAuth = FirebaseAuth.instance;

  Future<User?> signInWithApple() async {
    try {
      if (Platform.isIOS) {
        // Apple Sign-In only works on iOS
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthCredential credential = OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        UserCredential userCredential = await _appleAuth.signInWithCredential(credential);
        return userCredential.user;
      } else {
        // Handle non-iOS platform or show a fallback UI.
        print('Apple Sign-In is not supported on this platform');
        return null;
      }
    } catch (e) {
      print("Apple Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _appleAuth.signOut();
  }
}
