// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/auth_helper.dart';
import 'package:alletre_app/utils/deposit_calculator.dart';
import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/controller/providers/contact_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:alletre_app/view/screens/auction screen/payment_details_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ItemDetailsBidSection extends StatefulWidget {
  final AuctionItem item;
  final String title;
  final UserModel user;
  final VoidCallback? onBidPlaced;

  const ItemDetailsBidSection({
    super.key,
    required this.item,
    required this.title,
    required this.user,
    this.onBidPlaced,
  });

  @override
  State<ItemDetailsBidSection> createState() => _ItemDetailsBidSectionState();
}

class DepositConfirmationDialog extends StatelessWidget {
  final double bidAmount;
  final double depositAmount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isLoading;

  const DepositConfirmationDialog({
    super.key,
    required this.bidAmount,
    required this.depositAmount,
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        constraints: const BoxConstraints(maxWidth: 680),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Auction Hammer Icon
            const Icon(
              Icons.gavel,
              size: 48,
              color: primaryColor,
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Congratulations on your First Bid!!!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: onSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Description
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: expiredColor,
                    ),
                children: [
                  const TextSpan(text: 'You are about to place a bid of '),
                  TextSpan(
                    text:
                        'AED ${NumberFormat.decimalPattern().format(bidAmount)}',
                    style: const TextStyle(color: primaryColor),
                  ),
                  const TextSpan(
                      text:
                          '. Please note that you will need to pay an amount of '),
                  TextSpan(
                    text:
                        'AED ${NumberFormat.decimalPattern().format(depositAmount)}',
                    style: TextStyle(color: snapchatColor),
                  ),
                  const TextSpan(text: ' as one-time deposit for the auction.'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(secondaryColor),
                            ),
                          )
                        : Text(
                            'Pay AED ${NumberFormat.decimalPattern().format(depositAmount)}',
                            style: const TextStyle(color: secondaryColor),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemDetailsBidSectionState extends State<ItemDetailsBidSection> {
  double? _optimisticCurrentBid;
  late TextEditingController _bidController;
  late ValueNotifier<String> bidAmount;
  late String minimumBid;
  bool _isSubmitting = false;
  bool _showDepositDialog = false;
  final AuctionService _auctionService = AuctionService();
  double? _calculatedDeposit;

  @override
  void initState() {
    super.initState();
    final auction = context.read<AuctionProvider>().getAuctionById(widget.item.id) ?? widget.item;
    minimumBid = auction.currentBid.isEmpty
        ? auction.startBidAmount
        : auction.currentBid;
    bidAmount = ValueNotifier<String>(minimumBid);
    _optimisticCurrentBid = null; // Ensure reset on init
    _bidController = TextEditingController(
        text:
            'AED ${NumberFormat.decimalPattern().format(double.parse(minimumBid))}');

    bidAmount.addListener(_updateController);
    _calculateDeposit();
  }

  void _calculateDeposit() async {
    try {
      debugPrint('🔍 Deposit Calculation Debug:');
      final auction = context.read<AuctionProvider>().getAuctionById(widget.item.id) ?? widget.item;
      debugPrint('🔍 Starting bid amount: ${auction.startBidAmount}');
      debugPrint('🔍 Latest bid amount: ${auction.currentBid}');
      debugPrint('🔍 Product data: ${auction.product}');

      final startBidAmount = double.parse(auction.startBidAmount);
      final latestBidAmount = _optimisticCurrentBid ?? double.parse(auction.currentBid);

      // Fetch category data if not available
      Map<String, dynamic>? category = auction.product?['category'];
      if (category == null && auction.product?['categoryId'] != null) {
        final categoryId = auction.product?['categoryId'];

        try {
          final url =
              '${ApiEndpoints.baseUrl}/categories/getParticularCatergory?categoryId=$categoryId';

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true && data['data'] != null) {
              category = data['data'];
              debugPrint('🔍 Successfully fetched category data: $category');
            }
          } else {
            debugPrint('❌ Failed to fetch category data:');
            debugPrint('  - Status Code: ${response.statusCode}');
            debugPrint('  - Response: ${response.body}');
          }
        } catch (e, stackTrace) {
          debugPrint('❌ Error fetching category data:');
          debugPrint('  - Error: $e');
          debugPrint('  - Stack Trace: $stackTrace');
        }
      }

      if (category == null) {
        debugPrint('❌ No category data available');
        _calculatedDeposit = null;
        return;
      }

      debugPrint('🔍 Category details:');
      debugPrint('  - Name: ${category['nameEn']}');
      debugPrint('  - Fixed Deposit: ${category['bidderDepositFixedAmount']}');
      debugPrint('  - Luxury Amount: ${category['luxuaryAmount']}');
      debugPrint(
          '  - Luxury Percentage: ${category['percentageOfLuxuarySD_forBidder']}');
      debugPrint(
          '  - Min Luxury Deposit: ${category['minimumLuxuarySD_forBidder']}');

      _calculatedDeposit = DepositCalculator.calculateSecurityDeposit(
        startBidAmount: startBidAmount,
        latestBidAmount: latestBidAmount,
        category: category,
      );

      debugPrint('🔍 Calculated deposit amount: $_calculatedDeposit');

      if (mounted) {
        setState(() {}); // Update UI with new deposit amount
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error calculating deposit:');
      debugPrint('  - Error: $e');
      debugPrint('  - Stack Trace: $stackTrace');
      _calculatedDeposit = null;
    }
  }

  void _updateController() {
    final formattedValue =
        'AED ${NumberFormat.decimalPattern().format(double.parse(bidAmount.value))}';
    if (_bidController.text != formattedValue) {
      _bidController.text = formattedValue;
    }
    _calculateDeposit(); // Recalculate deposit when bid amount changes
  }

  @override
  void dispose() {
    _bidController.dispose();
    bidAmount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auctionProvider = context.watch<AuctionProvider>();
    final auction = auctionProvider.getAuctionById(widget.item.id) ?? widget.item;
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;
    final currentUser = FirebaseAuth.instance.currentUser;
    final productOwnerEmail = auction.product?['user']?['email'];
    final isOwner = currentUser?.email == productOwnerEmail;

    // Use robust current bid for all bid UI logic
    final robustCurrentBid = auctionProvider.getCurrentBidForAuction(auction.id, auction.currentBid);
    _optimisticCurrentBid = double.tryParse(robustCurrentBid);

    if (!auction.isAuctionProduct ||
        (widget.title == "Similar Products" && !auction.isAuctionProduct)) {
      return Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Consumer<ContactButtonProvider>(
              builder: (context, contactProvider, child) {
                // Use latest auction state for owner check
                if (isOwner) {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement change status functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Text(
                            'Change Status',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: secondaryColor, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement convert to auction functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: secondaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: const BorderSide(color: primaryColor),
                            ),
                          ),
                          child: Text(
                            'Convert to Auction',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: primaryColor, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return contactProvider.isShowingContactButtons(widget.item.id)
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final message = Uri.encodeComponent(
                                    "Hello, I would like to inquire about your product listed on Alletre.");
                                final whatsappUrl =
                                    "https://wa.me/${widget.item.phone}?text=$message";
                                launchUrl(Uri.parse(whatsappUrl));
                              },
                              icon: const Icon(FontAwesomeIcons.whatsapp,
                                  color: secondaryColor),
                              label: Text('Chat',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: secondaryColor, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Contact Number',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'You can connect on',
                                              style: TextStyle(
                                                  color: expiredColor),
                                            ),
                                            Text(
                                              widget.item.phone,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            RichText(
                                              textAlign: TextAlign.center,
                                              text: TextSpan(
                                                style: TextStyle(
                                                    color: textColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontStyle:
                                                        FontStyle.italic),
                                                children: const [
                                                  TextSpan(
                                                      text:
                                                          "Don't forget to mention "),
                                                  TextSpan(
                                                    text: "Alletre",
                                                    style: TextStyle(
                                                        color: primaryColor,
                                                        fontStyle:
                                                            FontStyle.italic),
                                                  ),
                                                  TextSpan(
                                                      text: " when you call"),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        secondaryColor,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      side: const BorderSide(
                                                          color: primaryColor),
                                                    ),
                                                  ),
                                                  child: const Text('Close'),
                                                ),
                                                const SizedBox(width: 10),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final url =
                                                        'tel:${widget.item.phone}';
                                                    launchUrl(Uri.parse(url));
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        primaryColor,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                  ),
                                                  child: const Text('Call Now',
                                                      style: TextStyle(
                                                          color:
                                                              secondaryColor)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.call, color: primaryColor),
                              label: Text('Call',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: primaryColor, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: const BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          if (!isLoggedIn) {
                            AuthHelper.showAuthenticationRequiredMessage(
                                context);
                          } else {
                            contactProvider
                                .toggleContactButtons(widget.item.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View Contact Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: secondaryColor, fontSize: 16),
                        ),
                      );
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: onSecondaryColor, width: 1.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: bidAmount,
                builder: (context, value, child) {
                  final bool canDecrease =
                      double.parse(value) > double.parse(auction.currentBid.isEmpty ? auction.startBidAmount : auction.currentBid);
                  return Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: canDecrease
                          ? primaryColor
                          : primaryColor.withAlpha(128),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove,
                          color: secondaryColor, size: 15),
                      onPressed: canDecrease
                          ? () {
                              final currentValue = double.parse(value);
                              bidAmount.value = (currentValue - 50).toString();
                            }
                          : null,
                    ),
                  );
                },
              ),
              Expanded(
                child: TextField(
                  controller: _bidController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: onSecondaryColor,
                      fontSize: 15),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (newValue) {
                    // Remove 'AED ' prefix and any commas
                    final cleanValue =
                        newValue.replaceAll('AED ', '').replaceAll(',', '');
                    if (cleanValue.isNotEmpty) {
                      final numericValue = double.tryParse(cleanValue);
                      if (numericValue != null) {
                        bidAmount.value = numericValue.toString();
                      }
                    }
                  },
                ),
              ),
              ValueListenableBuilder<String>(
                valueListenable: bidAmount,
                builder: (context, value, child) {
                  return Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add,
                          color: secondaryColor, size: 15),
                      onPressed: () {
                        final currentValue = double.parse(value);
                        bidAmount.value = (currentValue + 50).toString();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleBidSubmission,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(secondaryColor),
                    ),
                  )
                : Text(
                    'Submit Bid',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: secondaryColor, fontSize: 16),
                  ),
          ),
        ),
        if (_showDepositDialog)
          DepositConfirmationDialog(
            bidAmount: double.parse(bidAmount.value),
            depositAmount: _calculatedDeposit ?? 0,
            onCancel: () {
              setState(() {
                _showDepositDialog = false;
              });
            },
            onConfirm: _handleDepositPayment,
            isLoading: _isSubmitting,
          ),
      ],
    );
  }

  /// Gets the user's highest previous bid for this auction
  Future<double> _getUserHighestBid(int auctionId) async {
    try {
      final url = '${ApiEndpoints.baseUrl}/auctions/user/$auctionId/details';
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final highestBid = data['data']?['highestBid'] ?? 0;
        return (highestBid is num) ? highestBid.toDouble() : 0;
      }
      return 0;
    } catch (e) {
      print('🔍 Error fetching user highest bid: $e');
      return 0;
    }
  }

  /// Checks if the current user is a first-time bidder for this auction by calling /auctions/user/{auctionId}/details
  Future<bool> _isFirstTimeBidder() async {
    try {
      final auction = context.read<AuctionProvider>().getAuctionById(widget.item.id) ?? widget.item;
      final auctionId = auction.id;
      final url = '${ApiEndpoints.baseUrl}/auctions/user/$auctionId/details';
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final hasBids = data['data']?['hasBids'] ?? false;
        print('[DEBUG] _isFirstTimeBidder hasBids: $hasBids');
        return hasBids == false; // true if first time bidder
      }
      return false;
    } catch (e) {
      print('🔍 Error checking deposit status via submit-bid: $e');
      print(
          '[DEBUG] _checkDepositStatus encountered an error, returning false.');
      return false;
    }
  }

  void _handleBidSubmission() async {
    final isLoggedIn = context.read<LoggedInProvider>().isLoggedIn;
    if (!isLoggedIn) {
      AuthHelper.showAuthenticationRequiredMessage(context);
      return;
    }

    // Always validate bid amount against current bid before any deposit logic
    final enteredBid = double.tryParse(bidAmount.value);
    final auction = context.read<AuctionProvider>().getAuctionById(widget.item.id) ?? widget.item;
    final currentBidValue = _optimisticCurrentBid ?? double.tryParse(auction.currentBid);
    if (enteredBid == null || currentBidValue == null || enteredBid <= currentBidValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bid amount must be greater than the current bid (AED ${NumberFormat.decimalPattern().format(currentBidValue ?? 0)})',
            style: const TextStyle(fontSize: 13),
          ),
          backgroundColor: errorColor,
        ),
      );
      setState(() { _isSubmitting = false; });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final isFirstTime = await _isFirstTimeBidder();
      final categoryName = CategoryService.getCategoryName(auction.categoryId).toLowerCase();
      double userHighestBid = 0;
      if (categoryName == 'cars') {
        userHighestBid = await _getUserHighestBid(auction.id);
      }
      // Show deposit dialog if:
      // - first time bidder (non-cars), or
      // - cars: user has never bid >= 5000 and now bids >= 5000
      final shouldShowDepositDialog =
        (isFirstTime && categoryName != 'cars') ||
        (categoryName == 'cars' && userHighestBid < 5000 && enteredBid >= 5000);
      if (shouldShowDepositDialog) {
        print('[DEBUG] User is first-time bidder. Showing deposit dialog.');
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return DepositConfirmationDialog(
                bidAmount: enteredBid,
                depositAmount: _calculatedDeposit ?? 0,
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onConfirm: () {
                  Navigator.of(context).pop();
                  _handleDepositPayment();
                },
                isLoading: _isSubmitting,
              );
            },
          );
        }
      } else {
        // Deposit already paid, validate bid amount in frontend
        print('[DEBUG] Deposit already paid. Validating bid and placing...');
        final auctionProvider = context.read<AuctionProvider>();
        final auction = auctionProvider.getAuctionById(widget.item.id) ?? widget.item;
        final enteredBid = double.tryParse(bidAmount.value);
        final currentBidValue = _optimisticCurrentBid ?? double.tryParse(auction.currentBid);
        if (enteredBid == null || currentBidValue == null || enteredBid <= currentBidValue) {
          // Validation failed: entered bid is not greater than current
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Bid amount must be greater than the current bid (AED ${NumberFormat.decimalPattern().format(currentBidValue ?? 0)})',
                style: const TextStyle(fontSize: 13),
              ),
              backgroundColor: errorColor,
            ),
          );
          setState(() { _isSubmitting = false; });
          return;
        }

        // Send the bid to backend
        try {
          final userService = UserService();
          final refreshResult = await userService.refreshTokens();
          if (refreshResult['success'] != true) {
            // Auth error
            setState(() { _isSubmitting = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child: Text('Authentication error. Please login again.'))),
            );
            return;
          }
          const storage = FlutterSecureStorage();
          final token = await storage.read(key: 'access_token');
          final response = await http.post(
            Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/${widget.item.id}/submit-bid'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'bidAmount': enteredBid,
            }),
          );
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Only update provider/UI after backend confirms
            auctionProvider.optimisticBidUpdate(
              auction.id,
              enteredBid,
              (auction.bids) + 1,
            );
            setState(() {
              _optimisticCurrentBid = enteredBid;
            });
            if (widget.onBidPlaced != null) {
              widget.onBidPlaced!();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child: Text('Bid placed successfully')), backgroundColor: activeColor),
            );
          } else {
            setState(() { _isSubmitting = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Center(child: Text('Bid failed. Please try again.')), backgroundColor: errorColor),
            );
          }
        } catch (e) {
          // Network or other error
          setState(() { _isSubmitting = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Center(child: Text('Network error. Please try again.')), backgroundColor: errorColor),
          );
        }
      }
    } catch (e) {
      print('🔍 Error in bid submission:');
      print('  - Error Type: ${e.runtimeType}');
      print('  - Error Message: $e');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        String errorMessage = 'Failed to process request';
        if (e.toString().contains('{')) {
          try {
            final errorStr = e.toString().split('Exception: ').last;
            final errorMap = jsonDecode(errorStr);
            errorMessage = errorMap['en'] ?? errorMap['ar'] ?? errorMessage;
          } catch (parseError) {
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _handleDepositPayment() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final submittedBidAmount = double.parse(bidAmount.value);

      print('🔍 Starting Deposit Payment:');
      final auction = context.read<AuctionProvider>().getAuctionById(widget.item.id) ?? widget.item;
      print('  - Bid Amount: $submittedBidAmount');
      print('  - Auction ID: ${auction.id}');
      print('  - Current Bid: ${auction.currentBid}');
      print('  - Start Bid: ${auction.startBidAmount}');
      print('  - Calculated Deposit: $_calculatedDeposit');

      await _auctionService.processBidderDeposit(
          auction.id.toString(), submittedBidAmount);

      if (mounted) {
        print('🔍 Passing data to PaymentDetailsScreen:');
        print('  - Full item data: ${widget.item}');
        print('  - Expiry Date: ${widget.item.expiryDate}');
        print('  - End Date: ${widget.item.endDate}');
        print('  - Raw auction data: ${widget.item.product}');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentDetailsScreen(
              auctionData: {
                'id': widget.item.id,
                'amount': submittedBidAmount,
                'isDeposit': true,
                'product': widget.item.product,
                'currentBid': widget.item.currentBid,
                'startBidAmount': widget.item.startBidAmount,
                'status': widget.item.status,
                'usageStatus': widget.item.usageStatus,
                'title': widget.item.title,
                'description': widget.item.description,
                'category': widget.item.product?['category'],
                'subCategory': widget.item.product?['subCategory'],
                'images': widget.item.imageLinks,
                'user': widget.item.product?['user'],
                'createdAt': widget.item.createdAt,
                'expiryDate': widget.item.expiryDate,
                'isAuctionProduct': widget.item.isAuctionProduct,
                'bids': widget.item.bids,
                'depositAmount': _calculatedDeposit,
                'isDepositPaid': widget.item.isDepositPaid,
                'buyNowEnabled': widget.item.buyNowEnabled,
                'buyNowPrice': widget.item.buyNowPrice,
                'categoryId': widget.item.categoryId,
                'subCategoryId': widget.item.subCategoryId,
                'categoryName': widget.item.categoryName,
                'subCategoryName': widget.item.subCategoryName,
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('🔍 Deposit Payment Error in UI:');
      print('  - Error Type: ${e.runtimeType}');
      print('  - Error Message: $e');

      if (mounted) {
        String errorMessage = 'Failed to process deposit';
        if (e.toString().contains('{')) {
          try {
            final errorStr = e.toString().split('Exception: ').last;
            print('🔍 Parsing error message: $errorStr');
            final errorMap = jsonDecode(errorStr);
            errorMessage = errorMap['en'] ?? errorMap['ar'] ?? errorMessage;
            print('🔍 Parsed error message: $errorMessage');
          } catch (parseError) {
            print('🔍 Error parsing error message: $parseError');
            errorMessage = e.toString().replaceAll('Exception: ', '');
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _showDepositDialog = false;
        });
      }
    }
  }
}
