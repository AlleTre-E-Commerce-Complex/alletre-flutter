// import 'package:alletre_app/model/auction_item.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:flutter/material.dart';

// class AuctionListWidget extends StatelessWidget {
//   final String title;
//   final String subtitle;
//   final List<AuctionItem> auctions;

//   const AuctionListWidget({
//     super.key,
//     required this.title,
//     required this.subtitle,
//     required this.auctions,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
//           ),
//           const SizedBox(height: 4), // Spacing before subtitle
//           Text(
//             subtitle,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                   color: greyColor, fontSize: 12 
//                 ),
//           ),
//           const SizedBox(height: 10),
//           ...auctions.map((auction) {
//             return Card(
//               margin: const EdgeInsets.only(bottom: 10),
//               child: ListTile(
//                 leading: auction.imageLinks.isNotEmpty
//                     ? Image.network(
//                         auction.imageLinks.first,
//                         width: 50,
//                         height: 50,
//                         errorBuilder: (context, error, stackTrace) =>
//                             const Icon(Icons.image_not_supported),
//                       )
//                     : const Icon(Icons.image_not_supported),
//                 title: Text(
//                   auction.title,
//                   style: Theme.of(context).textTheme.bodyLarge,
//                 ),
//                 subtitle: Text(
//                   auction.price,
//                   style: Theme.of(context).textTheme.bodyMedium,
//                 ),
//               ),
//             );
//           }),
//         ],
//       ),
//     );
//   }
// }

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 16),
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
          ...auctions.map((auction) => _buildAuctionCard(context, auction)),
        ],
      ),
    );
  }

  Widget _buildAuctionCard(BuildContext context, AuctionItem auction) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auction Image with Price Tag
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12)), // Rounded top corners
                child: auction.imageLinks.isNotEmpty
                    ? Image.network(
                        auction.imageLinks.first,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported, size: 50),
                      )
                    : const Icon(Icons.image_not_supported, size: 50),
              ),
              // Price Tag
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "AED ${auction.startBidAmount}",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Auction Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auction.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Total Bids: ${auction.bids}", // Placeholder - Update dynamically if needed
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                // Countdown Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   "Ending Time",
                    //   style: Theme.of(context)
                    //       .textTheme
                    //       .bodySmall
                    //       ?.copyWith(fontWeight: FontWeight.bold),
                    // ),
                    Text(
                      auction.timeRemaining(),
                      style: TextStyle(
                        color: auction.isActive()
                            ? Colors.red
                            : Colors.green, // Red if ending soon
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
