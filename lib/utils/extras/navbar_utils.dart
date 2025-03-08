import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavBarUtils {
  // Bottom navbar for authenticated users
  static Widget buildAuthenticatedNavBar(
    BuildContext context, {
    required Function(int) onTabChange,
  }) {
    final tabIndex = Provider.of<TabIndexProvider>(context).selectedIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildNavItem(context, 'Home', Icons.home, 1, tabIndex, onTabChange),
        buildNavItem(context, 'Purchases', Icons.shopping_cart, 7, tabIndex, onTabChange),
        buildNavItem(context, 'My Bids', Icons.gavel, 8, tabIndex, onTabChange),
        buildNavItem(context, 'Profile', Icons.person, 4, tabIndex, onTabChange),
      ],
    );
  }

  // Reusable method to build the icon-text navigation items for authenticated users
  static Widget buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    int index,
    int selectIndex,
    Function(int) onTabChange,
  ) {
    final isSelected = index == selectIndex;
    const selectedColor = selectedIndex;
    const unselectedColor = secondaryColor;

    return GestureDetector(
      onTap: () {
        onTabChange(index); // Updates the tab index when an item is tapped
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? selectedColor : unselectedColor,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: 11,
              fontWeight: FontWeight.w500
            ),
          ),
        ],
      ),
    );
  }
}
