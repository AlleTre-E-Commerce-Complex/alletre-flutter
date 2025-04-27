import 'package:flutter/material.dart';

/// Shows a SnackBar with a cleaned error message (removes all 'Exception:' prefixes).
void showError(BuildContext context, dynamic e) {
  String errorMsg = e.toString();
  while (errorMsg.trim().toLowerCase().startsWith('exception:')) {
    errorMsg = errorMsg.substring(10).trim();
  }
  // Standardize session expired messages
  if (errorMsg.toLowerCase().contains('jwt expired') ||
      errorMsg.toLowerCase().contains('token error') ||
      errorMsg.toLowerCase().contains('session expired')) {
    errorMsg = 'Session expired. Please login again';
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Center(child: Text(errorMsg))),
  );
}
