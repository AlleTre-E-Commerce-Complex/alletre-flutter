import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/providers/auction_provider.dart';
import '../widgets/auction card widgets/auction_card.dart';
import '../../model/user_model.dart';

class MyAuctionsScreen extends StatelessWidget {
  static const List<String> _auctionTypes = [
    'Active',
    'Scheduled',
    'Sold',
    'Pending',
    'Waiting for Payment',
    'Expired',
  ];

  static final ValueNotifier<String> _selectedType =
      ValueNotifier<String>(_auctionTypes[0]);

  const MyAuctionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final borderRadius = BorderRadius.circular(12);
    return Scaffold(
      appBar: NavbarElementsAppbar(
        appBarTitle: 'My Auctions',
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.49,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.07),
                  borderRadius: borderRadius,
                  border: Border.all(color: primaryColor, width: 1.2),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ValueListenableBuilder<String>(
                    valueListenable: _selectedType,
                    builder: (context, selected, _) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selected,
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: primaryColor),
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
                                        Icon(_auctionTypeIcon(type),
                                            color: primaryColor, size: 18),
                                        const SizedBox(width: 5),
                                        Text(type,
                                            style: TextStyle(fontSize: 15)),
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
                  return _AuctionsTabView(type: selected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _auctionTypeIcon(String type) {
    switch (type) {
      case 'Active':
        return Icons.flash_on_rounded;
      case 'Scheduled':
        return Icons.schedule_rounded;
      case 'Sold':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.hourglass_bottom_rounded;
      case 'Waiting for Payment':
        return Icons.payment_rounded;
      case 'Expired':
        return Icons.cancel_rounded;
      default:
        return Icons.folder;
    }
  }
}

class _AuctionsTabView extends StatelessWidget {
  final String type;
  const _AuctionsTabView({required this.type});

  double getCardHeight(String type) {
    switch (type) {
      case 'Active':
      case 'Scheduled':
      case 'Expired':
      case 'Sold':
        return 198.0;
      case 'Pending':
      case 'Waiting for Payment':
      default:
        return 220.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Map auction type to status and provider list
    final statusMap = {
      'Active': 'ACTIVE',
      'Scheduled': 'IN_SCHEDULED',
      'Sold': 'SOLD',
      'Pending': 'PENDING_OWNER_DEPOIST',
      'Waiting for Payment': 'WAITING_FOR_DELIVERY',
      'Expired': 'EXPIRED',
    };
    final status = statusMap[type];

    return Consumer<AuctionProvider>(
      builder: (context, provider, _) {
        // Fetch on first build for each type
        switch (type) {
          case 'Active':
            if (!provider.isLoadingLive &&
                provider.liveAuctions.isEmpty &&
                provider.errorLive == null) {
              provider.getLiveAuctions();
            }
            // if (provider.isLoadingLive) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (provider.errorLive != null) {
              return EmptyState(message: provider.errorLive!);
            }
            final filtered = provider.liveAuctions
                .where((a) => a.status.toUpperCase() == status && a.isMyAuction)
                .toList();
            if (filtered.isEmpty) {
              return EmptyState(message: 'No $type auctions.');
            }
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (screenWidth - 32 - 12) / 2;
            final cardHeight = 198;

            return GridView.builder(
              padding: const EdgeInsets.all(5),
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
          case 'Scheduled':
            if (!provider.isLoadingUpcoming &&
                provider.upcomingAuctions.isEmpty &&
                provider.errorUpcoming == null) {
              provider.getUpcomingAuctions();
            }
            // if (provider.isLoadingUpcoming) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            if (provider.errorUpcoming != null) {
              return EmptyState(message: provider.errorUpcoming!);
            }
            final filtered = provider.upcomingAuctions
                .where((a) => a.status.toUpperCase() == status && a.isMyAuction)
                .toList();
            if (filtered.isEmpty) {
              return EmptyState(message: 'No $type auctions.');
            }
            
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (screenWidth - 32 - 12) / 2;
            final cardHeight = 198;

            return GridView.builder(
              padding: const EdgeInsets.all(5),
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
          
          case 'Sold':
            if (!provider.isLoadingSold &&
                provider.soldAuctions.isEmpty &&
                provider.errorSold == null) {
              provider.getSoldAuctions();
            }
            if (provider.errorSold != null) {
              return EmptyState(message: provider.errorSold!);
            }
            final filtered = provider.soldAuctions
                .where((a) => a.isMyAuction)
                .toList();
            if (filtered.isEmpty) {
              return EmptyState(message: 'No $type auctions.');
            }
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (screenWidth - 32 - 12) / 2;
            final cardHeight = getCardHeight(type);

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
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
          case 'Pending':
          case 'Waiting for Delivery':
            if (!provider.isLoadingListedProducts &&
                provider.listedProducts.isEmpty &&
                provider.errorListedProducts == null) {
              provider.getListedProducts();
            }
            if (provider.errorListedProducts != null) {
              return EmptyState(message: provider.errorListedProducts!);
            }
            final filtered = provider.listedProducts
                .where((a) => a.status.toUpperCase() == status && a.isMyAuction)
                .toList();
            if (filtered.isEmpty) {
              return EmptyState(message: 'No $type auctions.');
            }
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (screenWidth - 32 - 12) / 2;
            final cardHeight = getCardHeight(type);

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
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
          case 'Expired':
            if (!provider.isLoadingExpired &&
                provider.expiredAuctions.isEmpty &&
                provider.errorExpired == null) {
              provider.getExpiredAuctions();
            }
            if (provider.isLoadingExpired) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.errorExpired != null) {
              return EmptyState(message: provider.errorExpired!);
            }
            final filtered = provider.expiredAuctions
                .where((a) => a.status.toUpperCase() == status && a.isMyAuction)
                .toList();
            if (filtered.isEmpty) {
              return EmptyState(message: 'No $type auctions.');
            }
            final screenWidth = MediaQuery.of(context).size.width;
            final cardWidth = (screenWidth - 32 - 12) / 2;
            final cardHeight = getCardHeight(type);

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
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
                      password: ''),
                  title: type,
                  cardWidth: cardWidth,
                );
              },
            );
          default:
            return EmptyState(message: 'No $type auctions.');
        }
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, required this.message});

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
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
