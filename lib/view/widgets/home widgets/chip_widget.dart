import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/wishlist%20screen/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChipWidget extends StatelessWidget {
  final String? title;
  const ChipWidget({super.key, this.title});

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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            WishlistScreen(title: title ?? '')));
              },
            ),
          ),
        ],
      ),
    );
  }
}
