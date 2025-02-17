// ignore_for_file: avoid_print

import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final AuctionService _auctionService = AuctionService();
  List<AuctionItem> _liveAuctions = [];
  List<AuctionItem> _listedProducts = [];
  List<AuctionItem> _upcomingAuctions = [];
  List<AuctionItem> _expiredAuctions = [];
  final bool _isLoading = false;
  String? _error;

  bool _isLoadingLive = false;
  bool _isLoadingListedProducts= false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingExpired = false;

  String? _errorLive;
  String? _errorListedProducts;
  String? _errorUpcoming;
  String? _errorExpired;

  List<AuctionItem> get liveAuctions => _liveAuctions;
  List<AuctionItem> get listedProducts => _listedProducts;
  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get expiredAuctions => _expiredAuctions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isLoadingLive => _isLoadingLive;
  bool get isLoadingListedProducts => _isLoadingListedProducts;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingExpired => _isLoadingExpired;

  String? get errorLive => _errorLive;
  String? get erorListedProducts => _errorListedProducts;
  String? get errorUpcoming => _errorUpcoming;
  String? get errorExpired => _errorExpired;

  Future<void> getLiveAuctions() async {
  if (_isLoadingLive) return;

  _isLoadingLive = true;
  _errorLive = null;
  notifyListeners();

  try {
    print('Starting to fetch live auctions...');
    final auctions = await _auctionService.fetchLiveAuctions();
    print('Received ${auctions.length} live auctions from service');
    _liveAuctions = auctions;
    print('Updated live auctions in provider');
  } catch (e, stackTrace) {
    print('Error in getLiveAuctions:');
    print(e);
    print(stackTrace);
    _errorLive = e.toString();
  } finally {
    _isLoadingLive = false;
    print('Notifying listeners about live auctions update');
    notifyListeners();
  }
}

Future<void> getListedProducts() async {
  if (_isLoadingListedProducts) return;

  _isLoadingListedProducts = true;
  _errorListedProducts = null;
  notifyListeners();

  try {
    final auctions = await _auctionService.fetchListedProducts();
    _listedProducts = auctions;
  } catch (e) {
    _errorListedProducts = e.toString();
  } finally {
    _isLoadingListedProducts = false;
    notifyListeners();
  }
}

  Future<void> getUpcomingAuctions() async {
    if (_isLoadingUpcoming) return;

    _isLoadingUpcoming = true;
    _errorUpcoming = null;
    notifyListeners();

    try {
      // print('Fetching upcoming auctions...');
      final auctions = await _auctionService.fetchUpcomingAuctions();
      _upcomingAuctions = auctions;
      // print('Upcoming Auctions Fetched: ${_upcomingAuctions.length}');
    } catch (e) {
      _errorUpcoming = e.toString();
      // print('Error fetching upcoming auctions: $_error');
    } finally {
      _isLoadingUpcoming = false;
      notifyListeners();
    }
  }

  Future<void> getExpiredAuctions() async {
    if (_isLoadingExpired) return;

    _isLoadingExpired = true;
    _errorExpired = null;
    notifyListeners();

    try {
      print('Fetching expired auctions...');
      final auctions = await _auctionService.fetchExpiredAuctions();
      _expiredAuctions = auctions;
      if (auctions.isNotEmpty) {
      _expiredAuctions = auctions;
    } else {
      print('No expired auctions found');
    }
    } catch (e, stackTrace) {
      _errorExpired = e.toString();
      print('Error fetching expired auctions: $_error');
      print(stackTrace);
    } finally {
      _isLoadingExpired = false;
      notifyListeners();
    }
  }
}