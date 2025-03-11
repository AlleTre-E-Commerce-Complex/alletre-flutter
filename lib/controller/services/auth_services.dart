// Create a new file: lib/controller/services/auth_service.dart
import 'dart:convert';

import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserAuthService {
  final UserService _userService = UserService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Check if a user is authenticated
  Future<bool> isAuthenticated() async {
    // First check for Firebase auth
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return true;
    }
    
    // Then check for our API tokens
    return await _userService.validateTokens();
  }

  // Store last authentication method
  Future<void> setAuthMethod(String method) async {
    await _storage.write(key: 'auth_method', value: method);
  }

  // Get last authentication method
  Future<String?> getAuthMethod() async {
    return await _storage.read(key: 'auth_method');
  }

  // Store onboarding completed status
  Future<void> setOnboardingCompleted() async {
    await _storage.write(key: 'onboarding_completed', value: 'true');
  }

  // Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    final completed = await _storage.read(key: 'onboarding_completed');
    return completed == 'true';
  }

  // Forgot Password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${_userService.baseUrl}/auth/forget-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Password reset instructions sent to your email',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to process request',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again later.',
      };
    }
  }
}