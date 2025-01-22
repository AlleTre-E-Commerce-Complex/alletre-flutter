// import 'package:alletre_app/model/auction_item.dart';
// import 'package:flutter/material.dart';

// class AuctionProvider with ChangeNotifier {
//   final List<AuctionItem> _upcomingAuctions = [];
//   final List<AuctionItem> _ongoingAuctions = [];

//   List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
//   List<AuctionItem> get ongoingAuctions => _ongoingAuctions;

//   DateTime? _scheduledTime;

//   DateTime? get scheduledTime => _scheduledTime;

//   set scheduledTime(DateTime? time) {
//     _scheduledTime = time;
//     notifyListeners();
//   }

//   // Add an auction to the upcoming list
//   void addUpcomingAuction(AuctionItem auction) {
//     _upcomingAuctions.add(auction);
//     notifyListeners();
//     _checkAuctionStatus(auction);
//   }

//   // Check the status and update it to active if the scheduled time has passed
//   void _checkAuctionStatus(AuctionItem auction) {
//     if (auction.isActive()) {
//       auction.status = 'active';
//       _upcomingAuctions.remove(auction);
//       _ongoingAuctions.add(auction);
//       notifyListeners();
//     }
//   }

//   // Periodic check to update auctions status (optional)
//   void checkAllAuctionsStatus() {
//     for (var auction in _upcomingAuctions) {
//       if (auction.isActive()) {
//         auction.status = 'active';
//         _ongoingAuctions.add(auction);
//       }
//     }
//     notifyListeners();
//   }
// }


import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final List<AuctionItem> _upcomingAuctions = [];
  final List<AuctionItem> _ongoingAuctions = [];

  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get ongoingAuctions => _ongoingAuctions;

  DateTime? _scheduledTime;
  List<String> _media = [];
  String _condition = 'new';

  DateTime? get scheduledTime => _scheduledTime;
  List<String> get media => _media;
  String get condition => _condition;

  set scheduledTime(DateTime? time) {
    _scheduledTime = time;
    notifyListeners();
  }

  void setCondition(String condition) {
    _condition = condition;
    notifyListeners();
  }

  void addMedia(String mediaPath) {
    if (_media.length < 5) {
      _media.add(mediaPath);
      notifyListeners();
    }
  }

  void removeMedia(String mediaPath) {
    _media.remove(mediaPath);
    notifyListeners();
  }

  void clearMedia() {
    _media.clear();
    notifyListeners();
  }

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

  // Periodic check to update auction statuses (optional)
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
