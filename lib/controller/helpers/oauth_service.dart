// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class OAuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   // Generic response handler
//   Future<Map<String, dynamic>> _handleAuthResponse(User? user, String oAuthType) async {
//     if (user == null) {
//       return {
//         'success': false,
//         'message': 'Authentication failed',
//       };
//     }

//     // Get the ID token
//     final idToken = await user.getIdToken();

//     try {
//       // Make API call to your backend
//       final response = await http.post(
//         Uri.parse('YOUR_API_ENDPOINT/auth'), // Replace with your actual endpoint
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({
//           'userName': user.displayName,
//           'email': user.email,
//           'idToken': idToken,
//           'phone': user.phoneNumber,
//           'oAuthType': oAuthType,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         return {
//           'success': true,
//           'data': data['data'],
//         };
//       } else if (response.statusCode == 401) {
//         return {
//           'success': false,
//           'message': 'You are not authorized',
//           'isBlocked': true,
//         };
//       } else {
//         return {
//           'success': false,
//           'message': 'Something went wrong. Please try again later.',
//         };
//       }
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Network error. Please try again.',
//       };
//     }
//   }

//   // Google Sign In
//   Future<Map<String, dynamic>> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return {
//           'success': false,
//           'message': 'Google sign in cancelled',
//         };
//       }

//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final userCredential = await _auth.signInWithCredential(credential);
//       return await _handleAuthResponse(userCredential.user, 'GOOGLE');
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Something went wrong. Please try again later.',
//       };
//     }
//   }

//   // Apple Sign In
//   Future<Map<String, dynamic>> signInWithApple() async {
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//       );

//       final oAuthCredential = OAuthProvider('apple.com').credential(
//         idToken: appleCredential.identityToken,
//         accessToken: appleCredential.authorizationCode,
//       );

//       final userCredential = await _auth.signInWithCredential(oAuthCredential);
//       return await _handleAuthResponse(userCredential.user, 'APPLE');
//     } catch (e) {
//       return {
//         'success': false,
//         'message': 'Something went wrong. Please try again later.',
//       };
//     }
//   }
// }