// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const SignupButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () async {
            if (isLoading) return; // Prevent multiple presses
            isLoading = true;
            if (formKey.currentState!.validate()) {
              if (userProvider.agreeToTerms) {
                try {
                  await userProvider.signup();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                } catch (e) {
                  // Show error message
                  ScaffoldMessenger.of(context)
                      .hideCurrentSnackBar(); // Dismiss the current SnackBar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      key: UniqueKey(),
                      content: Text('Signup failed: $e'),
                      backgroundColor: errorColor,
                    ),
                  );
                } finally {
                  isLoading = false; // Reset loading state
                }
              } else {
                // Show error if terms are not agreed upon
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agree to the Terms & Conditions'),
                    backgroundColor: primaryColor,
                  ),
                );
              }
            } else {
              // Show generic error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Center(child: Text('Invalid registration')),
                  backgroundColor: primaryColor,
                  duration: Durations.extralong4,
                ),
              );
            }
          },
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 16,
              color: secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Login link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?  ',
              style: TextStyle(
                fontSize: 14,
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                userProvider.resetCheckboxes();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text(
                'Login Now',
                style: TextStyle(
                  fontSize: 14,
                  color: surfaceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
