import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_countdown.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/image_carousel.dart';
import 'package:timeago/timeago.dart' as timeago;

class ItemDetailsScreen extends StatelessWidget {
  final AuctionItem item;

  const ItemDetailsScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          // Share button
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareFromSquare ),
            onPressed: () {
              // Implement share functionality
            },
          ),
          // Wishlist button
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isInWishlist = wishlistProvider.isWishlisted(item.id);
              return IconButton(
                icon: Icon(
                  isInWishlist ? Icons.bookmark : FontAwesomeIcons.bookmark,
                  color: isInWishlist ? Colors.red : null,
                ),
                onPressed: () => wishlistProvider.toggleWishlist(item),
              );
            },
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Current Price: \$${item.price}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (item.hasBuyNow) ...[
                        const SizedBox(width: 16),
                        Text(
                          'Buy Now: \$${item.productListingPrice}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status and Time
                  if (item.status != 'Listed Products') ...[
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
                    Text(
                      'Status: ${item.status}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _getStatusColor(item.status),
                          ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Location and Creation Date
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
                      const Spacer(),
                      Text(
                        'Posted ${timeago.format(item.createdAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
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
                          '\$${item.startBidAmount}',
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

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'LIVE':
        return Colors.green;
      case 'UPCOMING':
        return Colors.blue;
      case 'EXPIRED':
        return Colors.red;
      case 'SOLD':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
