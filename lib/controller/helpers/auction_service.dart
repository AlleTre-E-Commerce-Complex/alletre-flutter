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

  Future<Map<String, dynamic>> setDeliveryType(String auctionId, String deliveryType) async {
    try {
      String? accessToken = await _getAccessToken();
      final url = Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/$auctionId/set-delivery-type');
      final body = jsonEncode({
        'auctionId': auctionId,
        'deliveryType': deliveryType,
      });
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };

      debugPrint('--- setDeliveryType DEBUG START ---');
      debugPrint('Endpoint: $url');
      debugPrint('Headers:');
      headers.forEach((k, v) => debugPrint('  $k: $v'));
      debugPrint('Request Body: $body');
      debugPrint('--- Sending PUT request...');

      var response = await http.put(url, headers: headers, body: body);

      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      if (response.statusCode == 401) {
        debugPrint('401 Unauthorized. Attempting token refresh...');
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('Retrying POST with refreshed token...');
          response = await http.post(url, headers: headers, body: body);
          debugPrint('Retry Response Status: ${response.statusCode}');
          debugPrint('Retry Response Body: ${response.body}');
        } else {
          debugPrint('Token refresh failed.');
          return {'success': false, 'message': 'Authentication failed'};
        }
      }
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('--- setDeliveryType DEBUG END: SUCCESS ---');
        return {'success': true, 'data': data['data']};
      } else {
        debugPrint('--- setDeliveryType DEBUG END: FAILURE ---');
        return {'success': false, 'message': data['message'] ?? 'Failed to set delivery type'};
      }
    } catch (e, stack) {
      debugPrint('--- setDeliveryType DEBUG END: EXCEPTION ---');
      debugPrint('Exception: $e');
      debugPrint('Stack Trace: $stack');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> buyNow(String auctionId) async {
    try {
      String? accessToken = await _getAccessToken();
      final url = Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/$auctionId/buy-now');
      final body = jsonEncode({'auctionId': auctionId});
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      var response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 401) {
        // Try refresh
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          headers['Authorization'] = 'Bearer $accessToken';
          response = await http.post(url, headers: headers, body: body);
        } else {
          return {'success': false, 'message': 'Authentication failed'};
        }
      }
      final data = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Buy Now failed'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }


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
        if (cleanProduct['memory'] != null) {
          cleanProduct['memory'] =
              int.parse(cleanProduct['memory'].toString());
        }
        if (cleanProduct['age'] != null) {
          cleanProduct['age'] =
              int.parse(cleanProduct['age'].toString());
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

      // Debug: print all request fields before sending
      debugPrint('Request fields being sent to backend:');
      request.fields.forEach((key, value) {
        debugPrint('  $key: $value (type: \'${value.runtimeType}\')');
      });
      // Double-check required fields
      final requiredFields = ['title', 'description', 'categoryId'];
      for (final field in requiredFields) {
        if (!request.fields.containsKey(field) || request.fields[field]!.trim().isEmpty) {
          debugPrint('ERROR: Required field "$field" is missing or empty!');
        }
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

      // --- Token refresh logic ---
      if (response.statusCode == 403 && responseData.contains('jwt expired')) {
        // Try to refresh token and retry once
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          request.headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('Retrying request with refreshed token...');
          final retryResponse = await request.send();
          final retryResponseData = await retryResponse.stream.bytesToString();
          debugPrint('Retry Response Status: ${retryResponse.statusCode}');
          debugPrint('Retry Response body: $retryResponseData');

          if (retryResponse.statusCode == 403 && retryResponseData.contains('jwt expired')) {
            throw Exception('Session expired. Please login again.');
          }

          final retryData = jsonDecode(retryResponseData) as Map<String, dynamic>;
          return retryData;
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }
      // --- End Token refresh logic ---

      final data = jsonDecode(responseData) as Map<String, dynamic>;
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Replace jwt expired error message for user
        if (data['message']?.toString().contains('jwt expired') ?? false) {
          throw Exception('Session expired. Please login again.');
        } else {
          throw Exception('Failed to create auction: ${data['message']}');
        }
      }
      return data;
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

      // Debug: print all request fields before sending
      debugPrint('Request fields being sent to backend:');
      request.fields.forEach((key, value) {
        debugPrint('  $key: $value (type: \'${value.runtimeType}\')');
      });
      // Double-check required fields
      final requiredFields = ['title', 'description', 'categoryId'];
      for (final field in requiredFields) {
        if (!request.fields.containsKey(field) || request.fields[field]!.trim().isEmpty) {
          debugPrint('ERROR: Required field "$field" is missing or empty!');
        }
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

      // --- Token refresh logic ---
      if (response.statusCode == 403 && responseData.contains('jwt expired')) {
        // Try to refresh token and retry once
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          request.headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('Retrying request with refreshed token...');
          final retryResponse = await request.send();
          final retryResponseData = await retryResponse.stream.bytesToString();
          debugPrint('Retry Response Status: ${retryResponse.statusCode}');
          debugPrint('Retry Response body: $retryResponseData');

          if (retryResponse.statusCode == 403 && retryResponseData.contains('jwt expired')) {
            throw Exception('Session expired. Please login again.');
          }

          final retryData = jsonDecode(retryResponseData) as Map<String, dynamic>;
          return retryData;
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }
      // --- End Token refresh logic ---

      final data = jsonDecode(responseData) as Map<String, dynamic>;
      if (response.statusCode != 200 && response.statusCode != 201) {
        // Replace jwt expired error message for user
        if (data['message']?.toString().contains('jwt expired') ?? false) {
          throw Exception('Session expired. Please login again.');
        } else {
          throw Exception('Failed to create auction: ${data['message']}');
        }
      }
      return data;
    } catch (e, stackTrace) {
      debugPrint('Error creating auction: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Save auction as draft
  Future<Map<String, dynamic>> saveDraft({
    required Map<String, dynamic> auctionData,
    required List<File> images,
    // required int locationId,
  }) async {
    try {
      debugPrint('Starting save draft...');
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

      debugPrint('Token acquired, preparing draft request...');
      // If there are images, use multipart, else send JSON
      if (images.isNotEmpty) {
        // Use multipart for images
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiEndpoints.baseUrl}/auctions/save-draft'),
        );

        // Set headers
        request.headers.addAll({
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        });

        // Add all product fields at the top level (not nested under 'product')
        auctionData.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        // Debug: print all request fields before sending
        debugPrint('Request fields being sent to backend:');
        request.fields.forEach((key, value) {
          debugPrint('  $key: $value (type: \'${value.runtimeType}\')');
        });
        // Double-check required fields
        final requiredFields = ['title', 'description', 'categoryId'];
        for (final field in requiredFields) {
          if (!request.fields.containsKey(field) || request.fields[field]!.trim().isEmpty) {
            debugPrint('ERROR: Required field "$field" is missing or empty!');
          }
        }

        // Add media files (images and videos)
        debugPrint('Adding ${images.length} media files to draft...');
        for (var i = 0; i < images.length; i++) {
          final file = images[i];
          final fileName = file.path.split('/').last;
          final isVideo = fileName.toLowerCase().endsWith('.mp4') || fileName.toLowerCase().endsWith('.mov');
          request.files.add(
            await http.MultipartFile.fromPath(
              isVideo ? 'videos' : 'images',
              file.path,
              contentType: isVideo
                  ? MediaType('video', 'mp4')
                  : MediaType('image', 'jpeg'),
            ),
          );
        }

        // Send request
        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        final data = json.decode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'data': data['data']};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to save draft',
          };
        }
      } else {
        // No images: send as JSON
        final response = await http.post(
          Uri.parse('${ApiEndpoints.baseUrl}/auctions/save-draft'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(auctionData),
        );
        debugPrint('Save draft response status: ${response.statusCode}');
        debugPrint('Save draft response body: ${response.body}');
        final data = json.decode(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {'success': true, 'data': data['data']};
        } else {
          return {
            'success': false,
            'message': data['message'] ?? 'Failed to save draft',
          };
        }
      }
    } catch (e) {
      debugPrint('Error saving draft: $e');
      return {
        'success': false,
        'message': e.toString(),
      };
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

  Future<List<AuctionItem>> fetchDrafts() async {
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
          Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/ownes?page=$page&perPage=10&status=DRAFTED'),
          headers: headers,
        );

        debugPrint('Drafts Response Code: ${response.statusCode} for page $page');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] is List) {
            final items = (data['data'] as List)
                .map((item) => AuctionItem.fromJson(item))
                .toList();

            final pagination = data['pagination'] as Map<String, dynamic>;
            final totalPages = pagination['totalPages'] as int;

            allItems.addAll(items);
            debugPrint('Successfully parsed ${items.length} drafts for page $page');

            if (page >= totalPages) {
              hasMore = false;
              debugPrint('Reached last page of drafts');
            } else {
              page++;
            }
          } else {
            hasMore = false;
          }
        
          // Try to refresh token and retry once
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

      debugPrint('Total drafts fetched: ${allItems.length}');
      return allItems;
    } catch (e) {
      debugPrint('Error fetching drafts: $e');
      return [];
    }
  }

  Future<bool> deleteDraft(String auctionId) async {
    try {
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      };

      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.delete(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userAuctionDetails(auctionId)}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      }

      // Handle token refresh if needed
      if (response.statusCode == 401 && accessToken != null) {
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          final retryResponse = await http.delete(
            Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.userAuctionDetails(auctionId)}'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
              'Content-Type': 'application/json'
            },
          );
          return retryResponse.statusCode == 200;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Error deleting draft: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> submitBid(String auctionId, double bidAmount) async {
    try {
      String? accessToken = await _getAccessToken();
      if (accessToken == null) {
        throw Exception('Not authenticated');
      }

      debugPrint('🔍 AuctionService.submitBid Debug:');
      debugPrint('🔍 Received bid amount: $bidAmount');
      debugPrint('🔍 Auction ID: $auctionId');
      debugPrint('🔍 Access Token: ${accessToken.substring(0, 10)}...');
      
      final requestBody = jsonEncode({
        'bidAmount': bidAmount,
      });
      debugPrint('🔍 Request Body (JSON): $requestBody');

      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.userAuctionDetails(auctionId)}/submit-bid';
      debugPrint('🔍 Request URL: $url');
      debugPrint('🔍 Request Headers:');
      debugPrint('  - Content-Type: application/json');
      debugPrint('  - Authorization: Bearer ${accessToken.substring(0, 10)}...');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBody,
      );

      debugPrint('🔍 Response Status Code: ${response.statusCode}');
      debugPrint('🔍 Response Headers: ${response.headers}');
      debugPrint('🔍 Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        debugPrint('🔍 Error Response Details:');
        debugPrint('  - Status Code: ${response.statusCode}');
        debugPrint('  - Error Body: $error');
        
        final errorMessage = error['message'] ?? error['error'] ?? 'Failed to submit bid';
        debugPrint('🔍 Extracted Error Message: $errorMessage');
        throw Exception(errorMessage);
      }

      final responseData = jsonDecode(response.body);
      debugPrint('🔍 Successful Response Data: $responseData');
      return responseData;
    } catch (e) {
      debugPrint('🔍 Bid Submission Error:');
      debugPrint('  - Error Type: ${e.runtimeType}');
      debugPrint('  - Error Message: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> processBidderDeposit(String auctionId, double bidAmount) async {
    try {
      final now = DateTime.now();
      print('==============================');
      print('🔍 [${now.toIso8601String()}] Starting Bidder Deposit Payment');
      print('  - Auction ID: $auctionId');
      print('  - Bid Amount: $bidAmount');
      String? accessToken = await _getAccessToken();
      print('  - Access Token: ${accessToken?.substring(0, 20) ?? "null"}...');
      if (accessToken == null) {
        print('❌ No access token found!');
        throw Exception('Not authenticated');
      }

      final requestBody = jsonEncode({
        'bidAmount': bidAmount,
      });

      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.userAuctionDetails(auctionId)}/bidder-deposit';
      print('🔍 Deposit Payment Request:');
      print('  - URL: $url');
      print('  - Headers:');
      print('    * Content-Type: application/json');
      print('    * Authorization: Bearer ${accessToken.substring(0, 20)}...');
      print('  - Body: $requestBody');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: requestBody,
      );

      print('🔍 Deposit Payment Response:');
      print('  - Status Code: ${response.statusCode}');
      print('  - Headers: ${response.headers}');
      print('  - Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = jsonDecode(response.body);
        final errorMessage = error['message'] ?? error['error'] ?? 'Failed to process deposit';
        print('🔍 Deposit Payment Error:');
        print('  - Status Code: ${response.statusCode}');
        print('  - Error Message: $errorMessage');
        print('  - Full Error: $error');
        throw Exception(errorMessage);
      }

      print('🔍 Detailed Debugging:');
      print('  - Access Token: $accessToken');
      print('  - Request Body: $requestBody');
      print('  - Request Headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      }}');
      print('  - Response Status Code: ${response.statusCode}');
      print('  - Response Headers: ${response.headers}');
      print('  - Response Body: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Deposit Payment Success!');
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Deposit Payment Error:');
        print('  - Status Code: ${response.statusCode}');
        print('  - Headers: ${response.headers}');
        print('  - Body: ${response.body}');
        try {
          final errorJson = jsonDecode(response.body);
          print('  - Backend Error Fields:');
          print('    * statusCode: ${errorJson['statusCode']}');
          print('    * message: ${errorJson['message']}');
          if (errorJson['error'] != null) print('    * error: ${errorJson['error']}');
          if (errorJson['stack'] != null) print('    * stack: ${errorJson['stack']}');
          String errorDetails = 'Deposit payment failed [${response.statusCode}]: ${errorJson['message']}';
          if (errorJson['error'] != null) errorDetails += ' (${errorJson['error']})';
          if (errorJson['stack'] != null) errorDetails += '\nBackend stack: ${errorJson['stack']}';
          throw Exception(errorDetails);
        } catch (jsonErr) {
          print('  - Could not parse backend error JSON: $jsonErr');
          throw Exception('Deposit payment failed [${response.statusCode}]: ${response.body}');
        }
      }
    } catch (e, stack) {
      print('🔍 Deposit Payment Exception:');
      print('  - Error Type: ${e.runtimeType}');
      print('  - Error Message: $e');
      print('  - Stack Trace: $stack');
      if (e is http.ClientException) {
        print('  - Client Exception Details:');
        print('    * Message: ${e.message}');
        print('    * Uri: ${e.uri}');
      }
      rethrow;
    }
  }
}
