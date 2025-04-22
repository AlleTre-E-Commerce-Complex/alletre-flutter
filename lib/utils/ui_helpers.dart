import 'package:flutter/material.dart';

/// Shows a SnackBar with a cleaned error message (removes all 'Exception:' prefixes).
void showError(BuildContext context, dynamic e) {
  String errorMsg = e.toString();
  while (errorMsg.trim().toLowerCase().startsWith('exception:')) {
    errorMsg = errorMsg.substring(10).trim();
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(errorMsg)),
  );
}
