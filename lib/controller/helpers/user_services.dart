import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final String baseUrl = 'https://www.alletre.com/api/auth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Signup API
  Future<bool> signup(String name, String email, String phoneNumber, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sign-up'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Extract tokens from the response
        final String accessToken = data['data']['accessToken'];
        final String refreshToken = data['data']['refreshToken'];
        
        // Store tokens securely
        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);
        
        return true; // Signup successful
      } else {
        throw Exception('Signup failed: ${data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Login API
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sign-in'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final Map<String, dynamic> data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Extract tokens from the response
        final String accessToken = data['data']['accessToken'];
        final String refreshToken = data['data']['refreshToken'];
        
        // Store tokens securely
        await _storage.write(key: 'accessToken', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);
        
        return true; // Login successful
      } else {
        throw Exception('Login failed: ${data['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
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