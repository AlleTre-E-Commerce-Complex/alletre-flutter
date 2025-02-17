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
      Uri.parse('$baseUrl/auctions/user/live'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> auctions = responseData['data'] ?? [];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      print('Live auctions fetch failed with status: ${response.statusCode}');
      return [];
    }
  } catch (e, stackTrace) {
    print('Error fetching live auctions: $e');
    print(stackTrace);
    return [];
  }
}


Future<List<AuctionItem>> fetchListedProducts() async {
  final accessToken = await _getAccessToken();
  if (accessToken == null) throw Exception('Access token not found');

  final response = await http.get(
    Uri.parse('$baseUrl/auctions/getAllListed-products'),
    headers: {'Authorization': 'Bearer $accessToken'},
  );

  print('Listed Products Response Code: ${response.statusCode}');

  if (response.statusCode == 200) {
    final List<dynamic> auctions = json.decode(response.body)['data'];
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
      throw Exception('Failed to load upcoming auctions: ${response.statusCode}');
    }
  }

  Future<List<AuctionItem>> fetchExpiredAuctions() async {
    final accessToken = await _getAccessToken();
    if (accessToken == null) throw Exception('Access token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/auctions/user/expired-auctions'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    print('Expired Auctions Response Code: ${response.statusCode}');
    // print('Expired Auctions Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> auctions = json.decode(response.body)['data'];
      return auctions.map((json) => AuctionItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load expired auctions: ${response.statusCode}');
    }
  }
}