// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class GoogleSignInHelper {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   // Sign in with Google
//   Future<User?> signInWithGoogle() async {
//     try {
//       // Trigger the Google sign-in flow
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

//       if (googleUser == null) {
//         return null; // User canceled the sign-in
//       }

//       // Obtain the authentication details
//       final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//       // Create a new credential for Firebase authentication
//       final OAuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       // Sign in to Firebase with the credential
//       final UserCredential userCredential = await _auth.signInWithCredential(credential);

//       return userCredential.user;
//     } catch (error) {
//       print("Error signing in with Google: $error");
//       return null;
//     }
//   }

//   // Sign out
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _auth.signOut();
//   }
// }
