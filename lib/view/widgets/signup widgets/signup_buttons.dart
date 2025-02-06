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
    return Consumer<UserProvider>(builder: (context, userProvider, child) {
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
            // onPressed: userProvider.isLoading
            //     ? null
            //     : () async {
            //         if (formKey.currentState!.validate()) {
            //           if (!userProvider.agreeToTerms) {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               const SnackBar(
            //                 content:
            //                     Text('Please agree to the Terms & Conditions'),
            //                 backgroundColor: errorColor,
            //               ),
            //             );
            //             return;
            //           }

            //           final result = await userProvider.signup();

            //           if (!context.mounted) return;

            //           if (result['success']) {
            //             Navigator.pushReplacementNamed(
            //                 context, AppRoutes.login);
            //           } else {
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(
            //                 content: Text(result['message'].toString()),
            //                 backgroundColor: errorColor,
            //               ),
            //             );
            //           }
            //         }
            //       },

            onPressed: userProvider.isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      if (!userProvider.validateSignupForm()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userProvider.lastValidationMessage),
                            backgroundColor: avatarColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      final result = await userProvider.signup();

                      if (!context.mounted) return;

                      if (result['success']) {
                        // Show verification dialog
                        // showDialog(
                        //   context: context,
                        //   barrierDismissible: false,
                        //   builder: (BuildContext context) {
                        //     return AlertDialog(
                        //       title: const Text('Verification Required'),
                        //       content: const Text(
                        //         'A verification link has been sent to your email address. Please verify your email before logging in.',
                        //       ),
                        //       actions: [
                        //         TextButton(
                        //           onPressed: () {
                        //             Navigator.of(context).pop(); // Close dialog
                        //             Navigator.pushReplacementNamed(context, AppRoutes.login);
                        //           },
                        //           child: const Text('OK'),
                        //         ),
                        //       ],
                        //     );
                        //   },
                        // );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Registration successful! Please check your email for verification instructions.',
                            ),
                            backgroundColor: activeColor,
                            duration: Duration(seconds: 4),
                            // action: SnackBarAction(
                            //   label: 'GO TO LOGIN',
                            //   textColor: Colors.white,
                            //   onPressed: () {
                            //     Navigator.pushReplacementNamed(context, AppRoutes.login);
                            //   },
                            // ),
                          ),
                        );
                        // Navigate to login after a short delay
            //             Future.delayed(const Duration(seconds: 2), () {
            //   if (context.mounted) {
            //     PlatformUtil.handleLoginRedirect(
            //       context,
            //       result['requiresVerification'] ?? false
            //     );
            //   }
            // });
                        Future.delayed(const Duration(seconds: 2), () {
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                                context, AppRoutes.login);
                          }
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'].toString()),
                            backgroundColor: avatarColor,
                            duration: const Duration(seconds: 3),
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
    });
  }
}
