import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'http://192.168.0.158:3001/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<Response> get(String endpoint) async {
    final token = await _getToken();
    debugPrint('🔍 API Request: GET $baseUrl$endpoint');

    try {
      final response = await _dio.get(
        baseUrl + endpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      debugPrint('🔍 API Response status: ${response.statusCode}');
      debugPrint('🔍 API Response data type: ${response.data.runtimeType}');
      debugPrint('🔍 API Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
      debugPrint('🔍 API Error status: ${e.response?.statusCode}');
      debugPrint('🔍 API Error data: ${e.response?.data}');
      debugPrint('🔍 API Error message: ${e.message}');
      debugPrint('🔍 API Error URI: ${e.requestOptions.uri}');
      rethrow;
    } catch (e) {
      debugPrint('🔍 Unexpected API error: $e');
      rethrow;
    }
  }

  static Future<Response> post(String endpoint, {dynamic data}) async {
    final token = await _getToken();
    debugPrint('🔍 API Request: POST $baseUrl$endpoint');
    debugPrint('🔍 Request data: $data');

    try {
      final response = await _dio.post(
        baseUrl + endpoint,
        data: data,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('🔍 API Response status: ${response.statusCode}');
      debugPrint('🔍 API Response headers: ${response.headers}');
      debugPrint('🔍 API Response data: ${response.data}');

      return response;
    } on DioException catch (e) {
    debugPrint('🔍 API Error status: ${e.response?.statusCode}');
    debugPrint('🔍 API Error data: ${e.response?.data}');
    debugPrint('🔍 API Error message: ${e.message}');
    debugPrint('🔍 API Error URI: ${e.requestOptions.uri}');
    
    rethrow;
  }
    catch (e) {
      debugPrint('🔍 Unexpected API error: $e');
      rethrow;
    }
  }
}
