import 'package:alletre_app/utils/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:alletre_app/model/auction_item.dart';
import 'package:alletre_app/services/api/category_api_service.dart';
import 'package:alletre_app/services/category_service.dart';

class ItemDetailsCategoryInfo extends StatelessWidget {
  final AuctionItem item;

  const ItemDetailsCategoryInfo({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: CategoryApiService.initSubCategories(item.categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final categoryName = CategoryService.getCategoryName(item.categoryId);
        final subCategoryName = CategoryService.getSubCategoryName(item.subCategoryId);

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: avatarColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSecondaryColor, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    categoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: onSecondaryColor, fontSize: 13),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            if(categoryName != 'Cars')...[
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: avatarColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sub Category',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: onSecondaryColor, fontSize: 13),
                  ),
                  const Spacer(),
                  Text(
                    subCategoryName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: onSecondaryColor, fontSize: 13),
                    softWrap: true,
                  ),
                ],
              ),
            ),
            ],
          ],
        );
      },
    );
  }
}