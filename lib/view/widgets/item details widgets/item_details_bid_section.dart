import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/utils/auth_helper.dart';
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

class _ItemDetailsBidSectionState extends State<ItemDetailsBidSection> {
  late TextEditingController _bidController;
  late ValueNotifier<String> bidAmount;
  late String minimumBid;

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
  }

  void _updateController() {
    final formattedValue = 'AED ${NumberFormat.decimalPattern().format(double.parse(bidAmount.value))}';
    if (_bidController.text != formattedValue) {
      _bidController.text = formattedValue;
    }
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
            onPressed: () {
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
              
              // TODO: Implement bid submission logic
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
