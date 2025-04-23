import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  Future<void> _startTokenRefresh() async {
    // Start periodic token refresh for backend tokens
    Timer.periodic(const Duration(minutes: 25), (timer) async {
      final userService = UserService();
      final result = await userService.refreshTokens();
      
      if (!result['success']) {
        debugPrint('Failed to refresh tokens: ${result['message']}');
        timer.cancel();
        return;
      }
      
      debugPrint('Backend tokens refreshed successfully');
    });
  }

  void _stopTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  Future<String?> hCurrentToken() async {
    return await _storage.read(key: 'access_token');
  }

  static const String baseUrl = 'http://192.168.0.158:3001/api';

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

      // Debug: Print Google auth tokens
      debugPrint('Google Access Token: ${googleAuth.accessToken}');
      debugPrint('Google ID Token: ${googleAuth.idToken}');

      // Get and store Firebase ID token
      if (userCredential.user != null) {
        // Start token refresh for backend
        _startTokenRefresh();

        // Call backend OAuth endpoint
        debugPrint('📤 Preparing OAuth request...');
        debugPrint('Base URL: $baseUrl');
        debugPrint('🌐 Parsed Request URL: $baseUrl/auth/oAuth');

        final response = await http.post(
          Uri.parse('$baseUrl/auth/oAuth'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'accessToken': googleAuth.accessToken,
            'idToken': await userCredential.user!.getIdToken(),
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoUrl': userCredential.user!.photoURL,
            'provider': 'google',
            'oAuthType': 'GOOGLE'
          }),
        );

        debugPrint('\n=== OAuth Response ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Body: ${response.body}');
        debugPrint('=====================\n');

        if (response.statusCode != 200 && response.statusCode != 201) {
          // If backend OAuth fails, sign out from Firebase
          await FirebaseAuth.instance.signOut();
          await _googleSignIn.signOut();
          
          final error = jsonDecode(response.body)['message'] ?? 'Failed to authenticate';
          throw Exception(error);
        }

        // Parse response and store tokens
        final responseData = jsonDecode(response.body);
        if (responseData['success'] && responseData['data'] != null) {
          final data = responseData['data'];
          await _storage.write(key: 'access_token', value: data['accessToken']);
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);
          debugPrint('✅ Backend tokens stored successfully');
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
