import 'package:alletre_app/model/auction_item.dart';
import 'package:flutter/material.dart';

class AuctionListWidget extends StatelessWidget {
  final String title;
  final List<AuctionItem> auctions;

  const AuctionListWidget({
    super.key,
    required this.title,
    required this.auctions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          ...auctions.map((auction) {
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Image.asset(auction.imageLinks.first),
                title: Text(
                  auction.title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                subtitle: Text(
                  auction.price,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
