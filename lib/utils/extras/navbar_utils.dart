import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottomNavBarUtils {
  // Bottom navbar for authenticated users
  static Widget buildAuthenticatedNavBar(
    BuildContext context, {
    required Function(int) onTabChange,
  }) {
    final tabIndex = Provider.of<TabIndexProvider>(context).selectedIndex;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(color: primaryColor),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: primaryColor,
          currentIndex: tabIndex,
          onTap: onTabChange,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedIndex,
          unselectedItemColor: secondaryColor,
          // backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Purchases',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gavel),
              label: 'My Bids',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
