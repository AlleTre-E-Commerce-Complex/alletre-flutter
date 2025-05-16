// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/controller/helpers/address_service.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_card.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/search_field_widget.dart';
import '../auction screen/product_details_screen.dart';
import '../../../utils/auth_helper.dart';

class AllAuctionsScreen extends StatelessWidget {
  final String title;
  final UserModel user;
  final List<AuctionItem> auctions;
  final String placeholder;

  const AllAuctionsScreen({
    super.key,
    required this.user,
    required this.title,
    required this.auctions,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // debugPrint('AllAuctionsScreen build called with ${auctions.length} items');
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;
    // Get card height based on whether we're showing auctions or listed products
    final cardHeight = getCardHeight(title,
        isAuctionProduct: title == 'Similar Products'
            ? auctions.firstOrNull?.isAuctionProduct ?? false
            : title.contains('Auction'));

    // Create a filtered list based on the search query from AuctionProvider
    final auctionProvider = context.watch<AuctionProvider>();
    final filteredAuctions = auctionProvider.searchQuery.isEmpty
        ? auctions
        : auctions
            .where((auction) => auction.title
                .toLowerCase()
                .contains(auctionProvider.searchQuery.toLowerCase()))
            .toList();

    // debugPrint('Filtered auctions count: ${filteredAuctions.length}');

    return Scaffold(
      appBar: NavbarElementsAppbar(
        appBarTitle: title,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 9),
          SearchFieldWidget(
            isNavigable: false,
            query: auctionProvider.searchQuery,
            onChanged: (value) {
              auctionProvider.searchItems(value);
            },
          ),
          const SizedBox(height: 9),
          // Expanded content below the search field
          Expanded(
            child: filteredAuctions.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          placeholder,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: onSecondaryColor, fontSize: 13),
                        ),
                      ),
                      if (title == "Live Auctions" ||
                          title == "Listed Products")
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(58, 32),
                            maximumSize: const Size(108, 32),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            // Address check before auction creation
                            final addresses =
                                await AddressService.fetchAddresses();
                            if (addresses.isEmpty) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const AddLocationScreen()),
                              );
                              return;
                            }
                            if (isLoggedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductDetailsScreen(),
                                ),
                              );
                            } else {
                              AuthHelper.showAuthenticationRequiredMessage(
                                  context);
                            }
                          },
                          child: Text(
                            title == "Live Auctions"
                                ? "Create Now"
                                : "List Product",
                            style: const TextStyle(
                                color: secondaryColor, fontSize: 9),
                          ),
                        ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: filteredAuctions.length,
                      itemBuilder: (context, index) {
                        return AuctionCard(
                          auction: filteredAuctions[index],
                          title: title,
                          user: user,
                          cardWidth: cardWidth,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
