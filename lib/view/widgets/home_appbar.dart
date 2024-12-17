import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/utils/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.watch<LanguageProvider>().currentLanguage;

    return AppBar(
      toolbarHeight: 58,
      backgroundColor: Theme.of(context).primaryColor,
      title: SizedBox(
        width: 74,
        child: SvgPicture.asset(
          'assets/images/alletre_header.svg',
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            context.read<LanguageProvider>().toggleLanguage();
          },
          child: SizedBox(
            width: 185,
            child: Text(
              currentLanguage,
              style: TextStyle(
                color: secondaryColor,
                fontSize: currentLanguage == 'English' ? 13 : 17,
                fontWeight: currentLanguage == 'English'
                    ? FontWeight.w500
                    : FontWeight.w600,
              ),
              textDirection: TextDirection.ltr,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(58);
}
