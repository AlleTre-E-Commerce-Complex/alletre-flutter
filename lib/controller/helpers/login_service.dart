// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class LoginService {
//   final String baseUrl = 'https://alletre.com/api/auth/login';
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<bool> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         body: {
//           'email': email,
//           'password': password,
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         // Extract tokens from the response
//         final String accessToken = data['data']['accessToken'];
//         final String refreshToken = data['data']['refreshToken'];

//         // Store tokens securely
//         await _storage.write(key: 'accessToken', value: accessToken);
//         await _storage.write(key: 'refreshToken', value: refreshToken);

//         return true; // Login successful
//       } else {
//         throw Exception('Login failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Login failed: $e');
//     }
//   }
// }