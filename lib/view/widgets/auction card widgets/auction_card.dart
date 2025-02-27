// import 'package:alletre_app/controller/providers/auction_provider.dart';
// import 'package:alletre_app/controller/providers/wishlist_provider.dart';
// import 'package:alletre_app/utils/extras/search_highlight.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:alletre_app/model/auction_item.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import '../auction card widgets/auction_countdown.dart';
// import '../auction card widgets/image_placeholder.dart';
// import '../../screens/item_details/item_details.dart';

// class AuctionCard extends StatelessWidget {
//   final AuctionItem auction;
//   final String title;
//   final double cardWidth;

//   const AuctionCard({
//     super.key,
//     required this.auction,
//     required this.title,
//     required this.cardWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: cardWidth,
//       child: Card(
//         margin: const EdgeInsets.only(right: 5),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10),
//           side: BorderSide(color: borderColor),
//         ),
//         child: Stack(
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Image Section
//                 Card(
//                   margin: const EdgeInsets.all(0),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(10),
//                     child: SizedBox(
//                       height: 120,
//                       child: auction.imageLinks.isNotEmpty
//                           ? _isSvg(auction.imageLinks.first)
//                               ? SvgPicture.network(
//                                   auction.imageLinks.first,
//                                   width: double.infinity,
//                                   fit: BoxFit.contain,
//                                   placeholderBuilder: (context) =>
//                                       const PlaceholderImage(),
//                                 )
//                               : Image.network(
//                                   auction.imageLinks.first,
//                                   width: double.infinity,
//                                   fit: BoxFit.contain,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       const PlaceholderImage(),
//                                 )
//                           : const PlaceholderImage(),
//                     ),
//                   ),
//                 ),

//                 // Content Section
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Status (if not Listed Products)
//                         if (title != 'Listed Products') ...[
//                           _buildStatusText(context, auction.status),
//                           const SizedBox(height: 5),
//                         ],
//                         // Title
//                         SizedBox(
//                           height: 34,
//                           child: Consumer<AuctionProvider>(
//                             builder: (context, auctionProvider, child) {
//                               return HighlightedText(
//                                 fullText: auction.title,
//                                 query: auctionProvider.searchQuery,
//                                 normalStyle: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .copyWith(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                 highlightStyle: Theme.of(context)
//                                     .textTheme
//                                     .bodyLarge!
//                                     .copyWith(
//                                       fontSize: 12,
//                                       fontWeight: FontWeight.w600,
//                                       backgroundColor: Colors.yellow,
//                                     ),
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                               );
//                             },
//                           ),
//                         ),

