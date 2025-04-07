import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/wallet%20screen/wallet_screen.dart';
import 'package:alletre_app/view/screens/wishlist%20screen/wishlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../screens/login screen/login_page.dart';

class ChipWidget extends StatelessWidget {
  final String? title;
  const ChipWidget({super.key, this.title});

  Future<bool> _isAuthenticated() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  void _handleAuthenticatedNavigation(BuildContext context, Widget page) async {
    if (await _isAuthenticated()) {
      // User is authenticated, navigate to the requested page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      // User is not authenticated, show message and navigate to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to access this feature'),
          backgroundColor: errorColor,
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildCustomChip(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(
              color: onSecondaryColor,
              fontSize: 11,
            ),
            iconSize: 15,
            onTap: () => _handleAuthenticatedNavigation(
              context,
              const WalletScreen(),
            ),
          ),
          buildCustomChip(
            icon: Icons.category,
            label: 'Categories',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(
              color: onSecondaryColor,
              fontSize: 11,
            ),
            iconSize: 14,
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CategoriesPage()));
            },
          ),
          buildCustomChip(
            icon: Icons.assignment,
            label: 'Wishlist',
            backgroundColor: buttonBgColor,
            labelStyle: const TextStyle(
              color: onSecondaryColor,
              fontSize: 11,
            ),
            iconSize: 15,
            onTap: () => _handleAuthenticatedNavigation(
              context,
              WishlistScreen(title: '', user: UserModel.empty()),
            ),
          ),
        ],
      ),
    );
  }
}
