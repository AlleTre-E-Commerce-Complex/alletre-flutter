import 'package:flutter/material.dart';

/// Helper function to build reusable Chip widgets
Widget buildCustomChip({
  required IconData icon,
  required String label,
  required Color backgroundColor,
  required TextStyle labelStyle,
  required VoidCallback onTap, // Add onTap parameter
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16), // Optional: Add ripple effect
    child: Chip(
      avatar: Icon(icon, color: labelStyle.color),
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: labelStyle,
    ),
  );
}
