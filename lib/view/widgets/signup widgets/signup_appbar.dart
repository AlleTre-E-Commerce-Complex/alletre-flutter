import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SignUpAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SignUpAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back,color: secondaryColor, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: SizedBox(
        width: 210,
        height: 31,
        child: SvgPicture.asset(
          'assets/images/alletre_header.svg'
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}