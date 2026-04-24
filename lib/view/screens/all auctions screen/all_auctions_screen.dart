// ignore_for_file: use_build_context_synchronously

import 'package:alletre_app/controller/helpers/address_service.dart';
import 'package:alletre_app/utils/category_filters.dart';
import 'package:alletre_app/view/screens/auction%20screen/add_location_screen.dart';
import 'package:alletre_app/view/widgets/home%20widgets/filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/auction_card.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/search_field_widget.dart';
import '../auction screen/product_details_screen.dart';
import '../../../utils/auth_helper.dart';

class AllAuctionsScreen extends StatefulWidget {
  final String title;
  final UserModel user;
  final List<AuctionItem> auctions;
  final String placeholder;

  const AllAuctionsScreen({
    super.key,
    required this.user,
    required this.title,
    required this.auctions,
    required this.placeholder,
  });

  @override
  State<AllAuctionsScreen> createState() => _AllAuctionsScreenState();
}

class _AllAuctionsScreenState extends State<AllAuctionsScreen> {
  String generalCategory = "All";
  @override
  Widget build(BuildContext context) {
    // debugPrint('AllAuctionsScreen build called with ${auctions.length} items');
    final isLoggedIn = context.watch<LoggedInProvider>().isLoggedIn;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 10) / 2;
    // Get card height based on whether we're showing auctions or listed products
    final cardHeight = getCardHeight(widget.title, isAuctionProduct: widget.title == 'Similar Products' ? widget.auctions.firstOrNull?.isAuctionProduct ?? false : widget.title.contains('Auction'));

    // Create a filtered list based on the search query from AuctionProvider
    final auctionProvider = context.watch<AuctionProvider>();

    final filteredAuctions = [];
    if (auctionProvider.filters.isNotEmpty) {
      filteredAuctions.addAll(widget.auctions.where((item) {
        bool isOk = false;
        if (item.title.toLowerCase().contains(auctionProvider.searchQuery.toLowerCase())) {
          for (var filter in auctionProvider.filters) {
            bool isFoundFilter = false;
            if (filter['type'] == 'toggle_group') {
              for (var filterValue in filter['values']) {
                var productValue = item.product![filter['backend_key_name']].toString().toLowerCase();
                if (productValue == filterValue.toString().toLowerCase()) {
                  isFoundFilter = true;
                  break;
                }
              }
            } else if (filter['type'] == 'range_selector') {
              var productValue = item.product![filter['backend_key_name']].toString().toLowerCase();
              if (double.parse(productValue) >= filter['values']['min'] && double.parse(productValue) <= filter['values']['max']) {
                isFoundFilter = true;
              }
            } else if (filter['type'] == 'segmented_button') {
              var productValue = item.product![filter['backend_key_name']].toString().toLowerCase();
              if (productValue == Set<String>.from(filter['values']).elementAt(0).toLowerCase()) {
                isFoundFilter = true;
              }
            }
            if (!isFoundFilter) {
              isOk = false;
              break;
            } else {
              isOk = true;
            }
          }
        }
        return isOk;
      }).toList());
    } else {
      bool isSameCategory = true;
      filteredAuctions.addAll(auctionProvider.searchQuery.isEmpty
          ? widget.auctions
          : widget.auctions.where((auction) {
              if (auction.categoryName.toLowerCase() != widget.auctions[0].categoryName.toLowerCase()) {
                isSameCategory = false;
              }
              if (auction.title.toLowerCase().contains(auctionProvider.searchQuery.toLowerCase())) {
                return true;
              } else {
                return false;
              }
            }).toList());
      if (isSameCategory) {
        generalCategory = widget.auctions[0].categoryName;
      }
    }

