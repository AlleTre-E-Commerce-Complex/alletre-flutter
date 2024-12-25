import 'package:alletre_app/controller/providers/language_provider.dart';
import 'package:alletre_app/utils/images/images.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.watch<LanguageProvider>().currentLanguage;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 56,
      backgroundColor: Theme.of(context).primaryColor,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Logo
          SvgPicture.asset(
            AppImages.header,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 90),
          // Language Text
          GestureDetector(
            onTap: () {
              context.read<LanguageProvider>().toggleLanguage();
            },
            child: Text(
              currentLanguage,
              style: const TextStyle(
                color: secondaryColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Notification Icon
          IconButton(
            icon: const Icon(Icons.notifications, color: secondaryColor, size: 19),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications Clicked!')),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
