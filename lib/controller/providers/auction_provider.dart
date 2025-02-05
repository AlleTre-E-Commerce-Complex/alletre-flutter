// ignore_for_file: avoid_print

import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
class AuctionProvider with ChangeNotifier {
  final AuctionService _auctionService = AuctionService();
  final List<AuctionItem> _upcomingAuctions = [];
  final List<AuctionItem> _ongoingAuctions = [];
  final bool _isLoading = false;
  String? _error;

  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get ongoingAuctions => _ongoingAuctions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> getUpcomingAuctions() async {
    try {
      final auctions = await _auctionService.fetchUpcomingAuctions();
      _upcomingAuctions.clear();
      _upcomingAuctions.addAll(auctions);
      notifyListeners();
    } catch (e) {
      print('Error fetching upcoming auctions: $e');
    }
  }

  DateTime? _scheduledTime;
  final List<String> _media = [];
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
  _upcomingAuctions.remove(auction);
  _ongoingAuctions.add(AuctionItem(
    id: auction.id,
    title: auction.title,
    price: auction.price,
    description: auction.description,
    startBidAmount: auction.startBidAmount,
    status: 'active', // New status assigned
    startDate: auction.startDate,
    expiryDate: auction.expiryDate,
    imageLinks: auction.imageLinks,
  ));
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
