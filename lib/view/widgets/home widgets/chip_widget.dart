import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';
import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChipWidget extends StatelessWidget {
  const ChipWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: buildCustomChip(
              icon: Icons.category,
              label: 'Categories',
              backgroundColor: buttonBgColor,
              labelStyle: const TextStyle(
                color: onSecondaryColor,
                fontSize: 12, 
              ),
              iconSize: 16, 
              onTap: () {
                context.read<TabIndexProvider>().updateIndex(11);
              },
            ),
          ),
          Expanded(
            child: buildCustomChip(
              icon: Icons.assignment,
              label: 'Wishlist',
              backgroundColor: buttonBgColor,
              labelStyle: const TextStyle(
                color: onSecondaryColor,
                fontSize: 13, 
              ),
              iconSize: 17, 
              onTap: () {
                Navigator.pushNamed(context, '/wishlist');
              },
            ),
          ),
        ],
      ),
    );
  }
}
