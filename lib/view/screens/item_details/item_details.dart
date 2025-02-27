import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_countdown.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/image_carousel.dart';
import 'package:share_plus/share_plus.dart';

class ItemDetailsScreen extends StatelessWidget {
  final AuctionItem item;
  final String title;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        actions: [
          // Wishlist button
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isInWishlist = wishlistProvider.isWishlisted(item.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.bookmark : FontAwesomeIcons.bookmark,
                  color: isInWishlist ? primaryColor : null,
                  size: 18
                ),
                onPressed: () => wishlistProvider.toggleWishlist(item),
                padding: const EdgeInsets.only(right: 2),
                constraints: const BoxConstraints(),
              );
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareFromSquare, size: 18),
            onPressed: () {
              Share.share(
              'Check out this auction: ${item.title}\nStarting bid: AED ${item.startBidAmount}',
              subject: 'Interesting Auction on Alletre',
            );
            },
            padding: const EdgeInsets.only(right: 16),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image carousel
            SizedBox(
              height: 300,
              child: ImageCarousel(
                images: item.imageLinks,
                onImageTap: (index) {
                  // Implement full-screen image view
                },
              ),
            ),

            // Item details section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Price
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  //Status
                  if(title != 'Listed Products')
                  Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: getStatusColor(item.status).withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getDisplayStatus(item.status),
                        style: TextStyle(
                          fontSize: 11,
                          color: getStatusColor(item.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                                      const SizedBox(height: 15),

                  Row(
                    children: [
                      if (title == 'Live Auctions' || title == 'Upcoming Auctions')
                        Text(
                          'Current Bid:\nAED ${item.startBidAmount}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15
                              ),
                        )
                      else if (title == 'Listed Products')
                        Text(
                          'Selling Price:\nAED ${item.productListingPrice}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 15
                              ),
                        ),
                      if (item.hasBuyNow) ...[
                        const SizedBox(width: 16),
                        Text(
                          'Buy Now:\nAED ${item.buyNowPrice}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Time
                  if (title != 'Listed Products' && title != 'Expired Auctions') ...[
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.clock,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        AuctionCountdown(
                          startDate: item.startDate,
                          endDate: item.expiryDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    
                  ],
                  const SizedBox(height: 16),

                  if(title == 'Listed Products')
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.location,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),

                  // Auction Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Starting Bid',
                          'AED ${item.startBidAmount}',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Total Bids',
                          item.bids.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (item.status == 'LIVE') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Implement bid now functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Bid Now'),
              ),
            ),
            if (item.hasBuyNow) ...[
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Implement buy now functionality
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toUpperCase()) {
  //     case 'LIVE':
  //       return Colors.green;
  //     case 'UPCOMING':
  //       return Colors.blue;
  //     case 'EXPIRED':
  //       return Colors.red;
  //     case 'SOLD':
  //       return Colors.purple;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  String getDisplayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Active';
      case 'UPCOMING':
        return 'Upcoming';
      case 'EXPIRED':
        return 'Expired';
      case 'SOLD':
        return 'Sold';
      default:
        return 'Unknown';
    }
  }
}
