// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'dart:convert';
import 'package:alletre_app/controller/helpers/image_picker_helper.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/model/custom_field_model.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/create_auction_validators.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import 'package:alletre_app/controller/providers/user_provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/home widgets/categories widgets/categories_data.dart';
import 'auction_details_screen.dart';
import 'shipping_details_screen.dart';
import 'package:alletre_app/utils/ui_helpers.dart';
import 'package:alletre_app/controller/helpers/auction_service.dart';
import 'drafts_page.dart';
import 'package:alletre_app/controller/services/auction_details_service.dart';
import 'package:alletre_app/services/custom_fields_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProductDetailsScreen extends StatelessWidget {
  final String title;
  final AuctionItem? draftAuction;
  const ProductDetailsScreen(
      {super.key, this.title = 'Create Auction', this.draftAuction});

  @override
  Widget build(BuildContext context) {
    // Add a ValueNotifier to track whether the form has been submitted
    final isSubmitted = ValueNotifier<bool>(false);
    final isSavingDraft = ValueNotifier<bool>(false); // Add loading state
    final formKey = GlobalKey<FormState>();
    final itemNameController = TextEditingController();
    final priceController = TextEditingController();
    final categoryController = ValueNotifier<String?>(null);
    final subCategoryController = ValueNotifier<String?>(null);
    final descriptionController = TextEditingController();
    final condition = ValueNotifier<String?>(null);
    final media = ValueNotifier<List<File>>([]);
    final coverPhotoIndex =
        ValueNotifier<int?>(null); // Track selected cover photo

    // Dynamic Custom Fields State
    final ValueNotifier<List<CustomField>> dynamicCustomFields =
        ValueNotifier([]);
    final customFieldControllers = <String, TextEditingController>{};
    final customFieldDropdownValues = <String, ValueNotifier<String?>>{};

    // Helper to pre-fill custom fields from draft
    void prefillCustomFields(Map<String, dynamic>? customFields) {
      if (customFields == null) return;
      customFields.forEach((key, value) {
        if (customFieldControllers.containsKey(key)) {
          customFieldControllers[key]!.text = value?.toString() ?? '';
        }
        if (customFieldDropdownValues.containsKey(key)) {
          customFieldDropdownValues[key]!.value = value?.toString();
        }
      });
    }

    // Helper to parse Dart-style map string to Map<String, dynamic>
    Map<String, dynamic> parseDartMapString(String input) {
      // Remove curly braces if present
      String trimmed = input.trim();
      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        trimmed = trimmed.substring(1, trimmed.length - 1);
      }
      // Split by comma, then by colon
      final Map<String, dynamic> result = {};
      for (final pair in trimmed.split(',')) {
        final kv = pair.split(':');
        if (kv.length == 2) {
          final key = kv[0].trim();
          final value = kv[1].trim();
          // Try to parse numbers, else keep as string
          final numValue = num.tryParse(value);
          result[key] = numValue ?? value;
        }
      }
      return result;
    }

    // Helper to extract custom fields from product map based on dynamic field keys
    Map<String, dynamic> extractCustomFieldsFromProduct(
        Map<String, dynamic> product, List<CustomField> dynamicFields) {
      final Map<String, dynamic> result = {};
      for (final field in dynamicFields) {
        if (product.containsKey(field.key)) {
          result[field.key] = product[field.key];
        }
      }
      return result;
    }

    // Fetch fields dynamically when category/subcategory changes
    Future<void> fetchAndSetupCustomFields(
        {int? categoryId,
        int? subCategoryId,
        Map<String, dynamic>? prefillFields,
        Map<String, dynamic>? product}) async {
      List<CustomField> fields = [];
      if (subCategoryId != null) {
        final categoryFields =
            await CustomFieldsService.getCustomFieldsBySubcategory(
                subCategoryId.toString());
        fields = categoryFields.fields;
      } else if (categoryId != null) {
        final categoryFields =
            await CustomFieldsService.getCustomFieldsByCategory(
                categoryId.toString());
        fields = categoryFields.fields;
      }
      dynamicCustomFields.value = fields;

      // Debug: Print the incoming product map
      debugPrint('🟩 Incoming product map:');
      debugPrint(product?.toString() ?? 'null');

      // Debug: Print the list of dynamic custom field keys
      debugPrint('🟩 Dynamic custom field keys:');
      for (final field in fields) {
        debugPrint('Field key: ${field.key}, type: ${field.type}');
      }

      // Setup controllers/notifiers for each field
      for (final field in fields) {
        if (field.type == 'dropdown') {
          customFieldDropdownValues[field.key] = ValueNotifier<String?>(null);
        } else {
          customFieldControllers[field.key] = TextEditingController();
          // Debug: Print the value being assigned to the controller (from product if available)
          final value = product != null ? product[field.key] : null;
          debugPrint('🟦 Creating controller for ${field.key} with value: $value');
        }
      }

      // If prefillFields is null but product is present, extract from product
      if (prefillFields == null && product != null) {
        prefillFields = extractCustomFieldsFromProduct(product, fields);
        debugPrint('🟦 Extracted custom fields from product: $prefillFields');
      }
      // Pre-fill if fields are provided
      if (prefillFields != null) {
        debugPrint('⭐️⭐️Prefilling with: $prefillFields');
        prefillCustomFields(prefillFields);
        // Debug: Print values after prefill
        debugPrint('--- Custom Field Prefill Debug ---');
        prefillFields.forEach((key, value) {
          debugPrint('key: $key, value: $value, '
            'controller: \'${customFieldControllers[key]?.text}\', '
            'dropdown: \'${customFieldDropdownValues[key]?.value}\'');
        });
      }
      // Debug: Print all controllers and dropdowns after setup
      debugPrint('--- Custom Field Controllers After Setup ---');
      customFieldControllers.forEach((key, controller) {
        debugPrint('controller for $key: ${controller.text}');
      });
      customFieldDropdownValues.forEach((key, notifier) {
        debugPrint('dropdown for $key: ${notifier.value}');
      });
    }

    // Helper function to download image from URL and save as local file
    Future<File> _downloadImage(String url) async {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Get temporary directory
        final tempDir = await getTemporaryDirectory();
        // Create a unique filename
        final filename = path.basename(url).split('?')[0];
        final file = File('${tempDir.path}/$filename');
        // Write the downloaded bytes to the file
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    }

    // If draftAuction is provided, pre-fill controllers and custom fields
    Future<void> getSetupFieldsFuture() async {
      if (draftAuction != null) {
        // Set initial values immediately
        itemNameController.text = draftAuction!.title;
        priceController.text = draftAuction!.price.toString();
        descriptionController.text = draftAuction!.description;
        categoryController.value = draftAuction!.categoryName;
        subCategoryController.value = draftAuction!.subCategoryName;
        condition.value = draftAuction!.usageStatus.toLowerCase();

        // Start loading images and custom fields in parallel
        final futures = <Future>[
          // Download images
          () async {
            final List<File> downloadedFiles = [];
            for (final url in draftAuction!.imageLinks) {
              try {
                final file = await _downloadImage(url);
                downloadedFiles.add(file);
              } catch (e) {
                debugPrint('Error downloading image: $e');
              }
            }
            media.value = downloadedFiles;
          }(),
          // Fetch custom fields
          fetchAndSetupCustomFields(
            categoryId: draftAuction!.categoryId,
            subCategoryId: draftAuction!.subCategoryId,
            prefillFields: draftAuction!.customFields is Map<String, dynamic>
                ? draftAuction!.customFields as Map<String, dynamic>
                : (draftAuction!.customFields is String &&
                        draftAuction!.customFields != null)
                    ? parseDartMapString(draftAuction!.customFields as String)
                    : null,
            product: draftAuction!.product,
          ),
        ];

        // Wait for all operations to complete
        await Future.wait(futures);
      } else {
        return fetchAndSetupCustomFields();
      }
    }

    // Get categories list
    final categories = CategoryData.categories;

    // Define consistent label text style
    const labelTextStyle = TextStyle(fontSize: 14);

    Future<bool> validateForm() async {
      if (!formKey.currentState!.validate()) {
        return false;
      }

      // Validate media section separately since it's async
      final mediaError =
          await CreateAuctionValidation.validateMediaSection(media.value);
      if (mediaError != null) {
        showError(context, mediaError);
        return false;
      }

      // Validate form including dropdown fields
      bool isDropdownsValid = true;
      customFieldDropdownValues.forEach((key, notifier) {
        if (notifier.value == null) {
          isDropdownsValid = false;
        }
      });

      if (!isDropdownsValid) {
        showError(context, 'Please fill in all dropdown fields');
        return false;
      }

      // Validate condition for non-property items
      if (categoryController.value != "Properties" && condition.value == null) {
        showError(context, 'Please select item condition');
        return false;
      }

      return true;
    }

    return Scaffold(
      appBar: NavbarElementsAppbar(appBarTitle: title, showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: FutureBuilder<void>(
            future: getSetupFieldsFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Form(
                key: formKey,
                child: ListView(
                  children: [
                    const Divider(thickness: 1, color: primaryColor),
                    const Center(
                      child: Text(
                        "Product Details",
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor),
                      ),
                    ),
                    const Divider(thickness: 1, color: primaryColor),
                    const SizedBox(height: 10),
                    const Text(
                      "Item Details",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: onSecondaryColor),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: itemNameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        labelStyle: labelTextStyle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: errorColor),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: errorColor),
                        ),
                      ),
                      validator: CreateAuctionValidation.validateTitle,
                    ),
                    const SizedBox(height: 15),
                    if (title == "List Product")
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Price",
                          labelStyle: labelTextStyle,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: errorColor),
                          ),
                        ),
                        validator: CreateAuctionValidation.validateTitle,
                      ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<String?>(
                      valueListenable: categoryController,
                      builder: (context, selectedCategory, child) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Category",
                            labelStyle: labelTextStyle,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: errorColor),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: errorColor),
                            ),
                          ),
                          value: selectedCategory,
                          items: categories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: onSecondaryColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            categoryController.value = value;
                            subCategoryController.value =
                                null; // Reset subcategory

                            // Clear the custom field controllers when category changes
                            customFieldControllers.forEach((key, controller) {
                              controller.clear();
                            });
                            customFieldControllers.clear();
                            customFieldDropdownValues.clear();

                            // Fetch custom fields for the selected category
                            fetchAndSetupCustomFields(
                                categoryId:
                                    CategoryData.getCategoryId(value ?? ''));
                          },
                          validator: CreateAuctionValidation.validateCategory,
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<String?>(
                      valueListenable: categoryController,
                      builder: (context, selectedCategory, child) {
                        if (selectedCategory == null ||
                            selectedCategory == 'Cars') {
                          return const SizedBox
                              .shrink(); // No subcategory dropdown if category not selected
                        }

                        return ValueListenableBuilder<String?>(
                          valueListenable: subCategoryController,
                          builder: (context, selectedSubCategory, child) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Sub Category",
                                labelStyle: labelTextStyle,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: errorColor),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: errorColor),
                                ),
                              ),
                              value: selectedSubCategory,
                              // ignore: unnecessary_null_comparison
                              items: selectedCategory != null
                                  ? CategoryData.getSubCategories(
                                          selectedCategory)
                                      .map((subcategory) {
                                      return DropdownMenuItem(
                                        value: subcategory,
                                        child: Text(
                                          subcategory,
                                          style: const TextStyle(
                                            color: onSecondaryColor,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      );
                                    }).toList()
                                  : [],
                              onChanged: (value) {
                                subCategoryController.value = value;
                                // Fetch custom fields for the selected subcategory
                                fetchAndSetupCustomFields(
                                    subCategoryId:
                                        CategoryData.getSubCategoryId(
                                            selectedCategory, value ?? ''));
                              },
                              validator:
                                  CreateAuctionValidation.validateSubCategory,
                            );
                          },
                        );
                      },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: categoryController,
                      builder: (context, selectedCategory, _) {
                        if (selectedCategory != 'Cars') {
                          return const SizedBox(height: 16);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Dynamic Custom Fields
                    ValueListenableBuilder<List<CustomField>>(
                      valueListenable: dynamicCustomFields,
                      builder: (context, fields, child) {
                        // Display 2 fields per row using GridView
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio:
                                      4.5, // Adjust for field height
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12),
                          itemCount: fields.length,
                          itemBuilder: (context, index) {
                            final field = fields[index];
                            if (field.type == 'dropdown') {
                              return ValueListenableBuilder<String?>(
                                valueListenable:
                                    customFieldDropdownValues[field.key]!,
                                builder: (context, value, child) {
                                  return DropdownButtonFormField<String>(
                                    value: value,
                                    decoration: InputDecoration(
                                      labelText: field.labelEn.isNotEmpty
                                          ? field.labelEn
                                          : field.key,
                                      labelStyle: const TextStyle(
                                          fontSize: 12), // smaller label
                                    ),
                                    items: field.options
                                        ?.map((option) => DropdownMenuItem(
                                              value: option,
                                              child: Text(option,
                                                  style: const TextStyle(
                                                      fontSize:
                                                          12)), // smaller dropdown text
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      customFieldDropdownValues[field.key]!
                                          .value = newValue;
                                    },
                                    validator: field.isRequired
                                        ? (v) => v == null ? 'Required' : null
                                        : null,
                                  );
                                },
                              );
                            } else {
                              final controller =
                                  customFieldControllers[field.key]!;
                              return TextFormField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: field.labelEn.isNotEmpty
                                      ? field.labelEn
                                      : field.key,
                                  labelStyle: const TextStyle(
                                      fontSize: 12), // smaller label
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                                style: const TextStyle(
                                    fontSize: 12), // smaller input text
                                showCursor: false,
                                keyboardType: field.type == 'number'
                                    ? TextInputType.number
                                    : TextInputType.text,
                                validator: field.isRequired
                                    ? (v) => (v == null || v.isEmpty)
                                        ? 'Required'
                                        : null
                                    : null,
                              );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: "Item Description",
                        labelStyle: labelTextStyle,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: errorColor),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: errorColor),
                        ),
                        errorStyle: const TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      maxLines: 5,
                      validator: CreateAuctionValidation.validateDescription,
                    ),
                    const SizedBox(height: 20),
                    RichText(
                      text: const TextSpan(
                        text: 'Add Media\n',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: onSecondaryColor),
                        children: [
                          TextSpan(
                            text:
                                '(You can upload upto 50 images & 1 video [max 50MB])',
                            style: TextStyle(
                                color: greyColor, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<List<File>>(
                      valueListenable: media,
                      builder: (context, mediaList, child) {
                        // Set the first image as the cover image if no cover photo is set
                        if (coverPhotoIndex.value == null &&
                            mediaList.isNotEmpty) {
                          coverPhotoIndex.value =
                              0; // Default to the first image as cover photo
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: mediaList.length < 5
                                  ? 5 // Initial count
                                  : mediaList.length >= 50
                                      ? 50 // Max limit
                                      : mediaList.length +
                                          1, // Current count + 1 empty slot
                              itemBuilder: (context, index) {
                                // Generate a reordered media list with the cover photo (if set) first
                                final reorderedMediaList = coverPhotoIndex
                                                .value !=
                                            null &&
                                        coverPhotoIndex.value! <
                                            mediaList.length
                                    ? [
                                        mediaList[coverPhotoIndex.value!],
                                        ...mediaList.where((file) =>
                                            file !=
                                            mediaList[coverPhotoIndex.value!])
                                      ]
                                    : mediaList;

                                // Check if this is an existing media item
                                if (index < reorderedMediaList.length) {
                                  return Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          // Open media gallery when image is tapped
                                          final File? newMedia =
                                              await pickMediaFromGallery();
                                          if (newMedia != null) {
                                            final updatedMedia =
                                                List<File>.from(mediaList);
                                            // Replace the correct item in the original list
                                            final originalIndex =
                                                mediaList.indexOf(
                                                    reorderedMediaList[index]);
                                            updatedMedia[originalIndex] =
                                                newMedia;
                                            media.value = updatedMedia;
                                          }
                                        },
                                        child: Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: greyColor),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: _buildMediaWidget(
                                                reorderedMediaList[index]),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: -14,
                                        right: -14,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.cancel,
                                            color: errorColor,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            final updatedMedia =
                                                List<File>.from(mediaList);
                                            // Remove the correct item from the original list
                                            final originalIndex =
                                                mediaList.indexOf(
                                                    reorderedMediaList[index]);
                                            updatedMedia
                                                .removeAt(originalIndex);
                                            media.value = updatedMedia;
                                            if (coverPhotoIndex.value ==
                                                originalIndex) {
                                              coverPhotoIndex.value =
                                                  null; // Reset cover photo
                                            }
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: ValueListenableBuilder<int?>(
                                          valueListenable: coverPhotoIndex,
                                          builder: (context, selectedCoverIndex,
                                              child) {
                                            return GestureDetector(
                                              onTap: () {
                                                coverPhotoIndex.value = index;

                                                // Reorder the media list to display the cover photo first
                                                final File selectedCover =
                                                    mediaList[index];
                                                final updatedMedia = [
                                                      selectedCover
                                                    ] +
                                                    mediaList
                                                        .where((file) =>
                                                            file !=
                                                            selectedCover)
                                                        .toList();
                                                media.value = updatedMedia;

                                                coverPhotoIndex.value =
                                                    0; // Reset the index
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: selectedCoverIndex ==
                                                          index
                                                      ? primaryColor.withAlpha(
                                                          (0.7 * 255).toInt())
                                                      : Colors.black.withAlpha(
                                                          (0.5 * 255).toInt()),
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Center(
                                                  child: Text(
                                                    selectedCoverIndex == index
                                                        ? "Cover Photo"
                                                        : "Set as Cover",
                                                    style: const TextStyle(
                                                      color: secondaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  // Add image button
                                  return GestureDetector(
                                    onTap: () => pickMultipleMedia(media),
                                    child: Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: greyColor),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            color: avatarColor,
                                            size: 32,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            ValueListenableBuilder<bool>(
                              valueListenable: isSubmitted,
                              builder: (context, submitted, child) {
                                if (submitted) {
                                  return FutureBuilder<String?>(
                                    future: CreateAuctionValidation
                                        .validateMediaSection(mediaList),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, left: 12),
                                          child: Text(
                                            snapshot.data!,
                                            style: const TextStyle(
                                              color: errorColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: categoryController,
                      builder: (context, selectedCategory, child) {
                        if (selectedCategory == "Properties") {
                          return const SizedBox(); // Hide item condition for Properties category
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            const Text(
                              "Item Condition",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: onSecondaryColor,
                              ),
                            ),
                            ValueListenableBuilder<String?>(
                              valueListenable: condition,
                              builder: (context, value, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "new",
                                          groupValue: value,
                                          onChanged: (selected) =>
                                              condition.value = selected!,
                                        ),
                                        const Text("New",
                                            style: radioTextStyle),
                                      ],
                                    ),
                                    const SizedBox(width: 20),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "used",
                                          groupValue: value,
                                          onChanged: (selected) =>
                                              condition.value = selected!,
                                        ),
                                        const Text("Used",
                                            style: radioTextStyle),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (title == 'Create Auction') ...[
                              ValueListenableBuilder<bool>(
                                valueListenable: isSavingDraft,
                                builder: (context, isSaving, child) {
                                  return ElevatedButton(
                                    onPressed: isSaving
                                        ? null
                                        : () async {
                                            isSavingDraft.value = true;
                                            isSubmitted.value = true;

                                            // This will trigger the validators and show error messages
                                            final formValid = await validateForm();

                                            if (formValid) {
                                              final customFields = <String, dynamic>{};
                                              for (final field in dynamicCustomFields.value) {
                                                if (field.type == 'dropdown') {
                                                  customFields[field.key] =
                                                      customFieldDropdownValues[field.key]?.value;
                                                } else {
                                                  customFields[field.key] =
                                                      customFieldControllers[field.key]?.text.trim();
                                                }
                                              }

                                              // Filter customFields to remove empty or null values
                                              final filteredCustomFields = <String, dynamic>{
                                                for (final entry in customFields.entries)
                                                  if (entry.value != null && entry.value.toString().trim().isNotEmpty)
                                                    entry.key: entry.value
                                              };

                                              final Map<String, dynamic> productData = {
                                                'title': itemNameController.text.trim(),
                                                'description': descriptionController.text.trim(),
                                                'categoryId': CategoryData.getCategoryId(
                                                        categoryController.value ?? '') ??
                                                    1,
                                                'subCategoryId': CategoryData.getSubCategoryId(
                                                        categoryController.value ?? '',
                                                        subCategoryController.value ?? '') ??
                                                    1,
                                                'usageStatus': condition.value?.toUpperCase() ?? 'UNKNOWN',
                                                ...filteredCustomFields,
                                              };

                                              // Validate required fields using API data
                                              for (final field in dynamicCustomFields.value) {
                                                if (field.isRequired && customFields[field.key] == null) {
                                                  showError(context, 'Please fill in all required fields');
                                                  isSavingDraft.value = false;
                                                  return;
                                                }
                                              }

                                              // Get image files from media
                                              final imageFiles = media.value;
                                              // Call saveDraft from AuctionService
                                              final auctionService = AuctionService();
                                              final result = await auctionService.saveDraft(
                                                  auctionData: productData, images: imageFiles);
                                              
                                              isSavingDraft.value = false;
                                              
                                              if (result['success'] == true) {
                                                // Fetch full draft details from backend
                                                final details =
                                                    await AuctionDetailsService
                                                        .getAuctionDetails(result['data']
                                                                ['id']
                                                            .toString());
                                                if (details['success'] == true &&
                                                    details['data'] != null) {
                                                  final AuctionItem fetchedDraft =
                                                      AuctionItem.fromJson(
                                                          details['data']);
                                                  debugPrint(
                                                      '--- CONTINUE BUTTON PRESSED ---');
                                                  debugPrint(
                                                      'AuctionItem fields after fetch:');
                                                  debugPrint('id: ${fetchedDraft.id}');
                                                  debugPrint(
                                                      'productId: ${fetchedDraft.productId}');
                                                  debugPrint(
                                                      'title: ${fetchedDraft.title}');
                                                  debugPrint(
                                                      'description: ${fetchedDraft.description}');
                                                  debugPrint(
                                                      'categoryId: ${fetchedDraft.categoryId}');
                                                  debugPrint(
                                                      'subCategoryId: ${fetchedDraft.subCategoryId}');
                                                  debugPrint(
                                                      'categoryName: ${fetchedDraft.categoryName}');
                                                  debugPrint(
                                                      'subCategoryName: ${fetchedDraft.subCategoryName}');
                                                  debugPrint(
                                                      'usageStatus: ${fetchedDraft.usageStatus}');
                                                  debugPrint(
                                                      'status: ${fetchedDraft.status}');
                                                  debugPrint(
                                                      'imageLinks: ${fetchedDraft.imageLinks}');
                                                  debugPrint(
                                                      'createdAt: ${fetchedDraft.createdAt}');
                                                  debugPrint(
                                                      'price: ${fetchedDraft.price}');
                                                  debugPrint(
                                                      'productListingPrice: ${fetchedDraft.productListingPrice}');
                                                  debugPrint(
                                                      'startBidAmount: ${fetchedDraft.startBidAmount}');
                                                  debugPrint(
                                                      'currentBid: ${fetchedDraft.currentBid}');
                                                  debugPrint(
                                                      'buyNowPrice: ${fetchedDraft.buyNowPrice}');
                                                  debugPrint(
                                                      'startDate: ${fetchedDraft.startDate}');
                                                  debugPrint(
                                                      'expiryDate: ${fetchedDraft.expiryDate}');
                                                  debugPrint(
                                                      'endDate: ${fetchedDraft.endDate}');
                                                  debugPrint(
                                                      'type: ${fetchedDraft.type}');
                                                  debugPrint(
                                                      'itemLocation: ${fetchedDraft.itemLocation}');
                                                  debugPrint(
                                                      'bids: ${fetchedDraft.bids}');
                                                  debugPrint(
                                                      'buyNowEnabled: ${fetchedDraft.buyNowEnabled}');
                                                  debugPrint(
                                                      'userName: ${fetchedDraft.userName}');
                                                  debugPrint(
                                                      'phone: ${fetchedDraft.phone}');
                                                  debugPrint(
                                                      'customFields: ${fetchedDraft.customFields}');
                                                  debugPrint(
                                                      '-----------------------------------');
                                                  // Get user from provider
                                                  final user = Provider.of<UserProvider>(
                                                          context,
                                                          listen: false)
                                                      .user;
                                                  Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) => DraftsPage(
                                                        draftAuction: fetchedDraft,
                                                        user: user,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  // Fallback: show error or fallback to previous logic
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                        content: Text(
                                                            'Failed to fetch full draft details.')),
                                                  );
                                                }
                                              } else {
                                                String errorMessage;
                                                if (result['message'] is List) {
                                                  errorMessage = (result['message'] as List)
                                                      .map((e) => mapBackendErrorToUserMessage(e.toString()))
                                                      .join('\n');
                                                } else {
                                                  errorMessage = mapBackendErrorToUserMessage(
                                                      result['message']?.toString());
                                                }

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(errorMessage),
                                                    backgroundColor: errorColor,
                                                  ),
                                                );
                                              }
                                            } else {
                                              isSavingDraft.value = false;
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(80, 33),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                    child: isSaving
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(onSecondaryColor),
                                            ),
                                          )
                                        : const Text(
                                            "Save as Draft",
                                            style: TextStyle(color: onSecondaryColor),
                                          ),
                                  );
                                },
                              ),
                            ],
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () async {
                                // Set submitted to true to show validation errors
                                isSubmitted.value = true;

                                final formValid = await validateForm();

                                if (formValid) {
                                  // Create base product data
                                  final customFields = <String, dynamic>{};
                                  for (final field
                                      in dynamicCustomFields.value) {
                                    if (field.type == 'dropdown') {
                                      customFields[field.key] =
                                          customFieldDropdownValues[field.key]
                                              ?.value;
                                    } else {
                                      customFields[field.key] =
                                          customFieldControllers[field.key]
                                              ?.text
                                              .trim();
                                    }
                                  }

                                  // Filter customFields to remove empty or null values
                                  final filteredCustomFields = <String, dynamic>{
                                    for (final entry in customFields.entries)
                                      if (entry.value != null && entry.value.toString().trim().isNotEmpty)
                                        entry.key: entry.value
                                  };

                                  final Map<String, dynamic> productData = {
                                    'title': itemNameController.text.trim(),
                                    'description':
                                        descriptionController.text.trim(),
                                    'categoryId': CategoryData.getCategoryId(
                                            categoryController.value ?? '') ??
                                        1,
                                    'subCategoryId':
                                        CategoryData.getSubCategoryId(
                                                categoryController.value ?? '',
                                                subCategoryController.value ??
                                                    '') ??
                                            1,
                                    'usageStatus':
                                        condition.value?.toUpperCase() ??
                                            'UNKNOWN',
                                    ...filteredCustomFields,
                                  };

                                  // Validate required fields using API data
                                  for (final field
                                      in dynamicCustomFields.value) {
                                    if (field.isRequired &&
                                        customFields[field.key] == null) {
                                      showError(context,
                                          'Please fill in all required fields');
                                      return;
                                    }
                                  }

                                  // Debug log the product structure
                                  debugPrint('Final product data structure:');
                                  debugPrint(json.encode(productData));

                                  // Debug log media files
                                  debugPrint(
                                      'ProductDetailsScreen - Media files before navigation:');
                                  debugPrint(
                                      'Total files: ${media.value.length}');
                                  for (var i = 0; i < media.value.length; i++) {
                                    final file = media.value[i];
                                    final isVideo = file.path
                                            .toLowerCase()
                                            .endsWith('.mp4') ||
                                        file.path
                                            .toLowerCase()
                                            .endsWith('.mov');
                                    debugPrint('  File $i: ${file.path}');
                                    debugPrint(
                                        '    Type: ${isVideo ? 'Video' : 'Image'}');
                                    debugPrint(
                                        '    Size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');
                                  }

                                  // Get image paths from media files
                                  final imagePaths = media.value
                                      .map((file) => file.path)
                                      .toList();

                                  if (title == 'Create Auction') {
                                    // Navigate to auction details for auction creation
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AuctionDetailsScreen(
                                          productData: productData,
                                          imagePaths: imagePaths,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // Navigate to shipping details for listing product
                                    final listProductData = {
                                      'product': {
                                        ...productData,
                                        'price': priceController.text.trim(),
                                      },
                                    };

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShippingDetailsScreen(
                                          auctionData: listProductData,
                                          imagePaths: imagePaths,
                                          title: title,
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(80, 33),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text("Next",
                                  style: TextStyle(color: secondaryColor)),
                            ),
                          ]),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget _buildMediaWidget(File mediaFile) {
    if (mediaFile.path.endsWith('.mp4') || mediaFile.path.endsWith('.mov')) {
      return _buildVideoPlayer(mediaFile);
    } else {
      return Image.file(
        mediaFile,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  Widget _buildVideoPlayer(File videoFile) {
    return FutureBuilder(
      future: _initializeVideoPlayer(videoFile),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return VideoPlayer(snapshot.data as VideoPlayerController);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoPlayer(File videoFile) async {
    final controller = VideoPlayerController.file(videoFile);
    await controller.initialize();
    return controller;
  }
}
