import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuctionDetailsService {
  static const String baseUrl = 'https://www.alletre.com/api';

  static Future<Map<String, dynamic>> getAuctionDetails(String auctionId) async {
    try {
      debugPrint('🎯 Fetching details for auction: $auctionId');
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
      );

      debugPrint('📥 Response status code: ${response.statusCode}');
      final data = jsonDecode(response.body);
      debugPrint('📦 Response data: $data');

      if (response.statusCode == 200) {
        debugPrint('✅ Successfully fetched auction details');
        return data;
      } else {
        final error = '❌ Failed to fetch auction details: ${response.statusCode}';
        debugPrint(error);
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching auction details: $e');
      rethrow;
    }
  }
}
