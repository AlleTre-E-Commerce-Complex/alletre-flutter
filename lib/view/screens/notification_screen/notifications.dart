import 'package:alletre_app/controller/helpers/date_formatter_helper.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/notification_provider.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/view/screens/item_details/item_details.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // final List<Map<String, dynamic>> notifications = const [
  //   {"icon": Icons.emoji_events, "iconColor": Colors.green, "title": "You won the auction!", "subtitle": "Congratulations! Your bid for 'Samsung Galaxy S22' was the highest.", "time": "2h ago"},
  //   {"icon": Icons.trending_up, "iconColor": Colors.orange, "title": "New bid placed", "subtitle": "Someone outbid you on 'Vintage Rolex Watch'. Place a higher bid now.", "time": "4h ago"},
  //   {"icon": Icons.alarm, "iconColor": Colors.blue, "title": "Auction starting soon", "subtitle": "'MacBook Air 2023' auction starts in 1 hour. Get ready!", "time": "Yesterday"},
  //   {"icon": Icons.check_circle, "iconColor": Colors.teal, "title": "Product listed", "subtitle": "Your item 'Sony Headphones' has been approved and is live.", "time": "Yesterday"},
  //   {"icon": Icons.local_shipping, "iconColor": Colors.purple, "title": "Order shipped", "subtitle": "'Canon DSLR Camera' has been shipped to your address.", "time": "2 days ago"},
  //   {"icon": Icons.cancel, "iconColor": Colors.red, "title": "Auction ended", "subtitle": "Your bid on 'Apple iPad Pro' was unsuccessful.", "time": "3 days ago"},
  // ];

  @override
  Widget build(BuildContext superParentContext) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider()..fetchNotifications(),
      child: Consumer<NotificationProvider>(
        builder: (parentContext, provider, child) {
          return Scaffold(
            appBar: const NavbarElementsAppbar(
              appBarTitle: 'Notifications',
              showBackButton: true,
            ),
            body: provider.notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 100,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Notifications Yet!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When you place bids or when auctions you follow are updated, you’ll see them here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.notifications.length,
                    itemBuilder: (context, index) {
                      final item = provider.notifications[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: item.isRead ? 0.5 : 2, // more elevation if unread
                        color: item.isRead ? Colors.white : const Color.fromARGB(255, 225, 248, 241), // highlight unread
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Stack(
                            children: [
                              CircleAvatar(
                                backgroundColor: item.iconColor.withOpacity(0.1),
                                child: Icon(item.icon, color: item.iconColor),
                              ),
                              if (!item.isRead)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          title: Text(
                            item.productTitle,
                            style: TextStyle(
                              fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            item.message,
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Text(
                            DateFormatter.getVerboseDateTimeRepresentation(dateTime: item.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          onTap: () {
                            // when tapped, mark as read
                            if (!item.isRead) provider.markAsRead();
                            var auctionItem = context.read<AuctionProvider>().liveAuctions.singleWhere((auctionItem) => auctionItem.id == item.auctionId);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ItemDetailsScreen(
                                  user: UserModel.empty(),
                                  item: auctionItem,
                                  title: auctionItem.title,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
