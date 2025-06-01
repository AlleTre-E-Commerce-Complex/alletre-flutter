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
    return Container(
      height: isAuthenticated ? 60 : 70, // Increased height for unauthenticated users
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        color: primaryColor,
      ),
      child: isAuthenticated
          ? _buildAuthenticatedNavBar(context)
          : _buildUnauthenticatedNavBar(context),
    );
  }

  Widget _buildAuthenticatedNavBar(BuildContext context) {
    final tabIndex = Provider.of<TabIndexProvider>(context).selectedIndex;

    return Theme(
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
    );
  }

  Widget _buildUnauthenticatedNavBar(BuildContext context) {
    return SizedBox(
      height: 80, // Adjusted height to make buttons more spacious
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildFixedSizeButton(
            text: 'Login',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LoginPage()),
            ),
            backgroundColor: secondaryColor,
            borderColor: primaryColor,
            textStyle: Theme.of(context).textTheme.bodySmall!,
          ),
          buildFixedSizeButton(
            text: 'Sign Up',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignUpPage()),
            ),
            backgroundColor: primaryColor,
            borderColor: secondaryColor,
            textStyle: Theme.of(context).textTheme.bodyMedium!,
          ),
        ],
      ),
    );
  }
}
