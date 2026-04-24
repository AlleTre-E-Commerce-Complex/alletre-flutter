import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:alletre_app/controller/helpers/user_services.dart';

class TokenRefreshService {
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  factory TokenRefreshService() => _instance;
  TokenRefreshService._internal();

  Timer? _tokenRefreshTimer;
  final UserService _userService = UserService();

  void startTokenRefresh() {
    // Cancel any existing timer
    _tokenRefreshTimer?.cancel();
    
    // Start a new timer that refreshes tokens every 10 minutes
    _tokenRefreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      debugPrint('🔄 Attempting to refresh tokens...');
      final result = await _userService.refreshTokens();
      
      if (!result['success']) {
        debugPrint('❌ Failed to refresh tokens: ${result['message']}');
        timer.cancel();
        return;
      }
      
      debugPrint('✅ Tokens refreshed successfully');
    });
  }

  void stopTokenRefresh() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }

  void dispose() {
    stopTokenRefresh();
  }
} 