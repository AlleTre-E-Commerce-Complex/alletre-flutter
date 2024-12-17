import 'package:flutter/material.dart';

/// Helper function to build reusable Chip widgets
Widget buildCustomChip({
  required IconData icon,
  required String label,
  required Color backgroundColor,
  required TextStyle labelStyle,
}) {
  return Chip(
    avatar: Icon(icon, color: labelStyle.color),
    label: Text(label),
    backgroundColor: backgroundColor,
    labelStyle: labelStyle,
  );
}