//                         const SizedBox(height: 10),
//                         // Price
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 7,
//                             vertical: 1,
//                           ),
//                           decoration: BoxDecoration(
//                             border:
//                                 Border.all(color: onSecondaryColor, width: 1.2),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             'AED ${title == 'Listed Products' ? NumberFormat.decimalPattern().format(double.tryParse(auction.productListingPrice) ?? 0.0) : NumberFormat.decimalPattern().format(double.tryParse(auction.startBidAmount))}',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .labelSmall!
//                                 .copyWith(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 10,
//                                 ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         // Location/Bids Section
//                         SizedBox(
//                           height: title == "Listed Products" ? 42 : 12,
//                           child: title == "Listed Products"
//                               ? Text.rich(
//                                   TextSpan(
//                                     children: [
//                                       TextSpan(
//                                         text: "Location:\n",
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .labelLarge!
//                                             .copyWith(
//                                               color: primaryVariantColor,
//                                               fontSize: 10,
//                                             ),
//                                       ),
//                                       TextSpan(
//                                         text: auction.location,
//                                         style: Theme.of(context)
//                                             .textTheme
//                                             .labelLarge!
//                                             .copyWith(
//                                               color: primaryVariantColor,
//                                               fontSize: 10,
//                                             ),
//                                       ),
//                                     ],
//                                   ),
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                 )
//                               : Text(
//                                   "Total Bids: ${auction.bids}",
//                                   style: Theme.of(context)
//                                       .textTheme
//                                       .labelLarge!
//                                       .copyWith(
//                                         color: primaryVariantColor,
//                                         fontSize: 10,
//                                       ),
//                                 ),
//                         ),
//                         const SizedBox(height: 9),
//                         // Countdown Section
//                         if (title != 'Expired Auctions' && title != 'Listed Products')
//                           AuctionCountdown(
//                             startDate: auction.startDate,
//                             endDate: auction.expiryDate,
//                           ),
//                         if (title == "Listed Products") ...[
//                           Text(
//                             "Listed: ${timeago.format(auction.createdAt, locale: 'en_custom')}",
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .labelLarge!
//                                 .copyWith(
//                                   color: primaryVariantColor,
//                                   fontSize: 10,
//                                 ),
//                           ),
//                           const SizedBox(height: 10),
//                           // View Details Button
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               minimumSize: const Size(double.infinity, 32),
//                               backgroundColor: primaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                             ),
//                             onPressed: () => _navigateToDetails(context, auction),
//                             child: const Text(
//                               'View Details',
//                               style: TextStyle(
//                                 color: secondaryColor,
//                                 fontSize: 11,
//                               ),
//                             ),
//                           ),
//                         ],
//                         // Auction Card Action Buttons
//                         if (title != 'Listed Products' &&
//                             title != 'Expired Auctions') ...[
//                           const SizedBox(height: 10),
//                           if (auction.hasBuyNow)
//                             Row(
//                               children: [
//                                 SizedBox(
//                                   width: 63,
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       minimumSize: const Size(0, 31),
//                                       backgroundColor: primaryColor,
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4),
//                                     ),
//                                     onPressed: () => _navigateToDetails(context, auction),
//                                     child: const Text(
//                                       'Bid Now',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: secondaryColor,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 SizedBox(
//                                   width: 63,
//                                   child: ElevatedButton(
//                                     style: ElevatedButton.styleFrom(
//                                       minimumSize: const Size(0, 31),
//                                       backgroundColor: secondaryColor,
//                                       side:
//                                           const BorderSide(color: primaryColor),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(6),
//                                       ),
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 4),
//                                     ),
//                                     onPressed: () => _navigateToDetails(context, auction),
//                                     child: const Text(
//                                       'Buy Now',
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                         color: primaryColor,
//                                         fontSize: 10,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           else
//                             ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 minimumSize: const Size(double.infinity, 32),
//                                 backgroundColor: primaryColor,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                               ),
//                               onPressed: () => _navigateToDetails(context, auction),
//                               child: const Text(
//                                 'Bid Now',
//                                 style: TextStyle(
//                                   color: secondaryColor,
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             if (title != 'Expired Auctions')
//               // Bookmark and Share buttons
//               Padding(
//                 padding: const EdgeInsets.all(6),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     if (title != 'Listed Products')
//                       _buildIconButton(
//                           context, FontAwesomeIcons.bookmark, auction),
//                     const SizedBox(width: 8),
//                     _buildIconButton(
//                         context, FontAwesomeIcons.shareFromSquare, auction),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToDetails(BuildContext context, AuctionItem auction) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => ItemDetailsScreen(
//           item: auction,
//           title: title,
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusText(BuildContext context, String status) {
//     final baseColor = getStatusColor(status);
//     String displayStatus = status;

//     if (status == "WAITING_FOR_PAYMENT") {
//       displayStatus = "SOLD";
//     } else if (status == "IN_SCHEDULED") {
//       displayStatus = "SCHEDULED";
//     } else if (status == "CANCELLED_BEFORE_EXP_DATE") {
//       displayStatus = "CANCELLED";
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//       decoration: BoxDecoration(
//         color: baseColor.withAlpha(26),
//         borderRadius: BorderRadius.circular(4),
//       ),
//       child: Text(
//         displayStatus,
//         style: TextStyle(
//           fontSize: 7,
//           color: getStatusColor(status),
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildIconButton(
//       BuildContext context, IconData icon, AuctionItem auction) {
//     final wishlistProvider = Provider.of<WishlistProvider>(context);
//     final isWishlisted = wishlistProvider.isWishlisted(auction.id);

//     return Container(
//       decoration: BoxDecoration(
//         color: buttonBgColor,
//         shape: BoxShape.circle,
//       ),
//       padding: const EdgeInsets.all(6),
//       child: GestureDetector(
//         onTap: () async {
//           if (icon == FontAwesomeIcons.bookmark) {
//             wishlistProvider.toggleWishlist(auction);
//           } else if (icon == FontAwesomeIcons.shareFromSquare) {
//             await Share.share(
//               'Check out this auction: ${auction.title}\nStarting bid: AED ${auction.startBidAmount}',
//               subject: 'Interesting Auction on Alletre',
//             );
//           }
//         },
//         child: Icon(
//           icon == FontAwesomeIcons.bookmark && isWishlisted
//               ? Icons.bookmark
//               : icon,
//           size: 12,
//           color: icon == FontAwesomeIcons.bookmark && isWishlisted
//               ? primaryColor
//               : onSecondaryColor,
//         ),
//       ),
//     );
//   }

//   bool _isSvg(String url) {
//     final Uri uri = Uri.parse(url);
//     final String path = uri.path;
//     final String extension = path.split('.').last.toLowerCase();
//     return extension == 'svg';
//   }
// }

import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/utils/extras/search_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../auction card widgets/auction_countdown.dart';
import '../auction card widgets/image_placeholder.dart';
import '../../screens/item_details/item_details.dart';
class AuctionCard extends StatelessWidget {
  final AuctionItem auction;
  final String title;
  final double cardWidth;
  const AuctionCard({
    super.key,
    required this.auction,
    required this.title,
    required this.cardWidth,
  });
  @override
  Widget build(BuildContext context) {
    // Determine spacing based on the auction type
    final double titleToBidSpacing = title == 'Expired Auctions' ? 0 : 10;
    
    return SizedBox(
      width: cardWidth,
      child: Card(
        margin: const EdgeInsets.only(right: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Card(
                  margin: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 120,
                      child: auction.imageLinks.isNotEmpty
                          ? _isSvg(auction.imageLinks.first)
                              ? SvgPicture.network(
                                  auction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (context) =>
                                      const PlaceholderImage(),
                                )
                              : Image.network(
                                  auction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const PlaceholderImage(),
                                )
                          : const PlaceholderImage(),
                    ),
                  ),
                ),
                // Content Section
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status (if not Listed Products)
                        if (title != 'Listed Products') ...[
                          _buildStatusText(context, auction.status),
                          const SizedBox(height: 5),
                        ],
                        // Title
                        SizedBox(
                          height: 34,
                          child: Consumer<AuctionProvider>(
                            builder: (context, auctionProvider, child) {
                              return HighlightedText(
                                fullText: auction.title,
                                query: auctionProvider.searchQuery,
                                normalStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                highlightStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      backgroundColor: Colors.yellow,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        // Reduced spacing for Expired Auctions
                        SizedBox(height: titleToBidSpacing),
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: onSecondaryColor, width: 1.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'AED ${title == 'Listed Products' ? NumberFormat.decimalPattern().format(double.tryParse(auction.productListingPrice) ?? 0.0) : NumberFormat.decimalPattern().format(double.tryParse(auction.startBidAmount))}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Location/Bids Section
                        SizedBox(
                          height: title == "Listed Products" ? 42 : 12,
                          child: title == "Listed Products"
                              ? Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Location:\n",
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              color: primaryVariantColor,
                                              fontSize: 10,
                                            ),
                                      ),
                                      TextSpan(
                                        text: auction.location,
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge!
                                            .copyWith(
                                              color: primaryVariantColor,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  "Total Bids: ${auction.bids}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge!
                                      .copyWith(
                                        color: primaryVariantColor,
                                        fontSize: 10,
                                      ),
                                ),
                        ),
                        const SizedBox(height: 9),
                        // Countdown Section
                        if (title != 'Expired Auctions' && title != 'Listed Products')
                          AuctionCountdown(
                            startDate: auction.startDate,
                            endDate: auction.expiryDate,
                          ),
                        if (title == "Listed Products") ...[
                          Text(
                            "Listed: ${timeago.format(auction.createdAt, locale: 'en_custom')}",
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(
                                  color: primaryVariantColor,
                                  fontSize: 10,
                                ),
                          ),
                          const SizedBox(height: 10),
                          // View Details Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 32),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () => _navigateToDetails(context, auction),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                        // Auction Card Action Buttons
                        if (title != 'Listed Products' &&
                            title != 'Expired Auctions') ...[
                          const SizedBox(height: 10),
                          if (auction.hasBuyNow)
                            Row(
                              children: [
                                SizedBox(
                                  width: 63,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 31),
                                      backgroundColor: primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    onPressed: () => _navigateToDetails(context, auction),
                                    child: const Text(
                                      'Bid Now',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: secondaryColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 63,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(0, 31),
                                      backgroundColor: secondaryColor,
                                      side:
                                          const BorderSide(color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    onPressed: () => _navigateToDetails(context, auction),
                                    child: const Text(
                                      'Buy Now',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 32),
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () => _navigateToDetails(context, auction),
                              child: const Text(
                                'Bid Now',
                                style: TextStyle(
                                  color: secondaryColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (title != 'Expired Auctions')
              // Bookmark and Share buttons
              Padding(
                padding: const EdgeInsets.all(6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (title != 'Listed Products')
                      _buildIconButton(
                          context, FontAwesomeIcons.bookmark, auction),
                    const SizedBox(width: 8),
                    _buildIconButton(
                        context, FontAwesomeIcons.shareFromSquare, auction),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  void _navigateToDetails(BuildContext context, AuctionItem auction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(
          item: auction,
          title: title,
        ),
      ),
    );
  }
  Widget _buildStatusText(BuildContext context, String status) {
    final baseColor = getStatusColor(status);
    String displayStatus = status;
    if (status == "WAITING_FOR_PAYMENT") {
      displayStatus = "SOLD";
    } else if (status == "IN_SCHEDULED") {
      displayStatus = "SCHEDULED";
    } else if (status == "CANCELLED_BEFORE_EXP_DATE") {
      displayStatus = "CANCELLED";
    }
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
  Widget _buildIconButton(
      BuildContext context, IconData icon, AuctionItem auction) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isWishlisted(auction.id);
    return Container(
      decoration: BoxDecoration(
        color: buttonBgColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(6),
      child: GestureDetector(
        onTap: () async {
          if (icon == FontAwesomeIcons.bookmark) {
            wishlistProvider.toggleWishlist(auction);
          } else if (icon == FontAwesomeIcons.shareFromSquare) {
            await Share.share(
              'Check out this auction: ${auction.title}\nStarting bid: AED ${auction.startBidAmount}',
              subject: 'Interesting Auction on Alletre',
            );
          }
        },
        child: Icon(
          icon == FontAwesomeIcons.bookmark && isWishlisted
              ? Icons.bookmark
              : icon,
          size: 12,
          color: icon == FontAwesomeIcons.bookmark && isWishlisted
              ? primaryColor
              : onSecondaryColor,
        ),
      ),
    );
  }
  bool _isSvg(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path;
    final String extension = path.split('.').last.toLowerCase();
    return extension == 'svg';
  }
}
