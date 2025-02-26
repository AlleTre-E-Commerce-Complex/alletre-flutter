// ignore_for_file: avoid_print

import 'dart:developer';

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
  bool _isLoadingListedProducts = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingExpired = false;

  bool _isFirstLoad = true;
  bool get isFirstLoad => _isFirstLoad;

  String? _errorLive;
  String? _errorListedProducts;
  String? _errorUpcoming;
  String? _errorExpired;

  DateTime? _lastRefreshTime;
  Duration _refreshCooldown = const Duration(seconds: 5);

  bool get _canRefresh => _lastRefreshTime == null || 
      DateTime.now().difference(_lastRefreshTime!) > _refreshCooldown;

  Future<void> _setRefreshTime() async {
    _lastRefreshTime = DateTime.now();
  }

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
  String? get errorListedProducts => _errorListedProducts;
  String? get errorUpcoming => _errorUpcoming;
  String? get errorExpired => _errorExpired;

  int _currentPage = 1;
  int _totalPages = 1;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  List<AuctionItem> _filteredLiveAuctions = [];
  List<AuctionItem> _filteredListedProducts = [];
  List<AuctionItem> _filteredUpcomingAuctions = [];
  List<AuctionItem> _filteredExpiredAuctions = [];

  void searchItems(String query) {
    _searchQuery = query.toLowerCase();
    
    _filteredLiveAuctions = _liveAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredListedProducts = _listedProducts.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredUpcomingAuctions = _upcomingAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredExpiredAuctions = _expiredAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();

    notifyListeners();
  }

  List<AuctionItem> get filteredLiveAuctions => _searchQuery.isEmpty ? _liveAuctions : _filteredLiveAuctions;
  List<AuctionItem> get filteredListedProducts => _searchQuery.isEmpty ? _listedProducts : _filteredListedProducts;
  List<AuctionItem> get filteredUpcomingAuctions => _searchQuery.isEmpty ? _upcomingAuctions : _filteredUpcomingAuctions;
  List<AuctionItem> get filteredExpiredAuctions => _searchQuery.isEmpty ? _expiredAuctions : _filteredExpiredAuctions;

  Future<void> getLiveAuctions() async {
    if (_isLoadingLive || !_canRefresh) return;

    _isLoadingLive = true;
    _errorLive = null;
    notifyListeners();

    try {
      print('Fetching live auctions...');
      final auctions = await _auctionService.fetchLiveAuctions();
      _liveAuctions = auctions;
      _filteredLiveAuctions = auctions;
      print('Live Auctions Fetched: ${auctions.length}');
      _isFirstLoad = false;
    } catch (e) {
      print('Error in getLiveAuctions: $e');
      _errorLive = e.toString();
      // Only clear auctions on first load or network errors
      if (_isFirstLoad || e.toString().contains('Network error')) {
        _liveAuctions = [];
        _filteredLiveAuctions = [];
      }
    } finally {
      _isLoadingLive = false;
      await _setRefreshTime();
      notifyListeners();
    }
  }

  Future<void> getListedProducts() async {
    if (_isLoadingListedProducts) return;

    _isLoadingListedProducts = true;
    _errorListedProducts = null;
    notifyListeners();

    try {
      print('Fetching listed products...');
      if (_isFirstLoad) {
        _listedProducts.clear();
        _filteredListedProducts.clear();
        _isFirstLoad = false;
      }
      final auctions = await _auctionService.fetchListedProducts(_currentPage);
      _listedProducts = auctions;
      _filteredListedProducts = auctions;
      print('Listed Products Fetched: ${auctions.length}');
    } catch (e) {
      print('Error fetching listed products: $e');
      _errorListedProducts = e.toString();
      _listedProducts = [];
      _filteredListedProducts = [];
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
      print('Fetching upcoming auctions...');
      final auctions = await _auctionService.fetchUpcomingAuctions();
      _upcomingAuctions = auctions;
      _filteredUpcomingAuctions = auctions;
      print('Upcoming Auctions Fetched: ${auctions.length}');
    } catch (e) {
      print('Error fetching upcoming auctions: $e');
      _errorUpcoming = e.toString();
      _upcomingAuctions = [];
      _filteredUpcomingAuctions = [];
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
      _filteredExpiredAuctions = auctions;
      print('Expired Auctions Fetched: ${auctions.length}');
    } catch (e) {
      print('Error fetching expired auctions: $e');
      _errorExpired = e.toString();
      _expiredAuctions = [];
      _filteredExpiredAuctions = [];
    } finally {
      _isLoadingExpired = false;
      notifyListeners();
    }
  }
}
