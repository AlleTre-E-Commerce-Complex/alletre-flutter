// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/image_carousel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/services/api/category_api_service.dart';
import '../../widgets/auction card widgets/auction_countdown.dart';
import '../image_view/full_screen_image.dart';

class ItemDetailsScreen extends StatelessWidget {
  final AuctionItem item;
  final String title;

  const ItemDetailsScreen({
    super.key,
    required this.item,
    required this.title,
  });

  Future<void> _loadSubCategories() async {
    print('Loading subcategories for item: ${item.title}');
    print('Category ID: ${item.categoryId}');
    print('Subcategory ID: ${item.subCategoryId}');

    if (item.categoryId > 0) {
      try {
        await CategoryApiService.initializeSubCategories(item.categoryId);
      } catch (e) {
        print('Error in _loadSubCategories: $e');
      }
    } else {
      print('Invalid category ID: ${item.categoryId}');
    }
  }

  Widget _buildCategoryInfo(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadSubCategories(),
      builder: (context, snapshot) {
        // Debug the FutureBuilder state
        print('FutureBuilder state: ${snapshot.connectionState}');
        if (snapshot.hasError) {
          print('FutureBuilder error: ${snapshot.error}');
        }

        final categoryName = CategoryService.getCategoryName(item.categoryId);
        final subcategoryName =
            CategoryService.getSubCategoryName(item.subCategoryId);

        print('Retrieved names:');
        print('- Category name: $categoryName');
        print('- Subcategory name: $subcategoryName');

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: greyColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sub Category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: greyColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subcategoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: onSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBidSection(BuildContext context) {
    final ValueNotifier<String> bidAmount = ValueNotifier<String>(
      item.currentBid.isEmpty ? item.startBidAmount : item.currentBid,
    );

    final String minimumBid = item.currentBid.isEmpty ? item.startBidAmount : item.currentBid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bid Amount Input
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 37, 27, 27)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Place your bid',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: greyColor,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () {
                      final currentValue = double.parse(bidAmount.value);
                      final minBid = double.parse(minimumBid);
                      if (currentValue > minBid) {
                        bidAmount.value = (currentValue - 50).toString();
                      }
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: bidAmount,
                      builder: (context, value, child) {
                        return Text(
                          'AED ${NumberFormat.decimalPattern().format(double.parse(value))}',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold, color: onSecondaryColor),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      final currentValue = double.parse(bidAmount.value);
                      bidAmount.value = (currentValue + 50).toString();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Submit Bid Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle bid submission
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Submit Bid',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: greyColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: onSecondaryColor),
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
              color: Colors.black.withValues(alpha: (0.1 * 255)),
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

  String getDisplayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'ACTIVE';
      case 'IN_SCHEDULED':
        return 'SCHEDULED';
      case 'EXPIRED':
        return 'EXPIRED';
      case 'WAITING_FOR_PAYMENT':
        return 'SOLD';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        actions: [
          // Wishlist button
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isInWishlist = wishlistProvider.isWishlisted(item.id);
              return IconButton(
                icon: Icon(
                    isInWishlist ? Icons.bookmark : FontAwesomeIcons.bookmark,
                    color: isInWishlist ? primaryColor : null,
                    size: 18),
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
                'Check out this auction: ${item.title}\nStarting bid: AED ${item.startBidAmount}\nCurrent bid: AED ${item.currentBid}',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImageView(
                        imageUrls: item.imageLinks,
                        initialIndex: index,
                      ),
                    ),
                  );
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
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 10),

                  //Status
                  if (title != 'Listed Products')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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

                  // Category and Subcategory
                  _buildCategoryInfo(context),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (title == 'Live Auctions' ||
                          title == 'Upcoming Auctions')
                        Text(
                          'Current Bid\nAED ${NumberFormat.decimalPattern().format(double.tryParse(item.currentBid) ?? 0.0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
                        ),
                      if (title == 'Listed Products')
                        Text(
                          'Selling Price\nAED ${item.productListingPrice}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15),
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
                  if (title != 'Listed Products' &&
                      title != 'Expired Auctions') ...[
                    Row(
                      children: [
                        // Icon(
                        //   FontAwesomeIcons.clock,
                        //   size: 16,
                        //   color: Theme.of(context).colorScheme.secondary,
                        // ),
                        // const SizedBox(width: 8),
                        AuctionCountdown(
                          startDate: item.startDate,
                          endDate: item.expiryDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 16),

                  if (title == 'Listed Products')
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

                  // Bid Section for non-listed products
                  if (title != 'Listed Products') _buildBidSection(context),

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
}
