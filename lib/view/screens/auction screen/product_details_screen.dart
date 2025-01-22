// // create_auction_screen.dart
// import 'package:alletre_app/controller/helpers/auction_screen_helper.dart';
// import 'package:alletre_app/controller/providers/auction_provider.dart';
// import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
// import 'package:alletre_app/utils/themes/app_theme.dart';
// import 'package:alletre_app/view/widgets/auction%20widgets/auction_form_fields.dart';
// import 'package:alletre_app/view/widgets/auction%20widgets/auction_screen_buttons.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class CreateAuctionScreen extends StatelessWidget {
//   const CreateAuctionScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final formKey = GlobalKey<FormState>();
//     final titleController = TextEditingController();
//     final imageUrlController = TextEditingController();
//     final priceController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Theme.of(context).primaryColor,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: secondaryColor),
//           onPressed: () {
//             context.read<TabIndexProvider>().updateIndex(1);
//           },
//         ),
//         title: const Text('Create Auction', style: TextStyle(color: secondaryColor)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               AuctionFormFields(
//                 titleController: titleController,
//                 imageUrlController: imageUrlController,
//                 priceController: priceController,
//               ),
//               Consumer<AuctionProvider>(
//                 builder: (context, auctionProvider, child) {
//                   return AuctionScreenButtons(
//                     onPickTime: () => AuctionHelper.pickScheduledTime(context),
//                     onSave: () => AuctionHelper.saveAuction(
//                       context: context,
//                       formKey: formKey,
//                       titleController: titleController,
//                       imageUrlController: imageUrlController,
//                       priceController: priceController,
//                     ),
//                     scheduledTime: auctionProvider.scheduledTime,
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:alletre_app/controller/providers/bottom_navbar_provider.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({super.key});

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
                    fontSize: 16,
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
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onSecondaryColor,
                ),
              ),
              ValueListenableBuilder<String?>(
                valueListenable: condition,
                builder: (context, value, child) {
                  return Column(
                    mainAxisSize:
                        MainAxisSize.min, // Minimize spacing within the column
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0), // Adds left padding
                        child: RadioListTile<String>(
                          title: const Text("New"),
                          value: "new",
                          groupValue: value,
                          onChanged: (selected) => condition.value = selected!,
                          visualDensity: const VisualDensity(vertical: -4),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 0), // Adds left padding
                        child: RadioListTile<String>(
                          title: const Text("Used"),
                          value: "used",
                          groupValue: value,
                          onChanged: (selected) => condition.value = selected!,
                          visualDensity: const VisualDensity(vertical: -4),
                        ),
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
                        // Navigate to the next step
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Proceed to next step')),
                        );
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
