import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/view/widgets/auction card widgets/auction_card.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';

class AllAuctionsScreen extends StatelessWidget {
  final String title;
  final List<AuctionItem> auctions;
  final String placeholder;

  const AllAuctionsScreen({
    super.key,
    required this.title,
    required this.auctions,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;
    final cardHeight = getCardHeight(title);
    
    return Scaffold(
      appBar: NavbarElementsAppbar(
        title: title,
        showBackButton: true,
      ),
      body: auctions.isEmpty
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
                if (title == "Live Auctions" || title == "Listed Products")
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
                        context.read<TabIndexProvider>().updateIndex(19);
                      } else if (title == "Listed Products") {
                        context.read<TabIndexProvider>().updateIndex(20);
                      }
                    },
                    child: Text(
                      title == "Live Auctions" ? "Create Now" : "List Product",
                      style: const TextStyle(color: secondaryColor, fontSize: 9),
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
                  // Calculates childAspectRatio based on the desired height
                  childAspectRatio: cardWidth / cardHeight,
                ),
                itemCount: auctions.length,
                itemBuilder: (context, index) {
                  return AuctionCard(
                    auction: auctions[index],
                    title: title,
                    cardWidth: cardWidth,
                  );
                },
              ),
            ),
    );
  }
}