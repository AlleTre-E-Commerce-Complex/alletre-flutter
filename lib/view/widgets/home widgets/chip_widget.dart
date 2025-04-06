import 'package:flutter/material.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/helpers/chip_widget_helper.dart';
import 'package:alletre_app/view/screens/categories%20screen/categories_page.dart';
import 'package:alletre_app/view/screens/wishlist%20screen/wishlist_screen.dart';
import 'package:alletre_app/view/screens/wallet%20screen/wallet_screen.dart';
import 'package:alletre_app/model/user_model.dart';

class ChipWidget extends StatelessWidget {
  final String? title;
  const ChipWidget({super.key, this.title});

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
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WalletScreen()));
            },
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
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WishlistScreen(
                          title: title ?? '', user: UserModel.empty())));
            },
          ),
        ],
      ),
    );
  }
}
