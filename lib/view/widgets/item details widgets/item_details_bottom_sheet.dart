import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';

class ItemDetailsBottomSheet extends StatelessWidget {
  final AuctionItem item;

  const ItemDetailsBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: onSecondaryColor,
                indicatorColor: primaryColor,
                labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: [
                  Tab(text: 'Item Details'),
                  Tab(text: 'Return Policy'),
                  Tab(text: 'Warranty Policy'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _itemDetailsTab(),
                    _returnPolicyTab(),
                    _warrantyPolicyTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _itemDetailsTitle(),
        _itemDetailsAbout(item.description),
        const SizedBox(height: 14),
        _itemDetailsContent('', ''),
      ],
    );
  }

  Widget _returnPolicyTab() {
    return const Center(child: Text('User reviews will be shown here.'));
  }

  Widget _warrantyPolicyTab() {
    return const Center(child: Text('Additional information about the product.'));
  }

  Widget _itemDetailsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'About The Brand',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: onSecondaryColor),
        ),
      ),
    );
  }

  Widget _itemDetailsAbout(String value) {
    return Center(
      child: Text(
        value,
        style: const TextStyle(color: onSecondaryColor, fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }

  Widget _itemDetailsContent(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(color: onSecondaryColor, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: onSecondaryColor, fontWeight: FontWeight.w500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}