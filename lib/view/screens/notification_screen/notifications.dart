import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, dynamic>> notifications = const [
    {"icon": Icons.emoji_events, "iconColor": Colors.green, "title": "You won the auction!", "subtitle": "Congratulations! Your bid for 'Samsung Galaxy S22' was the highest.", "time": "2h ago"},
    {"icon": Icons.trending_up, "iconColor": Colors.orange, "title": "New bid placed", "subtitle": "Someone outbid you on 'Vintage Rolex Watch'. Place a higher bid now.", "time": "4h ago"},
    {"icon": Icons.alarm, "iconColor": Colors.blue, "title": "Auction starting soon", "subtitle": "'MacBook Air 2023' auction starts in 1 hour. Get ready!", "time": "Yesterday"},
    {"icon": Icons.check_circle, "iconColor": Colors.teal, "title": "Product listed", "subtitle": "Your item 'Sony Headphones' has been approved and is live.", "time": "Yesterday"},
    {"icon": Icons.local_shipping, "iconColor": Colors.purple, "title": "Order shipped", "subtitle": "'Canon DSLR Camera' has been shipped to your address.", "time": "2 days ago"},
    {"icon": Icons.cancel, "iconColor": Colors.red, "title": "Auction ended", "subtitle": "Your bid on 'Apple iPad Pro' was unsuccessful.", "time": "3 days ago"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavbarElementsAppbar(
        appBarTitle: 'Notifications',
        showBackButton: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item['iconColor'].withOpacity(0.1),
                child: Icon(item['icon'], color: item['iconColor']),
              ),
              title: Text(
                item['title'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                item['subtitle'],
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Text(
                item['time'],
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
        },
      ),
    );
  }
}
