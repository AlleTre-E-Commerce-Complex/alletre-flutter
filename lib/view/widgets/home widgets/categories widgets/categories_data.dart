import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/services/api/category_api_service.dart';

class CategoryData {
  // Get all category names
  static List<String> get categories {
    return CategoryService.getAllCategories()
        .map((category) => category.nameEn)
        .toList();
  }

  // Get subcategories for a given category
  static List<String> getSubCategories(String categoryName) {
    final categoryId = getCategoryId(categoryName);
    if (categoryId == null) return [];

    // Trigger debounced loading of subcategories if needed
    CategoryApiService.debouncedInitSubCategories(categoryId);

    return CategoryService.getSubCategoriesForCategory(categoryId)
        .map((subcategory) => subcategory.nameEn)
        .toList();
  }

  // Get category ID from name
  static int? getCategoryId(String categoryName) {
    try {
      return CategoryService.getAllCategories()
          .firstWhere((cat) => cat.nameEn == categoryName)
          .id;
    } catch (e) {
      return null;
    }
  }

  // Get subcategory ID from category and subcategory names
  static int? getSubCategoryId(String categoryName, String subCategoryName) {
    final categoryId = getCategoryId(categoryName);
    if (categoryId == null) return null;

    try {
      return CategoryService.getSubCategoriesForCategory(categoryId)
          .firstWhere((subcat) => subcat.nameEn == subCategoryName)
          .id;
    } catch (e) {
      return null;
    }
  }
}
