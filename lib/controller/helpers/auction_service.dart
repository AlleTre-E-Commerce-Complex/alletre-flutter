// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuctionService {
  final String baseUrl = 'https://www.alletre.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<List<AuctionItem>> fetchLiveAuctions() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) throw Exception('Access token not found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/main'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // print('Live Auctions Response Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        // print('Parsing response body...');
        final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

        final List<dynamic> auctions = jsonResponse['data'] as List<dynamic>;
        // print('Number of auctions received: ${auctions.length}');

        List<AuctionItem> parsedAuctions = [];
        for (var i = 0; i < auctions.length; i++) {
          try {
            // print('Parsing auction $i...');
            final auction = AuctionItem.fromJson(auctions[i]);
            // print('Successfully parsed auction $i: ${auction.title}');
            parsedAuctions.add(auction);
          } catch (e, stackTrace) {
            // print('Error parsing auction $i:');
            // print('Data: ${auctions[i]}');
            // print('Error: $e');
            print('Stack trace: $stackTrace');
          }
        }

        // print('Successfully parsed ${parsedAuctions.length} auctions');
        return parsedAuctions;
      } else {
        throw Exception('Failed to load live auctions: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      // print('Error in fetchLiveAuctions: $e');
      print(stackTrace);
      throw Exception('Failed to fetch live auctions: $e');
    }
  }

// Future<List<AuctionItem>> fetchListedProducts() async {
//   final accessToken = await _getAccessToken();
//   if (accessToken == null) throw Exception('Access token not found');

//   final response = await http.get(
//     Uri.parse('$baseUrl/auctions/listedProducts/getAllListed-products'),
//     headers: {'Authorization': 'Bearer $accessToken'},
//   );

//   log('Listed Products Response Code: ${response.statusCode}', name: 'AuctionService');

//   if (response.statusCode == 200) {
//     final List<dynamic> auctions = json.decode(response.body)['data'];
//     return auctions.map((json) => AuctionItem.fromJson(json)).toList();
//   } else {
//     throw Exception('Failed to load listed products: ${response.statusCode}');
//   }
// }

// Future<List<AuctionItem>> fetchListedProducts() async {
//   final accessToken = await _getAccessToken();
//   if (accessToken == null) {
//     log('Access token not found', name: 'AuctionService');
//     throw Exception('Access token not found');
//   }

//   try {
//     final response = await http.get(
//       Uri.parse('$baseUrl/auctions/listedProducts/getAllListed-products'),
//       headers: {'Authorization': 'Bearer $accessToken'},
//     );

//     log('Listed Products Response Code: ${response.statusCode}', name: 'AuctionService');

//     if (response.statusCode == 200) {
//       final jsonResponse = json.decode(response.body) as Map<String, dynamic>;

//       if (!jsonResponse.containsKey('data')) {
//         log('Response does not contain "data" key', name: 'AuctionService', error: jsonResponse);
//         throw Exception('Invalid response format');
//       }

//       final List<dynamic> auctions = jsonResponse['data'] as List<dynamic>;
//       log('Number of listed products received: ${auctions.length}', name: 'AuctionService');

//       return auctions.map((json) {
//         try {
//           final item = AuctionItem.fromJson(json);
//           log('Parsed listed product: ${item.title}', name: 'AuctionService');
//           return item;
//         } catch (e, stackTrace) {
//           log('Error parsing auction item', name: 'AuctionService', error: e, stackTrace: stackTrace);
//           return null;
//         }
//       }).whereType<AuctionItem>().toList();
//     } else {
//       log('Failed to load listed products', name: 'AuctionService', error: response.statusCode);
//       throw Exception('Failed to load listed products: ${response.statusCode}');
//     }
//   } catch (e, stackTrace) {
//     log('Error in fetchListedProducts', name: 'AuctionService', error: e, stackTrace: stackTrace);
//     throw Exception('Failed to fetch listed products: $e');
//   }
// }

  // Future<List<AuctionItem>> fetchListedProducts() async {
  //   final accessToken = await _getAccessToken();
  //   if (accessToken == null) throw Exception('Access token not found');

  //   final response = await http.get(
  //     Uri.parse('$baseUrl/auctions/listedProducts/getAllListed-products?page=1&perPage=4'),
  //     headers: {'Authorization': 'Bearer $accessToken'},
  //   );

  //   print('Listed Products Response Code: ${response.statusCode}');
  //   print('Listed Products Response Body: ${response.body}');

  //   if (response.statusCode == 200) {
  //     final List<dynamic> auctions = json.decode(response.body)['data'];
  //     return auctions.map((json) => AuctionItem.fromJson(json)).toList();
  //   } else {
  //     throw Exception(
  //         'Failed to load listed products: ${response.statusCode}');
  //   }
  // }

  Future<List<AuctionItem>> fetchListedProducts(int page) async {
  final accessToken = await _getAccessToken();
  if (accessToken == null) throw Exception('Access token not found');

  final response = await http.get(
    Uri.parse('$baseUrl/auctions/listedProducts/getAllListed-products?perPage=20'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
      },
  );

  print('Listed Products Response Code: ${response.statusCode}');
  print('Listed Products Response Body: ${response.body}');

  if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> auctions = jsonResponse['data'];
      final pagination = jsonResponse['pagination'];

      // Check pagination details
      final totalPages = pagination['totalPages'];
      final totalItems = pagination['totalItems'];

      print('Fetched page: $page, Total pages: $totalPages, Total items: $totalItems');

      // Return the list of auction items
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load listed products: ${response.statusCode}');
    }
  }

  Future<List<AuctionItem>> fetchUpcomingAuctions() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) throw Exception('Access token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/up-comming'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // print('Upcoming Auctions Response Code: ${response.statusCode}');
    // print('Upcoming Auctions Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> auctions = json.decode(response.body)['data'];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load upcoming auctions: ${response.statusCode}');
    }
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) throw Exception('Access token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/expired-auctions'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    // print('Expired Auctions Response Code: ${response.statusCode}');
    // print('Expired Auctions Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> auctions = json.decode(response.body)['data'];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load expired auctions: ${response.statusCode}');
    }
  }
}
