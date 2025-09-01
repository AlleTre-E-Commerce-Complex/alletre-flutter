// ignore_for_file: avoid_print
import 'dart:developer';
import 'dart:convert';
import 'package:alletre_app/model/item_location.dart';
import 'package:alletre_app/model/custom_field_model.dart';
import 'package:flutter/foundation.dart';

class AuctionItem {
  final int id;
  final int productId;
  final String postedBy;
  final String? userName;
  final String phone;
  final String title;
  final String price;
  final String productListingPrice;
  final int bids;
  final Location? itemLocation;
  final String? sellerAddress;
  final String? sellerAddressLabel;
  final String? sellerCity;
  final String? sellerCountry;
  final String? sellerPhone;
  final DateTime createdAt;
  final String description;
  final String startBidAmount;
  String currentBid;
  final String buyNowPrice;
  final bool isDepositPaid;
  String status;
  String type;
  String usageStatus;
  bool buyNowEnabled;
  final DateTime startDate;
  final DateTime expiryDate;
  final DateTime? endDate;
  final List<String> imageLinks;
  final int categoryId;
  final int subCategoryId;
  final String categoryName;
  final String subCategoryName;
  final bool isAuctionProduct;
  final CategoryFields? customFields;
  final Map<String, dynamic>? product;
  final String? returnPolicyDescription;
  final String? warrantyPolicyDescription;
  bool isMyAuction;
  final String? deliveryType;
  bool isBuyNow;
  final List<Map<String, dynamic>>? payment;

  AuctionItem(
      {required this.id,
      required this.productId,
      required this.postedBy,
      this.userName,
      required this.phone,
      required this.title,
      required this.price,
      required this.productListingPrice,
      required this.bids,
      required this.itemLocation,
      required this.sellerAddress,
      required this.sellerAddressLabel,
      required this.sellerCity,
      required this.sellerCountry,
      required this.sellerPhone,
      required this.createdAt,
      required this.description,
      required this.startBidAmount,
      required this.currentBid,
      required this.buyNowPrice,
      required this.isDepositPaid,
      required this.status,
      required this.type,
      required this.usageStatus,
      required this.buyNowEnabled,
      required this.startDate,
      required this.expiryDate,
      this.endDate,
      required this.imageLinks,
      required this.categoryId,
      required this.subCategoryId,
      required this.categoryName,
      required this.subCategoryName,
      required this.isAuctionProduct,
      this.customFields,
      this.product,
      this.returnPolicyDescription,
      this.warrantyPolicyDescription,
      required this.isMyAuction,
      this.deliveryType,
      required this.isBuyNow,
      required this.payment});

