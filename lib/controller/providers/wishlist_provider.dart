import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/services/api_service.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<int> _wishlistedAuctionIds = {};
  final List<AuctionItem> _wishlistedAuctions = [];

  bool isWishlisted(int auctionId) => _wishlistedAuctionIds.contains(auctionId);
  List<AuctionItem> get wishlistedAuctions => _wishlistedAuctions;

  void toggleWishlist(AuctionItem auction) {
    if (_wishlistedAuctionIds.contains(auction.id)) {
      removeFromWishlist(auction);
    } else {
      saveToWishlist(auction);
    }
  }

  Future<void> saveToWishlist(AuctionItem auction) async {
    try {
      final response = await ApiService.post(
        '${ApiEndpoints .baseUrl}${ApiEndpoints.saveToWishlist}',
        data: {
          'auctionId': auction.id,
        },
      );
      // Assuming API returns success boolean
      if (response.data['success'] == true) {
        _wishlistedAuctionIds.add(auction.id);
        _wishlistedAuctions.add(auction);
        notifyListeners();
      } else {
        debugPrint('Failed to save to wishlist: \\${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error saving to wishlist: \\${e.toString()}');
    }
  }

  Future<void> removeFromWishlist(AuctionItem auction) async {
    try {
      final response = await ApiService.delete(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.unSaveFromWishlist(auction.id)}',
      );
      if (response.data['success'] == true) {
        _wishlistedAuctionIds.remove(auction.id);
        _wishlistedAuctions.removeWhere((item) => item.id == auction.id);
        notifyListeners();
      } else {
        debugPrint('Failed to remove from wishlist: \\${response.data['message']}');
      }
    } catch (e) {
      debugPrint('Error removing from wishlist: \\${e.toString()}');
    }
  }
}