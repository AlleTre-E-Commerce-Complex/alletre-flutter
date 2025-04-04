import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_card.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/home widgets/search_field_widget.dart';
import '../auction screen/product_details_screen.dart';
import '../login screen/login_page.dart';

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
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;
    final cardHeight = getCardHeight(title);

    // Create a filtered list based on the search query from AuctionProvider
    final auctionProvider = context.watch<AuctionProvider>();
    final filteredAuctions = auctionProvider.searchQuery.isEmpty
        ? auctions
        : auctions
            .where((auction) =>
                auction.title
                    .toLowerCase()
                    .contains(auctionProvider.searchQuery.toLowerCase()))
            .toList();

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
                              .copyWith(
                                  color: onSecondaryColor, fontSize: 13),
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
                          onPressed: () {
                            if (title == "Live Auctions") {
                              isLoggedIn ? Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen())) : Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                            } else if (title == "Listed Products") {
                              isLoggedIn ? Navigator.push(context, MaterialPageRoute(builder: (context) => const ProductDetailsScreen())) : Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
