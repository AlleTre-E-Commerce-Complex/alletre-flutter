// ignore_for_file: avoid_print

import 'dart:developer';

class AuctionItem {
  final int id;
  final String title;
  final String price;
  final String productListingPrice;
  final int bids;
  final String location;
  final DateTime createdAt;
  final String description;
  final String startBidAmount;
  String status;
  bool hasBuyNow;
  final DateTime startDate;
  final DateTime expiryDate;
  final List<String> imageLinks; // List of image URLs

  AuctionItem({
    required this.id,
    required this.title,
    required this.price,
    required this.productListingPrice,
    required this.bids,
    required this.location,
    // required this.duration,
    required this.createdAt,
    required this.description,
    required this.startBidAmount,
    required this.status,
    required this.hasBuyNow,
    required this.startDate,
    required this.expiryDate,
    required this.imageLinks,
  });

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    try {
      // Safely handle nested product data
      final item = json['product'] as Map<String, dynamic>? ?? {};
      // log('Parsing product data: $product'); // Log product data

      // Safely handle image list with detailed error logging
      List<String> imageLinks = [];
      try {
        final List<dynamic>? images = item['images'] as List<dynamic>?;
        if (images != null) {
          imageLinks = images
              .where((image) => image != null && image is Map<String, dynamic>)
              .map((image) {
                final imageLink =
                    (image as Map<String, dynamic>)['imageLink'] as String?;
                return imageLink ?? '';
              })
              .where((link) => link.isNotEmpty)
              .toList();
        }
      } catch (e) {
        log('Error parsing images: $e');
        log('Product data: $item');
      }

      DateTime createdAt = DateTime.now();
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'] as String);
        }
      } catch (e) {
        print('Error parsing createdAt: $e');
      }

      // Parse dates with validation
      DateTime startDate = DateTime.now();
      DateTime expiryDate = startDate.add(const Duration(days: 1));
      try {
        if (json['startDate'] != null) {
          startDate = DateTime.parse(json['startDate'] as String);
        }
        if (json['expiryDate'] != null) {
          expiryDate = DateTime.parse(json['expiryDate'] as String);
        }
      } catch (e) {
        print('Error parsing dates: $e');
      }

      // Safely get bid count
      int bidCount = 0;
      try {
        final countMap = json['_count'];
        if (countMap is Map<String, dynamic>) {
          bidCount = countMap['bids'] as int? ?? 0;
        }
      } catch (e) {
        print('Error parsing bid count: $e');
      }

      return AuctionItem(
        id: json['id'] as int? ?? 0,
        title: item['title'] as String? ?? 'No Title',
        price: item['price']?.toString() ?? '0',
        productListingPrice: json['ProductListingPrice'] ?? '0',
        bids: bidCount,
        location: json['location'] != null &&
                // json['location'] is Map<String, dynamic> &&
                json['location']['country'] != null &&
                json['location']['city'] != null
            ? "${json['location']['city']['nameEn'] ?? 'Unknown City'},\n${json['location']['country']['nameEn'] ?? 'Unknown Country'}"
            : 'Unknown Location',
        createdAt: createdAt,
        description: item['description'] as String? ?? 'No Description',
        startBidAmount: json['startBidAmount']?.toString() ?? '0',
        status: json['status'] as String? ?? 'UNKNOWN',
        hasBuyNow: true,
        startDate: startDate,
        expiryDate: expiryDate,
        imageLinks: imageLinks,
      );
    } catch (e, stackTrace) {
      log('Error in AuctionItem.fromJson: $e');
      print('JSON data: $json');
      print(stackTrace);
      rethrow;
    }
  }

  /// Determines if the auction is active
  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(expiryDate);
  }

  /// Calculates time remaining
  String timeRemaining() {
    final now = DateTime.now();
    if (now.isAfter(expiryDate)) {
      return "Expired";
    }
    final difference = expiryDate.difference(now);
    return "${difference.inDays} days : ${difference.inHours % 24} hrs : ${difference.inMinutes % 60} min : ${difference.inSeconds % 60} sec";
  }
}
