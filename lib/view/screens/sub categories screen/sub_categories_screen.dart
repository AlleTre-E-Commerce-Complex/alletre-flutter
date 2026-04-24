import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';

import '../../widgets/home widgets/categories widgets/categories_data.dart';

class SubCategoryPage extends StatelessWidget {
  final String categoryName;

  const SubCategoryPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final categorySubList = CategoryData.getSubCategories(categoryName);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: secondaryColor),
          onPressed: () {
            Navigator.pop(context, false); // Returns false to indicate title should be hidden
          },
        ),
        title: Text(categoryName, style: const TextStyle(color: secondaryColor)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categorySubList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias, // ensures the splash effect is clipped to the card's border radius
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  child: ListTile(
                    title: Text(categorySubList[index]),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}