// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuctionService {
  final String baseUrl = 'https://www.alletre.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    // Retrieve the access token from secure storage
    return await _storage.read(key: 'accessToken');
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      throw Exception('Access token not found');
    }
    
    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/expired-auctions'),
      headers: {
        // 'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body');
    print(response.body);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> auctions = data['data'];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      // Implement token refresh here if needed
      throw Exception('Authentication failed: Please login again');
    } else if (response.statusCode == 403) {
      throw Exception('Access denied: User may be blocked');
    } else {
      throw Exception('Failed to load expired auctions: ${response.statusCode}');
    }
  }
}