import 'dart:convert';
import 'package:http/http.dart' as http;

class AuctionDetailsService {
  static const String baseUrl = 'http://10.120.234.182:3001/api';

  static Future<Map<String, dynamic>?> getAuctionDetails(
      String auctionId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }
    return null;
  }

  // New: Fetch draft auction details for editing
  static Future<Map<String, dynamic>> getDraftAuctionDetails(
      String auctionId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/$auctionId'),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return data;
      } else {
        throw Exception(
            'Failed to fetch draft auction details: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
