// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:alletre_app/controller/services/token_refresh_service.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io'; // To check for platform

class AppleAuthService {
  final FirebaseAuth _appleAuth = FirebaseAuth.instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<User?> signInWithApple(
      {Function(String phoneNumber)? updateUserInfo}) async {
    try {
      if (Platform.isIOS) {
        // Apple Sign-In only works on iOS
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final OAuthCredential credential =
            OAuthProvider("apple.com").credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        UserCredential userCredential =
            await _appleAuth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _storage.write(
              key: 'saved_email', value: userCredential.user!.email);
          // Start token refresh service
          TokenRefreshService().startTokenRefresh();

          // Call backend OAuth endpoint
          debugPrint('📤 Preparing OAuth request...');
          debugPrint('Base URL: ${ApiEndpoints.baseUrl}');
          debugPrint(
              '🌐 Parsed Request URL: ${ApiEndpoints.baseUrl}/auth/oAuth');

          final response = await http.post(
            Uri.parse('${ApiEndpoints.baseUrl}/auth/oAuth'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'accessToken': appleCredential.authorizationCode,
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
            await _appleAuth.signOut();

            final error = jsonDecode(response.body)['message'] ??
                'Failed to authenticate';
            throw Exception(error);
          }

          // Parse response and store tokens
          final responseData = jsonDecode(response.body);
          if (responseData['success'] && responseData['data'] != null) {
            final data = responseData['data'];
            if (data['phone'] != null &&
                data['phone'] != "" &&
                updateUserInfo != null) {
              updateUserInfo(data['phone']);
            }
            await _storage.write(
                key: 'access_token', value: data['accessToken']);
            await _storage.write(
                key: 'refresh_token', value: data['refreshToken']);
            debugPrint('✅ Backend tokens stored successfully');
          }

          debugPrint('✅ Backend OAuth successful');
          return userCredential.user;
        }
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
