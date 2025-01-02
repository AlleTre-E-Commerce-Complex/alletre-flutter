import 'package:flutter/material.dart';

class EditProfileEmptySection extends StatelessWidget {
  final IconData icon;
  final String text;
  final String actionLabel;
  final VoidCallback onTap;

  const EditProfileEmptySection({
    super.key,
    required this.icon,
    required this.text,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 48, color: Theme.of(context).iconTheme.color),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: Theme.of(context).hintColor)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.add_circle),
          label: Text(actionLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 30),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
