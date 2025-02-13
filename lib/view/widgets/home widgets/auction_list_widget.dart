import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

class AuctionListWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AuctionItem> auctions;

  const AuctionListWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.auctions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min ,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 4), // Spacing before subtitle
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: greyColor, fontSize: 12),
          ),
          const SizedBox(height: 10),
          // Horizontal scrollable list of cards
          SizedBox(
            height: 242, // Set the height for the scrollable area
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Make it horizontal
              itemCount: auctions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 7.0),
                  child: _buildAuctionCard(context, auctions[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStatusText(BuildContext context, String status) {
    final baseColor = getStatusColor(status);
    final displayStatus = status == "WAITING_FOR_PAYMENT" ? "SOLD" : status;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 7,
          color: getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAuctionCard(BuildContext context, AuctionItem auction) {
  final screenWidth = MediaQuery.of(context).size.width;
  final cardWidth = (screenWidth - 32 - 10) / 2;

  return SizedBox(
    width: cardWidth,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: buttonBgColor), 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inner Card for Image
          Card(
            color: placeholderColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 3,
            margin: const EdgeInsets.all(10), // Adding margin inside the outer card
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 120, // Increased the image height
                child: auction.imageLinks.isNotEmpty
                    ? Image.network(
                        auction.imageLinks.first,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: double.infinity,
                          alignment: Alignment.center,
                          color: greyColor,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        height: double.infinity,
                        alignment: Alignment.center,
                        color: greyColor,
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                        ),
                      ),
              ),
            ),
          ),
          // Auction Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      auction.title,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                     buildStatusText(context, auction.status),
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 10),
                    //   decoration: BoxDecoration(color: placeholderColor),
                    //   child: Text(
                    //     auction.status == "WAITING_FOR_PAYMENT" ? "SOLD" : auction.status,
                    //     style: TextStyle(
                    //       fontSize: 8,
                    //       color: getStatusColor(status),
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: onSecondaryColor, width: 1.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'AED ${auction.startBidAmount}',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Total Bids: ${auction.bids}",
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: primaryVariantColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}