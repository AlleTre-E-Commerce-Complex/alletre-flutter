// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

Widget buildSuccessDialog(BuildContext context) {
  // Store the context in a variable that will be captured by the closure
  final navigatorContext = context;
  
  Future.delayed(const Duration(seconds: 2), () {
    // Check if the context is still mounted before using Navigator
    if (navigatorContext.mounted) {
      // Pop the dialog
      Navigator.of(navigatorContext).pop();
      // Navigate to the desired screen
      Navigator.pushReplacementNamed(navigatorContext, AppRoutes.home);
    }
  });

  return PopScope(
    canPop: false,
    child: Dialog(
      backgroundColor: secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: primaryColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Login Successful!',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back! You will be redirected to the home page.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

