import 'package:flutter/material.dart';

class EditProfileCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Widget actionButton;

  const EditProfileCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.actionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        subtitle: Text(value),
        trailing: actionButton,
      ),
    );
  }
}
