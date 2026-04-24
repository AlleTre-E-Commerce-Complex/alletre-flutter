import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class SignUpTitle extends StatelessWidget {
  const SignUpTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's create your account.",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: onSecondaryColor
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Begin the bidding experience now!",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}