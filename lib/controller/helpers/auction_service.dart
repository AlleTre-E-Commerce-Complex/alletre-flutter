import 'dart:convert';
import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuctionService {
  final String baseUrl = 'https://alletre.com/api/auctions/user';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    // Retrieve the access token from secure storage
    return await _storage.read(key: 'accessToken');
  }

  Future<List<AuctionItem>> fetchUpcomingAuctions() async {
    final accessToken = await _getAccessToken();

    if (accessToken == null) {
      throw Exception('Access token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/expired-auctions'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> auctions = data['data'];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      // Handle 403 Forbidden error (e.g., refresh token)
      throw Exception('Access denied: Invalid or expired token');
    } else {
      throw Exception('Failed to load upcoming auctions: ${response.statusCode}');
    }
  }
}