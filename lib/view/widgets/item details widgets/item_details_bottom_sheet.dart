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
        // _itemDetailsTitle(),
        // _itemDetailsAbout(item.description),
        const SizedBox(height: 10),
        ..._buildCustomFieldsContent()
      ],
    );
  }

  List<Widget> _buildCustomFieldsContent() {
    // Get product data from the item
    final product = item.product;
    if (product == null) return [];

    // Get relevant fields based on subcategory
    final List<String> relevantFields;
    switch (item.categoryId) {
      // Cars category
      case 4:
        relevantFields = [
          'carType',
          'color',
          'brand',
          'model',
        ];
        break;

      default:
        switch (item.subCategoryId) {
          // Laptops subcategory
          case 2:
            relevantFields = [
              'screenSize',
              'operatingSystem',
              'releaseYear',
              'ramSize',
              'processor',
              'brand',
              'model',
              'color',
              'graphicCard'
            ];
            break;

          // Cameras & photos
          case 3:
            relevantFields = [
              'releaseYear',
              'color',
              'regionOfManufacture',
              'cameraType',
              'brand',
              'model'
            ];
            break;

          // Smart Phones
          case 5:
            relevantFields = [
              'screenSize',
              'operatingSystem',
              'releaseYear',
              'color',
              'brand',
              'model',
              'memory',
              'regionOfManufacture'
            ];
            break;

          // Accessories
          case 6:
            relevantFields = ['color', 'type', 'material', 'brand', 'model'];
            break;

          // TVs & Audios
          case 4:
            relevantFields = [
              'screenSize',
              'releaseYear',
              'color',
              'regionOfManufacture',
              'brand',
              'model'
            ];
            break;

          // Home Appliances
          case 1:
            relevantFields = ['age', 'model', 'brand', 'color'];
            break;

          default:
            relevantFields = [];
        }
    }

    // Define the fields to display
    Map<String, dynamic> fields = {};

    // Helper function to format field value
    String formatFieldValue(String key, dynamic value) {
      if (value == null) return 'Not specified';

      switch (key) {
        case 'screenSize':
          return '$value inches';
        case 'ramSize':
          return '$value GB';
        case 'memory':
          return value.toString(); // May already include GB
        case 'color':
          if (value is List) {
            return value.join(', ');
          }
          return value.toString();
        case 'brand':
          return value.toString();
        case 'releaseYear':
        // case 'year':
          return value.toString();
        case 'age':
          return '$value years';
        default:
          return value.toString();
      }
    }

    // Add fields that are relevant for this subcategory
    for (var field in relevantFields) {
      if (product[field] != null) {
        String label;
        switch (field) {
          case 'screenSize':
            label = 'Screen Size';
            break;
          case 'operatingSystem':
            label = 'Operating System';
            break;
          case 'releaseYear':
            label = 'Release Year';
            break;
          case 'ramSize':
            label = 'RAM';
            break;
          case 'regionOfManufacture':
            label = 'Region of Manufacture';
            break;
          case 'graphicCard':
            label = 'Graphics Card';
            break;
          case 'carType':
            label = 'Car Type';
            break;
          case 'brand':
            label = 'Brand';
            break;
          case 'model':
            label = 'Model';
            break;
          case 'year':
            label = 'Year';
            break;
          case 'mileage':
            label = 'Mileage';
            break;
          case 'color':
            label = 'Color';
            break;
          case 'transmission':
            label = 'Transmission';
            break;
          case 'fuelType':
            label = 'Fuel Type';
            break;
          case 'bodyType':
            label = 'Body Type';
            break;
          case 'cylinders':
            label = 'Cylinders';
            break;
          case 'doors':
            label = 'Doors';
            break;
          case 'regionalSpecs':
            label = 'Regional Specs';
            break;
          case 'condition':
            label = 'Condition';
            break;
          case 'cameraType':
            label = 'Camera Type';
            break;
          default:
            // Capitalize first letter of each word
            label = field
                .split(RegExp(r'(?=[A-Z])'))
                .map((e) => e.substring(0, 1).toUpperCase() + e.substring(1))
                .join(' ');
        }
        fields[label] = formatFieldValue(field, product[field]);
      }
    }

    // If no fields to display, return empty list
    if (fields.isEmpty) return [];

    // Convert fields into pairs for grid layout
    return fields.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6), // Consistent spacing
        child: _buildFieldCard(label: entry.key, value: entry.value.toString()),
      );
    }).toList();
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
