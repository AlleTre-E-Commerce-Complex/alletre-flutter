// ignore_for_file: use_build_context_synchronously
import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/login%20widgets/success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LoginButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const LoginButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
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
            if (formKey.currentState!.validate()) {
              if (userProvider.validateLoginCredentials()) {
                // Update login state
                loggedinProvider.logIn();
                userProvider.resetCheckboxes();

                // Navigate to home using TabIndexProvider
                if (context.mounted) {
                  context
                      .read<TabIndexProvider>()
                      .updateIndex(1); // Index for HomeScreenContent

                  // Show success dialog
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => buildSuccessDialog(context),
                    );
                  }
                }
              } else {
                // Shows error message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid email or password'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('LOGIN',
              style: TextStyle(
                  fontSize: 16,
                  color: secondaryColor,
                  fontWeight: FontWeight.w600)),
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
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/google_icon.svg',
                  width: 15, height: 15),
              const SizedBox(width: 10),
              const Text(
                'Continue with Google',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
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
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/apple_icon.svg',
                  width: 15, height: 15),
              const SizedBox(width: 10),
              const Text(
                'Continue with Apple',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: primaryColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/facebook_icon.svg',
                  width: 15, height: 15),
              const SizedBox(width: 10),
              const Text(
                'Continue with Facebook',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
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
