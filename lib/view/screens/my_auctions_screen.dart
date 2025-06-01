import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controller/providers/auction_provider.dart';
import '../widgets/auction card widgets/auction_card.dart';
import '../../model/user_model.dart';
import '../../model/auction_item.dart';

class MyAuctionsScreen extends StatelessWidget {
  static const List<String> _auctionTypes = [
    'Active',
    'Scheduled',
    'Sold',
    'Pending',
    'Waiting for Payment',
    'Expired',
    'Cancelled'
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
                                        Icon(_auctionTypeIcon(type),
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
        return Icons.free_cancellation_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.folder;
    }
  }
}

class _AuctionsTabView extends StatelessWidget {
  final String type;
  const _AuctionsTabView({required this.type});

  @override
  Widget build(BuildContext context) {
    // Map auction type to status
    final statusMap = {
      'Active': 'ACTIVE',
      'Scheduled': 'IN_SCHEDULED',
      'Sold': 'SOLD',
      'Pending': 'PENDING_OWNER_DEPOIST',
      'Waiting for Payment': 'WAITING_FOR_PAYMENT',
      'Expired': 'EXPIRED',
      'Cancelled': [
        'CANCELLED_BEFORE_EXP_DATE',
        'CANCELLED_AFTER_EXP_DATE',
        'CANCELLED_BY_ADMIN'
      ]
    };
    final status = statusMap[type];

    debugPrint('🔍 [MyAuctionsScreen] Tab selected: $type (Status: $status)');

    // Log counts for all auction types
    final provider = Provider.of<AuctionProvider>(context, listen: false);

    // Helper function to log auction statuses
    void logAuctionStatuses(List<AuctionItem> auctions, String type) {
      final myAuctions = auctions.where((a) => a.isMyAuction).toList();
      if (myAuctions.isEmpty) {
        debugPrint('   - $type: 0');
        return;
      }

      // Group by status
      final statusCounts = <String, int>{};
      for (var auction in myAuctions) {
        statusCounts[auction.status] = (statusCounts[auction.status] ?? 0) + 1;
      }

      debugPrint('   - $type (${myAuctions.length}):');
      statusCounts.forEach((status, count) {
        debugPrint('     • $status: $count');
      });
    }

    debugPrint('   📊 My Auctions Counts:');
    logAuctionStatuses(provider.liveAuctions, 'Active');
    logAuctionStatuses(provider.upcomingAuctions, 'Scheduled');
    logAuctionStatuses(provider.soldAuctions, 'Sold');
    logAuctionStatuses(provider.pendingAuctions, 'Pending');
    logAuctionStatuses(provider.waitingForPaymentAuctions, 'Waiting for Payment');
    logAuctionStatuses(provider.expiredAuctions, 'Expired');
    logAuctionStatuses(provider.cancelledAuctions, 'Cancelled');

    return Consumer<AuctionProvider>(builder: (context, provider, _) {
      // Declare filtered list and loading state
      List<AuctionItem> filtered = [];
      String? error;

      // Set up data based on tab type
      switch (type) {
        case 'Active':
          // final myActiveAuctions = provider.liveAuctions;
          // debugPrint('   My Active auctions: ${myActiveAuctions.length}');
          if (!provider.isLoadingMyLive &&
              provider.liveMyAuctions.isEmpty &&
              provider.errorMyLive == null) {
            // Initiate the fetch but don't wait for it
            provider.getLiveMyAuctions();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingLive;
          error = provider.errorMyLive;
          filtered = provider.liveMyAuctions
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;

        case 'Scheduled':
          final myScheduledAuctions = provider.upcomingAuctions;
          debugPrint('   My Scheduled auctions: ${myScheduledAuctions.length}');
          if (!provider.isLoadingUpcoming &&
              provider.upcomingAuctions.isEmpty &&
              provider.errorUpcoming == null) {
            provider.getUpcomingMyAuctions();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingUpcoming;
          error = provider.errorUpcoming;
          filtered = provider.upcomingAuctions
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;

         case 'Expired':
  debugPrint('\n🔵 === EXPIRED AUCTIONS DEBUG ===');
  debugPrint('🔵 Current state:');
  debugPrint('🔵 - isLoadingExpired: ${provider.isLoadingExpired}');
  debugPrint('🔵 - expiredAuctions count: ${provider.expiredAuctions.length}');
  debugPrint('🔵 - errorExpired: ${provider.errorExpired}');
  
  // Log all auctions for inspection
  if (provider.expiredAuctions.isNotEmpty) {
    debugPrint('🔵 All expired auctions (${provider.expiredAuctions.length}):');
    for (var i = 0; i < provider.expiredAuctions.length; i++) {
      final auction = provider.expiredAuctions[i];
      debugPrint('  ${i + 1}. ID: ${auction.id}, Status: ${auction.status}, Title: ${auction.title}');
    }
  } else {
    debugPrint('🟡 No expired auctions in the list');
  }

  // Check if we need to fetch
  final shouldFetch = !provider.isLoadingExpired && 
                     provider.expiredAuctions.isEmpty && 
                     provider.errorExpired == null;
  
  debugPrint('🔵 Should fetch expired auctions: $shouldFetch');
  if (shouldFetch) {
    debugPrint('🔄 Calling getExpiredMyAuctions()...');
    // Don't await here to avoid blocking the UI
    provider.getExpiredMyAuctions().then((_) {
      debugPrint('✅ getExpiredMyAuctions completed');
      debugPrint('   - New expiredAuctions count: ${provider.expiredAuctions.length}');
      
      if (provider.expiredAuctions.isNotEmpty) {
        debugPrint('   First 3 items after fetch:');
        for (var i = 0; i < provider.expiredAuctions.length && i < 3; i++) {
          final auction = provider.expiredAuctions[i];
          debugPrint('    ${i + 1}. ID: ${auction.id}, Status: ${auction.status}');
        }
      } else {
        debugPrint('🟡 No items in expiredAuctions after fetch');
      }
    }).catchError((error) {
      debugPrint('❌ Error in getExpiredMyAuctions: $error');
    });
  }

  // Log any errors
  if (provider.errorExpired != null) {
    debugPrint('❌ Error loading expired auctions: ${provider.errorExpired}');
  }

  // Filter expired auctions - use case-insensitive comparison
  debugPrint('\n🔵 Filtering expired auctions...');
  filtered = provider.expiredAuctions
      .where((a) {
        final status = a.status.toUpperCase();
        final isMatch = status == 'EXPIRED';
        debugPrint('  🔍 Auction ${a.id}: Status=$status, Matches: $isMatch');
        return isMatch;
      })
      .toList();
  
  debugPrint('\n🔵 Filtering complete:');
  debugPrint('   - Total items before filter: ${provider.expiredAuctions.length}');
  debugPrint('   - Items after filter: ${filtered.length}');
  
  if (filtered.isNotEmpty) {
    debugPrint('   First filtered item:');
    debugPrint('   - ID: ${filtered.first.id}');
    debugPrint('   - Status: ${filtered.first.status}');
    debugPrint('   - Title: ${filtered.first.title}');
  } else {
    debugPrint('🟡 No items matched the EXPIRED filter');
  }
  
  debugPrint('🔵 === END EXPIRED AUCTIONS DEBUG ===\n');
  break;

        case 'Sold':
          final mySoldAuctions = provider.soldAuctions;
          debugPrint('   My Sold auctions: ${mySoldAuctions.length}');
          if (!provider.isLoadingSold &&
              provider.soldAuctions.isEmpty &&
              provider.errorSold == null) {
            provider.getSoldAuctions();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingSold;
          error = provider.errorSold;
          filtered = provider.soldAuctions
              .where((a) => a.status.toUpperCase() == status)
              .toList();
          break;

        case 'Pending':
          debugPrint('🔍 [MyAuctionsScreen] Pending tab selected');
          debugPrint(
              '   - Provider pendingAuctions count: ${provider.pendingAuctions.length}');

          // Log all pending auctions and their statuses
          debugPrint('   - All pending auctions in provider:');
          for (var i = 0; i < provider.pendingAuctions.length; i++) {
            final auction = provider.pendingAuctions[i];
            debugPrint(
                '     [$i] ID: ${auction.id}, Status: ${auction.status}');
          }

          // Fetch if needed
          if (!provider.isLoadingPending &&
              provider.pendingAuctions.isEmpty &&
              provider.errorPending == null) {
            debugPrint('   - No pending auctions found, fetching...');
            provider.getPendingAuctions();
          }

          error = provider.errorPending;

          // Apply status check only (no need for isMyAuction check as API handles this)
          filtered = provider.pendingAuctions.where((a) {
            final matches = status is List<String>
                ? status.contains(a.status.toUpperCase())
                : a.status.toUpperCase() == status;
            debugPrint(
                '   - Auction ${a.id}: status=${a.status}, matches=$matches');
            return matches;
          }).toList();

          debugPrint('   - Final filtered count: ${filtered.length}');
          break;

        case 'Waiting for Payment':
          final myWaitingAuctions = provider.waitingForPaymentAuctions;
          debugPrint(
              '   My Waiting for Payment auctions: ${myWaitingAuctions.length}');
          if (!provider.isLoadingWaitingForPayment &&
              provider.waitingForPaymentAuctions.isEmpty &&
              provider.errorWaitingForPayment == null) {
            provider.getWaitingForPaymentAuctions();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingWaitingForPayment;
          error = provider.errorWaitingForPayment;
          filtered = provider.waitingForPaymentAuctions;
          break;

        case 'Cancelled':
          final myCancelledAuctions = provider.cancelledAuctions;
          debugPrint('   My Cancelled auctions: ${myCancelledAuctions.length}');
          if (!provider.isLoadingCancelled &&
              provider.cancelledAuctions.isEmpty &&
              provider.errorCancelled == null) {
            provider.getCancelledAuctions();
            // return const Center(child: CircularProgressIndicator());
          }
          // isLoading = provider.isLoadingPending;
          error = provider.errorCancelled;
          filtered = provider.cancelledAuctions
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
