import 'package:flutter/material.dart';

class SignupFormFields extends StatelessWidget {
  const SignupFormFields({super.key});

  @override
  Widget build(BuildContext context) {
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
        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.flag),
                  hintText: '+91',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.language),
            labelText: 'Select Nationality',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: [
            'India',
            'United Arab Emirates',
            'United States',
            'United Kingdom'
          ].map((nationality) {
            return DropdownMenuItem(
              value: nationality,
              child: Text(nationality),
            );
          }).toList(),
          onChanged: (value) {},
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
        Row(
          children: [
            Checkbox(
              value: true,
              onChanged: (value) {},
            ),
            const Text(
              'I accept the ',
              style: TextStyle(fontSize: 14),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
