// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'user_services.dart';

class AuctionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    try {
      // Get server-issued access token
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        debugPrint('No access token found');
        return null;
      }

      debugPrint('Using server access token');
      return token;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> createAuction({
    required Map<String, dynamic> auctionData,
    required List<File> images,
    required int locationId,
  }) async {
    try {
      debugPrint('Starting auction creation...');
      String? accessToken = await _getAccessToken();

      if (accessToken == null) {
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
        } else {
          throw Exception('Failed to get valid access token');
        }
      }

      debugPrint('Token acquired, preparing request...');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.auctions}'),
      );

      // Set headers
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      });

      debugPrint('Headers prepared:');
      request.headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('  $key: [REDACTED]');
        } else {
          debugPrint('  $key: $value');
        }
      });

      // Process auction data
      debugPrint('Processing auction data...');
      debugPrint('Received end date: ${auctionData['endDate']}');

      // Debug product structure before processing
      if (auctionData['product'] != null) {
        debugPrint('Raw product data:');
        debugPrint(json.encode(auctionData['product']));
        debugPrint('Product data type: ${auctionData['product'].runtimeType}');
      }

      // Prepare the request body as a single JSON object
      final Map<String, dynamic> requestBody = {
        'type': auctionData['scheduleBid'] == true ? 'SCHEDULED' : 'ON_TIME',
        'durationUnit': auctionData['durationUnit'].toString().toUpperCase(),
        // Set duration field based on durationUnit
        'durationInDays':
            auctionData['durationUnit'].toString().toUpperCase() == 'DAYS'
                ? int.parse(auctionData['duration'].toString())
                : null,
        'durationInHours':
            auctionData['durationUnit'].toString().toUpperCase() == 'HOURS'
                ? int.parse(auctionData['duration'].toString())
                : null,
        'startBidAmount':
            double.parse(auctionData['startBidAmount'].toString()),
        'startDate': auctionData['startDate'],
        'endDate': auctionData['endDate'],
        'scheduleBid': auctionData['scheduleBid'] ?? false,
        'buyNowEnabled': auctionData['buyNowEnabled'] ?? false,
        'buyNowPrice':
            double.parse(auctionData['buyNowPrice']?.toString() ?? '0'),
        'locationId': locationId,
      };

      // Handle shipping details
      if (auctionData['shippingDetails'] != null) {
        final shippingDetails = auctionData['shippingDetails'];
        requestBody['shippingDetails'] = {
          'country': shippingDetails['country'],
          'city': shippingDetails['city'],
          'address': shippingDetails['address'],
          'phone': shippingDetails['phone']
        };
      }

      // Handle product data
      if (auctionData['product'] != null) {
        final productData = auctionData['product'];
        if (productData is! Map<String, dynamic>) {
          throw Exception('Product data must be an object');
        }

        // Create a clean copy of product data and convert numeric fields
        final cleanProduct = Map<String, dynamic>.from(productData);
        cleanProduct.removeWhere((key, value) => value == null || value == '');

        // Convert numeric fields
        if (cleanProduct['categoryId'] != null) {
          cleanProduct['categoryId'] =
              int.parse(cleanProduct['categoryId'].toString());
        }
        if (cleanProduct['subCategoryId'] != null) {
          cleanProduct['subCategoryId'] =
              int.parse(cleanProduct['subCategoryId'].toString());
        }
        if (cleanProduct['quantity'] != null) {
          cleanProduct['quantity'] =
              int.parse(cleanProduct['quantity'].toString());
        }
        if (cleanProduct['screenSize'] != null) {
          cleanProduct['screenSize'] =
              double.parse(cleanProduct['screenSize'].toString());
        }
        if (cleanProduct['releaseYear'] != null) {
          cleanProduct['releaseYear'] =
              int.parse(cleanProduct['releaseYear'].toString());
        }
        if (cleanProduct['ramSize'] != null) {
          cleanProduct['ramSize'] =
              int.parse(cleanProduct['ramSize'].toString());
        }

        // Validate required fields
        if (!cleanProduct.containsKey('title') ||
            !cleanProduct.containsKey('description') ||
            !cleanProduct.containsKey('categoryId') ||
            !cleanProduct.containsKey('subCategoryId')) {
          throw Exception('Product data missing required fields');
        }

        requestBody['product'] = cleanProduct;
      } else {
        throw Exception('Product data is required');
      }

      // Add all fields as form data
      debugPrint('Adding form fields...');

      // Add basic auction fields
      debugPrint('Adding end date to form fields: ${requestBody['endDate']}');
      request.fields['type'] = requestBody['type'];
      request.fields['durationUnit'] = requestBody['durationUnit'];

      // Add appropriate duration field based on duration unit
      if (requestBody['durationInDays'] != null) {
        request.fields['durationInDays'] =
            requestBody['durationInDays'].toString();
      }
      if (requestBody['durationInHours'] != null) {
        request.fields['durationInHours'] =
            requestBody['durationInHours'].toString();
      }
      request.fields['startBidAmount'] =
          requestBody['startBidAmount'].toString();
      request.fields['locationId'] = locationId.toString();
      if (requestBody['buyNowEnabled'] == true) {
        request.fields['isBuyNowAllowed'] = 'YES';
        request.fields['acceptedAmount'] =
            requestBody['buyNowPrice'].toString();
      }

      // Handle start date
      String startDateStr;
      if (requestBody['scheduleBid'] == true &&
          auctionData['startDate'] != null) {
        // Use the provided start date as is (it's already in UTC)
        startDateStr = auctionData['startDate'];
      } else {
        // If not scheduled, use current time in UTC
        startDateStr = DateTime.now().toUtc().toIso8601String();
      }

      // Parse the start date for duration calculation
      final startDate = DateTime.parse(startDateStr);

      // Calculate end date based on duration
      final duration =
          requestBody['durationInHours'] ?? requestBody['durationInDays'];
      final endDate =
          requestBody['durationUnit'].toString().toUpperCase() == 'HOURS'
              ? startDate.add(Duration(hours: duration))
              : startDate.add(Duration(days: duration));

      request.fields['startDate'] = startDateStr;
      request.fields['endDate'] = endDate.toIso8601String();
      request.fields['scheduleBid'] = requestBody['scheduleBid'].toString();
      request.fields['buyNowEnabled'] = requestBody['buyNowEnabled'].toString();
      request.fields['buyNowPrice'] = requestBody['buyNowPrice'].toString();
      request.fields['locationId'] = requestBody['locationId'].toString();

      // Add product fields
      final product = requestBody['product'] as Map<String, dynamic>;
      product.forEach((key, value) {
        request.fields['product[$key]'] = value.toString();
      });

      // Add shipping details
      if (requestBody['shippingDetails'] != null) {
        final shipping = requestBody['shippingDetails'] as Map<String, dynamic>;
        shipping.forEach((key, value) {
          request.fields['shippingDetails[$key]'] = value.toString();
        });
      }

      // Add media files (images and videos)
      debugPrint('Adding ${images.length} media files...');

      // Separate images and videos
      final imageFiles = images
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png'))
          .toList();

      final videoFiles = images
          .where((file) =>
              file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi'))
          .toList();

      // Validate image count
      if (imageFiles.length < 3 || imageFiles.length > 5) {
        throw Exception('Please upload 3 to 5 photos');
      }

      // Add images first
      for (var file in imageFiles) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = file.path.split('/').last;

        // Determine MIME type based on file extension
        final mimeType = filename.toLowerCase().endsWith('.png')
            ? 'image/png'
            : filename.toLowerCase().endsWith('.jpg') ||
                    filename.toLowerCase().endsWith('.jpeg')
                ? 'image/jpeg'
                : 'image/jpeg'; // default to jpeg

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Add videos if any
      for (var file in videoFiles) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = file.path.split('/').last;

        // Set video MIME type
        final mimeType = filename.toLowerCase().endsWith('.mp4')
            ? 'video/mp4'
            : filename.toLowerCase().endsWith('.mov')
                ? 'video/quicktime'
                : 'video/mp4'; // default to mp4

        final multipartFile = http.MultipartFile(
          'videos',
          stream,
          length,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      debugPrint('Sending request...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      debugPrint('Response received');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response body: $responseData');

      // Log response
      debugPrint('Response Details:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: $responseData');

      final data = jsonDecode(responseData) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        debugPrint('Error Response Body: $data');
        debugPrint('Error Message: ${data['message']}');
        throw Exception('Failed to create auction: ${data['message']}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating auction: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> listProduct({
    required Map<String, dynamic> auctionData,
    required List<File> images,
    required int locationId,
  }) async {
    try {
      debugPrint('Starting product listing...');
      String? accessToken = await _getAccessToken();

      if (accessToken == null) {
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
        } else {
          throw Exception('Failed to get valid access token');
        }
      }

      debugPrint('Token acquired, preparing request...');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.productListing}'),
      );

      // Set headers
      request.headers.addAll({
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      });

      debugPrint('Headers prepared:');
      request.headers.forEach((key, value) {
        if (key == 'Authorization') {
          debugPrint('  $key: [REDACTED]');
        } else {
          debugPrint('  $key: $value');
        }
      });

      // Process auction data
      debugPrint('Processing auction data...');
      debugPrint('Received end date: ${auctionData['endDate']}');

      // Debug product structure before processing
      if (auctionData['product'] != null) {
        debugPrint('Raw product data:');
        debugPrint(json.encode(auctionData['product']));
        debugPrint('Product data type: ${auctionData['product'].runtimeType}');
      }

      // Prepare the request body as a single JSON object
      final Map<String, dynamic> requestBody = {
        'locationId': locationId,
      };

      // Handle shipping details
      if (auctionData['shippingDetails'] != null) {
        final shippingDetails = auctionData['shippingDetails'];
        requestBody['shippingDetails'] = {
          'country': shippingDetails['country'],
          'city': shippingDetails['city'],
          'address': shippingDetails['address'],
          'phone': shippingDetails['phone']
        };
      }

      // Handle product data
      if (auctionData['product'] != null) {
        final productData = auctionData['product'];
        if (productData is! Map<String, dynamic>) {
          throw Exception('Product data must be an object');
        }

        // Create a clean copy of product data and convert numeric fields
        final cleanProduct = Map<String, dynamic>.from(productData);
        cleanProduct.removeWhere((key, value) => value == null || value == '');

        // Convert numeric fields
        if (cleanProduct['categoryId'] != null) {
          cleanProduct['categoryId'] =
              int.parse(cleanProduct['categoryId'].toString());
        }
        if (cleanProduct['subCategoryId'] != null) {
          cleanProduct['subCategoryId'] =
              int.parse(cleanProduct['subCategoryId'].toString());
        }
        if (cleanProduct['quantity'] != null) {
          cleanProduct['quantity'] =
              int.parse(cleanProduct['quantity'].toString());
        }
        if (cleanProduct['screenSize'] != null) {
          cleanProduct['screenSize'] =
              double.parse(cleanProduct['screenSize'].toString());
        }
        if (cleanProduct['releaseYear'] != null) {
          cleanProduct['releaseYear'] =
              int.parse(cleanProduct['releaseYear'].toString());
        }
        if (cleanProduct['ramSize'] != null) {
          cleanProduct['ramSize'] =
              int.parse(cleanProduct['ramSize'].toString());
        }

        // Validate required fields
        if (!cleanProduct.containsKey('title') ||
            !cleanProduct.containsKey('description') ||
            !cleanProduct.containsKey('categoryId') ||
            !cleanProduct.containsKey('subCategoryId')) {
          throw Exception('Product data missing required fields');
        }

        requestBody['product'] = cleanProduct;
      } else {
        throw Exception('Product data is required');
      }

      // Add all fields as form data
      debugPrint('Adding form fields...');

      request.fields['locationId'] = requestBody['locationId'].toString();

      // Add product fields
      final product = requestBody['product'] as Map<String, dynamic>;
      product.forEach((key, value) {
        request.fields['product[$key]'] = value.toString();
      });

      // Add shipping details
      if (requestBody['shippingDetails'] != null) {
        final shipping = requestBody['shippingDetails'] as Map<String, dynamic>;
        shipping.forEach((key, value) {
          request.fields['shippingDetails[$key]'] = value.toString();
        });
      }

      // Add media files (images and videos)
      debugPrint('Adding ${images.length} media files...');

      // Separate images and videos
      final imageFiles = images
          .where((file) =>
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg') ||
              file.path.toLowerCase().endsWith('.png'))
          .toList();

      final videoFiles = images
          .where((file) =>
              file.path.toLowerCase().endsWith('.mp4') ||
              file.path.toLowerCase().endsWith('.mov') ||
              file.path.toLowerCase().endsWith('.avi'))
          .toList();

      // Validate image count
      if (imageFiles.length < 3 || imageFiles.length > 5) {
        throw Exception('Please upload 3 to 5 photos');
      }

      // Add images first
      for (var file in imageFiles) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = file.path.split('/').last;

        // Determine MIME type based on file extension
        final mimeType = filename.toLowerCase().endsWith('.png')
            ? 'image/png'
            : filename.toLowerCase().endsWith('.jpg') ||
                    filename.toLowerCase().endsWith('.jpeg')
                ? 'image/jpeg'
                : 'image/jpeg'; // default to jpeg

        final multipartFile = http.MultipartFile(
          'images',
          stream,
          length,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Add videos if any
      for (var file in videoFiles) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = file.path.split('/').last;

        // Set video MIME type
        final mimeType = filename.toLowerCase().endsWith('.mp4')
            ? 'video/mp4'
            : filename.toLowerCase().endsWith('.mov')
                ? 'video/quicktime'
                : 'video/mp4'; // default to mp4

        final multipartFile = http.MultipartFile(
          'videos',
          stream,
          length,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      debugPrint('Sending request...');
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      debugPrint('Response received');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Response body: $responseData');

      // Log response
      debugPrint('Response Details:');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      debugPrint('Body: $responseData');

      final data = jsonDecode(responseData) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        debugPrint('Error Response Body: $data');
        debugPrint('Error Message: ${data['message']}');
        throw Exception('Failed to create auction: ${data['message']}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating auction: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Implement other auction methods
  Future<List<AuctionItem>> fetchLiveAuctions() async {
    try {
      // First try to get the token
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      // Add authorization header if we have a token
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      List<AuctionItem> allItems = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/main?page=$page'),
          headers: headers,
        );

        debugPrint(
            'Live Auctions Response Code: ${response.statusCode} for page $page');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] is List) {
            final items = (data['data'] as List)
                .map((item) => AuctionItem.fromJson(item))
                .toList();

            final pagination = data['pagination'] as Map<String, dynamic>;
            final totalPages = pagination['totalPages'] as int;

            allItems.addAll(items);
            debugPrint(
                'Successfully parsed ${items.length} live auctions for page $page');

            if (page >= totalPages) {
              hasMore = false;
              debugPrint('Reached last page of live auctions');
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else if (response.statusCode == 401 && accessToken != null) {
          // Only try token refresh if we had a token and got 401
          final userService = UserService();
          final refreshResult = await userService.refreshTokens();
          if (refreshResult['success']) {
            accessToken = refreshResult['data']['accessToken'];
            headers['Authorization'] = 'Bearer $accessToken';
            // Continue with the same page
            continue;
          } else {
            hasMore = false;
          }
        } else {
          hasMore = false;
        }
      }

      debugPrint('Total live auctions fetched: ${allItems.length}');
      return allItems;
    } catch (e) {
      debugPrint('Error fetching live auctions: $e');
      return [];
    }
  }

  Future<List<AuctionItem>> fetchListedProducts() async {
    try {
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      List<AuctionItem> allItems = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await http.get(
          Uri.parse(
              '${ApiEndpoints.baseUrl}/auctions/listedProducts/getAllListed-products?page=$page'),
          headers: headers,
        );

        debugPrint(
            'Listed Products Response Code: ${response.statusCode} for page $page');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] is List) {
            final items = (data['data'] as List)
                .map((item) => AuctionItem.fromJson(item))
                .toList();

            final pagination = data['pagination'] as Map<String, dynamic>;
            final totalPages = pagination['totalPages'] as int;

            allItems.addAll(items);
            debugPrint(
                'Successfully parsed ${items.length} listed products for page $page');

            if (page >= totalPages) {
              hasMore = false;
              debugPrint('Reached last page of listed products');
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else {
          hasMore = false;
        }
      }

      debugPrint('Total listed products fetched: ${allItems.length}');
      return allItems;
    } catch (e) {
      debugPrint('Error fetching listed products: $e');
      return [];
    }
  }

  Future<List<AuctionItem>> fetchUpcomingAuctions() async {
    try {
      // First try to get the token
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      // Add authorization header if we have a token
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      List<AuctionItem> allAuctions = [];

      // Fetch upcoming auctions with pagination
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await http.get(
          Uri.parse(
              '${ApiEndpoints.baseUrl}/auctions/user/up-comming?page=$page'),
          headers: headers,
        );

        debugPrint(
            'Upcoming Auctions Response Code: ${response.statusCode} for page $page');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] is List) {
            final items = (data['data'] as List)
                .map((item) => AuctionItem.fromJson(item))
                .toList();

            final pagination = data['pagination'] as Map<String, dynamic>;
            final totalPages = pagination['totalPages'] as int;

            allAuctions.addAll(items);
            debugPrint(
                'Successfully parsed ${items.length} upcoming auctions for page $page');

            if (page >= totalPages) {
              hasMore = false;
              debugPrint('Reached last page of upcoming auctions');
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        } else if (response.statusCode == 401 && accessToken != null) {
          final userService = UserService();
          final refreshResult = await userService.refreshTokens();
          if (refreshResult['success']) {
            accessToken = refreshResult['data']['accessToken'];
            headers['Authorization'] = 'Bearer $accessToken';
            continue;
          } else {
            hasMore = false;
          }
        } else {
          hasMore = false;
        }
      }

      // Fetch scheduled auctions with pagination
      int scheduledPage = 1;
      bool hasMoreScheduled = true;

      while (hasMoreScheduled) {
        final scheduledResponse = await http.get(
          Uri.parse(
              '${ApiEndpoints.baseUrl}/auctions/user/scheduled?page=$scheduledPage'),
          headers: headers,
        );

        debugPrint(
            'Scheduled Auctions Response Code: ${scheduledResponse.statusCode} for page $scheduledPage');

        if (scheduledResponse.statusCode == 200) {
          final data = jsonDecode(scheduledResponse.body);
          if (data['success'] == true && data['data'] is List) {
            final items = (data['data'] as List)
                .map((item) => AuctionItem.fromJson(item))
                .toList();

            final pagination = data['pagination'] as Map<String, dynamic>;
            final totalPages = pagination['totalPages'] as int;

            allAuctions.addAll(items);
            debugPrint(
                'Successfully parsed ${items.length} scheduled auctions for page $scheduledPage');

            if (scheduledPage >= totalPages) {
              hasMoreScheduled = false;
              debugPrint('Reached last page of scheduled auctions');
            } else {
              scheduledPage++;
            }
          } else {
            hasMoreScheduled = false;
          }
        } else if (scheduledResponse.statusCode == 401 && accessToken != null) {
          final userService = UserService();
          final refreshResult = await userService.refreshTokens();
          if (refreshResult['success']) {
            accessToken = refreshResult['data']['accessToken'];
            headers['Authorization'] = 'Bearer $accessToken';
            continue;
          } else {
            hasMoreScheduled = false;
          }
        } else {
          hasMoreScheduled = false;
        }
      }

      debugPrint(
          'Total upcoming and scheduled auctions fetched: ${allAuctions.length}');
      return allAuctions;
    } catch (e) {
      debugPrint('Error fetching upcoming auctions: $e');
      return [];
    }
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    try {
      // First try to get the token
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      // Add authorization header if we have a token
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // Only fetch first page with 10 items
      final response = await http.get(
        Uri.parse(
            '${ApiEndpoints.baseUrl}/auctions/user/expired-auctions?page=1&limit=10'),
        headers: headers,
      );

      debugPrint('Expired Auctions Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final items = (data['data'] as List)
              .map((item) => AuctionItem.fromJson(item))
              .toList();

          // Filter out cancelled auctions
          final validItems = items
              .where((auction) =>
                  auction.status.toUpperCase() != 'CANCELLED_BEFORE_EXP_DATE')
              .toList();

          debugPrint(
              'Successfully parsed ${validItems.length} expired auctions');
          return validItems;
        }
      } else if (response.statusCode == 401 && accessToken != null) {
        // Only try token refresh if we had a token and got 401
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          final retryResponse = await http.get(
            Uri.parse(
                '${ApiEndpoints.baseUrl}/auctions/user/expired-auctions?page=1&limit=10'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            },
          );

          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            if (data['success'] == true && data['data'] is List) {
              final items = (data['data'] as List)
                  .map((item) => AuctionItem.fromJson(item))
                  .toList();

              final validItems = items
                  .where((auction) =>
                      auction.status.toUpperCase() !=
                      'CANCELLED_BEFORE_EXP_DATE')
                  .toList();

              return validItems;
            }
          }
        }
      }

      return [];
    } catch (e) {
      debugPrint('Error fetching expired auctions: $e');
      return [];
    }
  }
}
