import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:alletre_app/controller/helpers/user_services.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    serverClientId: '1043853491459-v2vu534unt5v880p5qe4cntfs265qsfi.apps.googleusercontent.com', // Use web client ID as server client ID
  );
  final FirebaseAuth _googleAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Timer? _tokenRefreshTimer;

  void _startTokenRefresh(User user) async {
    _tokenRefreshTimer?.cancel();

    // Immediately get and store a fresh token
    try {
      final newToken = await user.getIdToken(true);
      await _storage.write(key: 'access_token', value: newToken);
      debugPrint('Initial token stored successfully');
    } catch (e) {
      debugPrint('Initial token store error: $e');
    }

    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 30), (_) async {
      try {
        final newToken = await user.getIdToken(true);
        await _storage.write(key: 'access_token', value: newToken);
        debugPrint('Token refreshed successfully');
      } catch (e) {
        debugPrint('Token refresh error: $e');
      }
    });
  }

  void _stopTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  Future<String?> hCurrentToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credential
final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

// Get Firebase ID token (this will have correct audience)
final firebaseIdToken = await userCredential.user!.getIdToken();


      // Debug: Print Google auth tokens
      debugPrint('Google Access Token: ${googleAuth.accessToken}');
      debugPrint('Google ID Token: ${googleAuth.idToken}');

      // Get and store Firebase ID token
      if (userCredential.user != null) {
        // Set up automatic token refresh
        _startTokenRefresh(userCredential.user!);

        // Call backend OAuth endpoint
        final userService = UserService();
        final oAuthResult = await userService.signInWithGoogle();

        if (!oAuthResult['success']) {
          // If backend OAuth fails, sign out from Firebase
          await _googleAuth.signOut();
          throw Exception(oAuthResult['message'] ?? 'Failed to authenticate with backend');
        }

        debugPrint('✅ Backend OAuth successful');
        return userCredential;
      }

      return userCredential;
    } catch (e) {
      debugPrint('❌ Google sign-in error: $e');
      // Clean up on error
      await _googleAuth.signOut();
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  Future<void> signOut() async {
    _stopTokenRefresh();
    await _storage.delete(key: 'access_token');
    await _googleSignIn.signOut();
    await _googleAuth.signOut();
  }

  void cleanup() {
    _stopTokenRefresh();
  }
}
