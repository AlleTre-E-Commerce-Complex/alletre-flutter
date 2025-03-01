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
  final String currentBid;
  final String buyNowPrice;
  String status;
  bool hasBuyNow;
  final DateTime startDate;
  final DateTime expiryDate;
  final List<String> imageLinks;
  final int categoryId;
  final int subCategoryId;
  final String categoryName;
  final String subCategoryName;

  AuctionItem({
    required this.id,
    required this.title,
    required this.price,
    required this.productListingPrice,
    required this.bids,
    required this.location,
    required this.createdAt,
    required this.description,
    required this.startBidAmount,
    required this.currentBid,
    required this.buyNowPrice,
    required this.status,
    required this.hasBuyNow,
    required this.startDate,
    required this.expiryDate,
    required this.imageLinks,
    required this.categoryId,
    required this.subCategoryId,
    required this.categoryName,
    required this.subCategoryName,
  });

  // Add copyWith method for real-time updates
  AuctionItem copyWith({
    int? id,
    String? title,
    String? price,
    String? productListingPrice,
    int? bids,
    String? location,
    DateTime? createdAt,
    String? description,
    String? startBidAmount,
    String? currentBid,
    String? buyNowPrice,
    String? status,
    bool? hasBuyNow,
    DateTime? startDate,
    DateTime? expiryDate,
    List<String>? imageLinks,
    int? categoryId,
    int? subCategoryId,
    String? categoryName,
    String? subCategoryName,
  }) {
    return AuctionItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      productListingPrice: productListingPrice ?? this.productListingPrice,
      bids: bids ?? this.bids,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      startBidAmount: startBidAmount ?? this.startBidAmount,
      currentBid: currentBid ?? this.currentBid,
      buyNowPrice: buyNowPrice ?? this.buyNowPrice,
      status: status ?? this.status,
      hasBuyNow: hasBuyNow ?? this.hasBuyNow,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      imageLinks: imageLinks ?? this.imageLinks,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      categoryName: categoryName ?? this.categoryName,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    try {
      // Safely handle nested product data
      final item = json['product'] as Map<String, dynamic>? ?? {};

      // Get category and subcategory information
      final categoryId = item['categoryId'] as int? ?? 0;
      final subCategoryId = item['subCategoryId'] as int? ?? 0;

      // Get the latest bid amount if available
      String currentBid = json['startBidAmount'] ?? '0';
      if (json['bids'] != null &&
          json['bids'] is List &&
          (json['bids'] as List).isNotEmpty) {
        final latestBid = json['bids'][0];
        if (latestBid != null && latestBid['amount'] != null) {
          currentBid = latestBid['amount'];
        }
      }

      // Handle images from product data
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
                  json['location']['country'] != null &&
                  json['location']['city'] != null
              ? "${json['location']['city']['nameEn'] ?? 'Unknown City'},\n${json['location']['country']['nameEn'] ?? 'Unknown Country'}"
              : 'Unknown Location',
          createdAt: createdAt,
          description: item['description'] as String? ?? 'No Description',
          startBidAmount: json['startBidAmount']?.toString() ?? '0',
          currentBid: currentBid,
          buyNowPrice: json['buyNowPrice']?.toString() ?? '0',
          status: json['status'] as String? ?? 'UNKNOWN',
          hasBuyNow: json['isBuyNowAllowed'] as bool? ?? false,
          startDate: startDate,
          expiryDate: expiryDate,
          imageLinks: imageLinks,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
          categoryName: '',
          subCategoryName: '');
    } catch (e, stackTrace) {
      log('Error in AuctionItem.fromJson: $e');
      log('Stack trace: $stackTrace');
      return AuctionItem.empty();
    }
  }

  factory AuctionItem.empty() {
    return AuctionItem(
      id: 0,
      title: '',
      description: '',
      imageLinks: [],
      price: '0',
      productListingPrice: '0',
      startBidAmount: '0',
      currentBid: '0',
      buyNowPrice: '0',
      startDate: DateTime.now(),
      expiryDate: DateTime.now(),
      createdAt: DateTime.now(),
      status: '',
      location: '',
      bids: 0,
      hasBuyNow: false,
      categoryId: 0,
      subCategoryId: 0,
      categoryName: '',
      subCategoryName: '',
    );
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
