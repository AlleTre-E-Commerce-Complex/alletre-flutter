import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/foundation.dart';

class AuctionProvider with ChangeNotifier {
  List<AuctionItem> _ongoingAuctions = [];
  List<AuctionItem> _upcomingAuctions = [];

  List<AuctionItem> get ongoingAuctions => _ongoingAuctions;
  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;

  void setOngoingAuctions(List<AuctionItem> auctions) {
    _ongoingAuctions = auctions;
    notifyListeners();
  }

  void setUpcomingAuctions(List<AuctionItem> auctions) {
    _upcomingAuctions = auctions;
    notifyListeners();
  }
}
