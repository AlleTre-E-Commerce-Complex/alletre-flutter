//import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/login_state.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/item_details/item_details.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BidsScreen extends StatelessWidget {
  const BidsScreen({super.key});

  IconData _auctionTypeIcon(String type) {
    switch (type) {
      case 'In Progress':
        return Icons.schedule_rounded;
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.hourglass_bottom_rounded;
      case 'Lost':
        return Icons.cancel_rounded;
      default:
        return Icons.folder;
    }
  }

  String _formatRemainingTime(DateTime expiryDate) {
    final now = DateTime.now();
    final diff = expiryDate.difference(now);

    if (diff.isNegative) return "Expired";

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final mins = diff.inMinutes % 60;

    return "${days}d ${hours}h ${mins}m";
  }

  @override
  Widget build(BuildContext context) {
    const List<Map<String, String>> _auctionTypes = [
      {'IN_PROGRESS': 'In Progress'},
      {'PENDING': 'Pending'},
      {'COMPLETED': 'Completed'},
      {'LOST': 'Lost'}
    ];
    final ValueNotifier<Map<String, String>> _selectedType = ValueNotifier<Map<String, String>>(_auctionTypes[0]);
    final borderRadius = BorderRadius.circular(12);
    if (context.watch<LoggedInProvider>().isLoggedIn == true) {
      context.read<AuctionProvider>().getJoinedAuctions(status: _selectedType.value.keys.first);
    }

    return Consumer<AuctionProvider>(
      builder: (context, provider, child) {
        final auctions = provider.joinedAuctions; // assumed data list

        return Scaffold(
          appBar: const NavbarElementsAppbar(appBarTitle: 'Bids'),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dropdown filter
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedType.value.values.first,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryColor, size: 22),
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
                                    value: type.values.first,
                                    child: Row(
                                      children: [
                                        Icon(_auctionTypeIcon(type.values.first), color: primaryColor, size: 16),
                                        const SizedBox(width: 5),
                                        Text(type.values.first, style: const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            var selectedItem = _auctionTypes.singleWhere((elem) => elem.values.first == val);
                            if (val != null) _selectedType.value = selectedItem;
                            provider.getJoinedAuctions(status: _selectedType.value.keys.first, shouldNotify: true);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (auctions.isEmpty) ...{
                  const Spacer(),
                  const Center(
                    child: Column(
                      children: [
                        Icon(Icons.gavel, size: 100, color: greyColor),
                        SizedBox(height: 20),
                        Text(
                          'No active bids!',
                          style: TextStyle(fontSize: 18, color: greyColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                } else ...{
                  // List of bids
                  Expanded(
                    child: ListView.builder(
                      itemCount: auctions.length,
                      itemBuilder: (context, index) {
                        var auction = auctions[index];
                        var endsIn = _formatRemainingTime(auction.expiryDate);
                        return GestureDetector(
                          onTap: () {
                            if (endsIn != 'Expired') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailsScreen(
                                    user: UserModel.empty(),
                                    item: auction,
                                    title: auction.title,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      auction.imageLinks.first,
                                      width: 90,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    // 👈 this prevents overflow
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          auction.product!['title'] ?? "Untitled",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Theme.of(context).textTheme.labelSmall!.color,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // 👈 prevent long titles breaking UI
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 16, color: primaryColor.withOpacity(0.6)),
                                            const SizedBox(width: 4),
                                            Text(
                                              auction.status,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text("Your BID: ${auction.currentBid} AED", style: const TextStyle(color: Colors.black26)),
                                        Row(
                                          children: [
                                            Text(
                                              "Ends In : ",
                                              style: const TextStyle(fontSize: 12, color: greyColor),
                                            ),
                                            Text(
                                              endsIn,
                                              style: TextStyle(fontSize: 12, color: endsIn == 'Expired' ? Theme.of(context).textTheme.bodySmall!.color : greyColor),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                },
              ],
            ),
          ),
        );
      },
    );
  }
}
