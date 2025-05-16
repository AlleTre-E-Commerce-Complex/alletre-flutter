// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'package:alletre_app/controller/services/auction_details_service.dart';
import 'package:alletre_app/view/widgets/item details widgets/seller_location_map.dart';

import '../../screens/auction screen/payment_details_screen.dart';

class DeliveryTypeModal extends StatelessWidget {
  final List<String> deliveryTypes;
  final void Function(String) onSubmit;
  final AuctionItem auction;

  const DeliveryTypeModal({
    super.key,
    required this.deliveryTypes,
    required this.onSubmit,
    required this.auction,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedType;
    // errorText must persist across StatefulBuilder rebuilds
    // so we use a ValueNotifier for errorText
    final ValueNotifier<String?> errorTextNotifier =
        ValueNotifier<String?>(null);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1.3),
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ValueListenableBuilder<String?>(
                    valueListenable: errorTextNotifier,
                    builder: (context, errorText, _) {
                      return DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'Select the delivery type',
                          labelStyle: const TextStyle(
                              fontSize: 13, color: onSecondaryColor),
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          errorText: errorText,
                          errorStyle: const TextStyle(
                              color: errorColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                        value: selectedType,
                        items: deliveryTypes
                            .map((type) => DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: onSecondaryColor,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                            errorTextNotifier.value = null;
                          });
                        },
                      );
                    },
                  ),
                ),
                if (selectedType == 'Pick up yourself') ...[
                  const SizedBox(height: 10),
                  Text(
                    'The buyer is responsible for collecting the item. No delivery fees apply.',
                    style: TextStyle(color: Colors.green[700], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                ] else if (selectedType == 'Deliver by company') ...[
                  const SizedBox(height: 10),
                  Text(
                    'The company will arrange delivery, and the buyer will be responsible for the associated delivery fee.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 16),
                const Text('Seller Details',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: onSecondaryColor,
                        fontSize: 14)),
                const SizedBox(height: 8),
                Table(
                  border: TableBorder.all(color: Colors.black54),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(children: [
                      _addressCell('Address Label'),
                      _addressCell(auction.sellerAddressLabel),
                    ]),
                    TableRow(children: [
                      _addressCell('Address'),
                      _addressCell(auction.sellerAddress),
                    ]),
                    TableRow(children: [
                      _addressCell('City'),
                      _addressCell(auction.sellerCity),
                    ]),
                    TableRow(children: [
                      _addressCell('Country'),
                      _addressCell(auction.sellerCountry),
                    ]),
                    TableRow(children: [
                      _addressCell('Contact'),
                      _addressCell(auction.sellerPhone),
                    ]),
                  ],
                ),
                if (selectedType == 'Pick up yourself' && auction.itemLocation != null) ...[
  const SizedBox(height: 18),
  SellerLocationMap(
    lat: auction.itemLocation!.lat,
    lng: auction.itemLocation!.lng,
    label: auction.sellerAddressLabel ?? 'Seller Location',
  ),
],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(58, 32),
            maximumSize: const Size(108, 32),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          child: const Text('Cancel',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11)),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return ElevatedButton(
              onPressed: () async {
                // --- BEGIN DEBUG LOGGING ---
                debugPrint('[DeliveryTypeModal] Submit tapped');
                debugPrint('  selectedType: '
                    '\u001b[32m${selectedType?.toString() ?? 'null'}\u001b[0m');
                debugPrint('  errorTextNotifier (before): '
                    '\u001b[33m${errorTextNotifier.value}\u001b[0m');

                if (selectedType == null) {
                  debugPrint(
                      '  No delivery type selected. Setting error message.');
                  errorTextNotifier.value = 'Please select a delivery type';
                  debugPrint('  errorTextNotifier (after): '
                      '\u001b[31m${errorTextNotifier.value}\u001b[0m');
                  return;
                }
                debugPrint(
                    '  Delivery type selected. Clearing error and submitting.');
                errorTextNotifier.value = null;
                debugPrint('  errorTextNotifier (after): '
                    '\u001b[32m${errorTextNotifier.value}\u001b[0m');

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                );
                bool dialogClosed = false;
                void closeDialogIfOpen() {
                  if (!dialogClosed && Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                    dialogClosed = true;
                  }
                }

                try {
                  // Set delivery type API call (simulate or use your AuctionService)
                  final deliveryTypeMap = {
                    'Pick up yourself': 'PICKUP',
                    'Deliver by company': 'DELIVERY',
                  };
                  final backendDeliveryType = deliveryTypeMap[selectedType]!;
                  final auctionService = AuctionService();
                  final setDeliveryRes = await auctionService.setDeliveryType(
                      auction.id.toString(), backendDeliveryType);
                  if (setDeliveryRes['success'] != true) {
                    closeDialogIfOpen();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(setDeliveryRes['message'] ??
                              'Failed to set delivery type')),
                    );
                    return;
                  }

                  // Fetch latest auction details
                  final detailsRes =
                      await AuctionDetailsService.getAuctionDetails(
                          auction.id.toString());
                  if (detailsRes == null || detailsRes['data'] == null) {
                    closeDialogIfOpen();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Failed to get auction details')),
                    );
                    return;
                  }

                  closeDialogIfOpen();
                  // Navigate to payment details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailsScreen(
                        auctionData: {
                          'auction': auction,
                          'details': detailsRes['data'],
                        },
                      ),
                    ),
                  );
                  debugPrint(
                      '[DeliveryTypeModal] Navigation to /payment-details finished');
                } catch (e, stack) {
                  closeDialogIfOpen();
                  debugPrint(
                      '[DeliveryTypeModal] Exception in submit: $e\n$stack');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An error occurred: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: primaryColor),
                ),
                minimumSize: const Size(58, 32),
                maximumSize: const Size(108, 32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    color: primaryColor),
              ),
            );
          },
        ),
      ],
    );
  }

  static Widget _addressCell(dynamic child) {
    if (child is Widget) {
      return Padding(padding: const EdgeInsets.all(8), child: child);
    }
    return Padding(
        padding: const EdgeInsets.all(8),
        child: Text(child ?? '-',
            style: const TextStyle(
                fontSize: 12,
                color: onSecondaryColor,
                fontWeight: FontWeight.w500)));
  }
}
