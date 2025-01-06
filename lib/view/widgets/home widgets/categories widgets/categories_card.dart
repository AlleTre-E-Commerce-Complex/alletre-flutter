import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:alletre_app/view/screens/sub%20categories%20screen/sub_categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CategoryListTile extends StatelessWidget {
  final String title;
  final String image;
  final int index;
  final VoidCallback onTap;

  const CategoryListTile({
    super.key,
    required this.title,
    required this.image,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryState = Provider.of<CategoryState>(context);

    return GestureDetector(
      onTap: () async {
        categoryState.toggleTitle(index);
        // Add a small delay before navigation
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SubCategoryPage(
                categoryName: title,
              ),
            ),
          );
          
          // If result is false (returned from SubCategoryPage), hide the title
          if (result == false && context.mounted) {
            categoryState.toggleTitle(index);
          }
        }
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SvgPicture.asset(
              image,
              height: 320,
              fit: BoxFit.cover,
            ),
          ),
          if (categoryState.isTitleVisible(index))
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: overlayColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: secondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}