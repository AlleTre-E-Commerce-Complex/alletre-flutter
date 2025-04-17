// ignore_for_file: avoid_print
import 'dart:math';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/auth_helper.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/all auctions screen/all_auctions_screen.dart';
import '../../screens/auction screen/product_details_screen.dart';
import '../auction card widgets/auction_card.dart';
import 'package:shimmer/shimmer.dart';
import 'shimmer_loading.dart';

class AuctionListWidget extends StatelessWidget {
  final String title;
  final UserModel user;
  final String subtitle;
  final List<AuctionItem> auctions;
  final bool isLoading;
  final String? error;
  final String placeholder;
  // final String emptyMessage;
  // final bool searchActive;
  // final bool showButton;

  const AuctionListWidget({
    super.key,
    required this.title,
    required this.user,
    required this.subtitle,
    required this.auctions,
    this.isLoading = false,
    this.error,
    required this.placeholder,
    // required this.emptyMessage,
    // required this.searchActive,
    // required this.showButton,
  });

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    return Padding(
      padding: title == 'Similar Products'
          ? EdgeInsets.zero
          : const EdgeInsets.only(left: 16, right: 16, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(fontSize: 15),
              ),
              TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                  ),
                  onPressed: () async {
                    debugPrint('See all clicked for: $title');
                    // Use the existing auctions list instead of fetching again
                    final fullList = auctions;
                    debugPrint('Navigating to AllAuctionsScreen with ${fullList.length} items');
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllAuctionsScreen(
                          title: title,
                          user: user,
                          auctions: fullList,
                          placeholder: placeholder,
                        ),
                      ),
                    );
                  },
                  child: Text('See all',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 12))),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: greyColor, fontSize: 13),
            ),
          ),
          const SizedBox(height: 10),

          /// **Shimmer Loading Effect**
          if (isLoading)
            SizedBox(
              height: getCardHeight(title, isAuctionProduct: auctions.firstOrNull?.isAuctionProduct ?? false), // Set consistent height
              child: ListView.builder(
                key: const PageStorageKey('shimmerList'),
                scrollDirection: Axis.horizontal,
                itemCount: auctions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: Shimmer.fromColors(
                      baseColor: borderColor,
                      highlightColor: shimmerColor,
                      child: ShimmerLoading(
                          width:
                              (MediaQuery.of(context).size.width - 32 - 10) / 2,
                          height: getCardHeight(title, isAuctionProduct: auctions.firstOrNull?.isAuctionProduct ?? false),
                          title: title),
                    ),
                  );
                },
              ),
            )
          else if (auctions.isEmpty)
            (() {
              // print('AuctionListWidget: No auctions to display for "$title"');
              // print('isLoading: $isLoading, error: $error');
              // print('searchActive: ${_searchQueryIsActive(context)}');
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Center(
                      child: Text(
                        _searchQueryIsActive(context)
                            ? "Searched item not found."
                            : placeholder,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: onSecondaryColor, fontSize: 13),
                      ),
                    ),
                  ),
                  if (!_searchQueryIsActive(context) &&
                      (title == "Live Auctions" || title == "Listed Products"))
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(58, 32),
                        maximumSize: const Size(108, 32),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (isLoggedIn) {
                          if (title == "Live Auctions") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductDetailsScreen()),
                            );
                          } else if (title == "Listed Products") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const ProductDetailsScreen(title: 'List Product')),
                            );
                          }
                        } else {
                          AuthHelper.showAuthenticationRequiredMessage(context);
                        }
                      },
                      child: Text(
                        title == "Live Auctions"
                            ? "Create Now"
                            : "List Product",
                        style:
                            const TextStyle(color: secondaryColor, fontSize: 9),
                      ),
                    ),
                ],
              );
            })()
          else
            SizedBox(
              height: getCardHeight(title, isAuctionProduct: auctions.firstOrNull?.isAuctionProduct ?? false), // Fixed height for each section
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: min(auctions.length, 6),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: AuctionCard(
                      user: user,
                      auction: auctions[index],
                      title: title,
                      cardWidth:
                          (MediaQuery.of(context).size.width - 32 - 10) / 2,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget buildStatusText(BuildContext context, String status) {
    final baseColor = getStatusColor(status);
    String displayStatus = status;

    if (status == "WAITING_FOR_PAYMENT") {
      displayStatus = "SOLD";
    } else if (status == "IN_SCHEDULED") {
      displayStatus = "SCHEDULED";
    } else if (status == "CANCELLED_BEFORE_EXP_DATE") {
      displayStatus = "CANCELLED";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: baseColor.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 7,
          color: getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  bool isSvg(String url) {
    final Uri uri = Uri.parse(url);
    final String path = uri.path;
    final String extension = path.split('.').last.toLowerCase();
    return extension == 'svg';
  }

  bool _searchQueryIsActive(BuildContext context) {
    final provider = context.read<AuctionProvider>();
    return provider.searchQuery.isNotEmpty;
  }
}