    List<Widget> lstQuickFilterMenu = [];
    var categoryFilters = [];
    if (generalCategory.toLowerCase() == 'cars') {
      categoryFilters = filtersCar;
    } else if (generalCategory.toLowerCase() == 'properties') {
      categoryFilters = filtersProperty;
    }
    for (var filter in categoryFilters) {
      if (filter['show_in_quick_menu'] == true) {
        String menuName = filter['name'].toString()[0] + filter['name'].toString().toLowerCase().substring(1);
        lstQuickFilterMenu.add(_buildFilterButton(
          context,
          menuName,
          isSelected: false,
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Theme.of(context).splashColor,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(28), topLeft: Radius.circular(28))),
              builder: (context) {
                return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(0),
                    child: FilterBottomSheetLite(
                      filterField: filter,
                      onFilterComplete: (newValue) {
                        if (auctionProvider.filters.isEmpty) {
                          auctionProvider.filters.add({
                            'name': 'CATEGORY',
                            'type': 'segmented_button',
                            'backend_key_name': 'categoryName',
                            'values': [generalCategory.toLowerCase()]
                          });
                        }
                        int index = 0;
                        bool isFound = false;
                        for (var tFilter in auctionProvider.filters) {
                          if (filter['name'] == tFilter['name']) {
                            isFound = true;
                            break;
                          }
                          index++;
                        }
                        if (isFound) {
                          auctionProvider.filters[index]['values'] = newValue;
                        } else if (!isFound) {
                          filter['values'] = newValue;
                          auctionProvider.filters.add(filter);
                        }
                        auctionProvider.searchItems(auctionProvider.searchQuery, [...auctionProvider.filters]);
                      },
                      fetchInitialValue: (pFilterField) {
                        for (var filter in auctionProvider.filters) {
                          if (filter['name'] == pFilterField['name']) {
                            return filter['values'];
                          }
                        }
                      },
                    ));
              },
            );
          },
        ));
        lstQuickFilterMenu.add(const SizedBox(
          width: 10,
        ));
      }
    }

    List<Map<String, dynamic>> cardBrandData = [];
    Future.delayed(const Duration(seconds: 0), () async {
      cardBrandData = await fetchCarBrandData();
    });

    debugPrint('Filtered auctions count: ${filteredAuctions.length}');

    return Scaffold(
      appBar: NavbarElementsAppbar(
        appBarTitle: widget.title,
        showBackButton: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 9),
          SearchFieldWidget(
            isNavigable: false,
            query: auctionProvider.searchQuery,
            onChanged: (value) {
              auctionProvider.searchItems(value, null);
            },
            onFilterPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Theme.of(context).splashColor,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(28), topLeft: Radius.circular(28))),
                builder: (context) {
                  return Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(0),
                      child: FilterBottomSheet(
                        carBrandData: cardBrandData,
                        filters: [...auctionProvider.filters],
                        onFilterComplete: (filters) {
                          String newCategory = Set<String>.from(filters[0]['values']).elementAt(0);
                          generalCategory = newCategory[0].toUpperCase() + newCategory.substring(1);
                          auctionProvider.searchItems(auctionProvider.searchQuery, filters);
                        },
                      ));
                },
              );
            },
          ),
          const SizedBox(height: 5),
          // --- Start of Scrollable Filter Group ---
          SizedBox(
            height: 45, // Set a fixed height for the scroll area
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: lstQuickFilterMenu
                    .map((widget) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 0),
                          child: widget,
                        ))
                    .toList(),
              ),
            ),
          ),
          // --- End of Scrollable Filter Group ---
          // Expanded content below the search field
          Expanded(
            child: filteredAuctions.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          widget.placeholder,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: onSecondaryColor, fontSize: 13),
                        ),
                      ),
                      if (widget.title == "Live Auctions" || widget.title == "Listed Products")
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
                            // Address check before auction creation
                            final addresses = await AddressService.fetchAddresses();
                            if (addresses.isEmpty) {
                              await Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AddLocationScreen()),
                              );
                              return;
                            }
                            if (isLoggedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductDetailsScreen(),
                                ),
                              );
                            } else {
                              AuthHelper.showAuthenticationRequiredMessage(context);
                            }
                          },
                          child: Text(
                            widget.title == "Live Auctions" ? "Create Now" : "List Product",
                            style: const TextStyle(color: secondaryColor, fontSize: 9),
                          ),
                        ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 20,
                        childAspectRatio: cardWidth / cardHeight,
                      ),
                      itemCount: filteredAuctions.length,
                      itemBuilder: (context, index) {
                        return AuctionCard(
                          auction: filteredAuctions[index],
                          title: widget.title,
                          user: widget.user,
                          cardWidth: cardWidth,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context, String label, {bool isSelected = false, required Function() onTap}) {
    // Define colors based on your screenshot
    Color goldColor = Theme.of(context).textSelectionTheme.selectionColor!; // Approximate gold color from image
    Color textColor = Theme.of(context).primaryColor; // Darker text color

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? goldColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.09),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? goldColor : textColor,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: isSelected ? goldColor : textColor,
            ),
          ],
        ),
      ),
    );
  }
}
