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

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
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
              onPressed: userProvider.isLoading
                  ? null
                  : () async {
                if (formKey.currentState!.validate()) {
                        if (!userProvider.agreeToTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please agree to the Terms & Conditions'),
                              backgroundColor: errorColor,
                            ),
                          );
                          return;
                        }

                        final result = await userProvider.signup();
                        
                        if (!context.mounted) return;

                        if (result['success']) {
                          Navigator.pushReplacementNamed(context, AppRoutes.login);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result['message'].toString()),
                              backgroundColor: errorColor,
                            ),
                          );
                        }
                      }
                    },
              child: userProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: secondaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
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
    );
  }
}
