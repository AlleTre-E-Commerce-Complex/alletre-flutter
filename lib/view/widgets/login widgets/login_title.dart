import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome back!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: onSecondaryColor
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Kindly enter your details to continue",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}