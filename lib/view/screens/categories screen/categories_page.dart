import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/widgets/home%20widgets/categories%20widgets/categories_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'title': 'Jewellery', 'image': 'assets/images/jewellery_category.svg'},
    {'title': 'Properties', 'image': 'assets/images/properties_category.svg'},
    {'title': 'Cars', 'image': 'assets/images/cars_category.svg'},
    {'title': 'Electronic Devices', 'image': 'assets/images/electronics_category.svg'},
  ];

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Resets all the titles when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryState>(context, listen: false).resetAllTitles();
    });

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
        title: const Text('Categories', style: TextStyle(color: secondaryColor)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                CategoryListTile(
                  index: index,
                  title: categories[index]['title']!,
                  image: categories[index]['image']!,
                  onTap: () {
                    context.read<TabIndexProvider>().updateIndex(11);
                  },
                ),
                if (index < categories.length - 1) const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}