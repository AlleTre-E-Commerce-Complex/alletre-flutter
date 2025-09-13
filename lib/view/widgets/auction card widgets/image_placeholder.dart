import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      color: greyColor,
      child: const Icon(
        Icons.image_not_supported,
        size: 50,
      ),
    );
  }
}
