// ignore_for_file: avoid_print, use_build_context_synchronously, unnecessary_null_comparison, duplicate_ignore

import 'dart:convert';
import 'dart:io';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/ui_helpers.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/utils/deposit_calculator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api_service.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/payment widgets/payment_success_dialog.dart';
import '../faqs screen/faqs_screen.dart';
import '../../../services/category_service.dart';
import '../../../services/payment_service.dart';
import '../../../controller/providers/user_provider.dart';
import '../../../controller/helpers/user_services.dart';

// Payment method enum
enum PaymentMethod { card, wallet }

// Card form widget
class CardFormWidget extends StatefulWidget {
  final CardFormEditController controller;
  final GlobalKey<FormState> formKey;

  const CardFormWidget({
    super.key,
    required this.controller,
    required this.formKey,
  });

  @override
  State<CardFormWidget> createState() => _CardFormWidgetState();
}

class _CardFormWidgetState extends State<CardFormWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CardFormField(
              controller: widget.controller,
              style: CardFormStyle(
                borderColor: Colors.grey.shade400,
                textColor: onSecondaryColor,
                fontSize: 13,
                placeholderColor: Colors.grey.shade600,
                borderWidth: 1,
                borderRadius: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> auctionData;

  const PaymentDetailsScreen({
    super.key,
    required this.auctionData,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final formKey = GlobalKey<FormState>();
  final selectedPaymentMethod =
      ValueNotifier<PaymentMethod>(PaymentMethod.card);
  late final CardFormEditController cardController;
  final UserService _userService = UserService();
  int? depositAmount;
  bool isLoading = false;
  bool showWalletPayment = false;
  bool showStripePayment = true;
  double? walletBalance;

  Future<String?> _getValidToken() async {
    try {
      // Get the current access token
      final token =
          await const FlutterSecureStorage().read(key: 'access_token');
      if (token == null) {
        debugPrint('No access token found, attempting refresh');
        final refreshResult = await _userService.refreshTokens();
        if (refreshResult['success']) {
          return refreshResult['data']['accessToken'];
        }
        return null;
      }
      return token;
    } catch (e) {
      debugPrint('Error getting/refreshing token: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    cardController = CardFormEditController();
    _calculateDepositAmount();
    _checkWalletBalance();
  }

  void _calculateDepositAmount() {
    try {
      final auctionData = widget.auctionData;
      final startBidAmount =
          double.tryParse(auctionData['startBidAmount']?.toString() ?? '0') ??
              0;
      final latestBidAmount =
          double.tryParse(auctionData['currentBid']?.toString() ?? '0') ??
              startBidAmount;
      final category = auctionData['category'];

      if (category == null) {
        debugPrint('No category data available');
        depositAmount = null;
        return;
      }

      final deposit = DepositCalculator.calculateSecurityDeposit(
        startBidAmount: startBidAmount,
        latestBidAmount: latestBidAmount,
        category: category,
      );

      setState(() {
        depositAmount = deposit.toInt();
        debugPrint('✅ Calculated deposit amount: $depositAmount');
      });
    } catch (e) {
      debugPrint('❌ Error calculating deposit amount: $e');
      depositAmount = null;
    }
  }

  Future<void> _checkWalletBalance() async {
    try {
      final response = await ApiService.get('/wallet/get_balance');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null) {
          // The API returns the balance directly as a string
          final balance = double.tryParse(responseData.toString());
          if (balance != null) {
            setState(() {
              walletBalance = balance;
              debugPrint('Wallet balance set to: $walletBalance');
              // Only show wallet payment if balance is sufficient
              if (walletBalance! >= (depositAmount ?? 0)) {
                showWalletPayment = true;
                showStripePayment = false;
              }
            });
          } else {
            throw Exception('Failed to parse balance value: $responseData');
          }
        } else {
          throw Exception('Response data is null');
        }
      } else {
        throw Exception('Failed to fetch balance: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
      // Only show error message if user is actively trying to make a payment
      if (mounted && selectedPaymentMethod.value == PaymentMethod.wallet) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to fetch wallet balance: ${e.toString()}'),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleWalletPayment() async {
    try {
      setState(() => isLoading = true);

      // Log the starting point of the payment process
      debugPrint('🔍 Starting wallet payment process...');

      // Get the auction ID from widget data (handle Buy Now and other flows)
      int? auctionId;
      if (widget.auctionData['details'] != null && widget.auctionData['details']['id'] != null) {
        auctionId = widget.auctionData['details']['id'] as int?;
        debugPrint('🔍 [Buy Now] Using auction ID from details: $auctionId');
      } else if (widget.auctionData['data'] != null && widget.auctionData['data']['id'] != null) {
        auctionId = widget.auctionData['data']['id'] as int?;
        debugPrint('🔍 [Other Flow] Using auction ID from data: $auctionId');
      }
      if (auctionId == null) {
        throw Exception('Auction ID not found in details or data');
      }
      debugPrint('🔍 Using auction ID: $auctionId');

      // Log the payment details being sent
      final paymentData = {
        'auctionId': auctionId,
        'amount': depositAmount,
        'type': 'SELLER_DEPOSIT'
      };
      debugPrint('🔍 Sending payment data: ${jsonEncode(paymentData)}');

      // Parse the DateTime before making the API call to help with timing
      final requestTime = DateTime.now();
      debugPrint('🔍 Parsed DateTime: $requestTime');

      // Try all possible endpoint variants to determine which one works
      try {
        // Attempt with endpoint variant 1
        debugPrint('🔍 Attempting API call to: /auctions/user/walletPay');
        final response = await ApiService.post(
          '/auctions/user/walletPay',
          data: {
            'auctionId': auctionId,
            'amount': depositAmount,
            'bidAmount': depositAmount
          },
        );

        _handleSuccessResponse(response);
      } on DioException catch (e) {
        debugPrint(
            '🔍 First endpoint failed with status: ${e.response?.statusCode}');
        debugPrint('🔍 Error response: ${e.response?.data}');

        if (e.response?.statusCode == 404) {
          // Try second variant with hyphen if first fails with 404
          debugPrint('🔍 Attempting API call to: /auctions/user/walletPay');
          final response = await ApiService.post(
            '/auctions/user/walletPay',
            data: {'auctionId': auctionId, 'amount': depositAmount},
          );

          _handleSuccessResponse(response);
        } else {
          // If it's not a 404, rethrow the original exception
          rethrow;
        }
      }
    } on DioException catch (e) {
      // Handle Dio specific exceptions with detailed logging
      final statusCode = e.response?.statusCode;
      final errorData = e.response?.data;
      final requestOptions = e.requestOptions;

      debugPrint(
          '🔍 Wallet payment error: DioException [${e.type}]: ${e.message}');
      debugPrint('🔍 Status code: $statusCode');
      debugPrint('🔍 Method: ${requestOptions.method}');
      debugPrint('🔍 URL: ${requestOptions.uri}');
      debugPrint('🔍 Headers: ${requestOptions.headers}');
      debugPrint('🔍 Request data: ${requestOptions.data}');
      debugPrint('🔍 Response data: $errorData');

      String errorMessage = 'Payment failed';

      if (statusCode == 401) {
        errorMessage = 'Authentication error. Please login again.';
        // Handle token refresh or logout logic
        _handleTokenExpiration();
      } else if (statusCode == 404) {
        errorMessage = 'Payment endpoint not found. Please contact support.';
      } else if (statusCode == 400) {
        // Try to extract specific error message from response
        if (errorData is Map && errorData.containsKey('message')) {
          errorMessage = errorData['message'].toString();
        } else {
          errorMessage = 'Invalid payment request.';
        }
      } else if (statusCode == 422) {
        errorMessage = 'Invalid payment data.';
      } else if (statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      }

      _showErrorToast(errorMessage);
    } catch (e) {
      // Handle all other exceptions
      debugPrint('🔍 General wallet payment error: $e');
      _showErrorToast('Payment failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

// Helper method to handle successful responses
  void _handleSuccessResponse(dynamic response) {
    debugPrint('🔍 API Response status: ${response.statusCode}');
    debugPrint('🔍 API Response data: ${response.data}');

    if (response.data['success']) {
      // Navigate to success screen or refresh current screen
      if (mounted) {
        PaymentSuccessDialog.show(context);
      }
    } else {
      throw Exception(response.data['message'] ?? 'Payment failed');
    }
  }

// Helper method to show error toast
  void _showErrorToast(String message) {
    if (mounted) {
      showError(context, message);
    }
  }

// Handle token expiration
  void _handleTokenExpiration() async {
    // Attempt to refresh token
    try {
      final refreshResult = await _userService.refreshTokens();
      if (!refreshResult['success']) {
        // Handle failed refresh by logging out
        if (mounted) {
          showError(context, 'Session expired. Please login again');
          // Navigate to login screen
          // Navigator.pushReplacementNamed(context, YourRoutes.login);
        }
      }
    } catch (e) {
      debugPrint('🔍 Token refresh error: $e');
    }
  }

  void _handlePaymentMethodChange(PaymentMethod method) {
    setState(() {
      selectedPaymentMethod.value = method;
      if (method == PaymentMethod.wallet) {
        showWalletPayment = true;
        showStripePayment = false;
      } else {
        showWalletPayment = false;
        showStripePayment = true;
      }
    });
  }

  @override
  void dispose() {
    selectedPaymentMethod.dispose();
    cardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Publish Auction', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Divider(thickness: 1, color: primaryColor),
            const Center(
              child: Text(
                "Payment Details",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
            ),
            const Divider(thickness: 1, color: primaryColor),
            const SizedBox(height: 8),
            const Text(
              'In order to complete publishing your auction successfully, please pay the auction fee and start receiving bids immediately.',
              style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),

            // Sample Debit Card UI
            _buildDebitCard(context),
            const SizedBox(height: 22),

            const Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Method',
                    style: TextStyle(
                        color: onSecondaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600))),
            const SizedBox(height: 10),

            // Payment Method Selection
            ValueListenableBuilder<PaymentMethod>(
              valueListenable: selectedPaymentMethod,
              builder: (context, method, child) {
                return Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      title: const Text('Credit/Debit Card'),
                      value: PaymentMethod.card,
                      groupValue: method,
                      onChanged: (value) =>
                          selectedPaymentMethod.value = value!,
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Wallet'),
                      value: PaymentMethod.wallet,
                      groupValue: method,
                      onChanged: (value) =>
                          selectedPaymentMethod.value = value!,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 10),

            // Card Details Form
            ValueListenableBuilder<PaymentMethod>(
              valueListenable: selectedPaymentMethod,
              builder: (context, method, child) {
                return method == PaymentMethod.card
                    ? KeyedSubtree(
                        key: const ValueKey('card_form'),
                        child: CardFormWidget(
                          key: const ValueKey('card_form_widget'),
                          controller: cardController,
                          formKey: formKey,
                        ),
                      )
                    : Container(
                        key: const ValueKey('wallet_form'),
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 22, bottom: 22),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Wallet Balance is AED ${NumberFormat('#,##0.00').format(walletBalance ?? 0)}/-',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: onSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton(
                                  onPressed: () {
                                    _handlePaymentMethodChange(
                                        PaymentMethod.wallet);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: primaryColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                ElevatedButton(
                                  // --- Handle Buy Now flow for wallet payment ---
                                  onPressed: () async {
                                    final isBuyNow = widget.auctionData['auction'] != null && widget.auctionData['details'] != null;
                                    double totalAmount = 0;
                                    if (isBuyNow) {
                                      final acceptedAmountStr = widget.auctionData['details']['acceptedAmount']?.toString() ?? '0';
                                      final acceptedAmount = double.tryParse(acceptedAmountStr) ?? 0;
                                      final auctionFee = acceptedAmount / 200;
                                      final cardFee = ((acceptedAmount + auctionFee) * 0.03) + 4;
                                      totalAmount = double.parse((acceptedAmount + auctionFee + cardFee).toStringAsFixed(2));
                                    }
                                    final hasBalance = isBuyNow
                                        ? (walletBalance ?? 0) >= totalAmount
                                        : (walletBalance ?? 0) >= (depositAmount ?? 0);
                                    if (isLoading || !hasBalance) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Center(child: Text('Insufficient wallet balance')),
                                          duration: Duration(seconds: 1),
                                          backgroundColor: errorColor,
                                        ),
                                      );
                                      return;
                                    }
                                    if (isBuyNow) {
                                      // --- Buy Now wallet payment ---
                                      setState(() => isLoading = true);
                                      try {
                                        final auctionId = widget.auctionData['details']['id'];
                                        // Retrieve token using the local helper
                                        final token = await _getValidToken();
                                        if (token == null) {
                                          debugPrint('❌ No access token available for Buy Now wallet payment');
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Authentication error: No access token'),
                                              backgroundColor: errorColor,
                                            ),
                                          );
                                          return;
                                        }
                                        final response = await PaymentService.buyNowAuctionThroughWallet(
                                          auctionId: auctionId,
                                          amount: totalAmount,
                                          currency: 'AED',
                                          token: token,
                                        );
                                        debugPrint('✅ Buy Now wallet payment response: $response');
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Center(child: Text('Great pick. Purchase successful!!')),
                                            backgroundColor: activeColor,
                                          ),
                                        );
                                        // Remove the auction from live auctions before navigating home
                                        if (context.mounted) {
                                          final auctionProvider = Provider.of<AuctionProvider>(context, listen: false);
                                          final auctionIdInt = auctionId is int ? auctionId : int.tryParse(auctionId.toString());
                                          if (auctionIdInt != null) {
                                            auctionProvider.removeAuctionFromLive(auctionIdInt);
                                          }
                                        }
                                        // Navigate to home page after short delay
                                        await Future.delayed(const Duration(milliseconds: 300));
                                        if (context.mounted) {
                                          Navigator.of(context).popUntil((route) => route.isFirst);
                                        }
                                      } catch (e) {
                                        debugPrint('❌ Buy Now wallet payment failed: $e');
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Buy Now wallet payment failed: $e'),
                                            backgroundColor: errorColor,
                                          ),
                                        );
                                      } finally {
                                        if (mounted) setState(() => isLoading = false);
                                      }
                                    } else {
                                      _handleWalletPayment();
                                    }
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ((walletBalance ?? 0) <
                                            (depositAmount ?? 0))
                                        ? greyColor
                                        : primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    secondaryColor),
                                          ),
                                        )
                                      : Text(
                                          () {
                                            final isBuyNow = widget.auctionData['auction'] != null && widget.auctionData['details'] != null;
                                            if (isBuyNow) {
                                              final acceptedAmountStr = widget.auctionData['details']['acceptedAmount']?.toString() ?? '0';
                                              final acceptedAmount = double.tryParse(acceptedAmountStr) ?? 0;
                                              final auctionFee = acceptedAmount / 200;
                                              final cardFee = ((acceptedAmount + auctionFee) * 0.03) + 4;
                                              final totalAmount = double.parse((acceptedAmount + auctionFee + cardFee).toStringAsFixed(2));
                                              return 'Pay AED ${NumberFormat("#,##0.00").format(totalAmount)}';
                                            }
                                            // For newly created auctions, calculate deposit based on category
                                            if (widget.auctionData['isDeposit'] == null && widget.auctionData['data'] != null) {
                                              final categoryId = widget.auctionData['data']['product']?['categoryId'];
                                              if (categoryId != null) {
                                                final depositAmount = CategoryService.getSellerDepositAmount(int.parse(categoryId.toString()));
                                                debugPrint('🔍 Calculated Deposit Amount for Pay Button: $depositAmount');
                                                return 'Pay AED ${NumberFormat("#,##0").format(double.tryParse(depositAmount)?.round() ?? 0)}';
                                              }
                                            }
                                            // For existing deposits, use the provided amount
                                            final depositAmount = widget.auctionData['isDeposit'] == true
                                                ? widget.auctionData['depositAmount']?.toString()
                                                : widget.auctionData['data']?['depositAmount']?.toString() ?? widget.auctionData['depositAmount']?.toString();
                                            debugPrint('🔍 Deposit Amount for Pay Button: $depositAmount');
                                            final formattedAmount = NumberFormat("#,##0").format(double.tryParse(depositAmount ?? '0')?.round() ?? 0);
                                            return 'Pay AED $formattedAmount';
                                          }(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: ((walletBalance ?? 0) <
                                                    (depositAmount ?? 0))
                                                ? Colors.grey[300]
                                                : secondaryColor,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
              },
            ),

            // Pay & Submit Button (only for card payment)
            // Replace the existing Pay & Submit button code with this fixed version
            ValueListenableBuilder<PaymentMethod>(
              valueListenable: selectedPaymentMethod,
              builder: (context, paymentMethod, child) {
                if (paymentMethod == PaymentMethod.wallet) {
                  return const SizedBox.shrink();
                }

                return ValueListenableBuilder<bool>(
                  valueListenable: PaymentService.isLoadingPayment,
                  builder: (context, isLoading, child) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                try {
                                  // Check if user is logged in
                                  final userProvider =
                                      Provider.of<UserProvider>(context,
                                          listen: false);
                                  if (!userProvider.isLoggedIn) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Please login to continue with the payment'),
                                        backgroundColor: errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  // Get token and validate
                                  final token = await _getValidToken();
                                  if (token == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Unable to get a valid token'),
                                        backgroundColor: errorColor,
                                      ),
                                    );
                                    return;
                                  }

                                  // Safely get categoryId with null checking
                                  final categoryId = (widget
                                                  .auctionData['auction'] !=
                                              null &&
                                          widget.auctionData['details'] != null)
                                      ? widget.auctionData['auction'].categoryId
                                      : widget.auctionData['categoryId'] ??
                                          widget.auctionData['data']?['product']
                                              ?['categoryId'];

                                  if (categoryId == null) {
                                    throw Exception('Category ID not found');
                                  }

                                  // Debug log
                                  print(
                                      'Category ID: $categoryId (${categoryId.runtimeType})');

                                  // Safely parse to int with error handling
                                  int parsedCategoryId;
                                  try {
                                    parsedCategoryId =
                                        int.parse(categoryId.toString());
                                    print(
                                        'Parsed category ID: $parsedCategoryId');
                                  } catch (e) {
                                    print('Error parsing categoryId: $e');
                                    throw Exception(
                                        'Invalid category ID format');
                                  }

                                  // Get deposit amount with null checking
                                  final depositAmount =
                                      CategoryService.getSellerDepositAmount(
                                          parsedCategoryId);
                                  print(
                                      'Deposit amount from service: $depositAmount (${depositAmount.runtimeType})');

                                  if (depositAmount.isEmpty) {
                                    throw Exception(
                                        'Invalid deposit amount for category');
                                  }

                                  // Safely get auctionId with null checking
                                  final auctionId =
                                      (widget.auctionData['auction'] != null &&
                                              widget.auctionData['details'] !=
                                                  null)
                                          ? widget.auctionData['auction'].id
                                          : widget.auctionData['id'] ??
                                              widget.auctionData['data']?['id'];
                                  if (auctionId == null) {
                                    throw Exception('Invalid auction ID');
                                  }

                                  // Safely parse amount with error handling
                                  double amount;
                                  try {
                                    amount = double.parse(depositAmount);
                                  } catch (e) {
                                    print('Error parsing deposit amount: $e');
                                    throw Exception(
                                        'Invalid deposit amount format');
                                  }

                                  // --- Handle Buy Now flow: use TOTAL amount ---
                                  final isBuyNow = widget.auctionData['auction'] != null && widget.auctionData['details'] != null;
                                  if (isBuyNow) {
                                    final acceptedAmountStr = widget.auctionData['details']['acceptedAmount']?.toString() ?? '0';
                                    final acceptedAmount = double.tryParse(acceptedAmountStr) ?? 0;
                                    final auctionFee = acceptedAmount / 200;
                                    final cardFee = ((acceptedAmount + auctionFee) * 0.03) + 4;
                                    final total = acceptedAmount + auctionFee + cardFee;
                                    amount = double.parse(total.toStringAsFixed(2)); // Ensure amount matches UI
                                    print('💳 [BUY NOW] Using TOTAL for payment: $amount (accepted: $acceptedAmount, fee: $auctionFee, cardFee: $cardFee)');
                                  }

                                  if (selectedPaymentMethod.value ==
                                      PaymentMethod.wallet) {
                                    if (widget.auctionData['isMyAuction'] ==
                                        true) {
                                      // Seller payment
                                      await PaymentService.walletPayForAuction(
                                        auctionId: auctionId,
                                        amount: amount,
                                        token: token,
                                      );
                                    } else {
                                      // Bidder payment - safely get bid amount
                                      final bidAmountStr = widget
                                              .auctionData['amount']
                                              ?.toString() ??
                                          '0';
                                      double bidAmount;
                                      try {
                                        bidAmount = double.parse(bidAmountStr);
                                      } catch (e) {
                                        print('Error parsing bid amount: $e');
                                        bidAmount =
                                            0; // Default to 0 if parsing fails
                                      }

                                      await PaymentService
                                          .walletPayDepositByBidder(
                                        auctionId: auctionId,
                                        amount: amount,
                                        bidAmount: bidAmount,
                                        token: token,
                                      );
                                    }

                                    if (!context.mounted) return;
                                    PaymentSuccessDialog.show(context);
                                    return;
                                  } else {
                                    // Get card details
                                    final cardDetails = cardController.details;
                                    if (!cardDetails.complete) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Please fill in all card details correctly'),
                                          backgroundColor: errorColor,
                                        ),
                                      );
                                      return;
                                    }

                                    try {
                                      print('==============================');
                                      print('🔍 [CARD PAYMENT ATTEMPT]');
                                      print('  - auctionId: $auctionId');
                                      print('  - amount: $amount');
                                      print(
                                          '  - token: ${token.substring(0, 20)}...');
                                      print(
                                          '  - cardDetails.complete: ${cardDetails.complete}');
                                      final isMyAuction = widget
                                                  .auctionData['data']
                                              ?['isMyAuction'] ??
                                          widget.auctionData['isMyAuction'] ??
                                          false;
                                      print(
                                          '  - isMyAuction (data?): ${widget.auctionData['data']?['isMyAuction']}');
                                      print(
                                          '  - isMyAuction (top?): ${widget.auctionData['isMyAuction']}');
                                      print(
                                          '  - isMyAuction (final): $isMyAuction');
                                      if (isMyAuction == true) {
                                        print('🔍 Seller payment branch');
                                        await PaymentService.payForAuction(
                                          auctionId: auctionId,
                                          amount: amount,
                                          paymentType: 'card',
                                          currency: 'AED',
                                          token: token,
                                          cardDetails: cardDetails,
                                        );
                                      } else {
                                        // Detect Buy Now flow
                                        final isBuyNow =
                                            widget.auctionData['auction'] !=
                                                    null &&
                                                widget.auctionData['details'] !=
                                                    null;
                                        if (isBuyNow) {
                                          print('🔍 Buy Now payment branch');
                                          print('  - auctionId: $auctionId');
                                          print('  - amount: $amount');
                                          print('  - currency: AED');
                                          print(
                                              '  - token: ${token.substring(0, 8)}...');
                                          // ignore: unnecessary_null_comparison
                                          print(
                                              '  - cardDetails: ${cardDetails != null ? cardDetails.toString() : 'null'}');
                                          print(
                                              '  - auctionData before payment: ${widget.auctionData}');

                                          Map<String, dynamic>? buyNowResponse;
                                          try {
                                            buyNowResponse =
                                                await PaymentService
                                                    .buyNowAuction(
                                              auctionId: auctionId,
                                              amount: amount,
                                              currency: 'AED',
                                              token: token,
                                              cardDetails: cardDetails,
                                            );
                                            print('⬅️ [BUY NOW] Payment API response: $buyNowResponse');
                                            print('🔍 Buy Now backend response:');
                                            print('  - Response: $buyNowResponse');
                                            if (buyNowResponse.containsKey('status')) {
                                              print('  - Auction status in response: ${buyNowResponse['status']}');
                                            } else if (buyNowResponse.containsKey('auction')) {
                                              print('  - Auction status in response: ${buyNowResponse['auction']?['status']}');
                                            }

                                            // ====== STRIPE PAYMENT CONFIRMATION ======
                                            final clientSecret = buyNowResponse['clientSecret'] ?? buyNowResponse['data']?['clientSecret'];
                                            if (clientSecret != null) {
                                              try {
                                                print('🔔 Confirming payment with Stripe using clientSecret: $clientSecret');
                                                final paymentResult = await Stripe.instance.confirmPayment(
                                                  paymentIntentClientSecret: clientSecret,
                                                  data: const PaymentMethodParams.card(
                                                    paymentMethodData: PaymentMethodData(),
                                                  ),
                                                );
                                                print('✅ Stripe payment confirmation result: $paymentResult');
                                              } catch (e) {
                                                print('❌ Stripe payment confirmation failed: $e');
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Card payment confirmation failed: $e'),
                                                    backgroundColor: errorColor,
                                                  ),
                                                );
                                                return;
                                              }
                                            } else {
                                              print('❌ No clientSecret found in buyNowResponse, skipping Stripe confirmation');
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Payment failed: No client secret from backend'),
                                                  backgroundColor: errorColor,
                                                ),
                                              );
                                              return;
                                            }
                                          } catch (e, stack) {
                                            print('❌ [BUY NOW PAYMENT ERROR]');
                                            print(
                                                '  - Error Type: [31m${e.runtimeType}[0m');
                                            print('  - Error Message: $e');
                                            print('  - Stack Trace: $stack');
                                            rethrow;
                                          }
                                          print(
                                              '  - auctionData after payment: ${widget.auctionData}');
                                        }
                                      }
                                    } catch (e, stack) {
                                      print('❌ [CARD PAYMENT ERROR]');
                                      print(
                                          '  - Error Type: [31m${e.runtimeType}[0m');
                                      print('  - Error Message: $e');
                                      print('  - Stack Trace: $stack');
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Payment failed [${e.runtimeType}]: ${e.toString()}\nSee logs for details.',
                                          ),
                                          backgroundColor: errorColor,
                                        ),
                                      );
                                      return;
                                    }
                                  }

                                  // Log successful payment details
                                  print('🎉🎉 Payment Successful!');
                                  print(
                                      '🎉🎉 Amount Paid: AED ${NumberFormat("#,##0.00").format(amount)}');

                                  if (!context.mounted) return;
                                  PaymentSuccessDialog.show(context);
                                } catch (e) {
                                  print(
                                      'Error in payment process: ${e.toString()}');
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: errorColor,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          isLoading ? "Processing..." : "Pay & Submit",
                          style: const TextStyle(
                              color: secondaryColor, fontSize: 14),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Error display
            ValueListenableBuilder<String?>(
              valueListenable: PaymentService.paymentError,
              builder: (context, error, child) {
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: errorColor, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a sample debit card UI
  Widget _buildDebitCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ad Preview',
                style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: placeholderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image container with "Pending" label
                Container(
                  width: 112,
                  height: 106,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        Builder(
                          builder: (context) {
                            String? imagePath;

                            // Buy Now flow: get image from auction.imageLinks
                            if (widget.auctionData['auction'] != null &&
                                widget.auctionData['details'] != null) {
                              final imageLinks =
                                  widget.auctionData['auction'].imageLinks;
                              if (imageLinks != null && imageLinks.isNotEmpty) {
                                imagePath = imageLinks[0];
                              }
                            } else if (widget.auctionData['isDeposit'] ==
                                true) {
                              imagePath = widget.auctionData['images']?[0];
                            } else {
                              imagePath = widget.auctionData['data']?['product']
                                      ?['images']?[0] ??
                                  widget.auctionData['images']?[0];
                            }

                            debugPrint('🔍 Image Path: $imagePath');

                            if (imagePath != null) {
                              // For Buy Now flow, always use Image.network for imageLinks
                              if (widget.auctionData['auction'] != null &&
                                  widget.auctionData['details'] != null) {
                                return Image.network(
                                  imagePath,
                                  width: 112,
                                  height: 106,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                        '❌ Error loading network image: $error');
                                    return SvgPicture.asset(
                                      'assets/images/properties_category.svg',
                                      width: 112,
                                      height: 106,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              } else if (widget.auctionData['isDeposit'] ==
                                  true) {
                                return Image.network(
                                  imagePath,
                                  width: 112,
                                  height: 106,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                        '❌ Error loading network image: $error');
                                    return SvgPicture.asset(
                                      'assets/images/properties_category.svg',
                                      width: 112,
                                      height: 106,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              } else {
                                return Image.file(
                                  File(imagePath),
                                  width: 112,
                                  height: 106,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint(
                                        '❌ Error loading file image: $error');
                                    return SvgPicture.asset(
                                      'assets/images/properties_category.svg',
                                      width: 112,
                                      height: 106,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                );
                              }
                            } else {
                              return SvgPicture.asset(
                                'assets/images/properties_category.svg',
                                width: 112,
                                height: 106,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        ),
                        // Pending label positioned on top of the image
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: getStatusColor(widget
                                          .auctionData['isDeposit'] ==
                                      true
                                  ? widget.auctionData['status']
                                  : (widget.auctionData['auction'] != null &&
                                          widget.auctionData['details'] != null)
                                      ? (widget.auctionData['auction'].status ??
                                          'Unknown')
                                      : widget.auctionData['data']?['product']
                                              ?['status'] ??
                                          'Unknown'),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              getDisplayStatus(widget
                                          .auctionData['isDeposit'] ==
                                      true
                                  ? widget.auctionData['status']
                                  : (widget.auctionData['auction'] != null &&
                                          widget.auctionData['details'] != null)
                                      ? (widget.auctionData['auction'].status ??
                                          'Unknown')
                                      : widget.auctionData['data']?['product']
                                              ?['status'] ??
                                          'Unknown'),
                              style: const TextStyle(
                                fontSize: 6.4,
                                color: secondaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Item details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          widget.auctionData['isDeposit'] == true
                              ? widget.auctionData['title'] ?? 'No Title'
                              : (widget.auctionData['auction'] != null &&
                                      widget.auctionData['details'] != null)
                                  ? (widget.auctionData['auction'].title ??
                                      'No Title')
                                  : widget.auctionData['data']?['product']
                                          ?['title'] ??
                                      'Title not found',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: onSecondaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.auctionData['isDeposit'] == true
                              ? widget.auctionData['description'] ??
                                  'No Description'
                              : (widget.auctionData['auction'] != null &&
                                      widget.auctionData['details'] != null)
                                  ? (widget
                                          .auctionData['auction'].description ??
                                      'No Description')
                                  : widget.auctionData['data']?['product']
                                          ?['description'] ??
                                      widget.auctionData['description'] ??
                                      'No Description',
                          style: const TextStyle(
                            color: onSecondaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        // Row(
                        //   children: [
                        //     _buildInfoCard(
                        //       context,
                        //       'Category',
                        //       widget.auctionData['isDeposit'] == true
                        //           ? widget.auctionData['categoryName'] ?? 'N/A'
                        //           : (widget.auctionData['auction'] != null && widget.auctionData['details'] != null)
                        //               ? (widget.auctionData['auction'].categoryName ?? 'N/A')
                        //               : widget.auctionData['data']?['product']?['categoryName'] ?? 'N/A',
                        //     ),
                        //     const SizedBox(width: 10),
                        //     _buildInfoCard(
                        //       context,
                        //       (widget.auctionData['auction'] != null && widget.auctionData['details'] != null)
                        //           ? 'Purchase Price'
                        //           : 'Security Deposit',
                        //       (widget.auctionData['auction'] != null && widget.auctionData['details'] != null)
                        //           ? (widget.auctionData['auction'].buyNowPrice?.toString() ?? 'N/A')
                        //           : widget.auctionData['depositAmount']?.toString() ?? widget.auctionData['data']?['depositAmount']?.toString() ?? 'N/A',
                        //     ),
                        //   ],
                        // ),
                        const Text(
                          'Ending Time:',
                          style: TextStyle(
                            color: onSecondaryColor,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          () {
                            // Access expiry date from the nested data structure
                            // Print the full structure for debugging
                            // debugPrint('🔍 [DEBUG] auctionData: \\n${const JsonEncoder.withIndent('  ').convert(widget.auctionData)}');
                            final endTime = widget.auctionData['isDeposit'] ==
                                    true
                                ? (widget.auctionData['endTime'] ??
                                    widget.auctionData['expiryDate'])
                                : (widget.auctionData['auction'] != null &&
                                        widget.auctionData['details'] != null)
                                    ? (widget.auctionData['auction']
                                            .expiryDate ??
                                        widget.auctionData['auction'].endDate)
                                    : (widget.auctionData['data']?['endTime'] ??
                                        widget.auctionData['endTime']);

                            debugPrint('🔍 Raw end date: $endTime');

                            if (endTime != null) {
                              try {
                                // Parse the date string if it's a string
                                final dateTime = endTime is String
                                    ? DateTime.parse(endTime)
                                    : endTime;

                                // Format the DateTime object
                                final formattedDate =
                                    DateFormat('dd-MM-yyyy').format(dateTime);
                                final formattedTime =
                                    DateFormat('hh:mm a').format(dateTime);
                                debugPrint('🔍 Formatted date: $formattedDate');
                                debugPrint('🔍 Formatted time: $formattedTime');
                                return '$formattedDate  |  $formattedTime';
                              } catch (e) {
                                debugPrint('❌ Error formatting end time: $e');
                              }
                            }
                            return 'Not available';
                          }(),
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: getStatusColor(widget
                                        .auctionData['isDeposit'] ==
                                    true
                                ? widget.auctionData['usageStatus'] ?? 'Unknown'
                                : (widget.auctionData['auction'] != null &&
                                        widget.auctionData['details'] != null)
                                    ? (widget.auctionData['auction']
                                            .usageStatus ??
                                        'Unknown')
                                    : widget.auctionData['data']?['product']
                                            ?['usageStatus'] ??
                                        'Unknown'),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            getDisplayStatus(widget.auctionData['isDeposit'] ==
                                    true
                                ? widget.auctionData['usageStatus'] ?? 'Unknown'
                                : (widget.auctionData['auction'] != null &&
                                        widget.auctionData['details'] != null)
                                    ? (widget.auctionData['auction']
                                            .usageStatus ??
                                        'Unknown')
                                    : widget.auctionData['data']?['product']
                                            ?['usageStatus'] ??
                                        'Unknown'),
                            style: const TextStyle(
                              color: secondaryColor,
                              fontSize: 6.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (widget.auctionData['auction'] != null &&
                        widget.auctionData['details'] != null)
                    ? 'Purchase Price'
                    : 'Security Deposit',
                style: const TextStyle(
                  color: onSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                () {
                  debugPrint('🔍 Auction Data: ${widget.auctionData}');
                  debugPrint(
                      '🔍 Is Deposit: ${widget.auctionData['isDeposit']}');
                  debugPrint('🔍 Data Object: ${widget.auctionData['data']}');

                  // Buy Now flow: use acceptedAmount from details
                  if (widget.auctionData['auction'] != null &&
                      widget.auctionData['details'] != null) {
                    final acceptedAmount = widget.auctionData['details']
                                ['acceptedAmount']
                            ?.toString() ??
                        '0';
                    final parsedAmount = double.tryParse(acceptedAmount) ?? 0;
                    final formattedAmount = NumberFormat("#,##0.00")
                        .format(parsedAmount);
                    return 'AED $formattedAmount';
                  }

                  // For newly created auctions, calculate deposit based on category
                  if (widget.auctionData['isDeposit'] == null &&
                      widget.auctionData['data'] != null) {
                    final categoryId =
                        widget.auctionData['data']['product']?['categoryId'];
                    if (categoryId != null) {
                      final depositAmount =
                          CategoryService.getSellerDepositAmount(
                              int.parse(categoryId.toString()));
                      debugPrint('🔍 Calculated Deposit Amount: $depositAmount');
                      return 'AED ${NumberFormat("#,##0.00").format(double.tryParse(depositAmount) ?? 0)}';
                    }
                  }

                  // For existing deposits, use the provided amount
                  final depositAmount = widget.auctionData['isDeposit'] == true
                      ? widget.auctionData['depositAmount']?.toString()
                      : widget.auctionData['data']?['depositAmount']
                              ?.toString() ??
                          widget.auctionData['depositAmount']?.toString();

                  debugPrint('🔍 Deposit Amount: $depositAmount');

                  final formattedAmount = NumberFormat("#,##0.00").format(
                      double.tryParse(depositAmount ?? '0') ?? 0);

                  return 'AED $formattedAmount';
                }(),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (!(widget.auctionData['auction'] != null &&
              widget.auctionData['details'] != null))
            Text(
              '(refunded after auction completion)',
              style: TextStyle(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(height: 20),

          // Category row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Category',
                style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                () {
                  final categoryId = widget.auctionData['isDeposit'] == true
                      ? widget.auctionData['categoryId'] ?? 'No Category'
                      : (widget.auctionData['auction'] != null &&
                              widget.auctionData['details'] != null)
                          ? (widget.auctionData['auction'].categoryId ??
                              'No Category')
                          : widget.auctionData['data']?['product']
                                  ?['categoryId'] ??
                              widget.auctionData['categoryId'] ??
                              'No Category';
                  if (categoryId != null) {
                    final name = CategoryService.getCategoryName(
                        int.parse(categoryId.toString()));
                    return name.isNotEmpty ? name : 'Unknown';
                  }
                  return 'Unknown';
                }(),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Auction fee or starting price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                (widget.auctionData['auction'] != null &&
                        widget.auctionData['details'] != null)
                    ? 'Auction Fee'
                    : 'Auction Starting Price',
                style: const TextStyle(
                  color: onSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Builder(
                builder: (context) {
                  // Buy Now flow: Auction Fee = purchase price / 200
                  if (widget.auctionData['auction'] != null &&
                      widget.auctionData['details'] != null) {
                    final acceptedAmountStr = widget.auctionData['details']
                                ['acceptedAmount']
                            ?.toString() ??
                        '0';
                    final acceptedAmount =
                        double.tryParse(acceptedAmountStr) ?? 0;
                    final auctionFee = acceptedAmount / 200;
                    final formattedFee =
                        NumberFormat("#,##0.00").format(auctionFee);
                    return Text(
                      'AED $formattedFee',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                      ),
                    );
                  }
                  // Other flows: show auction starting price as before
                  final startingPrice = int.tryParse(
                        widget.auctionData['isDeposit'] == true
                            ? widget.auctionData['startBidAmount'].toString()
                            : widget.auctionData['data']?['startBidAmount']
                                    ?.toString() ??
                                '0',
                      ) ??
                      0;
                  return Text(
                    'AED ${NumberFormat("#,##0.00").format(startingPrice.toDouble())}',
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 11,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Show total only for Buy Now flow
          if (widget.auctionData['auction'] != null &&
              widget.auctionData['details'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Card Fee',
                  style: TextStyle(
                    color: onSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Builder(
                  builder: (context) {
                    final acceptedAmountStr = widget.auctionData['details']
                                ['acceptedAmount']
                            ?.toString() ??
                        '0';
                    final acceptedAmount = double.tryParse(acceptedAmountStr) ?? 0;
                    final auctionFee = acceptedAmount / 200;
                    final cardFee = ((acceptedAmount + auctionFee) * 0.03) + 4;
                    final formattedCardFee = NumberFormat("#,##0.00").format(cardFee);
                    return Text(
                      'AED $formattedCardFee',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: onSecondaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Builder(
                  builder: (context) {
                    final acceptedAmountStr = widget.auctionData['details']
                                ['acceptedAmount']
                            ?.toString() ??
                        '0';
                    final acceptedAmount = double.tryParse(acceptedAmountStr) ?? 0;
                    final auctionFee = acceptedAmount / 200;
                    final cardFee = ((acceptedAmount + auctionFee) * 0.03) + 4;
                    final total = acceptedAmount + auctionFee + cardFee;
                    final formattedTotal = NumberFormat("#,##0.00").format(total);
                    return Text(
                      'AED $formattedTotal',
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          // FAQ text and link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "If you want to check auction's policies, refer ",
                style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FaqScreen()));
                },
                child: const Text(
                  'FAQs',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
