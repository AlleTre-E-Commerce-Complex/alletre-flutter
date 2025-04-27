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

/// Maps backend technical errors to user-friendly readable messages.
String mapBackendErrorToUserMessage(String? backendMessage) {
  if (backendMessage == null || backendMessage.isEmpty) {
    return 'Something went wrong. Please try again';
  }

  final lowerMsg = backendMessage.toLowerCase();

  if (lowerMsg.contains('title')) {
    return 'Please provide a title for your product';
  } else if (lowerMsg.contains('category')) {
    return 'Please select a category';
  } else if (lowerMsg.contains('sub category')) {
    return 'Please select a sub-category';
  } else if (lowerMsg.contains('unauthorized')) {
    return 'Session expired. Please login again';
  } else if (lowerMsg.contains('server error')) {
    return 'Server is not responding. Please try again later';
  } else if (lowerMsg.contains('failed to save draft')) {
    return 'Could not save your draft. Please check your internet and try again';
  } else if (lowerMsg.contains('validation failed')) {
    return 'Please fill all required fields properly';
  }

  // Fallback default
  return 'Session expired. Please login again';
}