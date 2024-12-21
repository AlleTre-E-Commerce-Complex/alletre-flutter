import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SignupButtons extends StatelessWidget {
  const SignupButtons({super.key});

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {},
          child: const Text('Create Account',
              style: TextStyle(fontSize: 15, color: secondaryColor)),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(child: Divider(color: Colors.grey)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('OR',
                  style: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: Divider(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.g_mobiledata_outlined, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Continue with Google',
                style: TextStyle(color: Colors.black, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.apple_outlined, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Continue with Apple',
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook_outlined, color: Colors.black),
              SizedBox(width: 8),
              Text(
                'Continue with Facebook',
                style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Already have an account?   ',
              style: TextStyle(
                fontSize: 14,
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Handle the tap action for "Login Now"
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
        )
      ],
    );
  }
}
