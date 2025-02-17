import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../auction card widgets/auction_countdown.dart';

class AuctionListWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AuctionItem> auctions;
  final bool isLoading;
  final String? error;

  const AuctionListWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.auctions,
    this.isLoading = false,
    this.error,
  });

  double _calculateListHeight(List<AuctionItem> auctions) {
    try {
      final now = DateTime.now();
      // Check if any auction is active (between start and expiry date)
      bool hasActiveAuctions = auctions.any((auction) => 
        auction.startDate.isBefore(now) && auction.expiryDate.isAfter(now)
      );
      return hasActiveAuctions ? 270 : 240;
    } catch (e) {
      print('Error calculating list height: $e');
      return 270; // Default height if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 2), // Spacing before subtitle
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: greyColor, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (error != null)
            Center(
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                    ),
              ),
            )
          else if (auctions.isEmpty)
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'No auctions available',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
          // Horizontal scrollable list of cards
          SizedBox(
            // height: auctions.any((auction) => auction.startDate.isBefore(DateTime.now())) ? 240 : 270,
            height: _calculateListHeight(auctions),
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
    String displayStatus = status;

    // Handle different status cases
    if (status == "WAITING_FOR_PAYMENT") {
      displayStatus = "SOLD";
    } else if (status == "IN_SCHEDULED") {
      displayStatus = "SCHEDULED";
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

  bool isSvg(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path;
    final String extension = path.split('.').last.toLowerCase();
    return extension == 'svg';
  }

   String getRemainingTime(DateTime startDate) {
    final DateTime now = DateTime.now();
    final Duration difference = startDate.isAfter(now) ? startDate.difference(now) : Duration.zero;

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) remaining';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) remaining';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute(s) remaining';
    } else {
      return 'Auction started';
    }
  }

  Widget _buildAuctionCard(BuildContext context, AuctionItem auction) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;

    return SizedBox(
      width: cardWidth,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: borderColor),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Inner Card for Image
                Card(
                  color: placeholderColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.all(0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 120,
                      child: auction.imageLinks.isNotEmpty
                          ? isSvg(auction.imageLinks.first)
                              ? SvgPicture.network(
                                  auction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (context) => Container(
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
                              : Image.network(
                                  auction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
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
                  padding: const EdgeInsets.only(
                      left: 8.0, right: 8.0, top: 10.0, bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildStatusText(context, auction.status),
                      const SizedBox(height: 5),
                      Text(
                        auction.title,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 1),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: onSecondaryColor, width: 1.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'AED ${auction.startBidAmount}',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontWeight: FontWeight.w600, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Total Bids: ${auction.bids}",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge!
                            .copyWith(color: primaryVariantColor, fontSize: 10),
                      ),
                      const SizedBox(height: 4),
                      AuctionCountdown(startDate: auction.startDate),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildIconButton(Icons.bookmark_outline_outlined),
                    const SizedBox(width: 8),
                    _buildIconButton(FontAwesomeIcons.shareFromSquare),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 14, color: onSecondaryColor),
    );
  }
}
