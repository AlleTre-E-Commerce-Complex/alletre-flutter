import 'package:flutter/material.dart';
import 'package:alletre_app/controller/services/auction_details_service.dart';

class AuctionDetailsProvider extends ChangeNotifier {
  final Map<String, String> _userNames = {};

  String? getUserName(String auctionId) => _userNames[auctionId];

  Future<void> fetchUserName(String auctionId) async {
    if (auctionId.isEmpty) return;
    
    try {
      final data = await AuctionDetailsService.getAuctionDetails(auctionId);
      if (data != null && data['success'] == true && data['data']?['user']?['userName'] != null) {
        _userNames[auctionId] = data['data']['user']['userName'];
        notifyListeners();
      }
    } catch (e) {
      // Silently handle the error without logging
    }
  }
}
