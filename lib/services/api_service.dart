// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../controller/helpers/user_services.dart';
import '../controller/helpers/navigation_services.dart';
import '../utils/routes/main_stack.dart';

class ApiService {
  static final Dio _dio = Dio();
  static const String baseUrl = 'http://192.168.0.158:3001/api';
  static const _storage = FlutterSecureStorage();

  static Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Setup Dio interceptor for token refresh and auto logout
  static void setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) async {
          final isJwtExpired = (e.response?.statusCode == 401 ||
              (e.response?.data is Map &&
                  (e.response?.data['message']?.toString().toLowerCase().contains('jwt expired') ?? false)));
          if (isJwtExpired) {
            // Try to refresh token
            final refreshResult = await UserService().refreshTokens();
            if (refreshResult['success']) {
              // Retry original request with new token
              final newToken = refreshResult['data']['accessToken'];
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final cloneReq = await _dio.request(
                  opts.path,
                  options: Options(
                    method: opts.method,
                    headers: opts.headers,
                  ),
                  data: opts.data,
                  queryParameters: opts.queryParameters,
                );
                return handler.resolve(cloneReq);
              } catch (e) {
                // If retry fails, logout
                await UserService().logout();
                final navigator = NavigationService.navigatorKey.currentState;
                if (navigator != null) {
                  // Show session timeout message before redirect
                  ScaffoldMessenger.of(navigator.context).showSnackBar(
                    const SnackBar(
                      content: Text('Session timed out. Please login again.'),
                      backgroundColor: onSecondaryColor,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 2));
                  navigator.pushNamedAndRemoveUntil(MainStack.login, (route) => false);
                }
                return;
              }
            } else {
              // Refresh token expired or invalid: logout and redirect
              await UserService().logout();
              final navigator = NavigationService.navigatorKey.currentState;
              if (navigator != null) {
                // Show session timeout message before redirect
                ScaffoldMessenger.of(navigator.context).showSnackBar(
                  const SnackBar(
                    content: Text('Session timed out. Please login again.'),
                    backgroundColor: onSecondaryColor,
                    duration: Duration(seconds: 2),
                  ),
                );
                await Future.delayed(const Duration(seconds: 2));
                navigator.pushNamedAndRemoveUntil(MainStack.login, (route) => false);
              }
              return;
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Future<Response> get(String endpoint) async {
    final token = await _getToken();
    debugPrint('🔍 API Request: GET $baseUrl$endpoint');

    if (token == null) {
      throw Exception('No access token found');
    }

    try {
      final response = await _dio.get(
        baseUrl + endpoint,
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

    if (token == null) {
      throw Exception('No access token found');
    }

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
      rethrow;
    } catch (e) {
      debugPrint('🔍 Unexpected API error: $e');
      rethrow;
    }
  }
}
