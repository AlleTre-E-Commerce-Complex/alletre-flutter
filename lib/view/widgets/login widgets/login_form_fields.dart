import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/obscure_password_field.dart';
import 'package:flutter/material.dart';

class LoginFormFields extends StatelessWidget {
  const LoginFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    bool isCheckboxChecked = false; // Track the state within the builder

    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email),
            labelText: 'Email',
            hintText: 'Enter your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ObscurePasswordField(
          labelText: 'Password',
          hintText: 'Enter your password',
        ),
        const SizedBox(height: 8),
        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // StatefulBuilder for 'Remember Password' checkbox
    StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Row(
          children: [
            Transform.scale(
              scale: 0.8,
              child: Checkbox(
                value: isCheckboxChecked,
                onChanged: (value) {
                  setState(() {
                    isCheckboxChecked = value ?? false;
                  });
                },
              ),
            ),
            const Text(
              'Remember Password',
              style: TextStyle(
                fontSize: 15,
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    ),
    Padding(
      padding: const EdgeInsets.only(left: 15),
      child: GestureDetector(
        onTap: () {
          // Navigate to Forgot Password page or perform an action
        },
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            fontSize: 15,
            color: surfaceColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  ],
),

      ],
    );
  }
}
