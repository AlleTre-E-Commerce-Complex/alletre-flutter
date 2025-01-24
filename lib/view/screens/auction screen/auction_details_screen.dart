import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuctionDetailsScreen extends StatelessWidget {
  const AuctionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final itemNameController = TextEditingController();
    final categoryController = ValueNotifier<String?>(null);
    final subCategoryController = ValueNotifier<String?>(null);
    final descriptionController = TextEditingController();
    final condition = ValueNotifier<String?>(null);

    final categories = [
      "Jewellery",
      "Properties",
      "Cars",
      "Electronic Devices",
    ];

    final subCategories = {
      "Jewellery": ["Gold", "Diamond", "Silver"],
      "Properties": ["House", "Townhouse", "Unit", "Villa", "Land", "Office"],
      "Cars": ["SUVs", "Sedans", "Electric"],
      "Electronic Devices": [
        "Computers & Tablets",
        "Cameras",
        "TVs & Audios",
        "Smartphones",
        "Accessories"
      ],
    };

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            context.read<TabIndexProvider>().updateIndex(1);
          },
        ),
        title: const Text('Create Auction',
            style: TextStyle(color: secondaryColor, fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Divider(thickness: 1, color: primaryColor),
              const Center(
                child: Text(
                  "Auction Details",
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: onSecondaryColor),
                ),
              ),
              const Divider(thickness: 1, color: primaryColor),
              const SizedBox(height: 10),
              const Text(
                "Auction Type",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
              const SizedBox(height: 8), 
              ValueListenableBuilder<String?>(
                valueListenable: condition,
                builder: (context, value, child) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Radio<String>(
                            value: "quickAuction",
                            groupValue: value,
                            onChanged: (selected) =>
                                condition.value = selected!,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Quick Auction", style: radioTextStyle),
                              Text(
                                "Short-term auction with faster results.",
                                style:
                                    TextStyle(fontSize: 11, color: greyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10), // Space between radio buttons
                      Row(
                        children: [
                          Radio<String>(
                            value: "longAuction",
                            groupValue: value,
                            onChanged: (selected) =>
                                condition.value = selected!,
                          ),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Long Auction", style: radioTextStyle),
                              Text(
                                "Extended auction for better reach.",
                                style:
                                    TextStyle(fontSize: 11, color: greyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
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
                validator: (value) => value!.isEmpty ? "Enter item name" : null,
              ),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              ValueListenableBuilder<String?>(
                valueListenable: categoryController,
                builder: (context, selectedCategory, child) {
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Category",
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
                    },
                    validator: (value) =>
                        value == null ? "Select a category" : null,
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
                  return ValueListenableBuilder<String?>(
                    valueListenable: subCategoryController,
                    builder: (context, selectedSubCategory, child) {
                      return DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: "Sub category",
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
                        items: (subCategories[selectedCategory] ?? [])
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
                        }).toList(),
                        onChanged: (value) {
                          subCategoryController.value = value;
                        },
                        validator: (value) =>
                            value == null ? "Select a sub category" : null,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Item Description",
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
                ),
                maxLines: 5,
                validator: (value) =>
                    value!.isEmpty ? "Enter item description" : null,
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
                          color: greyColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (index) => GestureDetector(
                    onTap: () {
                      // Implement media picker functionality
                    },
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      const SizedBox(width: 20), // Space between radio buttons
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
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Save as draft logic
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Saved as draft')),
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
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Navigate to auction details screen
                        context.read<TabIndexProvider>().updateIndex(17);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            6), // Adjust border radius here
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text("Next",
                        style: TextStyle(color: secondaryColor)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
