import 'package:alletre_app/utils/theme/app_theme.dart';
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
            prefixIcon: const Icon(Icons.person),
            labelText: 'Full Name',
            hintText: 'Enter your name exactly as it appears on your Emirates ID or Passport',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.email),
            labelText: 'Your Email',
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
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            labelText: 'Password',
            hintText: 'Enter your password',
            suffixIcon: const Icon(Icons.visibility_off),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock),
            labelText: 'Confirm Password',
            hintText: 'Enter your password again',
            suffixIcon: const Icon(Icons.visibility_off),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Row(
              children: [
                Checkbox(
                  value: isCheckboxChecked,
                  onChanged: (value) {
                    setState(() {
                      isCheckboxChecked = value ?? false;
                    });
                  },
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
