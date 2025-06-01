import 'package:alletre_app/controller/providers/tab_index_provider.dart';
import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/view/widgets/home%20widgets/categories%20widgets/categories_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common widgets/footer_elements_appbar.dart';

class CategoriesPage extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {
      'title': 'Electronic Devices',
      'image': 'assets/images/electronics_category.svg'
    },
    {'title': 'Jewellers', 'image': 'assets/images/jewellery_category.svg'},
    {'title': 'Properties', 'image': 'assets/images/properties_category.svg'},
    {'title': 'Cars', 'image': 'assets/images/cars_category.svg'},
    {'title': 'Furniture', 'image': 'assets/images/furniture_category.svg'},
    {'title': 'Antiques', 'image': 'assets/images/sports_category.svg'},
  ];

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Resets all the titles when the page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryState>(context, listen: false).resetAllTitles();
    });

    return Scaffold(
      appBar: const NavbarElementsAppbar(
          appBarTitle: 'Categories', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final title = categories[index]['title']!;
            final image = categories[index]['image']!;
            // Check if category is not "Electronic Devices"
            // final showBadge = title.toLowerCase() != 'electronic devices';

            return Column(
              children: [
                Stack(
                  children: [
                    CategoryListTile(
                      index: index,
                      title: title,
                      image: image,
                      onTap: () {
                        context.read<TabIndexProvider>().updateIndex(11);
                      },
                    ),
                    // if (showBadge)
                    //   Positioned.fill(
                    //     child: Container(
                    //       alignment: Alignment.center,
                    //       decoration: BoxDecoration(
                    //         color: const Color(0x66000000),
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //       child: Container(
                    //         padding: const EdgeInsets.symmetric(
                    //             horizontal: 111, vertical: 8),
                    //         decoration: const BoxDecoration(
                    //           color: primaryColor,
                    //         ),
                    //         child: const Text(
                    //           'coming soon',
                    //           style: TextStyle(
                    //             color: secondaryColor,
                    //             fontSize: 14,
                    //             fontWeight: FontWeight.bold,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                  ],
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
