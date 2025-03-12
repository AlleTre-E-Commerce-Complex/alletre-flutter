// ignore_for_file: avoid_print

import 'package:alletre_app/services/api/category_api_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/model/custom_field_model.dart';
import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/services/custom_fields_service.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/controller/providers/auction_provider.dart';
import 'package:alletre_app/controller/providers/contact_provider.dart';
import 'package:alletre_app/controller/providers/wishlist_provider.dart';
import 'package:alletre_app/view/widgets/auction%20card%20widgets/image_carousel.dart';
import 'package:share_plus/share_plus.dart';
import '../../widgets/auction card widgets/auction_countdown.dart';
import '../image_view/full_screen_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsScreen extends StatelessWidget {
  final AuctionItem item;
  final UserModel user;
  final String title;

  ItemDetailsScreen({
    super.key,
    required this.item,
    required this.user,
    required this.title,
  });

  final ValueNotifier<bool> _isBuyNowTapped = ValueNotifier(false);

  void _showDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DefaultTabController(
          length: 3,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tabs
                  const TabBar(
                    labelColor: primaryColor,
                    unselectedLabelColor: onSecondaryColor,
                    indicatorColor: primaryColor,
                    labelStyle: TextStyle(
                      // Common style for selected tab text
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      // Common style for unselected tab text
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(text: 'Item Details'),
                      Tab(text: 'Return Policy'),
                      Tab(text: 'Warranty Policy'),
                    ],
                  ),

                  // Tab Content
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
      },
    );
  }

