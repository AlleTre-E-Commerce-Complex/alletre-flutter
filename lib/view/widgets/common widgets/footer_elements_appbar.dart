import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class NavbarElementsAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;

  const NavbarElementsAppbar({
    this.title,
    this.showBackButton = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: primaryColor,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: secondaryColor),
              onPressed: () => Navigator.pop(context), // Navigates back
            )
          : null,
      title: Text(
        title!,
        style: const TextStyle(
          color: secondaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
