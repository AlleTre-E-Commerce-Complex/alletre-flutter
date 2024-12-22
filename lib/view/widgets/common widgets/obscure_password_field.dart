import 'package:flutter/material.dart';

class ObscurePasswordField extends StatefulWidget {
  final String labelText;
  final String hintText;

  const ObscurePasswordField({
    super.key,
    required this.labelText,
    required this.hintText,
  });

  @override
  State<ObscurePasswordField> createState() => _ObscurePasswordFieldState();
}

class _ObscurePasswordFieldState extends State<ObscurePasswordField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              obscureText = !obscureText;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
