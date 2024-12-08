import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/material.dart';

class AuctionProvider with ChangeNotifier {
  final List<AuctionItem> _upcomingAuctions = [];
  final List<AuctionItem> _ongoingAuctions = [];

  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get ongoingAuctions => _ongoingAuctions;

  // Add an auction to the upcoming list
  void addUpcomingAuction(AuctionItem auction) {
    _upcomingAuctions.add(auction);
    notifyListeners();
    _checkAuctionStatus(auction);
  }

  // Check the status and update it to active if the scheduled time has passed
  void _checkAuctionStatus(AuctionItem auction) {
    if (auction.isActive()) {
      auction.status = 'active';
      _upcomingAuctions.remove(auction);
      _ongoingAuctions.add(auction);
      notifyListeners();
    }
  }

  // Periodic check to update auctions status (optional)
  void checkAllAuctionsStatus() {
    for (var auction in _upcomingAuctions) {
      if (auction.isActive()) {
        auction.status = 'active';
        _ongoingAuctions.add(auction);
      }
    }
    notifyListeners();
  }
}
