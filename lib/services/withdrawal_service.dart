import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class WithdrawalService {
  static const String baseUrl = 'http://192.168.1.14:3001/api';
  static const storage = FlutterSecureStorage();

  static Future<void> submitWithdrawalRequest({
    required String accountId,
    required double amount,
  }) async {
    final token = await storage.read(key: 'access_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/auctions/user/withdrawalRequest'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'selectedBankAccountId': int.parse(accountId),
        'amount': amount,
      }),
    );

    debugPrint('Withdrawal response status: ${response.statusCode}');
    debugPrint('Withdrawal response body: ${response.body}');

    final responseData = json.decode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          responseData['message'] ?? 'Failed to submit withdrawal request');
    }

    if (responseData['success'] == false) {
      throw Exception(
          responseData['message'] ?? 'Failed to submit withdrawal request');
    }
  }
}
