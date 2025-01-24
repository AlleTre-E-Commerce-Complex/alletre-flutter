import 'package:alletre_app/model/auction_details.dart';
import 'package:flutter/material.dart';

class AuctionDetailsProvider with ChangeNotifier {
  final AuctionDetails _auctionDetails = AuctionDetails(); // Current auction
  AuctionDetails get auctionDetails => _auctionDetails;

  void updateAuction({
    bool? isQuickAuction,
    int? duration,
    bool? isScheduleBidEnabled,
    DateTime? scheduledTime,
    double? startPrice,
    bool? isBuyNowEnabled,
    double? buyNowPrice,
    bool? isReturnPolicyEnabled,
    String? returnPolicy,
    bool? isWarrantyPolicyEnabled,
    String? warrantyPolicy,
  }) {
    if (isQuickAuction != null) _auctionDetails.isQuickAuction = isQuickAuction;
    if (duration != null) _auctionDetails.duration = duration;
    if (isScheduleBidEnabled != null) {
      _auctionDetails.isScheduleBidEnabled = isScheduleBidEnabled;
    }
    if (scheduledTime != null) _auctionDetails.scheduledTime = scheduledTime;
    if (startPrice != null) _auctionDetails.startPrice = startPrice;
    if (isBuyNowEnabled != null) {
      _auctionDetails.isBuyNowEnabled = isBuyNowEnabled;
    }
    if (buyNowPrice != null) _auctionDetails.buyNowPrice = buyNowPrice;
    if (isReturnPolicyEnabled != null) {
      _auctionDetails.isReturnPolicyEnabled = isReturnPolicyEnabled;
    }
    if (returnPolicy != null) _auctionDetails.returnPolicy = returnPolicy;
    if (isWarrantyPolicyEnabled != null) {
      _auctionDetails.isWarrantyPolicyEnabled = isWarrantyPolicyEnabled;
    }
    if (warrantyPolicy != null) _auctionDetails.warrantyPolicy = warrantyPolicy;

    notifyListeners();
  }
}
