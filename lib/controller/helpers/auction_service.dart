// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuctionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // Future<Map<String, dynamic>> fetchAuctionDetails(int auctionId) async {
  //   final accessToken = await _getAccessToken();
  //   if (accessToken == null) throw Exception('Access token not found');

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
  //       headers: {'Authorization': 'Bearer $accessToken'},
  //     );

  //     print('Auction Details Response Code: ${response.statusCode}');
      
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       return jsonResponse['data'];
  //     } else {
  //       throw Exception('Failed to load auction details: ${response.statusCode}');
  //     }
  //   } catch (e, stackTrace) {
  //     print('Error in fetchAuctionDetails: $e');
  //     print(stackTrace);
  //     throw Exception('Failed to fetch auction details: $e');
  //   }
  // }

  Future<List<AuctionItem>> fetchLiveAuctions() async {
    try {
      final accessToken = await _getAccessToken();
      final headers = accessToken != null 
          ? {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/main'),
        headers: headers,
      );

      print('Live Auctions Response Code: ${response.statusCode}');
      print('Live Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        print('Failed to load live auctions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching live auctions: $e');
      return [];
    }
  }

  Future<List<AuctionItem>> fetchListedProducts(int page) async {
    try {
      final accessToken = await _getAccessToken();
      final headers = accessToken != null 
          ? {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auctions/listedProducts/getAllListed-products?perPage=20&page=$page'),
        headers: headers,
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

        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        print('Failed to load listed products: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching listed products: $e');
      return [];
    }
  }


  Future<List<AuctionItem>> fetchUpcomingAuctions() async {
    try {
      final accessToken = await _getAccessToken();
      final headers = accessToken != null 
          ? {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/up-comming'),
        headers: headers,
      );

      print('Upcoming Auctions Response Code: ${response.statusCode}');
      print('Upcoming Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        print('Failed to load upcoming auctions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching upcoming auctions: $e');
      return [];
    }
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    try {
      final accessToken = await _getAccessToken();
      final headers = accessToken != null 
          ? {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}
          : {'Content-Type': 'application/json'};

      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/expired-auctions'),
        headers: headers,
      );

      print('Expired Auctions Response Code: ${response.statusCode}');
      print('Expired Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        print('Failed to load expired auctions: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching expired auctions: $e');
      return [];
    }
  }
}
