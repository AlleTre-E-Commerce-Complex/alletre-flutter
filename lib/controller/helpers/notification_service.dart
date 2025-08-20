import 'dart:convert';

import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/model/notification_item.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  Future<String?> _getAccessToken() async {
    try {
      // Get server-issued access token
      final token = await _storage.read(key: 'access_token');
      if (token == null) {
        debugPrint('No access token found');
        return null;
      }

      debugPrint('Using server access token');
      return token;
    } catch (e) {
      debugPrint('Error getting access token: $e');
      return null;
    }
  }

  Future<List<NotificationItem>> fetchNotifications() async {
    List<NotificationItem> notifications = [];
    try {
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final url = Uri.parse('${ApiEndpoints.baseUrl}/notifications/get/all');
      var response = await http.get(url, headers: headers);
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      if (response.statusCode == 401 || response.statusCode == 403) {
        debugPrint('${response.statusCode} Unauthorized. Attempting token refresh...');
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('Retrying POST with refreshed token...');
          response = await http.get(url, headers: headers);
          debugPrint('Retry Response Status: ${response.statusCode}');
          debugPrint('Retry Response Body: ${response.body}');
        } else {
          debugPrint('Token refresh failed.');
        }
      }
      final resp = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('--- fetchNotifications DEBUG END: SUCCESS ---');
        for (var item in resp['data']) {
          item['icon'] = Icons.check_circle;
          item['iconColor'] = Colors.green;
          notifications.add(NotificationItem.fromJson(item));
        }
      } else {
        debugPrint('--- fetchNotifications DEBUG END: FAILURE ---');
        debugPrint(response.body);
      }
    } catch (e, stack) {
      debugPrint('Exception: $e');
      debugPrint('Stack Trace: $stack');
    }
    return notifications;
  }
  Future<Map<String,dynamic>> markAsRead() async {    
    Map<String,dynamic> resp={};
    try {
      String? accessToken = await _getAccessToken();
      Map<String, String> headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      };
      final url = Uri.parse('${ApiEndpoints.baseUrl}/notifications/mark-as-read');
      var response = await http.put(url, headers: headers);
      debugPrint('Response Status: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      if (response.statusCode == 401) {
        debugPrint('401 Unauthorized. Attempting token refresh...');
        final userService = UserService();
        final refreshResult = await userService.refreshTokens();
        if (refreshResult['success']) {
          accessToken = refreshResult['data']['accessToken'];
          headers['Authorization'] = 'Bearer $accessToken';
          debugPrint('Retrying POST with refreshed token...');
          response = await http.put(url, headers: headers);
          debugPrint('Retry Response Status: ${response.statusCode}');
          debugPrint('Retry Response Body: ${response.body}');
        } else {
          debugPrint('Token refresh failed.');
        }
      }
      resp = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('--- markAsRead DEBUG END: SUCCESS ---');
        
      } else {
        debugPrint('--- markAsRead DEBUG END: FAILURE ---');
        debugPrint(response.body);
      }
    } catch (e, stack) {
      debugPrint('Exception: $e');
      debugPrint('Stack Trace: $stack');
    }
    return resp;
  }
}
