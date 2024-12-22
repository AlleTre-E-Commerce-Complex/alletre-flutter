import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/obscure_password_field.dart';
import 'package:flutter/material.dart';

class SignupFormFields extends StatelessWidget {
  const SignupFormFields({super.key});

  @override
  Widget build(BuildContext context) {
    bool isCheckboxChecked = false; // Track the state within the builder

    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person),
            labelText: 'Full Name',
            hintText: 'Enter your name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.phone),
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
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
        const SizedBox(height: 16),
        const ObscurePasswordField(
          labelText: 'Confirm Password',
          hintText: 'Enter your password again',
        ),
        const SizedBox(height: 12),
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
                  'I agree to the ',
                  style: TextStyle(fontSize: 15, color: onSecondaryColor, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Terms & Conditions page or perform an action
                  },
                  child: const Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 15,
                      color: surfaceColor,
                      fontWeight: FontWeight.w500,
                      decorationColor: surfaceColor,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
