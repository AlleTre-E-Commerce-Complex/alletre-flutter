import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alletre_app/controller/services/token_refresh_service.dart';

import '../../utils/app_logger.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    serverClientId: '1043853491459-v2vu534unt5v880p5qe4cntfs265qsfi.apps.googleusercontent.com',
  );
  final FirebaseAuth _googleAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> hCurrentToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<UserCredential?> signInWithGoogle({Function(String phoneNumber)? updateUserInfo}) async {
    try {
      AppLogger.log.d('Starting Google sign-in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.log.d('❌ Google sign-in cancelled by user');
        return null;
      }

      AppLogger.log.d('✅ Google sign-in successful');
      AppLogger.log.d('Getting Google authentication...');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _googleAuth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _storage.write(key: 'saved_email', value: userCredential.user!.email);
        // Start token refresh service
        TokenRefreshService().startTokenRefresh();

        // Call backend OAuth endpoint
        AppLogger.log.d('📤 Preparing OAuth request...');
        AppLogger.log.d('Base URL: ${ApiEndpoints.baseUrl}');
        AppLogger.log.d('🌐 Parsed Request URL: ${ApiEndpoints.baseUrl}/auth/oAuth');

        final response = await http.post(
          Uri.parse('${ApiEndpoints.baseUrl}/auth/oAuth'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'accessToken': googleAuth.accessToken, 'idToken': await userCredential.user!.getIdToken(), 'email': userCredential.user!.email, 'displayName': userCredential.user!.displayName, 'photoUrl': userCredential.user!.photoURL, 'provider': 'google', 'oAuthType': 'GOOGLE'}),
        );

        AppLogger.log.d('\n=== OAuth Response ===');
        AppLogger.log.d('Status Code: ${response.statusCode}');
        AppLogger.log.d('Headers: ${response.headers}');
        AppLogger.log.d('Body: ${response.body}');
        AppLogger.log.d('=====================\n');

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
          if (data['phone'] != null && data['phone'] != "" && updateUserInfo != null) {
            updateUserInfo(data['phone']);
          }
          await _storage.write(key: 'access_token', value: data['accessToken']);
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);
          AppLogger.log.d('✅ Backend tokens stored successfully');
        }

        AppLogger.log.d('✅ Backend OAuth successful');
        return userCredential;
      }

      return userCredential;
    } catch (e) {
      AppLogger.log.d('❌ Google sign-in error: $e');
      // Clean up on error
      await _googleAuth.signOut();
      await _googleSignIn.signOut();
      // rethrow;
    }
    return null;
  }

  Future<void> signOut() async {
    TokenRefreshService().stopTokenRefresh();
    await _storage.delete(key: 'access_token');
    await _googleSignIn.disconnect(); // <-- This clears the cached Google account
    await _googleSignIn.signOut();
    await _googleAuth.signOut();
  }

  void cleanup() {
    TokenRefreshService().stopTokenRefresh();
  }
}
