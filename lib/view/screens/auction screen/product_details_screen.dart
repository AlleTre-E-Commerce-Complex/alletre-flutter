import 'dart:io';
import 'dart:convert';
import 'package:alletre_app/controller/helpers/image_picker_helper.dart';
import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/utils/validators/create_auction_validators.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';
import '../../widgets/home widgets/categories widgets/categories_data.dart';
import 'auction_details_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Add a ValueNotifier to track whether the form has been submitted
    final isSubmitted = ValueNotifier<bool>(false);
    final formKey = GlobalKey<FormState>();
    final itemNameController = TextEditingController();
    final categoryController = ValueNotifier<String?>(null);
    final subCategoryController = ValueNotifier<String?>(null);
    final descriptionController = TextEditingController();
    final condition = ValueNotifier<String?>(null);
    final media = ValueNotifier<List<File>>([]);
    final coverPhotoIndex =
        ValueNotifier<int?>(null); // Track selected cover photo

    // Map to store the custom field controllers and dropdown values
    final customFieldControllers = <String, TextEditingController>{};
    final customFieldDropdownValues = <String, ValueNotifier<String?>>{};

    // Get categories list
    final categories = CategoryData.categories;

    // Define consistent label text style
    const labelTextStyle = TextStyle(fontSize: 14);

    // Define color options for dropdown
    final List<String> colorOptions = [
      'White',
      'Black',
      'Blue',
      'Red',
      'Green',
      'Yellow',
      'Orange',
      'Purple',
      'Brown',
      'Pink',
      'Cyan',
      'Grey',
      'Silver',
      'Bronze',
      'Golden',
      'Pearl',
      'Matte Black',
      'Champagne',
      'Other color',
      'Multi color'
    ];

    // Define camera type options for dropdown
    final List<String> cameraTypeOptions = [
      'Digital',
      'Compact',
      'Mirrorless Interchangeable Lens',
      'DSLR',
      'Action Camera',
      'Instant Camera',
      '360 Camera',
      'Other'
    ];

    // Define memory options for dropdown
    final List<String> memoryOptions = [
      '4GB',
      '8GB',
      '16GB',
      '32GB',
      '64GB',
      '128GB',
      '256GB',
      '512GB',
      '1TB',
      '2TB'
    ];

    // Define material options for dropdown
    final List<String> materialOptions = [
      'ABS',
      'Plastic',
      'Metal',
      'Silicon',
      'Glass',
      'Wood',
      'Carbon Fiber',
      'Leather',
      'Other'
    ];

    // Define country options for dropdown
    final List<String> countryOptions = ['United Arab Emirates'];

    // Define city options for dropdown
    final List<String> cityOptions = [
      'Abu Dhabi',
      'Ajman',
      'Dubai',
      'Fujairah',
      'Ras al Khaimah',
      'Sharjah',
      'Umm al Quwain'
    ];

    final List<String> carType = [
      'Micro Cars, Hatchback',
      'Sedan',
      'SUV',
      'MPV',
      'Coupe',
      'Convertible',
      'Wagon',
      'Luxury'
    ];

    // Define subcategory custom fields mapping
    Map<String, dynamic> getSubCategoryFields(String? subCategory) {
      if (subCategory == null) return {};

      switch (subCategory) {
        case "Cars":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Computers & tablets":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Screen Size": {"type": "number"},
            "Operating System": {"type": "text"},
            "Release Year": {"type": "number"},
            "Region of Manufacture": {"type": "text"},
            "RAM Size": {"type": "number"},
            "Processor": {"type": "text"},
            "Graphics Card": {"type": "text"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Cameras & photos":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Camera Type": {"type": "dropdown", "options": cameraTypeOptions},
            "Release Year": {"type": "number"},
            "Region of Manufacture": {"type": "text"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Smart Phones":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Memory": {"type": "dropdown", "options": memoryOptions},
            "Screen Size": {"type": "number"},
            "Operating System": {"type": "text"},
            "Release Year": {"type": "number"},
            "Region of Manufacture": {"type": "text"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Accessories":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Material": {"type": "dropdown", "options": materialOptions},
            "Type": {"type": "text"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "TVs & Audios":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Screen Size": {"type": "number"},
            "Release Year": {"type": "number"},
            "Region of Manufacture": {"type": "text"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Home Appliances":
          return {
            "Age": {"type": "number"},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "Gold":
        case "Diamond":
        case "Silver":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Brand": {"type": "text"},
            "Model": {"type": "text"},
          };
        case "House":
        case "Townhouse":
        case "Villa":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Country": {
              "type": "dropdown",
              "options": countryOptions,
              "textStyle": const TextStyle(
                  fontSize: 10,
                  color: onSecondaryColor,
                  fontWeight: FontWeight.w500)
            },
            "City": {"type": "dropdown", "options": cityOptions},
            "Age": {"type": "number"},
            "Number of Rooms": {"type": "number"},
            "Total Area (Sq Ft)": {"type": "number"},
            "Number of Floors": {"type": "number"},
          };
        case "Unit":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Country": {"type": "dropdown", "options": countryOptions},
            "City": {"type": "dropdown", "options": cityOptions},
            "Age": {"type": "number"},
            "Number of Rooms": {"type": "number"},
            "Total Area (Sq Ft)": {"type": "number"},
          };
        case "Land":
          return {
            "Country": {"type": "dropdown", "options": countryOptions},
            "City": {"type": "dropdown", "options": cityOptions},
            "Land Type": {"type": "text"},
            "Total Area (Sq Ft)": {"type": "number"},
          };
        case "Office":
          return {
            "Color": {"type": "dropdown", "options": colorOptions},
            "Country": {"type": "dropdown", "options": countryOptions},
            "City": {"type": "dropdown", "options": cityOptions},
            "Age": {"type": "number"},
            "Number of Rooms": {"type": "number"},
            "Total Area (Sq Ft)": {"type": "number"},
          };
        case "Table and chairs":
        case "Cupboards and Beds":
        case "Paintings":
        case "Currency":
        case "Others":
          return {
            "Material": {"type": "text"},
            "Brand": {"type": "text"},
          };
        default:
          return {};
      }
    }

    // Function to initialize custom field controllers and dropdown values
    void initializeCustomFieldControllers(String? subCategory) {
      if (subCategory == null) return;

      // Clear existing controllers and dropdown values
      customFieldControllers.forEach((key, controller) {
        controller.clear();
      });
      customFieldControllers.clear();
      customFieldDropdownValues.clear();

      final fields = categoryController.value == "Cars"
          ? getSubCategoryFields("Cars")
          : getSubCategoryFields(subCategory);

      // Create new controllers and dropdown values
      fields.forEach((key, value) {
        if (value["type"] == "text") {
          customFieldControllers[key] = TextEditingController();
        } else if (value["type"] == "dropdown") {
          customFieldDropdownValues[key] = ValueNotifier<String?>(null);
        }
      });
    }

    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Create Auction', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Form(
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
              const SizedBox(height: 14),
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
                      subCategoryController.value = null; // Reset subcategory

                      // Clear the custom field controllers when category changes
                      customFieldControllers.forEach((key, controller) {
                        controller.clear();
                      });
                      customFieldControllers.clear();
                      customFieldDropdownValues.clear();
                    },
                    validator: CreateAuctionValidation.validateCategory,
                  );
                },
              ),
              const SizedBox(height: 12),
              ValueListenableBuilder<String?>(
                valueListenable: categoryController,
                builder: (context, selectedCategory, child) {
                  if (selectedCategory == null) {
                    return const SizedBox(); // No subcategory dropdown if category not selected
                  }

                  if (selectedCategory == "Cars") {
                    return ValueListenableBuilder<String?>(
                      valueListenable: subCategoryController,
                      builder: (context, selectedSubCategory, child) {
                        return DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: "Car Type",
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
                          value: selectedSubCategory,
                          items: carType.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(
                                type,
                                style: const TextStyle(
                                  color: onSecondaryColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            subCategoryController.value = value;
                          },
                          validator:
                              CreateAuctionValidation.validateSubCategory,
                        );
                      },
                    );
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
                            borderSide: const BorderSide(color: errorColor),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: errorColor),
                          ),
                        ),
                        value: selectedSubCategory,
                        // ignore: unnecessary_null_comparison
                        items: selectedCategory != null
                            ? CategoryData.getSubCategories(selectedCategory).map((subcategory) {
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
                          // Initialize controllers for this subcategory
                          initializeCustomFieldControllers(value);
                        },
                        validator: CreateAuctionValidation.validateSubCategory,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),

              // Dynamic Custom Fields based on selected subcategory
              ValueListenableBuilder<String?>(
                valueListenable: subCategoryController,
                builder: (context, selectedSubCategory, child) {
                  if (selectedSubCategory == null) {
                    return const SizedBox();
                  }

                  final fields = categoryController.value == "Cars"
                      ? getSubCategoryFields("Cars")
                      : getSubCategoryFields(selectedSubCategory);

                  if (fields.isEmpty) {
                    return const SizedBox();
                  }

                  // Get required fields map
                  final requiredFields =
                      CreateAuctionValidation.getRequiredFields(
                          selectedSubCategory);

                  // Ensure all fields have controllers or dropdown values
                  fields.forEach((key, value) {
                    if (value["type"] == "text" &&
                        !customFieldControllers.containsKey(key)) {
                      customFieldControllers[key] = TextEditingController();
                    } else if (value["type"] == "dropdown" &&
                        !customFieldDropdownValues.containsKey(key)) {
                      customFieldDropdownValues[key] =
                          ValueNotifier<String?>(null);
                    }
                  });

                  return GridView.builder(
                    key: ValueKey('grid-$selectedSubCategory'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 3,
                      mainAxisExtent:
                          60, // Slightly increased to ensure error messages are visible
                    ),
                    itemCount: fields.length,
                    itemBuilder: (context, index) {
                      final fieldName = fields.keys.elementAt(index);
                      final fieldValue = fields[fieldName];
                      final isRequired = requiredFields[fieldName] ?? false;

                      if (fieldValue["type"] == "text") {
                        return TextFormField(
                          controller: customFieldControllers[fieldName],
                          decoration: InputDecoration(
                            labelText: fieldName,
                            labelStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 11),
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
                              fontSize: 9,
                              height: 0.7,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          style: const TextStyle(fontSize: 12),
                          validator: (value) {
                            // if (fieldName == 'Model') {
                            //   return CreateAuctionValidation.validateModel(
                            //       value);
                            // }
                            return CreateAuctionValidation.validateCustomField(
                              fieldName,
                              value,
                              'text',
                              isRequired: isRequired,
                            );
                          },
                        );
                      } else if (fieldValue["type"] == "number") {
                        return TextFormField(
                          controller: customFieldControllers[fieldName],
                          decoration: InputDecoration(
                            labelText: fieldName,
                            labelStyle: const TextStyle(fontSize: 12),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
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
                              fontSize: 9,
                              height: 0.7,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              CreateAuctionValidation.validateCustomField(
                            fieldName,
                            value,
                            'number',
                            isRequired: isRequired,
                          ),
                        );
                      } else if (fieldValue["type"] == "dropdown") {
                        return ValueListenableBuilder<String?>(
                          valueListenable:
                              customFieldDropdownValues[fieldName]!,
                          builder: (context, selectedValue, child) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: fieldName,
                                labelStyle: const TextStyle(fontSize: 12),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
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
                                errorStyle: const TextStyle(
                                  fontSize: 9,
                                  height: 0.7,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: selectedValue,
                              items: fieldValue["options"]
                                  .map<DropdownMenuItem<String>>((option) {
                                return DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(
                                    option,
                                    style: (fieldValue["textStyle"]
                                            as TextStyle?) ??
                                        const TextStyle(
                                          color: onSecondaryColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                customFieldDropdownValues[fieldName]!.value =
                                    value;
                              },
                              validator: (value) {
                                return CreateAuctionValidation
                                    .validateCustomField(
                                  fieldName,
                                  value,
                                  'select',
                                  isRequired: isRequired,
                                );
                              },
                              isExpanded: true,
                            );
                          },
                        );
                      }
                      return null;
                      // return const SizedBox();
                    },
                  );
                },
              ),
              const SizedBox(height: 5),

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
                  text: 'Add Media ',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onSecondaryColor),
                  children: [
                    TextSpan(
                      text: '(3-5 images)',
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
                  if (coverPhotoIndex.value == null && mediaList.isNotEmpty) {
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
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          // Generate a reordered media list with the cover photo (if set) first
                          final reorderedMediaList = coverPhotoIndex.value !=
                                      null &&
                                  coverPhotoIndex.value! < mediaList.length
                              ? [
                                  mediaList[coverPhotoIndex.value!],
                                  ...mediaList.where((file) =>
                                      file != mediaList[coverPhotoIndex.value!])
                                ]
                              : mediaList;

                          if (index < reorderedMediaList.length) {
                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    // Open media gallery when image is tapped
                                    final File? newMedia =
                                        await pickMediaFromGallery();
                                    if (newMedia != null) {
                                      final updatedMedia = List<File>.from(
                                          mediaList)
                                        ..[index] =
                                            newMedia; // Replace the tapped image
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
                                      borderRadius: BorderRadius.circular(10),
                                      child: _buildMediaWidget(reorderedMediaList[index]),
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
                                          List<File>.from(mediaList)
                                            ..removeAt(index);
                                      media.value = updatedMedia;
                                      if (coverPhotoIndex.value == index) {
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
                                    builder:
                                        (context, selectedCoverIndex, child) {
                                      return GestureDetector(
                                        onTap: () {
                                          coverPhotoIndex.value = index;

                                          // Reorder the media list to display the cover photo first
                                          final File selectedCover =
                                              mediaList[index];
                                          final updatedMedia = [selectedCover] +
                                              mediaList
                                                  .where((file) =>
                                                      file != selectedCover)
                                                  .toList();
                                          media.value = updatedMedia;

                                          coverPhotoIndex.value =
                                              0; // Reset the index
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: selectedCoverIndex == index
                                                ? primaryColor.withAlpha(
                                                    (0.7 * 255).toInt())
                                                : Colors.black.withAlpha(
                                                    (0.5 * 255).toInt()),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Center(
                                            child: Text(
                                              selectedCoverIndex == index
                                                  ? "Cover Photo"
                                                  : "Set as Cover",
                                              style: const TextStyle(
                                                color: secondaryColor,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                            final mediaError =
                                CreateAuctionValidation.validateMediaSection(
                                    mediaList);
                            return mediaError != null
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, left: 12),
                                    child: Text(
                                      mediaError,
                                      style: const TextStyle(
                                          color: errorColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : const SizedBox.shrink();
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
                                  const Text("New", style: radioTextStyle),
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
                                  const Text("Used", style: radioTextStyle),
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
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Save as draft logic
                        isSubmitted.value = true;

                        // This will trigger the validators and show error messages
                        final formValid = formKey.currentState!.validate();

                        // Validate form including dropdown fields
                        bool isDropdownsValid = true;
                        customFieldDropdownValues.forEach((key, notifier) {
                          if (notifier.value == null) {
                            isDropdownsValid = false;
                          }
                        });

                        final isValid = formValid &&
                            CreateAuctionValidation.validateMediaSection(
                                    media.value) ==
                                null &&
                            (categoryController.value == "Properties" ||
                                condition.value != null) &&
                            isDropdownsValid;

                        if (isValid) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Saved in Drafts')),
                          );
                          // Navigate to the home page after a short delay
                          Future.delayed(const Duration(seconds: 1), () {
                            // ignore: use_build_context_synchronously
                            context.read<TabIndexProvider>().updateIndex(1);
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              6), // Adjust border radius here
                        ),
                        backgroundColor: Colors.grey[300],
                      ),
                      child: const Text(
                        "Save as Draft",
                        style: TextStyle(color: onSecondaryColor),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Set submitted to true to show validation errors
                        isSubmitted.value = true;

                        final formValid = formKey.currentState!.validate();

                        // Validate form including dropdown fields
                        bool isDropdownsValid = true;
                        customFieldDropdownValues.forEach((key, notifier) {
                          if (notifier.value == null) {
                            isDropdownsValid = false;
                          }
                        });

                        final isValid = formValid &&
                            CreateAuctionValidation.validateMediaSection(
                                    media.value) ==
                                null &&
                            (categoryController.value == "Properties" ||
                                condition.value != null) &&
                            isDropdownsValid;

                        if (isValid) {
                          // Create base product data
                          final Map<String, dynamic> productData = {
                            'title': itemNameController.text.trim(),
                            'description': descriptionController.text.trim(),
                            'categoryId': CategoryData.getCategoryId(categoryController.value ?? '') ?? 1,
                            'subCategoryId': CategoryData.getSubCategoryId(
                                categoryController.value ?? '',
                                subCategoryController.value ?? '') ?? 1,
                            'usageStatus': condition.value?.toUpperCase() ?? 'UNKNOWN',
                          };

                          // Add Electronics category custom fields with exact field names
                          final customFields = <String, dynamic>{
                            'screenSize': customFieldControllers['Screen Size']?.text.trim(),
                            'operatingSystem': customFieldControllers['Operating System']?.text.trim(),
                            'releaseYear': customFieldControllers['Release Year']?.text.trim(),
                            'regionOfManufacture': customFieldControllers['Region of Manufacture']?.text.trim(),
                            'ramSize': customFieldControllers['RAM Size']?.text.trim(),
                            'processor': customFieldControllers['Processor']?.text.trim(),
                            'brand': customFieldControllers['Brand']?.text.trim(),
                            'graphicCard': customFieldControllers['Graphic Card']?.text.trim(),
                            'model': customFieldControllers['Model']?.text.trim(),
                            'color': customFieldDropdownValues['Color']?.value,
                          };

                          // Add non-empty custom fields to product data
                          customFields.forEach((key, value) {
                            if (value != null && value.toString().isNotEmpty) {
                              // Convert numeric fields to numbers
                              if (['screenSize', 'releaseYear', 'ramSize'].contains(key)) {
                                try {
                                  productData[key] = num.tryParse(value.toString()) ?? value;
                                } catch (_) {
                                  productData[key] = value;
                                }
                              } else {
                                productData[key] = value;
                              }
                            }
                          });

                          // Validate required fields for Electronics category
                          if (productData['brand']?.toString().isEmpty ?? true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Brand is required for Electronics category')),
                            );
                            return;
                          }
                          if (productData['model']?.toString().isEmpty ?? true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Model is required for Electronics category')),
                            );
                            return;
                          }

                          // Debug log the product structure
                          debugPrint('Final product data structure:');
                          debugPrint(json.encode(productData));

                          // Get image paths from media files
                          final imagePaths = media.value.map((file) => file.path).toList();

                          // Pass the product data and image paths to the next screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AuctionDetailsScreen(
                                productData: {'product': productData},
                                imagePaths: imagePaths,
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(80, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Text(
                          "Next",
                          style: TextStyle(color: secondaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
