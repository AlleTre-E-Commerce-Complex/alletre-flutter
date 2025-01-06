import 'package:flutter/material.dart';

/// Helper function to build reusable Chip widgets
Widget buildCustomChip({
  required IconData icon,
  required String label,
  required Color backgroundColor,
  required TextStyle labelStyle,
  required double iconSize,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16), // Optional: Add ripple effect
    child: SizedBox(
      child: Chip(
        avatar: Icon(icon, color: labelStyle.color, size: iconSize),
        label: Text(label),
        backgroundColor: backgroundColor,
        labelStyle: labelStyle,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    ),
  );
}
