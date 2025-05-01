import 'package:flutter/material.dart';
import 'package:alletre_app/controller/services/auction_details_service.dart';

class AuctionDetailsProvider extends ChangeNotifier {
  final Map<String, String> _userNames = {};

  String? getUserName(String auctionId) => _userNames[auctionId];

  Future<void> fetchUserName(String auctionId) async {
    try {
      final data = await AuctionDetailsService.getAuctionDetails(auctionId);
      if (data!['success'] == true && data['data']?['user']?['userName'] != null) {
        _userNames[auctionId] = data['data']['user']['userName'];
        notifyListeners();
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching auction details: $e');
    }
  }
}
