// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SignupService {
//   final String baseUrl = 'https://alletre.com/api/auth/signup';
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();

//   Future<bool> signup(String name, String email, String phoneNumber, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse(baseUrl),
//         body: {
//           'name': name,
//           'email': email,
//           'phoneNumber': phoneNumber,
//           'password': password,
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);

//         // Extract tokens from the response (if provided by the backend)
//         final String accessToken = data['data']['accessToken'];
//         final String refreshToken = data['data']['refreshToken'];

//         // Store tokens securely
//         await _storage.write(key: 'accessToken', value: accessToken);
//         await _storage.write(key: 'refreshToken', value: refreshToken);

//         return true; // Signup successful
//       } else {
//         throw Exception('Signup failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Signup failed: $e');
//     }
//   }
// }