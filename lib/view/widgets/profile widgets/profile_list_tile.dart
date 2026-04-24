import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double defaultIconSize = 24.0;
    const double shareIconSize = 20.0;
    final double iconSize = icon == FontAwesomeIcons.shareFromSquare
        ? shareIconSize
        : defaultIconSize;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: buttonBgColor,
        child: Icon(icon, color: onSecondaryColor, size: iconSize),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
