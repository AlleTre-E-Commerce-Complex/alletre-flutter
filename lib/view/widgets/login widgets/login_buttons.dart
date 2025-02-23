// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/signup%20screen/signup_page.dart';
import 'package:alletre_app/view/widgets/login%20widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LoginButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
    // bool isLoading = false; // Add a loading state
    // final loggedinProvider =
    //     Provider.of<LoggedInProvider>(context, listen: false);

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
            Provider.of<TabIndexProvider>(context, listen: false).updateIndex(1);

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
                      MaterialPageRoute(
                        builder: (context) => SignUpPage()
                      ),
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
