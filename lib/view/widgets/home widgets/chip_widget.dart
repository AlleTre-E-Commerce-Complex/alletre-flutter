// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../../utils/auth_helper.dart';
import '../../../utils/themes/app_theme.dart';
import '../../screens/wallet screen/wallet_screen.dart';
import '../../screens/wishlist screen/wishlist_screen.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';

class ChipWidget extends StatelessWidget {
  final String? title;
  const ChipWidget({super.key, this.title});

  void _handleAuthenticatedNavigation(BuildContext context, Widget page) async {
    if (await AuthHelper.isAuthenticated()) {
      // User is authenticated, navigate to the requested page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    } else {
      // User is not authenticated, only show message
      AuthHelper.showAuthenticationRequiredMessage(context);
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
