// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/login%20widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LoginButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false; // Add a loading state
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final loggedinProvider =
        Provider.of<LoggedInProvider>(context, listen: false);

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
              try {
                await userProvider.login();
                loggedinProvider.logIn();

                // Show success dialog
                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => buildSuccessDialog(context),
                  ).then((_) {
                    if (context.mounted) {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.pushReplacementNamed(
                          context, AppRoutes.home); // Navigate to home
                    }
                  });
                }
              } catch (e) {
                // Show error message
                ScaffoldMessenger.of(context)
                    .hideCurrentSnackBar(); // Dismiss the current SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    key: UniqueKey(),
                    content: Text('Login failed: $e'),
                    backgroundColor: errorColor,
                  ),
                );
              } finally {
                isLoading = false; // Reset loading state
              }
            }
          },
          child: const Text(
            'LOGIN',
            style: TextStyle(
              fontSize: 16,
              color: secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account?  ",
              style: TextStyle(
                fontSize: 14,
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                userProvider.resetCheckboxes();
                Navigator.pushReplacementNamed(context, AppRoutes.signup);
              },
              child: const Text(
                'Register Now',
                style: TextStyle(
                  fontSize: 14,
                  color: surfaceColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
