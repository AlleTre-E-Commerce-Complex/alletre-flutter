import 'package:flutter/material.dart';

class EditProfileEmptySection extends StatelessWidget {
  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  const EditProfileEmptySection({
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 48),
        const SizedBox(height: 8),
        Text(text),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_circle),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
