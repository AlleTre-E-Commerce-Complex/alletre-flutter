import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/controller/providers/contact_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';

class ItemDetailsBidSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (title == 'Listed Products') {
      return Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Consumer<ContactButtonProvider>(
              builder: (context, contactProvider, child) {
                return contactProvider.isShowingContactButtons(item.id)
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final message = Uri.encodeComponent(
                                    "Hello, I would like to inquire about your product listed on Alletre.");
                                final whatsappUrl =
                                    "https://wa.me/${item.phone}?text=$message";
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
                                              item.phone,
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
                                                        'tel:${item.phone}';
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
                          contactProvider.toggleContactButtons(item.id);
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

    final ValueNotifier<String> bidAmount = ValueNotifier<String>(
      item.currentBid.isEmpty ? item.startBidAmount : item.currentBid,
    );

    final String minimumBid =
        item.currentBid.isEmpty ? item.startBidAmount : item.currentBid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
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
                child: ValueListenableBuilder<String>(
                  valueListenable: bidAmount,
                  builder: (context, value, child) {
                    return Text(
                      'AED ${NumberFormat.decimalPattern().format(double.parse(value))}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSecondaryColor,
                          fontSize: 15),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: secondaryColor, size: 15),
                  onPressed: () {
                    final currentValue = double.parse(bidAmount.value);
                    bidAmount.value = (currentValue + 50).toString();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle bid submission
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Submit Bid',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: secondaryColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
