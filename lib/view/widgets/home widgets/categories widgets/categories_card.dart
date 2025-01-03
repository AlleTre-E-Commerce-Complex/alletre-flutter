import 'package:alletre_app/controller/providers/category_state.dart';
import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CategoryListTile extends StatelessWidget {
  final String title;
  final String image;
  final int index; // index to identify the tile

  const CategoryListTile({
    super.key,
    required this.title,
    required this.image,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final categoryState = Provider.of<CategoryState>(context);

    return GestureDetector(
      onTap: () {
        categoryState.toggleTitle(index); // Toggles title visibility
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
                  color: overlayColor, // Semi-transparent overlay
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
