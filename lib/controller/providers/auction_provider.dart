// ignore_for_file: avoid_print

import 'dart:developer';

import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final AuctionService _auctionService = AuctionService();
    // Map<String, dynamic>? _auctionDetails;
  List<AuctionItem> _liveAuctions = [];
  List<AuctionItem> _listedProducts = [];
  List<AuctionItem> _upcomingAuctions = [];
  List<AuctionItem> _expiredAuctions = [];
  final bool _isLoading = false;
  String? _error;

  // Map<String, dynamic>? get auctionDetails => _auctionDetails;
  bool _isLoadingLive = false;
  bool _isLoadingListedProducts = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingExpired = false;

  bool _isFirstLoad = true;

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
  String? get errorListedProducts => _errorListedProducts;
  String? get errorUpcoming => _errorUpcoming;
  String? get errorExpired => _errorExpired;

  int _currentPage = 1;

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

// Future<void> getAuctionDetails(int auctionId) async {
//     if (_isLoading) return;

//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       print('Fetching details for auction ID: $auctionId');
//       final details = await _auctionService.fetchAuctionDetails(auctionId);
//       _auctionDetails = details;
//       print('Successfully fetched auction details');
//     } catch (e, stackTrace) {
//       print('Error in getAuctionDetails: $e');
//       print(stackTrace);
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

  Future<void> getLiveAuctions() async {
    if (_isLoadingLive) return;

    _isLoadingLive = true;
    _errorLive = null;
    notifyListeners();

    try {
      // print('Starting to fetch live auctions...');
      final auctions = await _auctionService.fetchLiveAuctions();
      // print('Received ${auctions.length} live auctions from service');
      _liveAuctions = auctions;
      // print('Updated live auctions in provider');
    } catch (e, stackTrace) {
      // print('Error in getLiveAuctions:');
      print(e);
      print(stackTrace);
      _errorLive = e.toString();
    } finally {
      _isLoadingLive = false;
      // print('Notifying listeners about live auctions update');
      notifyListeners();
    }
  }

  Future<void> getListedProducts() async {
    if (_isLoadingListedProducts) return;

    _isLoadingListedProducts = true;
    _errorListedProducts = null;
    notifyListeners();

    try {
      log('Fetching listed products...');
      if (_isFirstLoad) {
        _listedProducts.clear(); // Clear the list only during the first load
        _isFirstLoad = false;
      }
      
      final auctions = await _auctionService.fetchListedProducts(_currentPage);
      if (auctions.isNotEmpty) {
        if (_currentPage == 1) {
          _listedProducts = auctions; // Replace list only on first page
        } else {
          _listedProducts.addAll(auctions); // Append for subsequent pages
        }
        log('Listed Products Fetched: ${_listedProducts.length}');
        
        // Increment page only if we got data
        _currentPage++;
      } else {
        // No more data, reset pagination
        _currentPage = 1;
        _isFirstLoad = true;
      }
    } catch (e) {
      _errorListedProducts = e.toString();
      log('Error fetching listed products: $_errorListedProducts');
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
      // print('Fetching expired auctions...');
      final auctions = await _auctionService.fetchExpiredAuctions();
      
      // Filter out auctions with CANCELLED_BEFORE_EXP_DATE status
      _expiredAuctions = auctions.where((auction) => 
        auction.status.toUpperCase() != 'CANCELLED_BEFORE_EXP_DATE'
      ).toList();
      
      if (_expiredAuctions.isEmpty) {
        print('No valid expired auctions found');
      }
    } catch (e, stackTrace) {
      _errorExpired = e.toString();
      // print('Error fetching expired auctions: $_error');
      print(stackTrace);
    } finally {
      _isLoadingExpired = false;
      notifyListeners();
    }
  }
}
