import 'package:flutter/foundation.dart';

class DepositCalculator {
  static double calculateSecurityDeposit({
    required double startBidAmount,
    required double latestBidAmount,
    required Map<String, dynamic> category,
  }) {
    debugPrint('🔍 DepositCalculator Debug:');
    debugPrint('🔍 Input values:');
    debugPrint('  - Start bid amount: $startBidAmount');
    debugPrint('  - Latest bid amount: $latestBidAmount');
    debugPrint('  - Category data: $category');

    // Validate category data
    if (category.isEmpty) {
      debugPrint('❌ Empty category data');
      return 0;
    }

    // Get base fixed deposit amount
    final fixedDepositStr = category['bidderDepositFixedAmount']?.toString();
    debugPrint('🔍 Fixed deposit string: $fixedDepositStr');
    
    double amount = double.tryParse(fixedDepositStr ?? '0') ?? 0;
    debugPrint('🔍 Base fixed deposit amount: $amount');
    
    // Check if this is a luxury item
    final luxuryAmountStr = category['luxuaryAmount']?.toString();
    final luxuryAmount = double.tryParse(luxuryAmountStr ?? '0') ?? 0;
    final categoryName = category['nameEn']?.toString() ?? '';
    
    debugPrint('🔍 Luxury check:');
    debugPrint('  - Luxury amount: $luxuryAmount');
    debugPrint('  - Category name: $categoryName');
    
    if (luxuryAmount > 0 && startBidAmount > luxuryAmount) {
      debugPrint('🔍 Processing luxury item deposit');
      
      // Calculate percentage-based deposit for luxury items
      final percentageStr = category['percentageOfLuxuarySD_forBidder']?.toString();
      final percentage = double.tryParse(percentageStr ?? '0') ?? 0;
      debugPrint('  - Percentage: $percentage%');
      
      double total = (startBidAmount * percentage) / 100;
      debugPrint('  - Initial total: $total');
      
      // Special handling for Cars and Properties
      if (categoryName == 'Cars' || categoryName == 'Properties') {
        total = (latestBidAmount * percentage) / 100;
        debugPrint('  - Special category total: $total');
      }
      
      // Ensure minimum luxury deposit amount
      final minimumLuxuryDepositStr = category['minimumLuxuarySD_forBidder']?.toString();
      final minimumLuxuryDeposit = double.tryParse(minimumLuxuryDepositStr ?? '0') ?? 0;
      debugPrint('  - Minimum luxury deposit: $minimumLuxuryDeposit');
      
      if (minimumLuxuryDeposit > 0 && total < minimumLuxuryDeposit) {
        amount = minimumLuxuryDeposit;
        debugPrint('  - Using minimum luxury deposit: $amount');
      } else {
        amount = total;
        debugPrint('  - Using calculated total: $amount');
      }
    } else {
      debugPrint('🔍 Using base fixed deposit amount: $amount');
    }
    
    debugPrint('🔍 Final deposit amount: $amount');
    return amount;
  }
} 