import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/custom_field_model.dart';

class ItemDetailsBottomSheet extends StatelessWidget {
  final String title;
  final AuctionItem item;
  final CategoryFields? customFields;

  const ItemDetailsBottomSheet({
    super.key,
    required this.title,
    required this.item,
    this.customFields,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: title == "Listed Products" ? 1 : 3,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: onSecondaryColor,
                indicatorColor: primaryColor,
                labelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                tabs: [
                  const Tab(text: 'Item Details'),
                  if (title != "Listed Products") ...[
                    const Tab(text: 'Return Policy'),
                    const Tab(text: 'Warranty Policy'),
                  ],
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _itemDetailsTab(),
                    if (title != "Listed Products") ...[
                      _returnPolicyTab(),
                      _warrantyPolicyTab(),
                    ],
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
        const SizedBox(height: 10),
        // // Add location information at the top
        // if (item.itemLocation != null) ...[
        //   _buildFieldCard(
        //     label: 'Location',
        //     value: '${item.itemLocation?.city}, ${item.itemLocation?.country}',
        //   ),
        //   const SizedBox(height: 10),
        // ],
        ..._buildCustomFieldsContent()
      ],
    );
  }

  // Helper function to format field value
  String formatFieldValue(String field, dynamic value, {String? type}) {
    if (value == null) return '';

    // Handle array type fields
    if (type == 'array' && value is! List) {
      value = [value];
    }

    // Format based on field key
    switch (field.toLowerCase()) {
      case 'screensize':
        return '$value inches';
      case 'ramsize':
        return '$value GB';
      case 'totalarea':
        return '$value sqm';
      case 'age':
        return '$value years';
      case 'usagestatus':
        return value.toString().split('_').map((word) => 
          word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase()
        ).join(' ');
      default:
        if (value is List) {
          return value.join(', ');
        }
        return value.toString();
    }
  }

  List<Widget> _buildCustomFieldsContent() {
    // Get product data from the item
    final Map<String, dynamic>? product = item.product;
    if (product == null) return [];

    // Create a list to store field widgets
    final List<Widget> fieldWidgets = [];

    // Get system fields from customFields
    final systemFields = customFields;
    if (systemFields != null) {
      print('Building fields from: ${systemFields.fields}');
      
      // Process each field from system fields
      for (final field in systemFields.fields) {
        // Skip if the field has no value
        if (field.value == null) continue;
        
        print('Processing field: ${field.key} with value: ${field.value}');

        // Format the field value based on type and key
        final formattedValue = formatFieldValue(
          field.key,
          field.value,
          type: field.type,
        );

        // Add field card widget
        fieldWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: _buildFieldCard(
              label: field.labelEn,
              value: formattedValue,
            ),
          ),
        );
      }
    }
    return fieldWidgets;
  }

  Widget _buildFieldCard({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: onSecondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              color: onSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _returnPolicyTab() {
    final String? returnPolicy = item.returnPolicyDescription;

    bool isPlaceholder = returnPolicy == null || returnPolicy.trim().isEmpty;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: isPlaceholder
          ? const Center(
              child: Text(
                'No return policy has been specified for this item.',
                style: TextStyle(
                  fontSize: 12,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                returnPolicy,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 12,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  Widget _warrantyPolicyTab() {
    final String? warrantyPolicy = item.warrantyPolicyDescription;

    bool isPlaceholder =
        warrantyPolicy == null || warrantyPolicy.trim().isEmpty;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: isPlaceholder
          ? const Center(
              child: Text(
                'No warranty policy has been specified for this item.',
                style: TextStyle(
                  fontSize: 12,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                warrantyPolicy,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 12,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  // Widget _itemDetailsTitle() {
  //   return const Padding(
  //     padding: EdgeInsets.symmetric(vertical: 8),
  //     child: Center(
  //       child: Text(
  //         'About The Brand',
  //         style: TextStyle(
  //             fontSize: 12,
  //             fontWeight: FontWeight.w600,
  //             color: onSecondaryColor),
  //       ),
  //     ),
  //   );
  // }

  // Widget _itemDetailsAbout(String value) {
  //   return Center(
  //     child: Text(
  //       value,
  //       style: const TextStyle(
  //           color: onSecondaryColor, fontWeight: FontWeight.w500, fontSize: 11),
  //     ),
  //   );
  // }
}
