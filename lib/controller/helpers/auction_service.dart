// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuctionService {
  // TODO: Update this URL to match your SSL certificate
  final String baseUrl = 'https://alletre.com/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  Future<Map<String, String>> _getHeaders() async {
    final accessToken = await _getAccessToken();
    return accessToken != null
        ? {'Authorization': 'Bearer $accessToken', 'Content-Type': 'application/json'}
        : {'Content-Type': 'application/json'};
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.toString().contains('CERTIFICATE_VERIFY_FAILED')) {
      return 'Security certificate error. Please contact support.';
    } else if (error.toString().contains('401')) {
      return 'Authentication failed. Please log in again.';
    } else if (error.toString().contains('403')) {
      return 'Access denied. You may not have permission to view this content.';
    } else if (error.toString().contains('404')) {
      return 'Content not found. Please try again later.';
    } else if (error.toString().contains('500')) {
      return 'Server error. Please try again later.';
    }
    return 'An unexpected error occurred. Please try again.';
  }

  Future<List<AuctionItem>> fetchLiveAuctions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/main'),
        headers: headers,
      );

      print('Live Auctions Response Code: ${response.statusCode}');
      print('Live Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] == null) {
          throw Exception('Invalid response format: data field is missing');
        }
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        final error = 'Failed to load live auctions: ${response.statusCode}';
        print(error);
        throw Exception(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      print('Error fetching live auctions: $e');
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<AuctionItem>> fetchListedProducts(int page) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/listedProducts/getAllListed-products?perPage=20&page=$page'),
        headers: headers,
      );

      print('Listed Products Response Code: ${response.statusCode}');
      print('Listed Products Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] == null) {
          throw Exception('Invalid response format: data field is missing');
        }
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        final error = 'Failed to load listed products: ${response.statusCode}';
        print(error);
        throw Exception(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      print('Error fetching listed products: $e');
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<AuctionItem>> fetchUpcomingAuctions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/up-comming'),
        headers: headers,
      );

      print('Upcoming Auctions Response Code: ${response.statusCode}');
      print('Upcoming Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] == null) {
          throw Exception('Invalid response format: data field is missing');
        }
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        final error = 'Failed to load upcoming auctions: ${response.statusCode}';
        print(error);
        throw Exception(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      print('Error fetching upcoming auctions: $e');
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/expired-auctions'),
        headers: headers,
      );

      print('Expired Auctions Response Code: ${response.statusCode}');
      print('Expired Auctions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['data'] == null) {
          throw Exception('Invalid response format: data field is missing');
        }
        final List<dynamic> auctions = jsonResponse['data'];
        return auctions.map((json) => AuctionItem.fromJson(json)).toList();
      } else {
        final error = 'Failed to load expired auctions: ${response.statusCode}';
        print(error);
        throw Exception(_getErrorMessage(response.statusCode));
      }
    } catch (e) {
      print('Error fetching expired auctions: $e');
      throw Exception(_getErrorMessage(e));
    }
  }
}
