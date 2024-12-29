import 'package:alletre_app/utils/routes/named_routes.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class NavBarUtils {
  // Bottom navbar for authenticated users
  static Widget buildAuthenticatedNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        buildNavItem(context, 'Home', Icons.home, AppRoutes.home),
        buildNavItem(
            context, 'Purchases', Icons.shopping_cart, AppRoutes.purchases),
        buildNavItem(context, 'My Bids', Icons.gavel, AppRoutes.bids),
        buildNavItem(context, 'Profile', Icons.person, AppRoutes.profile),
      ],
    );
  }

  // Reusable method to build the icon-text navigation items for authenticated users
  static Widget buildNavItem(
      BuildContext context, String title, IconData icon, String route) {
    // Check if the current route matches the item's route
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: isSelected ? selectedIndex : secondaryColor,
          ),
          const SizedBox(height: 5), // Spacing between icon and text
          Text(
            title,
            style: TextStyle(
              color: isSelected ? selectedIndex : secondaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
