import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../auction card widgets/auction_countdown.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../auction card widgets/image_placeholder.dart';

class AuctionListWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AuctionItem> auctions;
  final bool isLoading;
  final String? error;
  final String placeholder;

  const AuctionListWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.auctions,
    this.isLoading = false,
    this.error,
    required this.placeholder,
  });

  double getCardHeight() {
    switch (title) {
      case "Live Auctions":
        return 338; // Taller to accommodate the countdown and the buttons
      case "Listed Products":
        return 332; // Tall enough for location and view details button
      case "Upcoming Auctions":
        return 290; // Bit shorter since no buttons
      default:
        return 250; // for expired auctions
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style:
                Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: greyColor, fontSize: 13),
          ),
          const SizedBox(height: 10),
          if (auctions.isEmpty)
            Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Center(
                    child: Text(
                      placeholder,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: onSecondaryColor, fontSize: 13),
                    ),
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
                      style:
                          const TextStyle(color: secondaryColor, fontSize: 9),
                    ),
                  ),
              ],
            )
          else
            SizedBox(
              height: getCardHeight(), // Fixed height for each section
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
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
                // Image Section
                Card(
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(10),
                  // ),
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
                          buildStatusText(context, auction.status),
                          const SizedBox(height: 5),
                        ],
                        // Title
                        SizedBox(
                          height: 32, // Fixed height for title
                          child: Text(
                            auction.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 10),
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
                        const SizedBox(height: 8),
                        // Countdown/Listed Time Section
                        if (title != 'Listed Products' &&
                            title != 'Expired Auctions')
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
                          const SizedBox(height: 5),
                          // View Details Button
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 32),
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {},
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
                        if (title == "Live Auctions") ...[
                          const SizedBox(height: 5),
                          if (auction.hasBuyNow)
                            // Two buttons in half-width
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
                                    onPressed: () {},
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
                                      side: const BorderSide(color: primaryColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                    ),
                                    onPressed: () {},
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
                            // Single full-width button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 32),
                                backgroundColor: primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              onPressed: () {},
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
            // Bookmark and Share buttons
            Padding(
              padding: const EdgeInsets.all(6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.bookmark_outline_outlined),
                  const SizedBox(width: 8),
                  _buildIconButton(FontAwesomeIcons.shareFromSquare),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStatusText(BuildContext context, String status) {
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

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(5),
      child: Icon(icon, size: 13, color: onSecondaryColor),
    );
  }

  bool isSvg(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path;
    final String extension = path.split('.').last.toLowerCase();
    return extension == 'svg';
  }
}
