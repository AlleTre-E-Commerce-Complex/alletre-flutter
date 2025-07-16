import 'dart:convert';
import 'package:alletre_app/utils/error/auth_error_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:alletre_app/controller/services/token_refresh_service.dart';

class UserService {
  final String baseUrl = 'http://192.168.1.6:3001/api/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // API Response Handler
  Future<Map<String, dynamic>> handleApiResponse(http.Response response) async {
    final Map<String, dynamic> data = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data['data'] != null) {
        return {'success': true, 'data': data['data']};
      } else {
        return {
          'success': false,
          'message': 'Invalid response format: missing data'
        };
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

  // Refresh token
  Future<Map<String, dynamic>> refreshTokens() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      debugPrint('Current refresh token: $refreshToken');
      if (refreshToken == null) {
        return {'success': false, 'message': 'No refresh token found'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      debugPrint('Refresh token response status: ${response.statusCode}');
      debugPrint('Refresh token response body: ${response.body}');

      final Map<String, dynamic> data = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          data['data'] != null) {
        final String newAccessToken = data['data']['accessToken'];
        final String newRefreshToken = data['data']['refreshToken'];

        await _storage.write(key: 'access_token', value: newAccessToken);
        await _storage.write(key: 'refresh_token', value: newRefreshToken);

        return {
          'success': true,
          'data': {
            'accessToken': newAccessToken,
            'refreshToken': newRefreshToken,
          }
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Failed to refresh tokens'
      };
    } catch (e) {
      debugPrint('Error refreshing tokens: $e');
      return {
        'success': false,
        'message': 'An error occurred while refreshing tokens'
      };
    }
  }

  // Signup API
  Future<Map<String, dynamic>> signupService(
      String name, String email, String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sign-up'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'userName': name,
          'email': email.trim(),
          'phone': phoneNumber,
          // 'platform': 'mobile_app'
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'message':
              'Registration successful! Please check your email for verification instructions.',
          'requiresVerification': true
        };
      }

