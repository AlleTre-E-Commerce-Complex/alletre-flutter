import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controller/providers/auction_provider.dart';
import '../../widgets/auction card widgets/auction_card.dart';
import '../../../model/user_model.dart';
import '../../../model/auction_item.dart';

class MyProductsScreen extends StatelessWidget {
  static const List<String> _auctionTypes = [
    'In Progress',
    'Out of Stock',
    'Sold Out',
  ];

  static final ValueNotifier<String> _selectedType =
      ValueNotifier<String>(_auctionTypes[0]);

  const MyProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderRadius = BorderRadius.circular(12);
    return Scaffold(
      appBar: NavbarElementsAppbar(
        appBarTitle: 'My Products',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.07),
                  borderRadius: borderRadius,
                  border: Border.all(color: primaryColor, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _selectedType,
                    builder: (context, selected, _) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selected,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: primaryColor, size: 22),
                          isExpanded: true,
                          dropdownColor: Theme.of(context).cardColor,
                          borderRadius: borderRadius,
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          items: _auctionTypes
                              .map((type) => DropdownMenuItem<String>(
                                    value: type,
                                    child: Row(
                                      children: [
                                        Icon(_productsTypeIcon(type),
                                            color: primaryColor, size: 16),
                                        const SizedBox(width: 5),
                                        Text(type,
                                            style: TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) _selectedType.value = val;
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: _selectedType,
                builder: (context, selected, _) {
                  return ProductsTabView(type: selected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _productsTypeIcon(String type) {
    switch (type) {
      case 'In Progress':
        return Icons.hourglass_bottom_rounded;
      case 'Out of Stock':
        return Icons.remove_shopping_cart_rounded;
      case 'Sold Out':
        return Icons.check_circle_rounded;
      default:
        return Icons.folder;
    }
  }
}

class ProductsTabView extends StatelessWidget {
  final String type;
  const ProductsTabView({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    // Map auction type to status
    final statusMap = {
      'In Progress': 'IN_PROGRESS',
      'Out of Stock': 'OUT_OF_STOCK',
      'Sold Out': 'SOLD_OUT',
    };

    final status = statusMap[type];

    debugPrint('🔍 [MyProductsScreen] Tab selected: $type (Status: $status)');

    return Consumer<AuctionProvider>(builder: (context, provider, _) {
      // Declare filtered list and loading state
      List<AuctionItem> filtered = [];
      String? error;

      // Set up data based on tab type
      switch (type) {
        case 'In Progress':
          // final myActiveAuctions = provider.liveAuctions;
          // debugPrint('   My Active auctions: ${myActiveAuctions.length}');
          if (!provider.isLoadingInProgress &&
              provider.inProgressProducts.isEmpty &&
              provider.errorInProgress == null) {
            // Initiate the fetch but don't wait for it
            provider.getInProgressProducts();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingInProgress;
          error = provider.errorInProgress;
          filtered = provider.inProgressProducts
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;

        case 'Out of Stock':
          // final myScheduledAuctions = provider.upcomingAuctions;
          // debugPrint('   My Scheduled auctions: ${myScheduledAuctions.length}');
          if (!provider.isLoadingOutOfStock &&
              provider.outOfStockProducts.isEmpty &&
              provider.errorOutOfStock == null) {
            provider.getOutOfStockProducts();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingOutOfStock;
          error = provider.errorOutOfStock;
          filtered = provider.outOfStockProducts
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;

        case 'Sold Out':
          // final mySoldAuctions = provider.soldOutProducts;
          // debugPrint('   My Sold auctions: ${mySoldAuctions.length}');
          if (!provider.isLoadingSoldOut &&
              provider.soldOutProducts.isEmpty &&
              provider.errorSoldOut == null) {
            provider.getSoldOutProducts();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingSoldOut;
          error = provider.errorSoldOut;
          filtered = provider.soldOutProducts
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;
      }

      // Show error if any
      if (error != null) {
        return EmptyState(message: error);
      }

      // Calculate dimensions for the grid
      final screenWidth = MediaQuery.of(context).size.width;
      final cardWidth = (screenWidth - 32 - 12) / 2;
      // Adjust height based on auction type
      final cardHeight = type.toLowerCase() == 'pending'
          ? 182
          : type.toLowerCase() == 'sold'
              ? 178
              : type.toLowerCase() == 'waiting for payment'
                  ? 180
                  : 192;

      Widget content;

      if (filtered.isEmpty) {
        content = EmptyState(message: 'No $type auctions found.', fontSize: 14);
      } else {
        content = GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 30,
            childAspectRatio: cardWidth / cardHeight,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final auction = filtered[index];
            return AuctionCard(
              auction: auction,
              user: UserModel(
                name: auction.userName ?? '',
                email: '',
                phoneNumber: auction.phone,
                password: '',
              ),
              title: type,
              cardWidth: cardWidth,
            );
          },
        );
      }

      return content;
    });
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final double? fontSize;
  const EmptyState({
    super.key,
    required this.message,
    this.fontSize = 14, // Default to 14 if not specified
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize ?? 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
