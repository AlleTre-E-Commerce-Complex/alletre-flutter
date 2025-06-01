import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/home widgets/search_field_widget.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';

class WishlistScreen extends StatelessWidget {
  final String title;
  final UserModel user;

  const WishlistScreen({super.key, required this.title, required this.user});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;
    const cardHeight = 337;

    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Wishlist', showBackButton: true),
      body: Column(
        children: [
          const SizedBox(height: 9),
          SearchFieldWidget(
            isNavigable: false,
            onChanged: (value) {
              context.read<AuctionProvider>().searchItems(value);
            },
          ),
          const SizedBox(height: 9),

          // Expanded grid of wishlist items
          Expanded(
            child: Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, child) {
                final wishlisted = wishlistProvider.wishlistedAuctions;
                if (wishlisted.isEmpty) {
                  return const Center(
                    child: Text(
                      'No items in Wishlist',
                      style: TextStyle(color: onSecondaryColor),
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 20,
                    childAspectRatio: cardWidth / cardHeight,
                  ),
                  itemCount: wishlisted.length,
                  itemBuilder: (context, index) {
                    return AuctionCard(
                      auction: wishlisted[index],
                      title: title,
                      cardWidth: cardWidth,
                      user: user,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
