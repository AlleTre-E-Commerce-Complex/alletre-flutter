// import 'package:alletre_app/utils/routes/named_routes.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class PlatformUtil {
//   static bool get isWebPlatform => kIsWeb;
  
//   static String getLoginUrl(bool requiresVerification) {
//     if (isWebPlatform) {
//       // Web login URL
//       return 'https://www.alletre.com/login';
//     } else {
//       // App login route
//       return AppRoutes.login;
//     }
//   }
  
//   static void handleLoginRedirect(BuildContext context, bool requiresVerification) {
//     final String loginDestination = getLoginUrl(requiresVerification);
    
//     if (isWebPlatform) {
//       // For web, launch the URL
//       launchUrl(Uri.parse(loginDestination));
//     } else {
//       // For app, use Navigator
//       Navigator.pushReplacementNamed(context, loginDestination);
//     }
//   }
// }