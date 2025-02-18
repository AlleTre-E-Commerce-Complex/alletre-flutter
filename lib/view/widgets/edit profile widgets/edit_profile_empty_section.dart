import 'package:alletre_app/utils/themes/app_theme.dart';
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

    final bool isEdit = actionLabel.toLowerCase().contains('edit');

    return Column(
      children: [
        Icon(icon, size: 48, color: avatarColor),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: avatarColor)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(
            isEdit ? Icons.edit_outlined : Icons.add_circle,
            color: secondaryColor,
          ),
          label: Text(actionLabel),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: secondaryColor,
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
