import 'package:flutter/material.dart';

Widget buildFixedSizeButton({
  required String text,
  required VoidCallback onPressed,
  required Color backgroundColor,
  required Color borderColor,
  required TextStyle textStyle,
}) {
  return SizedBox(
    width: 120, 
    height: 40,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        side: BorderSide(color: borderColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(text, style: textStyle),
    ),
  );
}
