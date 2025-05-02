import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/auth_helper.dart';
import 'package:alletre_app/utils/deposit_calculator.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
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

  const ItemDetailsBidSection({
    super.key,
    required this.item,
    required this.title,
    required this.user,
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
              'Congratulations on Your First Bid!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              'You are about to place a bid for AED ${NumberFormat.decimalPattern().format(bidAmount)}. '
              'In this auction, please note that you will need to pay a deposit of '
              'AED ${NumberFormat.decimalPattern().format(depositAmount)} '
              'of the price as a deposit only once, so you can freely enjoy bidding.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Bonus Amount Text
            Text(
              'You can use your bonus amount using wallet payment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
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
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Pay AED ${NumberFormat.decimalPattern().format(depositAmount)} Deposit',
                            style: const TextStyle(color: Colors.white),
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
    minimumBid = widget.item.currentBid.isEmpty 
        ? widget.item.startBidAmount 
        : widget.item.currentBid;
    bidAmount = ValueNotifier<String>(minimumBid);
    _bidController = TextEditingController(
      text: 'AED ${NumberFormat.decimalPattern().format(double.parse(minimumBid))}'
    );
    
    bidAmount.addListener(_updateController);
    _calculateDeposit();
  }

  void _calculateDeposit() async {
    try {
      debugPrint('🔍 Deposit Calculation Debug:');
      debugPrint('🔍 Starting bid amount: ${widget.item.startBidAmount}');
      debugPrint('🔍 Latest bid amount: ${bidAmount.value}');
      debugPrint('🔍 Product data: ${widget.item.product}');
      
      final startBidAmount = double.parse(widget.item.startBidAmount);
      final latestBidAmount = double.parse(bidAmount.value);
      
      // Fetch category data if not available
      Map<String, dynamic>? category = widget.item.product?['category'];
      if (category == null && widget.item.product?['categoryId'] != null) {
        final categoryId = widget.item.product?['categoryId'];
        
        try {
          final url = '${ApiEndpoints.baseUrl}/categories/getParticularCatergory?categoryId=$categoryId';
          
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
      debugPrint('  - Luxury Percentage: ${category['percentageOfLuxuarySD_forBidder']}');
      debugPrint('  - Min Luxury Deposit: ${category['minimumLuxuarySD_forBidder']}');

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
    final formattedValue = 'AED ${NumberFormat.decimalPattern().format(double.parse(bidAmount.value))}';
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
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.email == widget.item.product?['user']?['email'];

    if (!widget.item.isAuctionProduct || (widget.title == "Similar Products" && !widget.item.isAuctionProduct)) {
      return Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Consumer<ContactButtonProvider>(
              builder: (context, contactProvider, child) {
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
                                                  color: Colors.grey[700]),
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
                            AuthHelper.showAuthenticationRequiredMessage(context);
                          } else {
                            contactProvider.toggleContactButtons(widget.item.id);
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
                      double.parse(value) > double.parse(minimumBid);
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    final cleanValue = newValue.replaceAll('AED ', '').replaceAll(',', '');
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
                      icon: const Icon(Icons.add, color: secondaryColor, size: 15),
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

  Future<bool> _checkDepositStatus() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/${widget.item.id}/details'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['isDepositPaid'] ?? false;
      }
      return false;
    } catch (e) {
      print('🔍 Error checking deposit status: $e');
      return false;
    }
  }

  void _handleBidSubmission() async {
    final isLoggedIn = context.read<LoggedInProvider>().isLoggedIn;
    if (!isLoggedIn) {
      AuthHelper.showAuthenticationRequiredMessage(context);
      return;
    }
    
    final currentBid = double.parse(bidAmount.value);
    final minBid = double.parse(minimumBid);
    
    if (currentBid <= minBid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bid amount must be more than AED ${NumberFormat.decimalPattern().format(minBid)}',
          style: const TextStyle(fontSize: 13)),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // First check if deposit is paid
      final isDepositPaid = await _checkDepositStatus();
      
      if (!isDepositPaid) {
        // If deposit is not paid, show deposit dialog
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return DepositConfirmationDialog(
                bidAmount: currentBid,
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
        if (mounted) {
          // Fetch latest auction details
          try {
            final auctionDetailsResponse = await http.get(
              Uri.parse('${ApiEndpoints.baseUrl}/auctions/user/${widget.item.id}/details'),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            );

            if (auctionDetailsResponse.statusCode == 200) {
              final auctionData = jsonDecode(auctionDetailsResponse.body);
              
              if (auctionData['success'] == true && auctionData['data'] != null) {
                
                // Log the exact data being passed
                final dataToPass = auctionData['data'];
                
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentDetailsScreen(
                      auctionData: dataToPass,
                    ),
                  ),
                );
                return;
              }
            } else {
              print('❌ API Response Error:');
              print('  - Status Code: ${auctionDetailsResponse.statusCode}');
              print('  - Response Body: ${auctionDetailsResponse.body}');
            }
          } catch (e) {
            print('❌ Error fetching auction details: $e');
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentDetailsScreen(
                auctionData: {
                  'id': widget.item.id,
                  'amount': currentBid,
                  'isDeposit': false,
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
      print('  - Bid Amount: $submittedBidAmount');
      print('  - Auction ID: ${widget.item.id}');
      print('  - Current Bid: ${widget.item.currentBid}');
      print('  - Start Bid: ${widget.item.startBidAmount}');
      print('  - Calculated Deposit: $_calculatedDeposit');
      
      await _auctionService.processBidderDeposit(widget.item.id.toString(), submittedBidAmount);

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
