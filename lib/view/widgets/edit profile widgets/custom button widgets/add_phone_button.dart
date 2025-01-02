import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class AddPhoneButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddPhoneButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, right: 29.0),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: primaryColor,
        ),
        child: IconButton(
          icon: const Icon(Icons.add_ic_call_sharp, color: Colors.white, size: 20),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