      return AuthErrorHandler.handleSignUpError(data);
    } catch (e) {
      return AuthErrorHandler.handleSignUpError(e);
    }
  }

  // Login API
  Future<Map<String, dynamic>> loginService(
      String email, String password) async {
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
          debugPrint(
              'Storing tokens after login - Access: ${data['data']['accessToken']}');
          debugPrint(
              'Storing tokens after login - Refresh: ${data['data']['refreshToken']}');
          await _storage.write(
              key: 'access_token', value: data['data']['accessToken']);
          await _storage.write(
              key: 'refresh_token', value: data['data']['refreshToken']);

          // Start token refresh service
          TokenRefreshService().startTokenRefresh();

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

  // Google Sign In with OAuth
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint('Starting Google sign-in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google sign-in cancelled by user');
        return {'success': false, 'message': 'Sign in cancelled'};
      }

      debugPrint('✅ Google sign-in successful');
      debugPrint('Getting Google authentication...');

      GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        debugPrint('❌ Error getting Google authentication: $e');
        return {
          'success': false,
          'message': 'Failed to get Google authentication'
        };
      }

      // Get both tokens
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        debugPrint('❌ Failed to get Google tokens');
        debugPrint(
            'Access Token: ${accessToken != null ? 'present' : 'missing'}');
        debugPrint('ID Token: ${idToken != null ? 'present' : 'missing'}');
        return {
          'success': false,
          'message': 'Failed to get authentication tokens'
        };
      }

      debugPrint('✅ Got Google tokens successfully');
      debugPrint('🔑 Access Token length: ${accessToken.length}');
      debugPrint('🎫 ID Token length: ${idToken.length}');

      debugPrint('🔍 Starting token debug...');
      try {
        // Debug token format
        final parts = idToken.split('.');
        debugPrint('Token parts: ${parts.length}');
        if (parts.length == 3) {
          try {
            debugPrint('Attempting to decode token header...');
            final header =
                utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
            debugPrint('Token header: $header');
          } catch (e) {
            debugPrint('❌ Error decoding token header: $e');
          }
        }

        debugPrint('📤 Preparing OAuth request...');
        debugPrint('Base URL: $baseUrl');

        Uri oAuthUrl;
        try {
          oAuthUrl = Uri.parse('$baseUrl/oAuth');
          debugPrint('🌐 Parsed Request URL: $oAuthUrl');
        } catch (e) {
          debugPrint('❌ Error parsing URL: $e');
          return {'success': false, 'message': 'Invalid server URL'};
        }

        debugPrint('Preparing request body...');

        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? currentUser = auth.currentUser;

        if (currentUser == null) {
          return {'success': false, 'message': 'Failed to get Firebase user'};
        }

        // Get Firebase ID token (has correct audience)
        final String? firebaseIdToken = await currentUser.getIdToken();

        // Use Firebase ID token in your request
        final requestBody = {
          'accessToken': accessToken,
          'idToken': firebaseIdToken, // Firebase token instead of Google token
          'email': googleUser.email,
          'displayName': googleUser.displayName,
          'photoUrl': googleUser.photoUrl,
          'provider': 'google',
          'oAuthType': 'GOOGLE'
        };

        // Pretty print request for debugging
        const JsonEncoder encoder = JsonEncoder.withIndent('    ');
        debugPrint(
            '\n=== OAuth Request ===\n${encoder.convert(requestBody)}\n==================');

        debugPrint('🚀 Sending HTTP POST request...');
        late final http.Response response;
        try {
          response = await http.post(
            oAuthUrl,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Origin': 'http://192.168.1.6:3001',
              'Access-Control-Request-Method': 'POST',
              'Access-Control-Request-Headers': 'Content-Type'
            },
            body: json.encode(requestBody),
          );
        } catch (e) {
          debugPrint('❌ HTTP request failed: $e');
          return {'success': false, 'message': 'Failed to connect to server'};
        }

        debugPrint('\n=== OAuth Response ===');
        debugPrint('Status Code: ${response.statusCode}');
        debugPrint('Headers: ${response.headers}');
        debugPrint('Body: ${response.body}');
        debugPrint('=====================\n');

        Map<String, dynamic> data;
        try {
          data = json.decode(response.body);
          debugPrint('✅ Successfully parsed JSON response');

          // Pretty print the full response
          debugPrint('\n=== Parsed OAuth Response ===');
          debugPrint(const JsonEncoder.withIndent('    ').convert(data));
          debugPrint('=========================\n');

          debugPrint('=== Response Structure ===');
          debugPrint('Success: ${data['success']}');
          debugPrint('Has data: ${data['data'] != null}');

          if (data['success'] == true && data['data'] != null) {
            final userData = data['data'] as Map<String, dynamic>;
            final accessToken = userData['accessToken'];
            final refreshToken = userData['refreshToken'];

            if (accessToken != null && refreshToken != null) {
              // Store both tokens
              await _storage.write(key: 'access_token', value: accessToken);
              await _storage.write(key: 'refresh_token', value: refreshToken);
              debugPrint('✅ Stored server tokens');
              return {
                'success': true,
                'data': userData,
                'message': 'Authentication successful'
              };
            }
          }

          debugPrint('❌ OAuth failed: ${data['message'] ?? 'Unknown error'}');
          return {
            'success': false,
            'message': data['message'] ?? 'Authentication failed'
          };
        } catch (e) {
          debugPrint('❌ Error parsing response: $e');
          return {
            'success': false,
            'message': 'Failed to parse server response'
          };
        }
      } catch (e) {
        debugPrint('OAuth error: $e');
        return {'success': false, 'message': 'Authentication failed: $e'};
      }
    } catch (e) {
      debugPrint('OAuth error: $e');
      return {'success': false, 'message': 'Authentication failed: $e'};
    }
  }

  // Get stored access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Check stored tokens
  Future<void> checkStoredTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();

    debugPrint('=== Stored Tokens ===');
    debugPrint('Access Token: ${accessToken ?? 'Not found'}');
    debugPrint('Refresh Token: ${refreshToken ?? 'Not found'}');
    debugPrint('===================');
  }

  // Enhanced token validation method
  Future<bool> validateTokens() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');

      if (accessToken == null || refreshToken == null) {
        return false;
      }

      // Try to use the access token
      final response = await http.get(
        Uri.parse('$baseUrl/validate-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return true;
      }

      // If access token is invalid, try to refresh
      if (response.statusCode == 401) {
        final refreshResult = await refreshTokens();
        return refreshResult['success'];
      }

      return false;
    } catch (e) {
      debugPrint('Error validating tokens: $e');
      return false;
    }
  }

  // Get stored tokens
  Future<Map<String, String?>> getTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');

    // If access token is missing but we have refresh token, try to refresh
    if (accessToken == null && refreshToken != null) {
      final refreshResult = await refreshTokens();
      if (refreshResult['success']) {
        return {
          'accessToken': refreshResult['data']['accessToken'],
          'refreshToken': refreshResult['data']['refreshToken'],
        };
      }
    }

    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  // Check OAuth tokens
  Future<Map<String, dynamic>> checkOAuthTokens() async {
    try {
      final accessToken = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');

      debugPrint('=== Stored OAuth Tokens ===');
      debugPrint('🔐 Access Token: ${accessToken ?? 'Not found'}');
      debugPrint('🔄 Refresh Token: ${refreshToken ?? 'Not found'}');
      debugPrint('=========================');

      return {
        'success': true,
        'accessToken': accessToken,
        'refreshToken': refreshToken
      };
    } catch (e) {
      debugPrint('Error checking OAuth tokens: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Make address default via API
  Future<Map<String, dynamic>> makeDefaultAddress(String locationId) async {
    try {
      final tokens = await getTokens();
      final accessToken = tokens['accessToken'];
      if (accessToken == null) {
        return {'success': false, 'message': 'Not authenticated'};
      }
      final response = await http.post(
        Uri.parse(
            'http://192.168.1.6:3001/api/users/locations/$locationId/make-default'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      return await handleApiResponse(response);
    } catch (e) {
      debugPrint('Error making address default: $e');
      return {'success': false, 'message': 'Failed to make address default'};
    }
  }

  // Logout - Clear all authentication data
  Future<void> logout() async {
    try {
      // Clear all secure storage tokens
      await _storage.deleteAll();

      // Sign out from Firebase if signed in
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Error signing out from Firebase: $e');
      }

      // Clear any HTTP client state if needed
      // client.close(); // Uncomment if you have an HTTP client that needs to be closed

      debugPrint('Successfully logged out and cleared all auth data');
    } catch (e) {
      debugPrint('Error during logout: $e');
      rethrow; // Re-throw to handle in the caller
    }
  }
}