  // Add copyWith method for real-time updates
  AuctionItem copyWith({
    int? id,
    int? productId,
    String? postedBy,
    String? userName,
    String? phone,
    String? title,
    String? price,
    String? productListingPrice,
    int? bids,
    Location? itemLocation,
    String? sellerAddress,
    String? sellerAddressLabel,
    String? sellerCity,
    String? sellerCountry,
    String? sellerPhone,
    DateTime? createdAt,
    String? description,
    String? startBidAmount,
    String? currentBid,
    String? buyNowPrice,
    bool? isDepositPaid,
    String? status,
    String? type,
    String? usageStatus,
    bool? buyNowEnabled,
    DateTime? startDate,
    DateTime? expiryDate,
    DateTime? endDate,
    List<String>? imageLinks,
    int? categoryId,
    int? subCategoryId,
    String? categoryName,
    String? subCategoryName,
    bool? isAuctionProduct,
    Map<String, dynamic>? product,
    String? returnPolicyDescription,
    String? warrantyPolicyDescription,
    bool? isMyAuction,
    String? deliveryType,
    bool? isBuyNow,
    List<Map<String, dynamic>>? payment,
  }) {
    return AuctionItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        postedBy: postedBy ?? this.postedBy,
        userName: userName ?? this.userName,
        phone: phone ?? this.phone,
        title: title ?? this.title,
        price: price ?? this.price,
        productListingPrice: productListingPrice ?? this.productListingPrice,
        bids: bids ?? this.bids,
        itemLocation: itemLocation ?? this.itemLocation,
        sellerAddress: sellerAddress ?? this.sellerAddress,
        sellerAddressLabel: sellerAddressLabel ?? this.sellerAddressLabel,
        sellerCity: sellerCity ?? this.sellerCity,
        sellerCountry: sellerCountry ?? this.sellerCountry,
        sellerPhone: sellerPhone ?? this.sellerPhone,
        createdAt: createdAt ?? this.createdAt,
        description: description ?? this.description,
        startBidAmount: startBidAmount ?? this.startBidAmount,
        currentBid: currentBid ?? this.currentBid,
        buyNowPrice: buyNowPrice ?? this.buyNowPrice,
        isDepositPaid: isDepositPaid ?? this.isDepositPaid,
        status: status ?? this.status,
        type: type ?? this.type,
        usageStatus: usageStatus ?? this.usageStatus,
        buyNowEnabled: buyNowEnabled ?? this.buyNowEnabled,
        startDate: startDate ?? this.startDate,
        expiryDate: expiryDate ?? this.expiryDate,
        endDate: endDate ?? this.endDate,
        imageLinks: imageLinks ?? this.imageLinks,
        categoryId: categoryId ?? this.categoryId,
        subCategoryId: subCategoryId ?? this.subCategoryId,
        categoryName: categoryName ?? this.categoryName,
        subCategoryName: subCategoryName ?? this.subCategoryName,
        isAuctionProduct: isAuctionProduct ?? this.isAuctionProduct,
        customFields: customFields ?? customFields,
        product: product ?? this.product,
        returnPolicyDescription: returnPolicyDescription ?? this.returnPolicyDescription,
        warrantyPolicyDescription: warrantyPolicyDescription ?? this.warrantyPolicyDescription,
        isMyAuction: isMyAuction ?? this.isMyAuction,
        deliveryType: deliveryType ?? this.deliveryType,
        isBuyNow: this.isBuyNow,
        payment: this.payment);
  }

  // Helper for printing long strings in chunks
  static void printLongString(String text) {
    final pattern = RegExp('.{1,800}');
    for (final match in pattern.allMatches(text)) {
      print(match.group(0));
    }
  }

  factory AuctionItem.fromJson(Map<String, dynamic> json) {
    try {
      // Extract the data
      // final data = json['data'] as Map<String, dynamic>?;

      // // Safely check if 'data' is not null and extract the productId
      // final productId = data?['productId'] as int? ?? 0;

      // Safely handle nested product data
      final product = json['product'] as Map<String, dynamic>? ?? {};

      // Parse policy descriptions
      String? returnPolicyDescription;
      String? warrantyPolicyDescription;
      if (json['auctionId'] != null) {
        returnPolicyDescription = json['returnPolicyDescription'] as String?;
        warrantyPolicyDescription = json['warrantyPolicyDescription'] as String?;
      }

      // Get category and subcategory information
      final categoryId = product['categoryId'] as int? ?? 0;
      final subCategoryId = product['subCategoryId'] as int? ?? 0;

      // Parse custom fields if available
      CategoryFields? customFields;
      if (json['customFields'] != null) {
        try {
          customFields = CategoryFields.fromJson({'data': json['customFields']});
        } catch (e) {
          log('Error parsing custom fields: $e');
        }
      }

      // Handle images from product data
      List<String> imageLinks = [];
      try {
        final List<dynamic>? images = product['images'] as List<dynamic>?;
        if (images != null) {
          imageLinks = images
              .where((image) => image != null && image is Map<String, dynamic>)
              .map((image) {
                final imageLink = (image as Map<String, dynamic>)['imageLink'] as String?;
                return imageLink ?? '';
              })
              .where((link) => link.isNotEmpty)
              .toList();
        }
      } catch (e) {
        log('Error parsing images: $e');
        log('Product data: $product');
      }

      DateTime createdAt = DateTime.now();
      try {
        if (json['createdAt'] != null) {
          createdAt = DateTime.parse(json['createdAt'] as String);
        }
      } catch (e) {
        // Suppress error message
        debugPrint('Error parsing createdAt: $e');
      }

      // Parse dates with validation
      DateTime startDate = DateTime.now();
      DateTime expiryDate = DateTime.now().add(const Duration(minutes: 4));
      DateTime? endDate;
      try {
        // First check navigation data which might contain the correct dates
        final navigationData = json['navigationData'] as Map<String, dynamic>?;
        if (navigationData != null) {
          if (navigationData['startDate'] != null) {
            startDate = DateTime.parse(navigationData['startDate'] as String);
          }
          if (navigationData['endDate'] != null) {
            endDate = DateTime.parse(navigationData['endDate'] as String);
            expiryDate = endDate;
          }
        }

        // If no dates in navigation data, try the regular fields
        if (navigationData == null) {
          // Parse start date if provided
          if (json['startDate'] != null) {
            startDate = DateTime.parse(json['startDate'] as String);
          }

          // Parse end date if provided
          if (json['endDate'] != null) {
            endDate = DateTime.parse(json['endDate'] as String);
            expiryDate = endDate;
          } else if (json['expiryDate'] != null) {
            // Fallback to expiryDate if endDate is not available
            expiryDate = DateTime.parse(json['expiryDate'] as String);
          } else {
            // If no end date is provided, calculate based on duration
            final duration = json['duration'] as int? ?? 1;
            final durationUnit = json['durationUnit'] as String? ?? 'hours';

            if (durationUnit == 'hours') {
              if (duration < 1 || duration > 24) {
                throw Exception('Quick auction duration must be between 1 and 24 hours');
              }
              expiryDate = startDate.add(Duration(hours: duration));
            } else if (durationUnit == 'days') {
              if (duration < 1 || duration > 7) {
                throw Exception('Long auction duration must be between 1 and 7 days');
              }
              expiryDate = startDate.add(Duration(days: duration));
            }
          }
        }
      } catch (e) {
        // Suppress error message
        debugPrint('Error parsing dates: $e');
      }

      int bidCount = 0;
      try {
        final countMap = json['_count'];
        if (countMap is Map<String, dynamic>) {
          bidCount = countMap['bids'] as int? ?? 0;
        }
      } catch (e) {
        // Suppress error message
        debugPrint('Error parsing bid count: $e');
      }

      // Get the latest bid amount if available
      String currentBid = json['startBidAmount'] ?? '0';
      if (json['bids'] != null && json['bids'] is List && (json['bids'] as List).isNotEmpty) {
        final latestBid = json['bids'][0];
        if (latestBid != null && latestBid['amount'] != null) {
          currentBid = latestBid['amount'];
        }
      }

      Location? itemLocation;
      // Prefer shippingDetails for city/country if available
      if (json['shippingDetails'] != null) {
        final shipping = json['shippingDetails'] as Map<String, dynamic>;
        print('💸🔦[AuctionItem.fromJson] Using shippingDetails: $shipping');
        // Always use English state for city, and clean up country string
        final rawCountry = (shipping['country'] ?? '') as String;
        final cleanedCountry = rawCountry.replaceAll(RegExp(r'[^A-Za-z ]'), '').trim();
        itemLocation = Location(
          id: 0,
          address: shipping['address'] ?? '',
          lat: 0.0,
          lng: 0.0,
          phone: shipping['phone'] ?? '',
          addressLabel: '',
          city: shipping['state'] ?? '', // Use English state as city
          country: cleanedCountry,
        );
        print('[AuctionItem.fromJson] Created itemLocation from shippingDetails: city=${itemLocation.city}, country=${itemLocation.country}');
      } else if (json['location'] != null) {
        print('[AuctionItem.fromJson] Using location object: ${json['location']}');
        itemLocation = Location.fromJson(json['location']);
        print('[AuctionItem.fromJson] Created itemLocation from location object: city=${itemLocation.city}, country=${itemLocation.country}');
      } else if (product['cityId'] != null || product['countryId'] != null) {
        print('[AuctionItem.fromJson] Using cityId/countryId from product: cityId=${product['cityId']}, countryId=${product['countryId']}');
        print('[AuctionItem.fromJson] Product map: $product');
        // Fallback: if product['address'] is empty, use user's first location address if available
        String address = product['address'] ?? '';
        String addressLabel = product['addressLabel'] ?? '';
        if ((address.isEmpty || address == '') && product['user'] != null && product['user']['locations'] != null) {
          final locations = product['user']['locations'];
          if (locations is List && locations.isNotEmpty) {
            address = locations[0]['address'] ?? '';
            addressLabel = locations[0]['addressLabel'] ?? '';
          }
        }
        itemLocation = Location.fromIds(
          id: json['locationId'] ?? 0,
          cityId: product['cityId'],
          countryId: product['countryId'],
          address: address,
          addressLabel: addressLabel,
          phone: product['phone'] ?? '',
        );
        print('[💡💡💡AuctionItem.fromJson] Created itemLocation from product IDs: city=${itemLocation.city}, country=${itemLocation.country}, address=${itemLocation.address}');
      } else if (json['cityId'] != null || json['countryId'] != null) {
        print('[AuctionItem.fromJson] Using cityId/countryId: cityId=${json['cityId']}, countryId=${json['countryId']}, locationId=${json['locationId']}');
        print('[AuctionItem.fromJson] Product map: $product');
        itemLocation = Location.fromIds(
          id: json['locationId'] ?? 0,
          cityId: json['cityId'],
          countryId: json['countryId'],
          address: json['address'] ?? '',
          addressLabel: json['addressLabel'] ?? '',
          phone: json['phone'] ?? '',
        );
        print('[AuctionItem.fromJson] Created itemLocation from IDs: city=${itemLocation.city}, country=${itemLocation.country}, address=${itemLocation.address}');
      }

      // Safely handle nested product data
      List<Map<String, dynamic>> payment = [];
      if (json.containsKey('Payment')) {
        for (var elem in json['Payment']) {
          payment.add(elem as Map<String, dynamic>);
        }
      }

      // Debug: Print the relevant fields just before returning
      printLongString('[AuctionItem.fromJson] RAW JSON: ${jsonEncode(json)}');
      print('[AuctionItem.fromJson] sellerAddress: ${json['location']?['address']}');
      print('[AuctionItem.fromJson] sellerAddressLabel: ${json['location']?['addressLabel']}');
      print('[AuctionItem.fromJson] sellerCity: ${json['location']?['city']?['nameEn']}');
      print('[AuctionItem.fromJson] sellerCountry: ${json['location']?['country']?['nameEn']}');
      print('[AuctionItem.fromJson] sellerPhone: ${json['location']?['phone']}');

      return AuctionItem(
          id: json['id'] as int? ?? 0,
          productId: product['id'] as int? ?? 0,
          postedBy: json['user']?['userName'] as String? ?? '',
          userName: json['user']?['userName'] as String?,
          phone: product['user']?['phone'] as String? ?? '',
          title: product['title'] as String? ?? '',
          price: json['price'] as String? ?? '0',
          productListingPrice: product['ProductListingPrice'] as String? ?? '0',
          bids: bidCount,
          itemLocation: itemLocation,
          sellerAddress: json['location']?['address'] ?? '',
          sellerAddressLabel: json['location']?['addressLabel'] ?? '',
          sellerCity: json['location']?['city']?['nameEn'] ?? '',
          sellerCountry: json['location']?['country']?['nameEn'] ?? '',
          sellerPhone: json['location']?['phone'] as String? ?? '',
          createdAt: createdAt,
          description: product['description'] as String? ?? '',
          startBidAmount: json['startBidAmount'] as String? ?? '0',
          currentBid: currentBid,
          buyNowPrice: json['acceptedAmount'] as String? ?? '0',
          status: json['status'] as String? ?? '',
          type: json['type'] as String? ?? 'ON_TIME',
          usageStatus: product['usageStatus'] as String? ?? '',
          buyNowEnabled: json['isBuyNowAllowed'] as bool? ?? false,
          isDepositPaid: json['isDepositPaid'] as bool? ?? false,
          startDate: startDate,
          expiryDate: expiryDate,
          endDate: endDate,
          imageLinks: imageLinks,
          categoryId: categoryId,
          subCategoryId: subCategoryId,
          categoryName: product['category']?['nameEn'] as String? ?? '',
          subCategoryName: product['subCategory']?['nameEn'] as String? ?? '',
          isAuctionProduct: product['isAuctionProduct'] as bool? ?? true,
          customFields: customFields,
          product: product,
          returnPolicyDescription: returnPolicyDescription,
          warrantyPolicyDescription: warrantyPolicyDescription,
          isMyAuction: json['isMyAuction'] as bool? ?? false,
          deliveryType: json['deliveryType'] as String?,
          isBuyNow: false,
          payment: payment);
    } catch (e) {
      log('Error creating AuctionItem: $e');
      rethrow;
    }
  }

  /// Helper to create AuctionItem after local listing (use state as city)
  static Location createLocationFromApp(Map<String, dynamic> shipping) {
    return Location(
      id: 0,
      address: shipping['address'] ?? '',
      lat: 0.0,
      lng: 0.0,
      phone: shipping['phone'] ?? '',
      addressLabel: '',
      city: shipping['state'] ?? '', // Use state as city when listing from app
      country: shipping['country'] ?? '',
    );
  }

  factory AuctionItem.empty() {
    return AuctionItem(
      id: 0,
      productId: 0,
      postedBy: '',
      userName: null,
      phone: '',
      title: '',
      description: '',
      imageLinks: [],
      price: '0',
      productListingPrice: '0',
      startBidAmount: '0',
      currentBid: '0',
      buyNowPrice: '0',
      isDepositPaid: false,
      startDate: DateTime.now(),
      expiryDate: DateTime.now(),
      endDate: null,
      createdAt: DateTime.now(),
      status: '',
      type: 'ON_TIME',
      usageStatus: '',
      itemLocation: null,
      sellerAddress: '',
      sellerAddressLabel: '',
      sellerCity: '',
      sellerCountry: '',
      sellerPhone: '',
      bids: 0,
      buyNowEnabled: false,
      categoryId: 0,
      subCategoryId: 0,
      categoryName: '',
      subCategoryName: '',
      isAuctionProduct: false,
      customFields: null,
      product: null,
      isMyAuction: false,
      isBuyNow: false,
      payment: null,
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

    return "${difference.inHours} hrs : ${difference.inMinutes % 60} mins : ${difference.inSeconds % 60} sec";
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'title': title,
      'postedBy': postedBy,
      'userName': userName,
      'phone': phone,
      'price': price,
      'productListingPrice': productListingPrice,
      'bids': bids,
      'itemLocation': itemLocation,
      'sellerAddress': sellerAddress,
      'sellerAddressLabel': sellerAddressLabel,
      'sellerCity': sellerCity,
      'sellerCountry': sellerCountry,
      'sellerPhone': sellerPhone,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'startBidAmount': startBidAmount,
      'currentBid': currentBid,
      'buyNowPrice': buyNowPrice,
      'status': status,
      'type': type,
      'buyNowEnabled': buyNowEnabled,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'imageLinks': imageLinks,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'categoryName': categoryName,
      'subCategoryName': subCategoryName,
      'isAuctionProduct': isAuctionProduct,
      'customFields': customFields?.fields,
      'product': product,
      'isMyAuction': isMyAuction,
      'deliveryType': deliveryType,
      'payment': payment,
    };
  }
}
