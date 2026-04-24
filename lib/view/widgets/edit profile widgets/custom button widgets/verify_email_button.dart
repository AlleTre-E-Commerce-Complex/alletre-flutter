import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class VerifyEmailButton extends StatelessWidget {
  final VoidCallback onPressed;

  const VerifyEmailButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 4.0),
      child: SizedBox(
        width: 62,
        height: 36,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            padding: EdgeInsets.zero,
          ),
          child: const Text(
            'Verify',
            style: TextStyle(color: secondaryColor, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
