import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dio/dio.dart';

class OAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return {'success': false, 'message': 'Sign in aborted'};

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();

      // Make API call to your backend
      final response = await _dio.post(
        'YOUR_API_ENDPOINT/auth',  // Replace with your actual endpoint
        data: {
          'userName': userCredential.user?.displayName,
          'email': userCredential.user?.email,
          'idToken': idToken,
          'phone': userCredential.user?.phoneNumber,
          'oAuthType': 'GOOGLE',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Authentication failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthProvider = OAuthProvider('apple.com');
      final credentialFirebase = oAuthProvider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credentialFirebase);
      final String? idToken = await userCredential.user?.getIdToken();

      // Make API call to your backend
      final response = await _dio.post(
        'YOUR_API_ENDPOINT/auth',  // Replace with your actual endpoint
        data: {
          'userName': '${credential.givenName} ${credential.familyName}',
          'email': credential.email,
          'idToken': idToken,
          'oAuthType': 'APPLE',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      } else {
        return {
          'success': false,
          'message': 'Authentication failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
