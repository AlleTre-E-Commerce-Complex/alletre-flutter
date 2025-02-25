import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<int> _wishlistedAuctionIds = {};
  final List<AuctionItem> _wishlistedAuctions = [];

  bool isWishlisted(int auctionId) => _wishlistedAuctionIds.contains(auctionId);
  List<AuctionItem> get wishlistedAuctions => _wishlistedAuctions;

  void toggleWishlist(AuctionItem auction) {
    if (_wishlistedAuctionIds.contains(auction.id)) {
      _wishlistedAuctionIds.remove(auction.id);
      _wishlistedAuctions.removeWhere((item) => item.id == auction.id);
    } else {
      _wishlistedAuctionIds.add(auction.id);
      _wishlistedAuctions.add(auction);
    }
    notifyListeners();
  }
}