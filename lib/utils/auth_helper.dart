// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'themes/app_theme.dart';

class AuthHelper {
  static const _storage = FlutterSecureStorage();

  /// Check if user is authenticated by checking for access token
  static Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  /// Show a snackbar message for unauthenticated users
  static void showAuthenticationRequiredMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Center(child: Text('This action requires user login')),
        backgroundColor: avatarColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Handle an action that requires authentication
  static Future<bool> handleAuthenticatedAction(
    BuildContext context,
    VoidCallback action,
  ) async {
    if (await isAuthenticated()) {
      action();
      return true;
    } else {
      showAuthenticationRequiredMessage(context);
      return false;
    }
  }
}
