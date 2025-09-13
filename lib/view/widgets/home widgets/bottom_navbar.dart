import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/extras/text_button.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/login screen/login_page.dart';
import '../../screens/signup screen/signup_page.dart';

class BottomNavBar extends StatelessWidget {
  final bool isAuthenticated;
  final Function(int)? onTabChange;

  const BottomNavBar({
    super.key,
    this.isAuthenticated = false,
    this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    return isAuthenticated ? _buildAuthenticatedNavBar(context) : _buildUnauthenticatedNavBar(context);
  }

  Widget _buildAuthenticatedNavBar(BuildContext context) {
    final tabIndex = Provider.of<TabIndexProvider>(context).selectedIndex;

    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: primaryColor,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, "Home", 0, tabIndex),
            _buildNavItem(Icons.shopping_cart, "Purchases", 1, tabIndex),
            const SizedBox(width: 40), // space for FAB
            _buildNavItem(Icons.gavel, "My Bids", 2, tabIndex),
            _buildNavItem(Icons.person, "Profile", 3, tabIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, int selectedIndex) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onTabChange?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? primaryVariantColor : secondaryColor),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? primaryVariantColor : secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnauthenticatedNavBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildFixedSizeButton(
            text: 'Login',
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            backgroundColor: secondaryColor,
            borderColor: primaryColor,
            textStyle: Theme.of(context).textTheme.bodySmall!,
          ),
          buildFixedSizeButton(
            text: 'Sign Up',
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => SignUpPage(),
                ),
              );
            },
            backgroundColor: primaryColor,
            borderColor: secondaryColor,
            textStyle: Theme.of(context).textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }
}
