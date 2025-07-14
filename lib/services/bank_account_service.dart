import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import '../model/bank_account.dart';

class BankAccountService {
  static const String baseUrl = 'http://192.168.1.14:3001/api';
  static const storage = FlutterSecureStorage();

  static Future<List<BankAccount>> getAccountData() async {
    try {
      debugPrint('Fetching bank accounts...');
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        debugPrint('No token found');
        throw Exception('No authentication token found');
      }
      debugPrint('Token found: ${token.substring(0, 10)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/getAccountData'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Get accounts response status: ${response.statusCode}');
      debugPrint('Get accounts response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        debugPrint('Response data: $responseData');

        final List<dynamic> data = responseData['accountData'] ?? [];
        debugPrint('Bank accounts data: $data');

        final accounts =
            data.map((json) => BankAccount.fromJson(json)).toList();
        debugPrint('Parsed ${accounts.length} bank accounts');
        return accounts;
      } else {
        final error = json.decode(response.body);
        debugPrint('Error response: $error');
        throw Exception(error['message'] ?? 'Failed to load bank accounts');
      }
    } catch (e) {
      debugPrint('Error in getAccountData: $e');
      rethrow;
    }
  }

  static Future<void> addBankAccount(BankAccount account) async {
    try {
      debugPrint('Adding bank account...');
      final token = await storage.read(key: 'access_token');
      if (token == null) {
        debugPrint('No token found');
        throw Exception('No authentication token found');
      }
      debugPrint('Token found: ${token.substring(0, 10)}...');

      final accountJson = account.toJson();
      debugPrint('Request payload: $accountJson');

      final response = await http.post(
        Uri.parse('$baseUrl/auctions/user/addBankAccount'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(accountJson),
      );

      debugPrint('Add account response status: ${response.statusCode}');
      debugPrint('Add account response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        final error = json.decode(response.body);
        debugPrint('Error response: $error');
        throw Exception(error['message'] ?? 'Failed to add bank account');
      }
      debugPrint('Bank account added successfully');
    } catch (e) {
      debugPrint('Error in addBankAccount: $e');
      rethrow;
    }
  }
}
