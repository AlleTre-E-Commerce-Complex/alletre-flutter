// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:provider/provider.dart';

Widget buildSuccessDialog(BuildContext context) {
  // Store the context in a variable that will be captured by the closure
  final navigatorContext = context;
  
  Future.delayed(const Duration(seconds: 2), () {
    // Check if the context is still mounted before using Navigator
    if (navigatorContext.mounted) {
      // // Pop the dialog
      // Navigator.of(navigatorContext).pop();
      // // Navigate to the desired screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreenContent()));

       // Pop the dialog
      Navigator.of(navigatorContext).pop();
      
      // Update the tab index to home (1)
      Provider.of<TabIndexProvider>(navigatorContext, listen: false).updateIndex(1);
      
      // Pop everything until we reach the MainStack
      Navigator.of(navigatorContext).popUntil((route) => route.isFirst);
      
      // Force rebuild of MainStack with new index
      Provider.of<TabIndexProvider>(navigatorContext, listen: false).notifyListeners();
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

