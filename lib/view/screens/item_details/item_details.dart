// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/custom_field_model.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/services/custom_fields_service.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/image_carousel.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_countdown.dart';
import 'package:alletre_app/view/screens/image_view/full_screen_image.dart';
import '../../widgets/item details widgets/item_details_bid_section.dart';
import '../../widgets/item details widgets/item_details_bottom_bar.dart';
import '../../widgets/item details widgets/item_details_bottom_sheet.dart';
import '../../widgets/item details widgets/item_details_category_info.dart';

class ItemDetailsScreen extends StatelessWidget {
  final AuctionItem item;
  final UserModel user;
  final String title;

  ItemDetailsScreen({
    super.key,
    required this.item,
    required this.user,
    required this.title,
  });

  final ValueNotifier<bool> _isBuyNowTapped = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auctionProvider =
          Provider.of<AuctionProvider>(context, listen: false);
      auctionProvider.joinAuctionRoom(item.id.toString());
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(item.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        actions: [
          if (title != 'Listed Products')
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
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareFromSquare, size: 18),
            onPressed: () {
              final String itemUrl = 'https://alletre.com/items/${item.id}';
              Share.share(
                'Check out this ${title.toLowerCase()}: ${item.title}\n'
                '${title == "Listed Products" ? "Price" : "Starting bid"}: AED ${item.startBidAmount}\n'
                '${title != "Listed Products" ? "Current bid: AED ${item.currentBid}\n" : ""}'
                '$itemUrl',
                subject: title == "Listed Products"
                    ? 'Interesting Product on Alletre'
                    : 'Interesting Auction on Alletre',
              );
            },
            padding: const EdgeInsets.only(right: 16),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            final auctionProvider =
                Provider.of<AuctionProvider>(context, listen: false);
            auctionProvider.leaveAuctionRoom(item.id.toString());
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    if (title != 'Listed Products') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: getStatusColor(item.status).withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          getDisplayStatus(item.status),
                          style: TextStyle(
                            fontSize: 8,
                            color: getStatusColor(item.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    IntrinsicWidth(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(Icons.person, size: 14, color: onSecondaryColor),
                            const SizedBox(width: 3),
                            Text(
                              'Posted by ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .copyWith(
                                      fontSize: 11, fontWeight: FontWeight.w600, color: onSecondaryColor),
                            ),
                            Text(
                              item.postedBy,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(fontSize: 11, color: primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextButton.icon(
                      onPressed: () => _showDetailsBottomSheet(context),
                      icon: const Icon(Icons.info_outline, size: 14),
                      label: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ItemDetailsCategoryInfo(item: item),
                    const SizedBox(height: 22),
                    if (title != 'Listed Products' &&
                        title != 'Expired Auctions') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildInfoCard(
                              context, 'Total Bids', item.bids.toString()),
                          const Spacer(),
                          _buildEnhancedAuctionCountdown(context),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title == 'Live Auctions' ||
                              title == 'Upcoming Auctions')
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: avatarColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Current Bid',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              color: onSecondaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                    ),
                                    const SizedBox(height: 5),
                                    Center(
                                      child: Text(
                                        'AED ${NumberFormat.decimalPattern().format(double.tryParse(item.currentBid) ?? 0.0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                                color: primaryColor,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (title == 'Listed Products')
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: avatarColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Selling Price',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            color: onSecondaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Center(
                                    child: Text(
                                      'AED ${NumberFormat.decimalPattern().format(double.tryParse(item.productListingPrice) ?? 0.0)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (item.hasBuyNow) ...[
                            const SizedBox(width: 15),
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: _isBuyNowTapped,
                                builder: (context, isTapped, child) {
                                  return InkWell(
                                    onTap: () {
                                      _isBuyNowTapped.value = true;
                                      Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {
                                        _isBuyNowTapped.value = false;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: primaryColor, width: 1.5),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            'Buy Now',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                    color: onSecondaryColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                          ),
                                          const SizedBox(height: 5),
                                          Center(
                                            child: Text(
                                              'AED ${item.buyNowPrice}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (title == 'Listed Products') ...[
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  size: 30,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.itemLocation != null &&
                                        item.itemLocation?.address != null) ...[
                                      Text(
                                        item.itemLocation?.address ??
                                            'Address not available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.itemLocation?.city ?? 'Unknown city'}, ${item.itemLocation?.country ?? 'Unknown country'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ] else
                                      Text(
                                        'Location not available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              if (item.itemLocation?.lat != null &&
                                  item.itemLocation?.lng != null) {
                                launchUrl(Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=${item.itemLocation!.lat},${item.itemLocation!.lng}'));
                              }
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: avatarColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    if (item.itemLocation?.lat != null &&
                                        item.itemLocation?.lng != null)
                                      Image.network(
                                        'https://maps.googleapis.com/maps/api/staticmap?center=${item.itemLocation?.lat},${item.itemLocation?.lng}&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C${item.itemLocation?.lat},${item.itemLocation?.lng}&key=AIzaSyB9ATxmePBJdgRl8mq4D1ahCRxHy99IFqg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.map,
                                                size: 50, color: Colors.grey),
                                          );
                                        },
                                      )
                                    else
                                      const Center(
                                        child: Icon(Icons.map,
                                            size: 50, color: Colors.grey),
                                      ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.open_in_new,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            const SizedBox(width: 4),
                                            Text('View Larger Map',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    ItemDetailsBidSection(item: item, title: title, user: user),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ItemDetailsBottomBars(item: item),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: avatarColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: onSecondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Center(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedAuctionCountdown(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: avatarColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuctionCountdown(
            startDate: item.startDate,
            endDate: item.expiryDate,
            customPrefix: 'Time Left',
            prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: onSecondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600, color: primaryColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showDetailsBottomSheet(BuildContext context) async {
    print('\nDEBUG: Opening details bottom sheet');
    print('DEBUG: Item details:');
    print('  - ID: ${item.id}');
    print('  - Title: ${item.title}');
    print('  - Custom fields: ${item.customFields}');
    print('  - Subcategory ID: ${item.subCategoryId}');
    print('  - Is auction: ${item.isAuctionProduct}');
    print('  - 🪪 Product ID: ${item.productId}');

    CategoryFields? mergedFields;
    try {
      // Fetch custom fields for the specific subcategory
      final customFields =
          await CustomFieldsService.getCustomFieldsBySubcategory(
              item.subCategoryId.toString());
      print('DEBUG: Custom fields fetched: $customFields');

      // Create a copy of custom fields to avoid modifying the original
      mergedFields = CategoryFields(fields: List.from(customFields.fields));

      // If item has custom fields, merge them
      if (item.customFields != null) {
        print('DEBUG: Merging with item custom fields');
        mergedFields.mergeWith(item.customFields!);
      }

      // Fetch item details based on whether it's an auction or listed product
      Map<String, dynamic>? itemDetails;
      try {
        final String itemId = item.isAuctionProduct
            ? item.id.toString()
            : item.productId.toString();
        print('\nDEBUG: Fetching item details');
        print('  - Using ID: $itemId');
        print(
            '  - Type: ${item.isAuctionProduct ? "Auction" : "Listed Product"}');

        if (item.isAuctionProduct) {
          itemDetails = await CustomFieldsService.getAuctionDetails(itemId);
        } else if (item.productId > 0) {
          itemDetails =
              await CustomFieldsService.getListedProductDetails(itemId);
        } else {
          print('WARNING: Invalid product ID ${item.productId}');
        }

        print('\nDEBUG: Processing item details');
        print('  - Details found: ${itemDetails != null}');

        // Update field values from item details if available
        if (itemDetails != null) {
          final customFieldsMap = itemDetails['customFields'];
          print('  - Custom fields present: ${customFieldsMap != null}');
          print('  - Custom fields type: ${customFieldsMap?.runtimeType}');

          if (customFieldsMap is Map<String, dynamic>) {
            print('\nDEBUG: Updating field values');
            print('  - Fields to update: ${customFieldsMap.keys.toList()}');
            mergedFields.updateFieldValues(customFieldsMap);
            print('  - Update complete');
          } else if (customFieldsMap != null) {
            print(
                'WARNING: Unexpected custom fields type: ${customFieldsMap.runtimeType}');
          }
        }
      } catch (e) {
        print('DEBUG: Error fetching item details: $e');
        // Continue with custom fields even if item details fetch fails
      }

      print('DEBUG: Final merged fields: $mergedFields');
    } catch (e) {
      print('DEBUG: Error fetching custom fields: $e');
      // If custom fields fetch fails, use item custom fields as fallback
      mergedFields = item.customFields;
    }

    // Show bottom sheet with available fields
    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return ItemDetailsBottomSheet(
            title: title,
            item: item,
            customFields: mergedFields,
          );
        },
      );
    }
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

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return activeColor;
      case 'IN_SCHEDULED':
        return scheduledColor;
      case 'EXPIRED':
        return expiredColor;
      case 'WAITING_FOR_PAYMENT':
        return errorColor;
      default:
        return avatarColor;
    }
  }
}
