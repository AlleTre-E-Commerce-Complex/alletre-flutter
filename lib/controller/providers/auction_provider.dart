// ignore_for_file: avoid_print

import 'dart:io';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:alletre_app/controller/helpers/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  final SocketService _socketService = SocketService();
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
  bool _isCreatingAuction = false;
  bool _isListingProduct = false;

  String? _errorLive;
  String? _errorListedProducts;
  String? _errorUpcoming;
  String? _errorExpired;
  String? _createAuctionError;
  String? _listProductError;

  List<AuctionItem> get liveAuctions => _liveAuctions;
  List<AuctionItem> get listedProducts => _listedProducts;
  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get expiredAuctions => _expiredAuctions;
  bool get isLoading => _isLoading;
  bool get isCreatingAuction => _isCreatingAuction;
  bool get isListingProduct => _isListingProduct;
  String? get error => _error;
  String? get createAuctionError => _createAuctionError;
  String? get listProductError => _listProductError;

  List<AuctionItem> getSimilarProducts(AuctionItem currentItem) {
    // Combine all available products
    final allProducts = [
      ..._listedProducts,
      ..._liveAuctions,
      ..._upcomingAuctions
    ];

    // Get all products from the same category
    final sameCategory = allProducts.where((item) => 
      item.id != currentItem.id && 
      item.categoryId == currentItem.categoryId
    ).toList();

    // If current item is an auction, only show similar auctions
    if (currentItem.isAuctionProduct) {
      final similarAuctions = sameCategory
          .where((item) => item.isAuctionProduct)
          .take(10)
          .toList();
      
      return similarAuctions;
    }
    
    // If current item is a listed product, only show similar listed products
    final similarProducts = sameCategory
        .where((item) => !item.isAuctionProduct)
        .take(10)
        .toList();

    return similarProducts;
  }

  void initializeSocket() {
    _socketService.connect();

    // Listen for connection state changes
    _socketService.connectionState.listen((state) {
      switch (state) {
        case SocketConnectionState.connected:
          _error = null;
          break;
        case SocketConnectionState.disconnected:
          _error = 'Connection lost. Reconnecting...';
          break;
        case SocketConnectionState.error:
          _error = 'Connection error. Please check your internet connection.';
          break;
        default:
          break;
      }
      notifyListeners();
    });

    // Listen for auction updates
    _socketService.auctionUpdates.listen((data) {
      _handleAuctionUpdate(data);
    });

    // Listen for bid updates
    _socketService.bidUpdates.listen((data) {
      _handleBidUpdate(data);
    });

    // Listen for errors
    _socketService.errors.listen((error) {
      _error = error;
      notifyListeners();
    });
  }

  void _handleAuctionUpdate(Map<String, dynamic> data) {
    final String auctionId = data['auctionId']?.toString() ?? '';
    final String updateType = data['type'] ?? '';
    final Map<String, dynamic> updateData = data['data'] ?? {};

    switch (updateType) {
      case 'status_change':
        _updateAuctionStatus(auctionId, updateData);
        break;
      case 'new_auction':
        _addNewAuction(updateData);
        break;
      case 'auction_ended':
        handleAuctionEnded(auctionId);
        break;
    }
  }

  void _handleBidUpdate(Map<String, dynamic> data) {
    final String auctionId = data['auctionId']?.toString() ?? '';
    final String newBid = data['amount']?.toString() ?? '0';
    final int totalBids = data['totalBids'] ?? 0;
    
    void updateList(List<AuctionItem> list) {
      final index = list.indexWhere((item) => item.id.toString() == auctionId);
      if (index != -1) {
        final updatedItem = list[index].copyWith(
          currentBid: newBid,
          bids: totalBids,
        );
        list[index] = updatedItem;
      }
    }

    updateList(_liveAuctions);
    updateList(_listedProducts);
    notifyListeners();
  }

  void _updateAuctionStatus(String auctionId, Map<String, dynamic> statusData) {
    // Remove from old status list and add to new status list
    final auction = [..._liveAuctions, ..._listedProducts, ..._upcomingAuctions, ..._expiredAuctions]
        .firstWhere(
          (item) => item.id.toString() == auctionId,
          orElse: () => AuctionItem.fromJson(statusData), // Create a new item if not found
        );

    // // Parse dates in UTC
    // DateTime? expiryDate;
    // if (statusData['expiryDate'] != null) {
    //   expiryDate = DateTime.parse(statusData['expiryDate']).toUtc();
    // }

    final updatedAuction = auction.copyWith(
      status: statusData['status'],
      expiryDate: statusData['expiryDate'] != null ? DateTime.parse(statusData['expiryDate']) : null,
    );

    // Remove from all lists
    _liveAuctions.removeWhere((item) => item.id.toString() == auctionId);
    _listedProducts.removeWhere((item) => item.id.toString() == auctionId);
    _upcomingAuctions.removeWhere((item) => item.id.toString() == auctionId);
    _expiredAuctions.removeWhere((item) => item.id.toString() == auctionId);
    
      switch (statusData['status']) {
        case 'live':
          _liveAuctions.add(updatedAuction);
          break;
        case 'listed':
          _listedProducts.add(updatedAuction);
          break;
        case 'upcoming':
          _upcomingAuctions.add(updatedAuction);
          break;
        case 'expired':
          _expiredAuctions.add(updatedAuction);
          break;
      }

    notifyListeners();
  }

  void _addNewAuction(Map<String, dynamic> auctionData) {
    final newAuction = AuctionItem.fromJson(auctionData);
    
      switch (newAuction.status) {
        case 'live':
          _liveAuctions.add(newAuction);
          break;
        case 'listed':
          _listedProducts.add(newAuction);
          break;
        case 'upcoming':
          _upcomingAuctions.add(newAuction);
          break;
      }
    
    notifyListeners();
  }

  void handleAuctionEnded(String auctionId) {
    // Remove from all lists
    _liveAuctions.removeWhere((item) => item.id.toString() == auctionId);
    _listedProducts.removeWhere((item) => item.id.toString() == auctionId);
    _upcomingAuctions.removeWhere((item) => item.id.toString() == auctionId);
    _expiredAuctions.removeWhere((item) => item.id.toString() == auctionId);

    notifyListeners();
  }

  bool get isLoadingLive => _isLoadingLive;
  bool get isLoadingListedProducts => _isLoadingListedProducts;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingExpired => _isLoadingExpired;

  String? get errorLive => _errorLive;
  String? get errorListedProducts => _errorListedProducts;
  String? get errorUpcoming => _errorUpcoming;
  String? get errorExpired => _errorExpired;

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

  Future<bool> placeBid(String auctionId, double amount) async {
    return await _socketService.placeBid(auctionId, amount);
  }

  void joinAuctionRoom(String auctionId) {
    _socketService.joinAuctionRoom(auctionId);
  }

  void leaveAuctionRoom(String auctionId) {
    _socketService.leaveAuctionRoom(auctionId);
  }

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
      final auctions = await _auctionService.fetchListedProducts();
      if (auctions.isNotEmpty) {
        _listedProducts = auctions;
      }
      _errorListedProducts = null;
    } catch (e) {
      debugPrint('Error fetching listed products: $e');
      if (e.toString().contains('Authentication failed')) {
        // Token refresh failed, user needs to re-login
        _errorListedProducts = 'Session expired. Please login again.';
      } else {
        _errorListedProducts = 'Failed to load products. Please try again.';
      }
      // Keep existing data
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

  Future<Map<String, dynamic>> createAuction({
  required Map<String, dynamic> auctionData,
  required List<String> imagePaths,
}) async {
  try {
    _isCreatingAuction = true;
    _createAuctionError = '';
    notifyListeners();

    // Convert image paths to File objects
    final List<File> images = imagePaths.map((path) => File(path)).toList();

    // Make sure the product field exists and is a proper object
    if (!auctionData.containsKey('product') || auctionData['product'] is! Map<String, dynamic>) {
      throw Exception('Product data must be a non-empty object');
    }

    // Create auction with the service
    final response = await _auctionService.createAuction(
      auctionData: auctionData,
      images: images,
      locationId: auctionData['locationId'] ?? 1,
    );

    if (response['success']) {
      _createAuctionError = '';
      return response;
    } else {
      _createAuctionError = response['message'] ?? 'Failed to create auction';
      throw Exception(_createAuctionError);
    }
  } catch (e) {
    _createAuctionError = e.toString();
    throw Exception(_createAuctionError);
  } finally {
    _isCreatingAuction = false;
    notifyListeners();
  }
}

Future<Map<String, dynamic>> listProduct({
  required Map<String, dynamic> auctionData,
  required List<String> imagePaths,
}) async {
  try {
    _isListingProduct = true;
    _listProductError = '';
    notifyListeners();

    // Convert image paths to File objects
    final List<File> images = imagePaths.map((path) => File(path)).toList();

    // Make sure the product field exists and is a proper object
    if (!auctionData.containsKey('product') || auctionData['product'] is! Map<String, dynamic>) {
      throw Exception('Product data must be a non-empty object');
    }

    // Create auction with the service
    final response = await _auctionService.listProduct(
      auctionData: auctionData,
      images: images,
      locationId: auctionData['locationId'] ?? 1,
    );

    if (response['success']) {
      _listProductError = '';
      return response;
    } else {
      _listProductError = response['message'] ?? 'Failed to list product';
      throw Exception(_listProductError);
    }
  } catch (e) {
    _listProductError = e.toString();
    throw Exception(_listProductError);
  } finally {
    _isCreatingAuction = false;
    notifyListeners();
  }
}

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
