// ignore_for_file: avoid_print
import 'dart:io';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:alletre_app/controller/helpers/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class AuctionProvider with ChangeNotifier {
  // Tracks pending optimistic bids: auctionId -> bidAmount
  final Map<int, double> _pendingOptimisticBids = {};

  /// Removes an auction from the live auctions list and notifies listeners
  void removeAuctionFromLive(int auctionId) {
    _liveAuctions.removeWhere((item) => item.id == auctionId);
    notifyListeners();
  }

  void optimisticBidUpdate(int auctionId, double newBid, int newTotalBids) {
    _pendingOptimisticBids[auctionId] = newBid;
    void updateList(List<AuctionItem> list) {
      final index = list.indexWhere((item) => item.id == auctionId);
      if (index != -1) {
        final updatedItem = list[index].copyWith(
          currentBid: newBid.toString(),
          bids: newTotalBids,
        );
        list[index] = updatedItem;
      }
    }

    updateList(_liveAuctions);
    updateList(_listedProducts);
    notifyListeners();
  }

  AuctionItem? getAuctionById(int id) {
    try {
      return _liveAuctions.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  final SocketService _socketService = SocketService();
  final AuctionService _auctionService = AuctionService();
  List<AuctionItem> _liveAuctions = [];
  List<AuctionItem> _liveMyAuctions = [];
  List<AuctionItem> _listedProducts = [];
  List<AuctionItem> _upcomingAuctions = [];
  List<AuctionItem> _expiredAuctions = [];
  List<AuctionItem> _soldAuctions = [];
  List<AuctionItem> _pendingAuctions = [];
  List<AuctionItem> _waitingForPaymentAuctions = [];
  List<AuctionItem> _cancelledAuctions = [];
  List<AuctionItem> _inProgressProducts = [];
  List<AuctionItem> _outOfStockProducts = [];
  List<AuctionItem> _soldOutProducts = [];
  List<AuctionItem> _joinedAuctions = [];
  final bool _isLoading = false;
  String? _error;

  bool _isLoadingLive = false;
  bool _isLoadingMyLive = false;
  bool _isLoadingListedProducts = false;
  bool _isLoadingUpcoming = false;
  bool _isLoadingExpired = false;
  bool _isLoadingSold = false;
  bool _isLoadingPending = false;
  bool _isLoadingWaitingForPayment = false;
  bool _isLoadingCancelled = false;
  bool _isLoadingInProgress = false;
  bool _isLoadingOutOfStock = false;
  bool _isLoadingSoldOut = false;
  bool _isCreatingAuction = false;
  bool _isListingProduct = false;

  String? _errorLive;
  String? _errorMyLive;
  String? _errorListedProducts;
  String? _errorUpcoming;
  String? _errorExpired;
  String? _errorSold;
  String? _errorPending;
  String? _errorWaitingForPayment;
  String? _errorCancelled;
  String? _errorInProgress;
  String? _errorOutOfStock;
  String? _errorSoldOut;
  String? _createAuctionError;
  String? _listProductError;

  List<AuctionItem> get liveAuctions => _liveAuctions;
  List<AuctionItem> get liveMyAuctions => _liveMyAuctions;
  List<AuctionItem> get listedProducts => _listedProducts;
  List<AuctionItem> get upcomingAuctions => _upcomingAuctions;
  List<AuctionItem> get expiredAuctions => _expiredAuctions;
  List<AuctionItem> get soldAuctions => _soldAuctions;
  List<AuctionItem> get pendingAuctions => _pendingAuctions;
  List<AuctionItem> get waitingForPaymentAuctions => _waitingForPaymentAuctions;
  List<AuctionItem> get cancelledAuctions => _cancelledAuctions;
  List<AuctionItem> get inProgressProducts => _inProgressProducts;
  List<AuctionItem> get outOfStockProducts => _outOfStockProducts;
  List<AuctionItem> get soldOutProducts => _soldOutProducts;
  List<AuctionItem> get joinedAuctions => _joinedAuctions;

  bool get isLoading => _isLoading;
  bool get isCreatingAuction => _isCreatingAuction;
  bool get isListingProduct => _isListingProduct;
  bool get isLoadingPending => _isLoadingPending;
  bool get isLoadingWaitingForPayment => _isLoadingWaitingForPayment;
  bool get isLoadingCancelled => _isLoadingCancelled;
  bool get isLoadingInProgress => _isLoadingInProgress;
  bool get isLoadingOutOfStock => _isLoadingOutOfStock;
  bool get isLoadingSoldOut => _isLoadingSoldOut;

  String? get error => _error;

  String? get errorPending => _errorPending;
  String? get errorWaitingForPayment => _errorWaitingForPayment;
  String? get errorCancelled => _errorCancelled;
  String? get errorInProgress => _errorInProgress;
  String? get errorOutOfStock => _errorOutOfStock;
  String? get errorSoldOut => _errorSoldOut;
  String? get createAuctionError => _createAuctionError;
  String? get listProductError => _listProductError;

  List<AuctionItem> getSimilarProducts(AuctionItem currentItem) {
    // Combine all available products
    final allProducts = [..._listedProducts, ..._liveAuctions, ..._upcomingAuctions];

    // Get all products from the same category
    final sameCategory = allProducts.where((item) => item.id != currentItem.id && item.categoryId == currentItem.categoryId).toList();

    // If current item is an auction, only show similar auctions
    if (currentItem.isAuctionProduct) {
      final similarAuctions = sameCategory.where((item) => item.isAuctionProduct).take(10).toList();

      return similarAuctions;
    }

    // If current item is a listed product, only show similar listed products
    final similarProducts = sameCategory.where((item) => !item.isAuctionProduct).take(10).toList();

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
    final String auctionIdStr = data['auctionId']?.toString() ?? '';
    final int? auctionId = int.tryParse(auctionIdStr);
    final String newBidStr = data['amount']?.toString() ?? '0';
    final double newBid = double.tryParse(newBidStr) ?? 0;
    final int totalBids = data['totalBids'] ?? 0;

    void updateList(List<AuctionItem> list) {
      final index = list.indexWhere((item) => item.id.toString() == auctionIdStr);
      if (index != -1) {
        double? optimisticBid = auctionId != null ? _pendingOptimisticBids[auctionId] : null;
        // If there's a pending optimistic bid, only accept backend if it matches or exceeds
        if (optimisticBid != null) {
          if (newBid >= optimisticBid) {
            // Backend caught up or surpassed, clear optimism and update
            _pendingOptimisticBids.remove(auctionId);
            final updatedItem = list[index].copyWith(
              currentBid: newBidStr,
              bids: totalBids,
            );
            list[index] = updatedItem;
          } else {
            // Backend is behind, keep optimistic value
            // Do not update currentBid here
            return;
          }
        } else {
          // No optimism, just update
          final updatedItem = list[index].copyWith(
            currentBid: newBidStr,
            bids: totalBids,
          );
          list[index] = updatedItem;
        }
      }
    }

    updateList(_liveAuctions);
    updateList(_listedProducts);
    notifyListeners();
  }

  /// Returns the current bid for UI: max of backend and any pending optimistic bid
  String getCurrentBidForAuction(int auctionId, String backendBid) {
    final double backend = double.tryParse(backendBid) ?? 0;
    final double? optimistic = _pendingOptimisticBids[auctionId];
    if (optimistic != null && optimistic > backend) {
      return optimistic.toString();
    }
    return backendBid;
  }

  void _updateAuctionStatus(String auctionId, Map<String, dynamic> statusData) {
    // Remove from old status list and add to new status list
    final auction = [..._liveAuctions, ..._listedProducts, ..._upcomingAuctions, ..._expiredAuctions].firstWhere(
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
      case 'expired':
        _expiredAuctions.add(newAuction);
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
    _soldAuctions.removeWhere((item) => item.id.toString() == auctionId);

    // notifyListeners();
  }

  bool get isLoadingLive => _isLoadingLive;
  bool get isLoadingMyLive => _isLoadingMyLive;
  bool get isLoadingListedProducts => _isLoadingListedProducts;
  bool get isLoadingUpcoming => _isLoadingUpcoming;
  bool get isLoadingExpired => _isLoadingExpired;
  bool get isLoadingSold => _isLoadingSold;

  String? get errorLive => _errorLive;
  String? get errorMyLive => _errorMyLive;
  String? get errorListedProducts => _errorListedProducts;
  String? get errorUpcoming => _errorUpcoming;
  String? get errorExpired => _errorExpired;
  String? get errorSold => _errorSold;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  List<AuctionItem> _filteredLiveAuctions = [];
  List<AuctionItem> _filteredListedProducts = [];
  List<AuctionItem> _filteredUpcomingAuctions = [];
  List<AuctionItem> _filteredExpiredAuctions = [];
  List<AuctionItem> _filteredSoldAuctions = [];

  void searchItems(String query) {
    _searchQuery = query.toLowerCase();

    _filteredLiveAuctions = _liveAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredListedProducts = _listedProducts.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredUpcomingAuctions = _upcomingAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredExpiredAuctions = _expiredAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();
    _filteredSoldAuctions = _soldAuctions.where((item) => item.title.toLowerCase().contains(_searchQuery)).toList();

    notifyListeners();
  }

  List<AuctionItem> get filteredLiveAuctions => _searchQuery.isEmpty ? _liveAuctions : _filteredLiveAuctions;
  List<AuctionItem> get filteredListedProducts => _searchQuery.isEmpty ? _listedProducts : _filteredListedProducts;
  List<AuctionItem> get filteredUpcomingAuctions => _searchQuery.isEmpty ? _upcomingAuctions : _filteredUpcomingAuctions;
  List<AuctionItem> get filteredExpiredAuctions => _searchQuery.isEmpty ? _expiredAuctions : _filteredExpiredAuctions;
  List<AuctionItem> get filteredSoldAuctions => _searchQuery.isEmpty ? _soldAuctions : _filteredSoldAuctions;

  Future<bool> placeBid(String auctionId, double amount) async {
    return await _socketService.placeBid(auctionId, amount);
  }

  void joinAuctionRoom(String auctionId) {
    _socketService.joinAuctionRoom(auctionId);
  }

  void leaveAuctionRoom(String auctionId) {
    _socketService.leaveAuctionRoom(auctionId);
  }

  Future<void> getLiveMyAuctions() async {
    if (_isLoadingMyLive) return;

    _isLoadingMyLive = true;
    _errorMyLive = null;
    notifyListeners();

    try {
      // print('Starting to fetch live auctions...');
      final status = 'ACTIVE';
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);
      // print('Received ${auctions.length} live auctions from service');
      _liveMyAuctions = auctions;
      _isLoadingMyLive = true;
      // print('Updated live auctions in provider');
    } catch (e, stackTrace) {
      // print('Error in getLiveAuctions:');
      print(e);
      print(stackTrace);
      _errorMyLive = e.toString();
    } finally {
      _isLoadingMyLive = true;
      // print('Notifying listeners about live auctions update');
      notifyListeners();
    }
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
        _errorListedProducts = 'Session expired. Please login again';
      } else {
        _errorListedProducts = 'Failed to load products. Please try again.';
      }
      // Keep existing data
    } finally {
      _isLoadingListedProducts = false;
      notifyListeners();
    }
  }

  Future<void> getUpcomingMyAuctions() async {
    if (_isLoadingUpcoming) return;

    _isLoadingUpcoming = true;
    _errorUpcoming = null;
    notifyListeners();

    try {
      // print('Fetching upcoming auctions...');
      final status = 'IN_SCHEDULED';
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);
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

  Future<void> getExpiredMyAuctions() async {
    debugPrint('\n🔵 [getExpiredMyAuctions] Starting...');

    if (_isLoadingExpired) {
      debugPrint('🟡 [getExpiredMyAuctions] Already loading, skipping...');
      return;
    }

    _isLoadingExpired = true;
    _errorExpired = null;
    notifyListeners();

    try {
      debugPrint('🔵 [getExpiredMyAuctions] Fetching expired auctions...');

      // Use the exact status that matches the API's expected value
      const status = 'EXPIRED';
      debugPrint('🔵 [getExpiredMyAuctions] Using status: $status');

      final stopwatch = Stopwatch()..start();
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);
      stopwatch.stop();

      debugPrint('🟢 [getExpiredMyAuctions] Fetched ${auctions.length} auctions in ${stopwatch.elapsedMilliseconds}ms');

      // Log the status of each auction for debugging
      if (auctions.isNotEmpty) {
        debugPrint('🔵 [getExpiredMyAuctions] First ${auctions.length} auctions:');
        for (var i = 0; i < auctions.length; i++) {
          final auction = auctions[i];
          debugPrint('  ${i + 1}. ID: ${auction.id}, Status: ${auction.status}, Title: ${auction.title}');
        }
      } else {
        debugPrint('🟡 [getExpiredMyAuctions] No auctions found with status: $status');
      }

      _expiredAuctions = List<AuctionItem>.from(auctions); // Create a new list to ensure reactivity
      debugPrint('🟢 [getExpiredMyAuctions] Updated _expiredAuctions with ${_expiredAuctions.length} items');

      // Verify the list after update
      if (_expiredAuctions.isEmpty) {
        debugPrint('🟠 [getExpiredMyAuctions] WARNING: _expiredAuctions is empty after update!');
      } else {
        debugPrint('🟢 [getExpiredMyAuctions] First item status: ${_expiredAuctions.first.status}');
      }
    } catch (e, stackTrace) {
      _errorExpired = e.toString();
      debugPrint('❌ [getExpiredMyAuctions] Error: $e');
      debugPrint('❌ [getExpiredMyAuctions] Stack trace: $stackTrace');
    } finally {
      _isLoadingExpired = false;
      notifyListeners();
      debugPrint('🔵 [getExpiredMyAuctions] Fetch completed. _expiredAuctions length: ${_expiredAuctions.length}');

      // Final verification
      if (_expiredAuctions.isNotEmpty) {
        debugPrint('🟢 [getExpiredMyAuctions] Final check - First item status: ${_expiredAuctions.first.status}');
      }
    }
  }

  Future<void> getExpiredAuctions() async {
    if (_isLoadingExpired) return;

    _isLoadingExpired = true;
    _errorExpired = null;
    notifyListeners();

    try {
      final auctions = await _auctionService.fetchExpiredAuctions();
      _expiredAuctions = auctions;
    } catch (e, stackTrace) {
      _errorExpired = e.toString();
      debugPrint('Error fetching expired auctions: $e');
      print(stackTrace);
    } finally {
      _isLoadingExpired = false;
      notifyListeners();
    }
  }

  Future<void> getCancelledAuctions() async {
    if (_isLoadingCancelled) return;

    _isLoadingCancelled = true;
    _errorCancelled = null;
    notifyListeners();

    try {
      debugPrint('🔄 [AuctionProvider] Fetching CANCELLED auctions...');
      final status = ['CANCELLED_BEFORE_EXP_DATE', 'CANCELLED_AFTER_EXP_DATE', 'CANCELLED_BY_ADMIN'];
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status as String);
      _cancelledAuctions = auctions;
      debugPrint('✅ [AuctionProvider] Fetched ${auctions.length} CANCELLED auctions');
      if (auctions.isNotEmpty) {
        debugPrint('   First auction status: ${auctions.first.status}');
      }
      if (_cancelledAuctions.isEmpty) {
        print('No valid cancelled auctions found');
      }
    } catch (e, stackTrace) {
      _errorCancelled = e.toString();
      debugPrint('Error fetching cancelled auctions: $e');
      print(stackTrace);
    } finally {
      _isLoadingCancelled = false;
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

      // List product with the service
      final response = await _auctionService.listProduct(
        auctionData: auctionData,
        images: images,
        locationId: auctionData['locationId'] ?? 0,
      );

      if (response['success']) {
        _listProductError = '';
        // --- Begin: Add new item to _listedProducts with correct itemLocation ---
        try {
          final data = response['data'] ?? {};
          // Use the shippingDetails you just submitted
          final shippingDetails = auctionData['shippingDetails'] ?? {};
          final itemLocation = AuctionItem.createLocationFromApp(shippingDetails);
          // Compose a new AuctionItem (fallback to fromJson, then override itemLocation)
          AuctionItem newItem = AuctionItem.fromJson({
            ...data,
            'shippingDetails': shippingDetails,
            'product': auctionData['product'],
            // If API data already includes location, this is a safe override
          });
          newItem = newItem.copyWith(itemLocation: itemLocation);
          _listedProducts.add(newItem);
          notifyListeners();
        } catch (e) {
          debugPrint('Error adding new listed product locally: $e');
        }
        // --- End: Add new item to _listedProducts with correct itemLocation ---
        return response;
      } else {
        _listProductError = response['message'] ?? 'Failed to list product';
        throw Exception(_listProductError);
      }
    } catch (e) {
      _listProductError = e.toString();
      throw Exception(_listProductError);
    } finally {
      _isListingProduct = false;
      notifyListeners();
    }
  }

  Future<void> getSoldAuctions() async {
    if (_isLoadingSold) return;

    _isLoadingSold = true;
    _errorSold = null;
    notifyListeners();

    try {
      debugPrint('🔄 [AuctionProvider] Fetching SOLD auctions...');
      final status = 'SOLD';
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);
      _soldAuctions = auctions;
      debugPrint('✅ [AuctionProvider] Fetched ${auctions.length} SOLD auctions');
      if (auctions.isNotEmpty) {
        debugPrint('   First auction status: ${auctions.first.status}');
      }
      _errorSold = null;
    } catch (e) {
      debugPrint('Error fetching sold auctions: $e');
      _errorSold = 'Failed to load sold auctions. Please try again.';
    } finally {
      _isLoadingSold = false;
      notifyListeners();
    }
  }

  Future<void> getPendingAuctions() async {
    if (_isLoadingPending) {
      debugPrint('⚠️ [AuctionProvider] Already loading pending auctions, skipping...');
      return;
    }

    _isLoadingPending = true;
    _errorPending = null;
    notifyListeners();

    debugPrint('🔄 [AuctionProvider] Fetching PENDING auctions...');

    try {
      final status = 'PENDING_OWNER_DEPOIST';
      debugPrint('📡 [AuctionProvider] Calling fetchUserAuctionsByStatus with status: $status');

      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);

      debugPrint('✅ [AuctionProvider] Received ${auctions.length} pending auctions');
      if (auctions.isNotEmpty) {
        debugPrint('   First auction details:');
        debugPrint('   - ID: ${auctions.first.id}');
        debugPrint('   - Status: ${auctions.first.status}');
        debugPrint('   - isMyAuction: ${auctions.first.isMyAuction}');
      } else {
        debugPrint('ℹ️ [AuctionProvider] No pending auctions received');
      }

      _pendingAuctions = auctions;
      debugPrint('📊 [AuctionProvider] Updated _pendingAuctions with ${_pendingAuctions.length} items');
    } catch (e, stackTrace) {
      _errorPending = e.toString();
      debugPrint('❌ [AuctionProvider] Error fetching pending auctions: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoadingPending = false;
      notifyListeners();

      // Debug: Check the final state after update
      debugPrint('🏁 [AuctionProvider] Final _pendingAuctions count: ${_pendingAuctions.length}');
      if (_pendingAuctions.isNotEmpty) {
        debugPrint('   First auction in final list:');
        debugPrint('   - ID: ${_pendingAuctions.first.id}');
        debugPrint('   - Status: ${_pendingAuctions.first.status}');
      }
    }
  }

  Future<void> getWaitingForPaymentAuctions() async {
    try {
      _isLoadingWaitingForPayment = true;
      _errorWaitingForPayment = null;
      notifyListeners();

      debugPrint('🔄 [AuctionProvider] Fetching WAITING_FOR_PAYMENT auctions...');
      final status = 'WAITING_FOR_PAYMENT';
      final auctions = await _auctionService.fetchUserAuctionsByStatus(status);
      _waitingForPaymentAuctions = auctions;
      debugPrint('✅ [AuctionProvider] Fetched ${auctions.length} WAITING_FOR_PAYMENT auctions');
      if (auctions.isNotEmpty) {
        debugPrint('   First auction status: ${auctions.first.status}');
      }
    } catch (e) {
      _errorWaitingForPayment = 'Failed to load waiting for payment auctions: $e';
      debugPrint('Error fetching waiting for payment auctions: $e');
    } finally {
      _isLoadingWaitingForPayment = false;
      notifyListeners();
    }
  }

  //My Products Status
  Future<void> getInProgressProducts() async {
    try {
      _isLoadingInProgress = true;
      _errorInProgress = null;
      notifyListeners();

      debugPrint('🔄 [AuctionProvider] Fetching IN_PROGRESS products...');
      final status = 'IN_PROGRESS';
      final products = await _auctionService.fetchUserProductsByStatus(status);
      _inProgressProducts = products;
      debugPrint('✅ [AuctionProvider] Fetched ${products.length} IN_PROGRESS products');
      if (products.isNotEmpty) {
        debugPrint('   First product status: ${products.first.status}');
      }
    } catch (e) {
      _errorInProgress = 'Failed to load in progress products: $e';
      debugPrint('Error fetching in progress products: $e');
    } finally {
      _isLoadingInProgress = false;
      notifyListeners();
    }
  }

  Future<void> getOutOfStockProducts() async {
    try {
      _isLoadingOutOfStock = true;
      _errorOutOfStock = null;
      notifyListeners();

      debugPrint('🔄 [AuctionProvider] Fetching OUT_OF_STOCK products...');
      final status = 'OUT_OF_STOCK';
      final products = await _auctionService.fetchUserProductsByStatus(status);
      _outOfStockProducts = products;
      debugPrint('✅ [AuctionProvider] Fetched ${products.length} OUT_OF_STOCK products');
      if (products.isNotEmpty) {
        debugPrint('   First product status: ${products.first.status}');
      }
    } catch (e) {
      _errorOutOfStock = 'Failed to load out of stock products: $e';
      debugPrint('Error fetching out of stock products: $e');
    } finally {
      _isLoadingOutOfStock = false;
      notifyListeners();
    }
  }

  Future<void> getSoldOutProducts() async {
    try {
      _isLoadingSoldOut = true;
      _errorSoldOut = null;
      notifyListeners();

      debugPrint('🔄 [AuctionProvider] Fetching SOLD_OUT products...');
      final status = 'SOLD_OUT';
      final products = await _auctionService.fetchUserProductsByStatus(status);
      _soldOutProducts = products;
      debugPrint('✅ [AuctionProvider] Fetched ${products.length} SOLD_OUT products');
      if (products.isNotEmpty) {
        debugPrint('   First product status: ${products.first.status}');
      }
    } catch (e) {
      _errorSoldOut = 'Failed to load sold out products: $e';
      debugPrint('Error fetching sold out products: $e');
    } finally {
      _isLoadingSoldOut = false;
      notifyListeners();
    }
  }

  Future<void> getJoinedAuctions(String status) async {
    try {
      // print('Starting to fetch live auctions...');
      final auctions = await _auctionService.fetchJoinedAuctions(status);
      // print('Received ${auctions.length} live auctions from service');
      _joinedAuctions = auctions;
      // print('Updated live auctions in provider');
    } catch (e, stackTrace) {
      // print('Error in getLiveAuctions:');
      print(e);
      print(stackTrace);
    } finally {
      // print('Notifying listeners about live auctions update');
    }
  }

  @override
  void dispose() {
    _socketService.dispose();
    super.dispose();
  }
}
