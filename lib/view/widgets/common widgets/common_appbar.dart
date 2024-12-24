import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CommonAppBar extends StatelessWidget {
  const CommonAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: false, // Keeps it off-screen when scrolling down
      floating: true, // Makes it appear only when scrolling up
      backgroundColor: primaryColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: secondaryColor, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: SizedBox(
        width: 210,
        height: 31,
        child: SvgPicture.asset(
          'assets/images/alletre_header.svg',
        ),
      ),
    );
  }
}
