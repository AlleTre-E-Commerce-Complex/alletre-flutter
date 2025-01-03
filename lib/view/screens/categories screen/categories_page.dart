import 'package:alletre_app/view/widgets/common%20widgets/footer_elements_appbar.dart';
import 'package:alletre_app/view/widgets/home%20widgets/categories%20widgets/categories_card.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: const NavbarElementsAppbar(title: 'Categories', showBackButton: true),
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