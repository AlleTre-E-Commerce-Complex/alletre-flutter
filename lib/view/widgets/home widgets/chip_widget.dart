import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class ChipWidget extends StatelessWidget {
  const ChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCustomChip(
            icon: Icons.discount,
            label: 'Sell Now',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(color: onSecondaryColor),
            onTap: () {
              Navigator.pushNamed(context, '/sellNow'); // Example navigation
            },
          ),
          buildCustomChip(
            icon: Icons.category,
            label: 'Categories',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(color: onSecondaryColor),
            onTap: () {
              Navigator.pushNamed(context, '/categories');
            },
          ),
          buildCustomChip(
            icon: Icons.assignment,
            label: 'Wishlist',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(color: onSecondaryColor),
            onTap: () {
              Navigator.pushNamed(context, '/wishlist');
            },
          ),
        ],
      ),
    );
  }
}
