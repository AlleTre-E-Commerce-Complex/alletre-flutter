import 'dart:convert';
import 'package:alletre_app/utils/error/auth_error_handler.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String baseUrl = 'https://www.alletre.com/api/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // API Response Handler
  Future<Map<String, dynamic>> handleApiResponse(http.Response response) async {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['data'] != null) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': 'Invalid response format: missing data'};
      }
    } else {
      String errorMessage = '';
      if (data['message'] is List) {
        errorMessage = (data['message'] as List).join(', ');
      } else if (data['message'] is String) {
        errorMessage = data['message'];
      } else {
        errorMessage = 'An error occurred during request';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  // Signup API
  Future<Map<String, dynamic>> signupService(String name, String email, String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sign-up'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'userName': name,
          'email': email,
          'phone': phoneNumber,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['data'] != null) {
          final String accessToken = data['data']['accessToken'];
          final String refreshToken = data['data']['refreshToken'];
          
          await _storage.write(key: 'accessToken', value: accessToken);
          await _storage.write(key: 'refreshToken', value: refreshToken);
          
          return {'success': true, 'message': 'Signup successful'};
        } else {
          throw Exception('Invalid response format: missing data');
        }
      } else {
        // Handle error message that could be either String or List
        String errorMessage = '';
        if (data['message'] is List) {
          errorMessage = (data['message'] as List).join(', ');
        } else if (data['message'] is String) {
          errorMessage = data['message'];
        } else {
          errorMessage = 'An error occurred during signup';
        }
        return {
          'success': false,
          'message': errorMessage
        };
      }
    } on FormatException {
      return {'success': false, 'message': 'Invalid response format from server'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Login API
  Future<Map<String, dynamic>> loginService(String email, String password) async {
    try {
      // Log request data for debugging (remove in production)
      debugPrint('Login attempt for email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/sign-in'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim(),
          'password': password,
        }),
      );

      // Log response for debugging (remove in production)
      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (data['data']?['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['data']['accessToken']);
          await _storage.write(key: 'refreshToken', value: data['data']['refreshToken']);
          return {'success': true, 'message': 'Login successful'};
        }
      }

      return AuthErrorHandler.handleSignInError({
        ...data,
        'statusCode': response.statusCode,
      });
      
    } catch (e) {
      return AuthErrorHandler.handleSignInError(e);
    }
  }

      // if (response.statusCode >= 200 && response.statusCode < 300) {
      //   if (data['data'] != null) {
      //     final String accessToken = data['data']['accessToken'];
      //     final String refreshToken = data['data']['refreshToken'];
          
      //     await _storage.write(key: 'accessToken', value: accessToken);
      //     await _storage.write(key: 'refreshToken', value: refreshToken);
          
      //     return {'success': true, 'message': 'Login successful'};
      //   } 
      //   else {
      //     debugPrint('Missing token data in response: $data');
      //     return {'success': false, 'message': 'Invalid server response: missing token data'};
      //     // throw Exception('Invalid response format: missing data');
      //   }
      // } else {
      //   String errorMessage = '';
      //   if (data['message'] is List) {
      //     errorMessage = (data['message'] as List).join(', ');
      //   } else if (data['message'] is String) {
      //     errorMessage = data['message'];
      //   } else {
      //     errorMessage = 'Server returned error status: ${response.statusCode}';
      //   }
        
      //   debugPrint('Login error: $errorMessage');
      //   return {
      //     'success': false,
      //     'message': errorMessage
      //   };
      // }
    // } on FormatException catch (e) {
    //   debugPrint('Format error during login: $e');
    //   return {'success': false, 'message': 'Invalid response format from server'};
    // } on SocketException catch (e) {
    //   debugPrint('Network error during login: $e');
    //   return {'success': false, 'message': 'Network connection error. Please check your internet connection.'};
    // } catch (e) {
    //   debugPrint('Unexpected error during login: $e');
    //   return {'success': false, 'message': 'An unexpected error occurred. Please try again.'};
    // }
  // }

  // Enhanced token validation method
  Future<bool> validateTokens() async {
    try {
      final accessToken = await _storage.read(key: 'accessToken');
      final refreshToken = await _storage.read(key: 'refreshToken');
      
      return accessToken != null && refreshToken != null;
    } catch (e) {
      debugPrint('Error validating tokens: $e');
      return false;
    }
  }

  // Get stored tokens
  Future<Map<String, String?>> getTokens() async {
    final accessToken = await _storage.read(key: 'accessToken');
    final refreshToken = await _storage.read(key: 'refreshToken');
    
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}