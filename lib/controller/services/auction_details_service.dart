import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuctionDetailsService {
  static const String baseUrl = 'http://192.168.0.158:3001/api';

  static Future<Map<String, dynamic>?> getAuctionDetails(String auctionId) async {
    // debugPrint('🎯 Fetching details for auction: $auctionId');
    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
    );

    // debugPrint('📥 Response status code: ${response.statusCode}');
    final data = jsonDecode(response.body);
    // debugPrint('📦 Response data: $data');

    if (response.statusCode == 200) {
      // debugPrint('✅ Successfully fetched auction details');
      return data;
    }
    return null;
  }

  // New: Fetch draft auction details for editing
  static Future<Map<String, dynamic>> getDraftAuctionDetails(String auctionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/$auctionId'),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        final error = '❌ Failed to fetch draft auction details: ${response.statusCode}';
        debugPrint(error);
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching draft auction details: $e');
      rethrow;
    }
  }
}
