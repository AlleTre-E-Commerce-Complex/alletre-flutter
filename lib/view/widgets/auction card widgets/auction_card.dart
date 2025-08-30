import 'package:alletre_app/app.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/controller/services/auction_details_service.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/auth_helper.dart';
import 'package:alletre_app/utils/extras/search_highlight.dart';
import 'package:alletre_app/view/screens/auction%20screen/payment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  final UserModel user;
  final String title;
  final double cardWidth;

  const AuctionCard({
    super.key,
    required this.auction,
    required this.user,
    required this.title,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Always get the latest auction object from provider
    final latestAuction = context.select<AuctionProvider, AuctionItem?>(
          (provider) => provider.getAuctionById(auction.id),
        ) ??
        auction;

    // Determine spacing based on the auction type
    const double titleToBidSpacing = 10;

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: title == 'Active' || title == 'Scheduled' || title == 'Sold' || title == 'Pending' || title == 'Waiting for Payment' || title == 'Expired' || title == 'Cancelled' ? 160 : 120, // Increased height for My Auctions page
                      child: latestAuction.imageLinks.isNotEmpty
                          ? _isSvg(latestAuction.imageLinks.first)
                              ? SvgPicture.network(
                                  latestAuction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (context) => const PlaceholderImage(),
                                )
                              : Image.network(
                                  auction.imageLinks.first,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) => const PlaceholderImage(),
                                )
                          : const PlaceholderImage(),
                    ),
                  ),
                ),
                // Content Section
                Expanded(
                  child: SingleChildScrollView(
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status (if not Listed Products)
                          if ((title != 'Listed Products' && title != 'Similar Products') || (title == 'Similar Products' && auction.isAuctionProduct)) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatusText(context, auction.status),
                                SizedBox(height: 22),
                                if (title == 'Active' || title == 'Scheduled' || title == 'Sold' || title == 'Pending' || title == 'Waiting for Payment' || title == 'Expired' || title == 'Cancelled')
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryVariantColor,
                                      minimumSize: const Size(0, 28),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    onPressed: () => _navigateToDetails(context, auction, user),
                                    child: const Text('View Details', style: TextStyle(color: secondaryColor, fontSize: 9)),
                                  ),
                              ],
                            ),
                          ],
                          // Title
                          SizedBox(
                            height: 31,
                            child: Consumer<AuctionProvider>(
                              builder: (context, auctionProvider, child) {
                                return HighlightedText(
                                  fullText: auction.title,
                                  query: auctionProvider.searchQuery,
                                  normalStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  highlightStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        backgroundColor: highlightColor,
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          // Reduced spacing for Expired Auctions
                          const SizedBox(height: titleToBidSpacing),
                          // Price and Delivery Type Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price Container
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: onSecondaryColor, width: 1.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'AED ${(title == 'Listed Products' || (title == 'Similar Products' && !auction.isAuctionProduct)) ? NumberFormat.decimalPattern().format(double.tryParse(auction.productListingPrice) ?? 0.0) : NumberFormat.decimalPattern().format(double.tryParse(auction.currentBid))}',
                                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                              // Show delivery type only on My Auctions page for sold items
                              if (title == 'Sold' && auction.status == 'SOLD' && auction.deliveryType != null) ...[
                                // Delivery Type Container
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: primaryColor,
                                      width: 0.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    auction.deliveryType == 'PICKUP' ? 'The buyer will pick up the item' : 'The company will deliver the item',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: primaryVariantColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Location/Bids Section
                          SizedBox(
                            height: (!auction.isAuctionProduct || (title == "Similar Products" && !auction.isAuctionProduct)) ? 42 : 12,
                            child: (!auction.isAuctionProduct || (title == "Similar Products" && !auction.isAuctionProduct))
                                ? Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Location:\n",
                                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                                color: primaryVariantColor,
                                                fontSize: 10,
                                              ),
                                        ),
                                        TextSpan(
                                          text: auction.itemLocation != null ? '${auction.itemLocation?.city},\n${auction.itemLocation?.country}' : 'Location not available',
                                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
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
                                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                                          color: primaryVariantColor,
                                          fontSize: 10,
                                        ),
                                  ),
                          ),
                          const SizedBox(height: 9),
                          // Show creation date for pending auctions
                          if (auction.isAuctionProduct && (title == 'Pending' || auction.status == 'PENDING_OWNER_DEPOIST'))
                            Text(
                              'Created on: ${DateFormat('MMM d, y').format(auction.createdAt)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: primaryVariantColor,
                                    fontSize: 10,
                                  ),
                            )
                          else if (title != 'Expired Auctions' && title != 'Listed Products' && auction.isAuctionProduct || (title == 'Similar Products' && auction.isAuctionProduct))
                            Column(
                              children: [
                                if (auction.status != 'SOLD')
                                  AuctionCountdown(
                                    startDate: auction.startDate,
                                    endDate: auction.endDate ?? auction.expiryDate,
                                    auctionId: auction.id.toString(),
                                    customPrefix: auction.status == 'ACTIVE' ? 'Ending in:' : 'Starting in:',
                                  ),
                                if (title == 'Active' || title == 'Scheduled' || title == 'Sold' || title == 'Waiting for Payment' || title == 'Expired' || title == 'Cancelled') const SizedBox(height: 4),
                              ],
                            ),
                          if (!auction.isAuctionProduct || (title == "Similar Products" && !auction.isAuctionProduct)) ...[
                            Text(
                              "Listed: ${timeago.format(auction.createdAt, locale: 'en_custom')}",
                              style: Theme.of(context).textTheme.labelLarge!.copyWith(
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
                              onPressed: () => _navigateToDetails(context, auction, user),
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
                          if ((title != 'Listed Products' && title != 'Expired Auctions' && auction.isAuctionProduct) || (title == 'Similar Products' && auction.isAuctionProduct)) ...[
                            if (title == 'Active' || title == 'Scheduled' || title == 'Sold' || title == 'Pending' || title == 'Waiting for Payment' || title == 'Expired' || title == 'Cancelled')
                              auction.status == 'SOLD'
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        minimumSize: const Size(double.infinity, 32),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      onPressed: () {
                                        // TODO: Implement View Buyer Details logic
                                      },
                                      child: const Text(
                                        'Buyer Contact Details',
                                        style: TextStyle(
                                          color: secondaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                            ),
                                            onPressed: () async {
                                              final detailsRes = await AuctionDetailsService.getAuctionDetails(auction.id.toString());
                                              if (detailsRes == null || detailsRes['data'] == null) {
                                                ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!).showSnackBar(
                                                  const SnackBar(content: Text('Failed to get auction details')),
                                                );
                                                return;
                                              }
                                              detailsRes['data']['isMyAuction'] = auction.isMyAuction;
                                              if (auction.status == 'PENDING_OWNER_DEPOIST') {
                                                detailsRes['data']['isDeposit'] = true;
                                                Navigator.push(
                                                  MyApp.navigatorKey.currentContext!,
                                                  MaterialPageRoute(
                                                    builder: (context) => PaymentDetailsScreen(
                                                      auctionData: {
                                                        'auction': auction,
                                                        'details': detailsRes['data'],
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return _navigateToDetails(context, auction, user);
                                              }
                                            },
                                            child: Text(
                                              auction.status == 'PENDING_OWNER_DEPOIST' ? 'Pay Deposit' : 'Edit Auction',
                                              style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 11,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: const Size(0, 32),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: primaryColor)),
                                            ),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Are you sure?'),
                                                    content: const Text(
                                                      'You are going to Cancel the auction. The ongoing bids will be lost.',
                                                      style: TextStyle(color: Colors.black),
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 32),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: primaryColor)),
                                                        ),
                                                        child: const Text('Go Back', style: TextStyle(color: primaryColor, fontSize: 11)),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                      ),
                                                      ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          minimumSize: const Size(0, 32),
                                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: BorderSide(color: primaryColor)),
                                                        ),
                                                        child: const Text('Proceed', style: TextStyle(color: primaryColor, fontSize: 11)),
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          context.read<AuctionProvider>().cancelAuction(auction, auction.id).then((resp) {
                                                            if (resp['success'] == true) {
                                                              ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!).showSnackBar(
                                                                SnackBar(
                                                                  content: Text('Auction cancelled successfully'),
                                                                  backgroundColor: Colors.green,
                                                                ),
                                                              );
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Text('Cancel Auction', style: TextStyle(color: primaryColor, fontSize: 11)),
                                          ),
                                        ),
                                      ],
                                    )
                            else if (auction.isMyAuction)
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 32),
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () => _navigateToDetails(context, auction, user),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: secondaryColor,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                            else if (auction.buyNowEnabled) ...[
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
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                      ),
                                      onPressed: () => _navigateToDetails(context, auction, user),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                      ),
                                      onPressed: () {
                                        auction.isBuyNow = true;
                                        _navigateToDetails(context, auction, user);
                                      },
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
                            ] else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 32),
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onPressed: () => _navigateToDetails(context, auction, user),
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
                ),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: getStatusColor(auction.usageStatus),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
                ),
                child: Text(
                  auction.usageStatus,
                  style: const TextStyle(
                    fontSize: 7,
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (title != 'Expired Auctions')
              // Bookmark and Share buttons
              Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if ((title != 'Listed Products' && auction.isAuctionProduct) || (title == 'Similar Products' && auction.isAuctionProduct))
                      if (!auction.isMyAuction) // Hide wishlist for my auctions
                        _buildIconButton(context, FontAwesomeIcons.bookmark, auction),
                    const SizedBox(width: 4),
                    _buildIconButton(context, FontAwesomeIcons.shareFromSquare, auction),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, AuctionItem auction, UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailsScreen(
          user: user,
          item: auction,
          title: title,
        ),
      ),
    );
  }

  Widget _buildStatusText(BuildContext context, String status) {
    final baseColor = getStatusColor(status);
    final displayStatus = getDisplayStatus(status);

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

  Widget _buildIconButton(BuildContext context, IconData icon, AuctionItem auction) {
    // Don't show wishlist icon on My Auctions page for any tab
    final myAuctionsTabs = ['Active', 'Pending', 'Sold', 'Waiting for Payment', 'Expired', 'Cancelled'];
    if (myAuctionsTabs.contains(title) && icon == FontAwesomeIcons.bookmark) {
      return const SizedBox.shrink();
    }

    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isWishlisted = wishlistProvider.isWishlisted(auction.id);

    return Container(
      decoration: BoxDecoration(
        color: buttonBgColor,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: () async {
          if (icon == FontAwesomeIcons.bookmark) {
            if (!isLoggedIn) {
              AuthHelper.showAuthenticationRequiredMessage(context);
            } else {
              wishlistProvider.toggleWishlist(auction);
            }
          } else if (icon == FontAwesomeIcons.shareFromSquare) {
            final String itemUrl = 'https://alletre.com/items/${auction.id}';
            await Share.share(
              'Check out this ${title.toLowerCase()}: ${auction.title}\n'
              '${title == "Listed Products" ? "Price" : "Starting bid"}: AED ${title == "Listed Products" ? auction.productListingPrice : auction.startBidAmount}\n'
              '${auction.itemLocation?.address != null ? "Location: ${auction.itemLocation!.address}\n" : ""}'
              '$itemUrl',
              subject: title == "Listed Products" ? 'Interesting Product on Alletre' : 'Interesting Auction on Alletre',
            );
          }
        },
        child: Icon(
          icon == FontAwesomeIcons.bookmark && isWishlisted ? Icons.bookmark : icon,
          size: 13,
          color: icon == FontAwesomeIcons.bookmark && isWishlisted ? primaryColor : onSecondaryColor,
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
