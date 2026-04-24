import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class EditProfileLoginOption extends StatelessWidget {
  final String svgPath;
  final String label;
  final bool isConnected;
  final VoidCallback onTap;

  const EditProfileLoginOption({
    super.key,
    required this.svgPath,
    required this.label,
    required this.isConnected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBgColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 15,
              height: 15,
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
            if (isConnected)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              const Icon(Icons.link_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}
