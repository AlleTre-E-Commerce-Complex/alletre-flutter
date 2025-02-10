// // lib/services/url_handler_service.dart
// import 'package:alletre_app/utils/routes/named_routes.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/material.dart';

// class UrlHandlerService {
//   static Future<void> handleUrl(String url, BuildContext context) async {
//     // Check if this is the website login URL
//     if (url.contains('alletre.com/login') || url.contains('www.alletre.com/login')) {
//       // Instead of opening the URL, navigate to the app's login page
//       Navigator.pushReplacementNamed(context, AppRoutes.login);
//     } else {
//       // For all other URLs, launch them normally
//       final Uri uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       }
//     }
//   }
// }