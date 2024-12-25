import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class SignupButtons extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  const SignupButtons({super.key, required this.formKey});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            // Validating the form
            if (formKey.currentState!.validate()) {
              // Checks if user agreed to terms
              if (userProvider.agreeToTerms) {
                // Simulates user registration success
                // Navigates to the login page
                Navigator.pushReplacementNamed(context, AppRoutes.login);
                userProvider.resetCheckboxes();
              } else {
                // Shows error if terms are not agreed upon
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Agree to the Terms & Conditions'),
                    backgroundColor: primaryColor,
                  ),
                );
              }
            } else {
              // generic error message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Center(child: Text('Invalid registration')),
                    backgroundColor: primaryColor,
                    duration: Durations.extralong4),
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
        Row(
          children: [
            Expanded(child: Divider(color: dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'OR',
                style: TextStyle(
                  color: dividerColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: dividerColor),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Google button
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
        // Apple button
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
        // Facebook button
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
