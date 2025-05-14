import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

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
    String? errorText;
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
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select the delivery type',
                      labelStyle:
                          const TextStyle(fontSize: 13, color: onSecondaryColor),
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      errorText: errorText,
                      errorStyle: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600),
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
                        errorText = null;
                      });
                    },
                  ),
                ),
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
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11)),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return ElevatedButton(
              onPressed: () {
                if (selectedType == null) {
                  setState(() {
                    errorText = 'Please select a delivery type before proceeding';
                  });
                  // Do NOT close the dialog
                  return;
                }
                setState(() {
                  errorText = null;
                });
                Navigator.of(context).pop();
                onSubmit(selectedType!);
              },
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: secondaryColor,
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
