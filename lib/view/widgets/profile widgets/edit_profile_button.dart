import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class EditProfileButton extends StatelessWidget {
  const EditProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = customTheme();

    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Add functionality for editing the profile
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: primaryColor,
          backgroundColor: buttonBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: dividerColor),
          ),
          elevation: 0,
        ),
        child: Text(
          "Edit Profile",
          style: theme.textTheme.bodyLarge!.copyWith(color: onSecondaryColor),
        ),
      ),
    );
  }
}
