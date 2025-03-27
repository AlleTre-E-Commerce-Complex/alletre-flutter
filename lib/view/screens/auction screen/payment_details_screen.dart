import 'dart:io';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
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

class _CardFormWidgetState extends State<CardFormWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    widget.controller.dispose();
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
  final selectedPaymentMethod = ValueNotifier<PaymentMethod>(PaymentMethod.card);
  late final CardFormEditController cardController;
  final UserService _userService = UserService();

  Future<String?> _getValidToken() async {
    try {
      // Get the current access token
      final token = await const FlutterSecureStorage().read(key: 'access_token');
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
  }

  @override
  void dispose() {
    selectedPaymentMethod.dispose();
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
                      onChanged: (value) => selectedPaymentMethod.value = value!,
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Wallet'),
                      value: PaymentMethod.wallet,
                      groupValue: method,
                      onChanged: (value) => selectedPaymentMethod.value = value!,
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
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: method == PaymentMethod.card
                      ? KeyedSubtree(
                          key: const ValueKey('card_form'),
                          child: CardFormWidget(
                            key: const ValueKey('card_form_widget'),
                            controller: cardController,
                            formKey: formKey,
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
            const SizedBox(height: 10),

            // Submit Button
            ValueListenableBuilder<bool>(
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
                              final userProvider = Provider.of<UserProvider>(context, listen: false);
                              if (!userProvider.isLoggedIn) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please login to continue with the payment'),
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
                                    content: Text('Unable to get a valid token'),
                                    backgroundColor: errorColor,
                                  ),
                                );
                                return;
                              }

                              final categoryId = widget.auctionData['data']?['product']?['categoryId'];
                              print('Category ID from auction data: $categoryId (${categoryId.runtimeType})');
                              if (categoryId == null) {
                                throw Exception('Invalid category ID');
                              }

                              final parsedCategoryId = int.parse(categoryId.toString());
                              print('Parsed category ID: $parsedCategoryId');
                              
                              final depositAmount = CategoryService.getSellerDepositAmount(parsedCategoryId);
                              print('Deposit amount from service: $depositAmount (${depositAmount.runtimeType})');
                              
                              if (depositAmount.isEmpty) {
                                throw Exception('Invalid deposit amount for category');
                              }

                              final auctionId = widget.auctionData['data']?['id'];
                              if (auctionId == null) {
                                throw Exception('Invalid auction ID');
                              }

                              final amount = double.parse(depositAmount);
                              
                              if (selectedPaymentMethod.value == PaymentMethod.wallet) {
                                await PaymentService.walletPayForAuction(
                                  auctionId: auctionId,
                                  amount: amount,
                                  token: token,
                                );
                              } else {
                                // Get card details
                                final cardDetails = cardController.details;
                                if (!cardDetails.complete) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill in all card details correctly'),
                                      backgroundColor: errorColor,
                                    ),
                                  );
                                  return;
                                }
                                
                                try {
                                  await PaymentService.payForAuction(
                                    auctionId: auctionId,
                                    amount: amount,
                                    paymentType: 'card',
                                    currency: 'AED',
                                    token: token,
                                    cardDetails: cardDetails,
                                  );
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Payment failed: ${e.toString()}'),
                                      backgroundColor: errorColor,
                                    ),
                                  );
                                  return;
                                }
                              }

                              if (!context.mounted) return;
                              
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.credit_card,
                                            color: Colors.green,
                                            size: 64,
                                          ),
                                          const SizedBox(height: 16),
                                          const Text(
                                            'Payment success',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            'Your deposit has been successfully transferred and your\nauction is active now',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushNamedAndRemoveUntil(
                                                    context,
                                                    '/auctions',
                                                    (route) => false,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.white,
                                                  side: const BorderSide(color: Colors.grey),
                                                ),
                                                child: const Text(
                                                  'View Auctions',
                                                  style: TextStyle(color: Colors.black),
                                                ),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pushNamedAndRemoveUntil(
                                                    context,
                                                    '/',
                                                    (route) => false,
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: activeColor,
                                                ),
                                                child: const Text('Back to home'),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
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
                      style: const TextStyle(color: secondaryColor, fontSize: 14),
                    ),
                  ),
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
                            final imagePath = widget.auctionData['data']?['product']
                                ?['images']?[0] as String?;
                            if (imagePath != null) {
                              return Image.file(
                                File(imagePath),
                                width: 112,
                                height: 106,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                    'assets/images/properties_category.svg',
                                    width: 112,
                                    height: 106,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
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
                              color: avatarColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6),
                              ),
                            ),
                            child: Text(
                              getDisplayStatus(
                                  widget.auctionData['data']?['status'] ?? 'Unknown'),
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
                    padding: const EdgeInsets.only(
                        left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          widget.auctionData['data']?['product']?['title'] ??
                              'No Title',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: onSecondaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          widget.auctionData['data']?['product']?['description'] ??
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
                        const Text(
                          'Ending Time:',
                          style: TextStyle(
                            color: onSecondaryColor,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          () {
                            final endTimeStr = widget.auctionData['data']?['endDate'];

                            if (endTimeStr != null) {
                              try {
                                final endTime = DateTime.parse(endTimeStr);
                                debugPrint('Parsed DateTime: $endTime');

                                // Format the date as DD-MM-YYYY
                                final formattedDate =
                                    DateFormat('dd-MM-yyyy').format(endTime);
                                // Format the time as HH:MM AM/PM
                                final formattedTime =
                                    DateFormat('hh:mm a').format(endTime);

                                return '$formattedDate  |  $formattedTime'; // Added separation after date
                              } catch (e) {
                                debugPrint('Error parsing end time: $e');
                              }
                            }
                            return 'Not known';
                          }(),
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        widget.auctionData['data']?['status'] == 'PENDING_OWNER_DEPOIST'
                          ? Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: avatarColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Text(
                              'PENDING DEPOSIT',
                              style: TextStyle(
                                color: secondaryColor,
                                fontSize: 6.4,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                          : const Text('UNKNOWN')
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
              const Text('Security Deposit',
                  style: TextStyle(
                      color: onSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Builder(builder: (context) {
                final categoryId =
                    widget.auctionData['data']?['product']?['categoryId'];
                final depositAmount = categoryId != null
                    ? CategoryService.getSellerDepositAmount(
                        int.parse(categoryId.toString()))
                    : null;
                return Text(
                  'AED ${depositAmount ?? 'Unknown'}',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ],
          ),
          Text('(refunded after auction completion)',
              style: TextStyle(
                  color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     Text('Auction Fee',
          //         style: TextStyle(
          //             color: onSecondaryColor,
          //             fontSize: 12,
          //             fontWeight: FontWeight.bold)),
          //     Text(
          //       'AED ${_calculateAuctionFee(auctionData['data']?['startBidAmount'] ?? auctionData['startBidAmount'])}',
          //       style: TextStyle(
          //         color: primaryColor,
          //         fontSize: 12,
          //         fontWeight: FontWeight.bold,
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 16),

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
                  final categoryId = widget.auctionData['data']?['product']
                          ?['categoryId'] ??
                      widget.auctionData['product']?['categoryId'];
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
          // Auction starting price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auction Starting Price',
                style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: 12,
                ),
              ),
              Text(
                'AED ${NumberFormat("#,##0").format((widget.auctionData['data']?['startBidAmount'] ?? widget.auctionData['startBidAmount'] ?? 0).toInt())}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
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

  int _calculateAuctionFee(dynamic startBidAmount) {
    // Convert startBidAmount to integer
    final int amount =
        (double.tryParse(startBidAmount.toString()) ?? 0).toInt();

    // Calculate fee as 2% of starting bid, minimum 10 AED
    final fee = (amount * 0.02).toInt();
    return fee < 10 ? 10 : fee;
  }

  Widget _buildDetailRow(String label, String value, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: style ??
                const TextStyle(
                  color: onSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: style ??
                const TextStyle(
                  color: onSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
