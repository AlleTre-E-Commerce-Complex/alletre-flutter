import 'dart:io';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../faqs screen/faqs_screen.dart';
import '../../../services/category_service.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> auctionData;

  const PaymentDetailsScreen({
    super.key,
    required this.auctionData,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isSubmitted = ValueNotifier<bool>(false);

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

            // Card Details Form
            Form(
              key: formKey,
              child: Column(
                children: [
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        errorStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Card Number',
                        labelStyle: const TextStyle(
                            color: onSecondaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        prefixIcon: const Icon(Icons.credit_card, size: 18),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              errorStyle: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Expiry Date',
                              labelStyle: const TextStyle(
                                  color: onSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              prefixIcon:
                                  const Icon(Icons.calendar_today, size: 18),
                            ),
                            keyboardType: TextInputType.datetime,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter expiry date';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            inputDecorationTheme: const InputDecorationTheme(
                              errorStyle: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'CVV',
                              labelStyle: const TextStyle(
                                  color: onSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400),
                              ),
                              prefixIcon: const Icon(Icons.lock, size: 18),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        errorStyle: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Country',
                        labelStyle: const TextStyle(
                          color: onSecondaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        prefixIcon: const Icon(Icons.flag, size: 18),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please choose country';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            ElevatedButton(
              onPressed: () {
                isSubmitted.value = true;
                final isValid = formKey.currentState!.validate();
                if (isValid) {
                  Navigator.popUntil(context, (route) => route == myRoute);
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(50, 33),
                maximumSize: const Size(130, 33),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                "Pay & Submit",
                style: TextStyle(color: secondaryColor),
              ),
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
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                  width: 100,
                  height: 100,
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
                            final imagePath = auctionData['data']?['product']
                                ?['images']?[0] as String?;
                            if (imagePath != null) {
                              return Image.file(
                                File(imagePath),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return SvgPicture.asset(
                                    'assets/images/properties_category.svg',
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            } else {
                              return SvgPicture.asset(
                                'assets/images/properties_category.svg',
                                width: 110,
                                height: 100,
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
                            child: const Text(
                              'Pending',
                              style: TextStyle(
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
                        left: 12, right: 8, top: 4, bottom: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 3),
                        Text(
                          auctionData['data']?['product']?['title'] ??
                              'No Title',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: onSecondaryColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          auctionData['data']?['product']?['description'] ??
                              'No Description',
                          style: const TextStyle(
                            color: onSecondaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Ending Time:',
                          style: TextStyle(
                            color: onSecondaryColor,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          () {
                            final endTimeStr = auctionData['data']?['endDate'];

                            if (endTimeStr != null) {
                              try {
                                final endTime = DateTime.parse(endTimeStr);
                                debugPrint('Parsed DateTime: $endTime');

                                // Format the date as YYYY-MM-DD
                                final formattedDate =
                                    DateFormat('yyyy-MM-dd').format(endTime);
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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Security Deposit',
                  style: TextStyle(
                      color: onSecondaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text(
                'AED 500',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text('(refunded after auction completion)',
              style: TextStyle(
                  color: textColor, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
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
                  final categoryId = auctionData['data']?['product']
                          ?['categoryId'] ??
                      auctionData['product']?['categoryId'];
                  if (categoryId != null) {
                    final name = CategoryService.getCategoryName(
                        int.parse(categoryId.toString()));
                    return name.isNotEmpty ? name : 'Unknown';
                  }
                  return 'Unknown';
                }(),
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
                'AED ${NumberFormat("#,##0").format((auctionData['data']?['startBidAmount'] ?? auctionData['startBidAmount'] ?? 0).toInt())}',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 12,
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
