import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  List<AuctionItem> _allAuctions = [];
  String _query = '';

  List<AuctionItem> get filteredAuctions {
    if (_query.isEmpty) {
      return [];
    }
    return _allAuctions
        .where((auction) => auction.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  void setAllAuctions(List<AuctionItem> auctions) {
    _allAuctions = auctions;
    notifyListeners();
  }

  void updateQuery(String query) {
    _query = query;
    notifyListeners();
  }

  bool get isQueryEmpty => _query.isEmpty;
}