// Tab Content Widgets
  Widget _itemDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _itemDetailsTitle(),
        _itemDetailsAbout(item.description),
        const SizedBox(height: 14),
        _itemDetailsContent(),
      ],
    );
  }

  Widget _returnPolicyTab() {
    return const Center(child: Text('User reviews will be shown here.'));
  }

  Widget _warrantyPolicyTab() {
    return const Center(
        child: Text('Additional information about the product.'));
  }

  Widget _itemDetailsTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'About The Brand',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: onSecondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _itemDetailsAbout(String value) {
    return Center(
        child: Text(value,
            style: const TextStyle(
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 11)));
  }

  Future<Map<String, dynamic>?> _loadItemDetails() async {
    debugPrint('🔍 Loading details for item: ${item.title}');
    debugPrint('📂 Category ID: ${item.categoryId}');

    try {
      // First, fetch subcategories for this category
      debugPrint('🔄 Fetching subcategories for category: ${item.categoryId}');
      final subCategoriesResponse = await http.get(
        Uri.parse(
            'https://www.alletre.com/api/categories/${item.categoryId}/subcategories'),
      );

      if (subCategoriesResponse.statusCode == 200) {
        CategoryService.initializeSubCategories(subCategoriesResponse.body);
      }

      // Get subcategory name after initialization
      final subCategoryName =
          CategoryService.getSubCategoryName(item.subCategoryId);
      debugPrint('✅ Found subcategory: $subCategoryName');

      // Fetch custom fields
      debugPrint(
          '🔄 Fetching custom fields for subcategory: ${item.subCategoryId}');
      final customFields =
          await CustomFieldsService.getCustomFieldsBySubcategory(
              item.subCategoryId.toString());

      // For Electronics category, ensure all required fields are present
      if (item.categoryId == 1) {
        final requiredFields = [
          CustomField(
            id: 1,
            subCategoryId: item.subCategoryId,
            key: 'brand',
            resKey: 'brand',
            type: 'text',
            labelAr: 'العلامة التجارية',
            labelEn: 'Brand',
            isRequired: true,
          ),
          CustomField(
            id: 2,
            subCategoryId: item.subCategoryId,
            key: 'model',
            resKey: 'model',
            type: 'text',
            labelAr: 'الموديل',
            labelEn: 'Model',
            isRequired: true,
          ),
          CustomField(
            id: 3,
            subCategoryId: item.subCategoryId,
            key: 'screenSize',
            resKey: 'screen_size',
            type: 'number',
            labelAr: 'حجم الشاشة',
            labelEn: 'Screen Size',
            unit: 'inches',
          ),
          CustomField(
            id: 4,
            subCategoryId: item.subCategoryId,
            key: 'operatingSystem',
            resKey: 'operating_system',
            type: 'text',
            labelAr: 'نظام التشغيل',
            labelEn: 'Operating System',
          ),
          CustomField(
            id: 5,
            subCategoryId: item.subCategoryId,
            key: 'releaseYear',
            resKey: 'release_year',
            type: 'number',
            labelAr: 'سنة الإصدار',
            labelEn: 'Release Year',
            validation: 'year',
          ),
          CustomField(
            id: 6,
            subCategoryId: item.subCategoryId,
            key: 'ramSize',
            resKey: 'ram_size',
            type: 'number',
            labelAr: 'حجم الذاكرة',
            labelEn: 'RAM Size',
            unit: 'GB',
          ),
          CustomField(
            id: 7,
            subCategoryId: item.subCategoryId,
            key: 'processor',
            resKey: 'processor',
            type: 'text',
            labelAr: 'المعالج',
            labelEn: 'Processor',
          ),
          CustomField(
            id: 8,
            subCategoryId: item.subCategoryId,
            key: 'graphicCard',
            resKey: 'graphic_card',
            type: 'text',
            labelAr: 'كرت الشاشة',
            labelEn: 'Graphic Card',
          ),
          CustomField(
            id: 9,
            subCategoryId: item.subCategoryId,
            key: 'color',
            resKey: 'color',
            type: 'select',
            labelAr: 'اللون',
            labelEn: 'Color',
            isArray: true,
          ),
        ];

        // Add any missing required fields
        for (final field in requiredFields) {
          if (!customFields.fields
              .any((f) => f.key.toLowerCase() == field.key.toLowerCase())) {
            customFields.fields.add(field);
          }
        }
      }

      debugPrint(
          '📋 Available custom fields: ${customFields.fields.map((f) => f.labelEn).join(', ')}');

      // Fetch auction details
      debugPrint('🎯 Fetching auction details');
      final response = await http.get(
        Uri.parse(
            'https://www.alletre.com/api/auctions/user/${item.id}/details'),
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        debugPrint('📦 Auction details received: $responseJson');

        if (responseJson['success'] == true && responseJson['data'] != null) {
          final data = responseJson['data'] as Map<String, dynamic>;
          final product = data['product'] as Map<String, dynamic>?;

          // Extract custom fields from product data
          final customFieldValues = <String, dynamic>{};
          if (product != null) {
            // Add model if available
            if (product['model'] != null) {
              customFieldValues['model'] = product['model'];
            }

            // Add brand if available
            if (product['brand'] != null) {
              customFieldValues['brand'] = product['brand'];
            }

            // Add other custom fields if present
            final productCustomFields =
                product['customFields'] as Map<String, dynamic>?;
            if (productCustomFields != null) {
              customFieldValues.addAll(productCustomFields);
            }
          }

          return {
            'subCategoryName': subCategoryName,
            'customFields': customFields.fields,
            'filledValues': customFieldValues,
          };
        }
      }
    } catch (e, stackTrace) {
      debugPrint('⚠️ Error loading item details: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    return null;
  }

  String _formatFieldValue(CustomField field, dynamic value) {
    if (value == null) return '';

    // Handle array fields first
    if (field.isArray) {
      if (field.key.toLowerCase().contains('color') ||
          field.labelEn.toLowerCase().contains('color')) {
        // Convert array or comma-separated string to formatted list
        final colors = value is List ? value : value.toString().split(',');
        return colors
            .map((c) => c.toString().trim())
            .where((c) => c.isNotEmpty)
            .join(', ');
      }
      return value is List ? value.join(', ') : value.toString();
    }

    switch (field.type.toLowerCase()) {
      case 'number':
        final number = double.tryParse(value.toString());
        if (number != null) {
          // Format based on field's unit or validation type
          if (field.unit?.toLowerCase() == 'gb') {
            return '${number.toStringAsFixed(0)} GB';
          } else if (field.unit?.toLowerCase() == 'inches') {
            return '${number.toStringAsFixed(1)}"';
          } else if (field.validation == 'year') {
            final year = number.toInt();
            // Validate year is between 1900 and next year
            final currentYear = DateTime.now().year;
            if (year >= 1900 && year <= currentYear + 1) {
              return year.toString();
            }
            return 'Invalid Year';
          }
          // For other numeric fields, show decimals only if needed
          return number
              .toStringAsFixed(number.truncateToDouble() == number ? 0 : 1);
        }
        return value.toString();

      case 'text':
        final text = value.toString().trim();
        // Special handling for required fields
        if (field.isRequired && text.isEmpty) {
          return 'Not Specified';
        }
        return text;

      case 'select':
        return value.toString().trim();

      default:
        return value.toString().trim();
    }
  }

  Widget _itemDetailsContent() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadItemDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        }

        if (snapshot.hasError) {
          debugPrint('⚠️ Error in FutureBuilder: ${snapshot.error}');
          return const SizedBox.shrink(); // Hide section on error
        }

        final data = snapshot.data;
        final customFields = data?['customFields'] as List<CustomField>?;
        final filledValues = data?['filledValues'] as Map<String, dynamic>?;
        final subCategoryName = data?['subCategoryName'] as String?;

        // Early return if no custom fields
        if (customFields == null ||
            filledValues == null ||
            customFields.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subCategoryName != null && subCategoryName.isNotEmpty)
                _buildDetailRow('Category:', subCategoryName),
            ],
          );
        }

        // Sort fields based on our memory of field order for Electronics category
        final fieldOrder = [
          // Required text fields first
          'brand', // Required text field
          'model', // Required text field
          // Number fields with units
          'screen size', // Number field with inches unit
          'ram size', // Number field with GB unit
          // Validation fields
          'release year', // Number field with year validation
          // Regular text fields
          'operating system', // Text field
          'processor', // Text field
          'graphic card', // Text field
          'region of manufacture', // Text field
          // Array fields last
          'color', // Array of strings
        ];

        final sortedFields = List<CustomField>.from(customFields)
          ..sort((a, b) {
            // First, prioritize required fields
            if (a.isRequired != b.isRequired) {
              return a.isRequired ? -1 : 1;
            }

            // Then sort by field type groups and predefined order
            final aIndex = fieldOrder.indexWhere((name) =>
                a.key.toLowerCase().contains(name) ||
                a.labelEn.toLowerCase().contains(name));
            final bIndex = fieldOrder.indexWhere((name) =>
                b.key.toLowerCase().contains(name) ||
                b.labelEn.toLowerCase().contains(name));

            if (aIndex == -1 && bIndex == -1) {
              // If neither field is in the order list, sort by field type priority
              final typeOrder = ['text', 'number', 'select'];
              final aTypeIndex = typeOrder.indexOf(a.type.toLowerCase());
              final bTypeIndex = typeOrder.indexOf(b.type.toLowerCase());
              if (aTypeIndex != bTypeIndex) {
                return aTypeIndex.compareTo(bTypeIndex);
              }
              // Within same type, sort alphabetically by English label
              return a.labelEn.toLowerCase().compareTo(b.labelEn.toLowerCase());
            }
            if (aIndex == -1) return 1;
            if (bIndex == -1) return -1;
            return aIndex.compareTo(bIndex);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show subcategory if available
            // if (subCategoryName != null && subCategoryName.isNotEmpty)
            //   _buildDetailRow('Category:', subCategoryName),

            // Show all fields in sorted order
            ...sortedFields
                .where((field) => filledValues[field.key] != null)
                .map((field) {
              final value = filledValues[field.key];
              return _buildDetailRow(
                '${field.labelEn}:',
                _formatFieldValue(field, value),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin:
          const EdgeInsets.symmetric(vertical: 4), // Adds spacing between rows
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Light grey background
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
                color: onSecondaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
                color: onSecondaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryInfo(BuildContext context) {
    return FutureBuilder<void>(
      // First load the subcategories
      future: CategoryApiService.initSubCategories(item.categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: primaryColor));
        }

        final categoryName = CategoryService.getCategoryName(item.categoryId);
        final subCategoryName =
            CategoryService.getSubCategoryName(item.subCategoryId);

        print(
            'Building category info - Category: $categoryName, Subcategory: $subCategoryName');
        print(
            'Category ID: ${item.categoryId}, Subcategory ID: ${item.subCategoryId}');

        return Column(
          children: [
            // Category box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: avatarColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: onSecondaryColor, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: onSecondaryColor,
                        fontSize: 13),
                    softWrap: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Sub Category box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: avatarColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sub Category',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: onSecondaryColor, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    subCategoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: onSecondaryColor,
                        fontSize: 13),
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedAuctionCountdown(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: avatarColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuctionCountdown(
            startDate: item.startDate,
            endDate: item.expiryDate,
            customPrefix: 'Time Left',
            prefixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: onSecondaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidSection(
      BuildContext context, String title, AuctionItem item) {
    if (title == 'Listed Products') {
      return Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: Consumer<ContactButtonProvider>(
              builder: (context, contactProvider, child) {
                return contactProvider.isShowingContactButtons(item.id)
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final message = Uri.encodeComponent(
                                    "Hello, I would like to inquire about your product listed on Alletre.");
                                final whatsappUrl =
                                    "https://wa.me/${user.phoneNumber}?text=$message";
                                launchUrl(Uri.parse(whatsappUrl));
                              },
                              icon: const Icon(FontAwesomeIcons.whatsapp,
                                  color: secondaryColor),
                              label: Text('Chat',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: secondaryColor, fontSize: 16)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'Contact Number',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'You can connect on',
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Text(
                                              user.phoneNumber,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              "Don't forget to mention Alletre when you call",
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontStyle: FontStyle.italic,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        secondaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      side: const BorderSide(
                                                          color: primaryColor),
                                                    ),
                                                  ),
                                                  child: const Text('Close'),
                                                ),
                                                const SizedBox(width: 8),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final url =
                                                        'tel:${user.phoneNumber}';
                                                    launchUrl(Uri.parse(url));
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        secondaryColor,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      side: const BorderSide(
                                                          color: primaryColor),
                                                    ),
                                                  ),
                                                  child: const Text('Call Now'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.call, color: primaryColor),
                              label: Text(
                                'Call',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: primaryColor, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: secondaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  side: const BorderSide(color: primaryColor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ElevatedButton(
                        onPressed: () {
                          contactProvider.toggleContactButtons(item.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'View Contact Details',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: secondaryColor, fontSize: 16),
                        ),
                      );
              },
            ),
          ),
        ],
      );
    }

    final ValueNotifier<String> bidAmount = ValueNotifier<String>(
      item.currentBid.isEmpty ? item.startBidAmount : item.currentBid,
    );

    final String minimumBid =
        item.currentBid.isEmpty ? item.startBidAmount : item.currentBid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bid Amount Input
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: onSecondaryColor, width: 1.4),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: bidAmount,
                builder: (context, value, child) {
                  final bool canDecrease =
                      double.parse(value) > double.parse(minimumBid);
                  return Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: canDecrease
                          ? primaryColor
                          : primaryColor.withAlpha(128),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.remove,
                          color: secondaryColor, size: 15),
                      onPressed: canDecrease
                          ? () {
                              final currentValue = double.parse(value);
                              bidAmount.value = (currentValue - 50).toString();
                            }
                          : null,
                    ),
                  );
                },
              ),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: bidAmount,
                  builder: (context, value, child) {
                    return Text(
                      'AED ${NumberFormat.decimalPattern().format(double.parse(value))}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: onSecondaryColor,
                          fontSize: 15),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: secondaryColor, size: 15),
                  onPressed: () {
                    final currentValue = double.parse(bidAmount.value);
                    bidAmount.value = (currentValue + 50).toString();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Submit Bid Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // Handle bid submission
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Submit Bid',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: secondaryColor, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: avatarColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: onSecondaryColor, fontSize: 13),
          ),
          const SizedBox(height: 3),
          Center(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    if (item.status == 'LIVE') {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: (0.1 * 255)),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Implement bid now functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Bid Now'),
              ),
            ),
            if (item.hasBuyNow) ...[
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // Implement buy now functionality
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Buy Now'),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String getDisplayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'ACTIVE';
      case 'IN_SCHEDULED':
        return 'SCHEDULED';
      case 'EXPIRED':
        return 'EXPIRED';
      case 'WAITING_FOR_PAYMENT':
        return 'SOLD';
      default:
        return 'Unknown';
    }
  }

  Color getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return activeColor;
      case 'IN_SCHEDULED':
        return scheduledColor;
      case 'EXPIRED':
        return const Color(0xFF9E9E9E);
      case 'WAITING_FOR_PAYMENT':
        return errorColor;
      default:
        return const Color(0xFF757575);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle joining/leaving auction room in build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auctionProvider =
          Provider.of<AuctionProvider>(context, listen: false);
      auctionProvider.joinAuctionRoom(item.id.toString());
    });

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(item.title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ),
        actions: [
          // Wishlist button
          if (title != 'Listed Products')
            Consumer<WishlistProvider>(
              builder: (context, wishlistProvider, child) {
                final isInWishlist = wishlistProvider.isWishlisted(item.id);
                return IconButton(
                  icon: Icon(
                      isInWishlist ? Icons.bookmark : FontAwesomeIcons.bookmark,
                      color: isInWishlist ? primaryColor : null,
                      size: 18),
                  onPressed: () => wishlistProvider.toggleWishlist(item),
                  padding: const EdgeInsets.only(right: 2),
                  constraints: const BoxConstraints(),
                );
              },
            ),
          // Share button
          IconButton(
            icon: const Icon(FontAwesomeIcons.shareFromSquare, size: 18),
            onPressed: () {
              final String itemUrl =
                  'https://alletre.com/items/${item.id}'; // Replace with your actual domain
              Share.share(
                'Check out this ${title.toLowerCase()}: ${item.title}\n'
                '${title == "Listed Products" ? "Price" : "Starting bid"}: AED ${item.startBidAmount}\n'
                '${title != "Listed Products" ? "Current bid: AED ${item.currentBid}\n" : ""}'
                '$itemUrl',
                subject: title == "Listed Products"
                    ? 'Interesting Product on Alletre'
                    : 'Interesting Auction on Alletre',
              );
            },
            padding: const EdgeInsets.only(right: 16),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: PopScope(
        canPop: true,
        // ignore: deprecated_member_use
        onPopInvoked: (didPop) {
          if (didPop) {
            final auctionProvider =
                Provider.of<AuctionProvider>(context, listen: false);
            auctionProvider.leaveAuctionRoom(item.id.toString());
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image carousel
              SizedBox(
                height: 300,
                child: ImageCarousel(
                  images: item.imageLinks,
                  onImageTap: (index) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImageView(
                          imageUrls: item.imageLinks,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Item details section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Text(
                      item.title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 15),

                    //Status
                    if (title != 'Listed Products') ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: getStatusColor(item.status).withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          getDisplayStatus(item.status),
                          style: TextStyle(
                            fontSize: 8,
                            color: getStatusColor(item.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],

                    // View Details Button
                    TextButton.icon(
                      onPressed: () => _showDetailsBottomSheet(context),
                      icon: const Icon(Icons.info_outline, size: 14),
                      label: Text(
                        'View Details',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 11),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description
                    Text(
                      'Description',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 16),

                    // Category and Subcategory
                    _buildCategoryInfo(context),
                    const SizedBox(height: 22),

                    // Time and Bids
                    if (title != 'Listed Products' &&
                        title != 'Expired Auctions') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildInfoCard(
                            context,
                            'Total Bids',
                            item.bids.toString(),
                          ),
                          const Spacer(),
                          _buildEnhancedAuctionCountdown(context),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (title == 'Live Auctions' ||
                              title == 'Upcoming Auctions')
                            Expanded(
                              // width: MediaQuery.of(context).size.width * 0.5,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: avatarColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Current Bid',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: onSecondaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                    ),
                                    const SizedBox(
                                        height:
                                            5), // Spacing between title and value
                                    Center(
                                      child: Text(
                                        'AED ${NumberFormat.decimalPattern().format(double.tryParse(item.currentBid) ?? 0.0)}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: primaryColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (title == 'Listed Products')
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: avatarColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Selling Price',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: onSecondaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                  ),
                                  const SizedBox(
                                      width:
                                          8), // Spacing between title and value
                                  Center(
                                    child: Text(
                                      'AED ${item.productListingPrice}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            color: primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (item.hasBuyNow) ...[
                            const SizedBox(width: 15),
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                  valueListenable: _isBuyNowTapped,
                                  builder: (context, isTapped, child) {
                                    return InkWell(
                                      onTap: () {
                                        _isBuyNowTapped.value = true;
                                        Future.delayed(
                                            const Duration(milliseconds: 100),
                                            () {
                                          _isBuyNowTapped.value = false;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(6),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: primaryColor, width: 1.5),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Buy Now',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    color: onSecondaryColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                  ),
                                            ),
                                            const SizedBox(
                                                height:
                                                    5), // Spacing between title and value
                                            Center(
                                              child: Text(
                                                'AED ${item.buyNowPrice}',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleLarge
                                                    ?.copyWith(
                                                      color: primaryColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 12,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (title == 'Listed Products') ...[
                      // Location section
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 30,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (item.itemLocation != null &&
                                        item.itemLocation?.address != null) ...[
                                      Text(
                                        item.itemLocation?.address ??
                                            'Address not available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${item.itemLocation?.city ?? 'Unknown city'}, ${item.itemLocation?.country ?? 'Unknown country'}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                      ),
                                    ] else
                                      Text(
                                        'Location not available',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              if (item.itemLocation?.lat != null &&
                                  item.itemLocation?.lng != null) {
                                launchUrl(Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=${item.itemLocation!.lat},${item.itemLocation!.lng}'));
                              }
                            },
                            child: Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: avatarColor),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Stack(
                                  children: [
                                    if (item.itemLocation?.lat != null &&
                                        item.itemLocation?.lng != null)
                                      Image.network(
                                        'https://maps.googleapis.com/maps/api/staticmap?center=${item.itemLocation?.lat},${item.itemLocation?.lng}&zoom=15&size=600x300&maptype=roadmap&markers=color:red%7C${item.itemLocation?.lat},${item.itemLocation?.lng}&key=AIzaSyB9ATxmePBJdgRl8mq4D1ahCRxHy99IFqg',
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Center(
                                            child: Icon(Icons.map,
                                                size: 50, color: Colors.grey),
                                          );
                                        },
                                      )
                                    else
                                      const Center(
                                        child: Icon(Icons.map,
                                            size: 50, color: Colors.grey),
                                      ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.open_in_new,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .primaryColor),
                                            const SizedBox(width: 4),
                                            Text('View Larger Map',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),
                    _buildBidSection(context, title, item),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }
}
