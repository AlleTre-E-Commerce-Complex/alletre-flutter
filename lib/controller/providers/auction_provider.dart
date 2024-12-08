import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/foundation.dart';

class AuctionProvider with ChangeNotifier {
  final List<AuctionItem> _ongoingAuctions = [];
  final List<AuctionItem> _upcomingAuctions = [];

  List<AuctionItem> get ongoingAuctions => _ongoingAuctions;
  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;

  void addOngoingAuction(AuctionItem auction) {
    _ongoingAuctions.add(auction);
    notifyListeners();
  }

  void addUpcomingAuction(AuctionItem auction) {
    _upcomingAuctions.add(auction);
    notifyListeners();
  }
}
