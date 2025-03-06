// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/services/apple_auth.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/login%20screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/services/google_auth.dart';

class SignupButtons extends StatelessWidget {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final AppleAuthService _appleAuthService = AppleAuthService();
  final GlobalKey<FormState> formKey;

  SignupButtons({super.key, required this.formKey});

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
                          // if (context.mounted) {
                          //   UrlHandlerService.handleUrl(
                          //       'https://www.alletre.com/login', // The website login URL
                          //       context);
                          // }
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
          Row(
            children: [
              Expanded(child: Divider(color: dividerColor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('OR',
                    style: TextStyle(
                        color: dividerColor, fontWeight: FontWeight.w500)),
              ),
              Expanded(
                child: Divider(color: dividerColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: primaryColor),
              padding: const EdgeInsets.only(right: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              var user = await _googleAuthService.signInWithGoogle();
              if (user != null) {
                print("Signed in as ${user.user?.displayName}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registration successful',
                    ),
                    backgroundColor: activeColor,
                    duration: Duration(seconds: 3),
                  ),
                );

                Provider.of<LoggedInProvider>(context, listen: false)
                            .logIn();

                        // First update the tab index to home
                        Provider.of<TabIndexProvider>(context, listen: false)
                            .updateIndex(1);

                        if (!context.mounted) return;

                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                });
              } else {
                // Authentication failed or user canceled login
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('Google sign-up failed. Please try again.'),
                    backgroundColor: avatarColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/google_icon.svg',
                    width: 15, height: 15),
                const SizedBox(width: 10),
                const Text(
                  'Sign up with Google',
                  style: TextStyle(color: primaryColor, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: primaryColor),
              padding: const EdgeInsets.only(right: 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              var user = await _appleAuthService.signInWithApple();
              if (user != null) {
                print("Signed in as ${user.displayName}");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Registration successful',
                    ),
                    backgroundColor: activeColor,
                    duration: Duration(seconds: 3),
                  ),
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                });
              } else {
                // Authentication failed or user canceled login
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        const Text('Apple sign-up is not supported on this platform'),
                    backgroundColor: avatarColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/apple_icon.svg',
                    width: 15, height: 15),
                const SizedBox(width: 10),
                const Text(
                  'Sign up with Apple',
                  style: TextStyle(color: primaryColor, fontSize: 14),
                ),
              ],
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
                  userProvider.resetSignupForm();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
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
