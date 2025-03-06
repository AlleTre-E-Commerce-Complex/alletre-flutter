// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/controller/services/apple_auth.dart';
import 'package:alletre_app/controller/services/google_auth.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:alletre_app/view/widgets/login%20widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final AppleAuthService _appleAuthService = AppleAuthService();
  final GlobalKey<FormState> formKey;

  LoginButtons({super.key, required this.formKey});

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
            //           if (!userProvider.validateLoginForm()) {
            //           final result = await userProvider.login();

            //           if (!context.mounted) return;

            //           if (result['success']) {
            //             Provider.of<LoggedInProvider>(context, listen: false).logIn();

            //             if (!context.mounted) return;

            //             // Show success dialog
            //             showDialog(
            //               context: context,
            //               barrierDismissible: false,
            //               builder: (context) => buildSuccessDialog(context),
            //             );
            //           } else {
            //             ScaffoldMessenger.of(context).hideCurrentSnackBar();
            //             ScaffoldMessenger.of(context).showSnackBar(
            //               SnackBar(
            //                 content: Text(result['message']),
            //                 backgroundColor: errorColor,
            //               ),
            //             );
            //           }
            //         }
            //         }
            //       },

            onPressed: userProvider.isLoading
                ? null
                : () async {
                    if (formKey.currentState!.validate()) {
                      if (!userProvider.validateLoginForm()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(userProvider.lastValidationMessage),
                            backgroundColor: avatarColor,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        return;
                      }

                      final result = await userProvider.login();

                      if (!context.mounted) return;

                      if (result['success']) {
                        Provider.of<LoggedInProvider>(context, listen: false)
                            .logIn();

                        // First update the tab index to home
                        Provider.of<TabIndexProvider>(context, listen: false)
                            .updateIndex(1);

                        if (!context.mounted) return;

                        // Show success dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => buildSuccessDialog(context),
                        );
                      } else {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message']),
                            backgroundColor: avatarColor,
                            duration: const Duration(seconds: 2),
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
                      'Login successful',
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
                        const Text('Google sign-in failed. Please try again.'),
                    backgroundColor: avatarColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            // userProvider.isLoading
            // ? null
            // : () async {
            //     final result = await userProvider.handleGoogleSignIn(context);

            //     if (!context.mounted) return;

            //     if (result['success']) {
            //       // Update logged in state
            //       Provider.of<LoggedInProvider>(context, listen: false).logIn();

            //       // Update tab index to home
            //       Provider.of<TabIndexProvider>(context, listen: false).updateIndex(1);

            //       // Show success dialog
            //       showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (context) => buildSuccessDialog(context),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(result['message']),
            //           backgroundColor: avatarColor,
            //           duration: const Duration(seconds: 2),
            //         ),
            //       );
            //     }
            //   },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/google_icon.svg',
                    width: 15, height: 15),
                const SizedBox(width: 10),
                const Text(
                  'Login with Google',
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
                      'Login successful',
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
                        const Text('Apple sign-in is not supported on this platform'),
                    backgroundColor: avatarColor,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            // userProvider.isLoading
            // ? null
            // : () async {
            //     final result = await userProvider.handleAppleSignIn(context);

            //     if (!context.mounted) return;

            //     if (result['success']) {
            //       Provider.of<LoggedInProvider>(context, listen: false).logIn();
            //       Provider.of<TabIndexProvider>(context, listen: false).updateIndex(1);

            //       showDialog(
            //         context: context,
            //         barrierDismissible: false,
            //         builder: (context) => buildSuccessDialog(context),
            //       );
            //     } else {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(
            //           content: Text(result['message']),
            //           backgroundColor: avatarColor,
            //           duration: const Duration(seconds: 2),
            //         ),
            //       );
            //     }
            //   },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset('assets/icons/apple_icon.svg',
                    width: 15, height: 15),
                const SizedBox(width: 10),
                const Text(
                  'Login with Apple',
                  style: TextStyle(color: primaryColor, fontSize: 14),
                ),
              ],
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
                  userProvider.resetSignupForm();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpPage()),
                  );
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
    });
  }
}
