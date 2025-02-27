import 'dart:convert';
import 'package:alletre_app/model/category.dart';
import 'package:alletre_app/model/sub_category.dart';

class CategoryService {
  static final Map<int, Category> _categories = {};
  static final Map<int, SubCategory> _subCategories = {};

  static void initializeCategories(String jsonResponse) {
    try {
      print('Initializing categories with response: $jsonResponse');
      final Map<String, dynamic> data = json.decode(jsonResponse);
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> categoriesData = data['data'] as List<dynamic>;
        print('Found ${categoriesData.length} categories');
        
        for (var categoryData in categoriesData) {
          final category = Category.fromJson(categoryData as Map<String, dynamic>);
          _categories[category.id] = category;
          print('Added category: ${category.nameEn} (ID: ${category.id})');
        }
      } else {
        print('Invalid categories data format: success=${data['success']}, data=${data['data']}');
      }
    } catch (e) {
      print('Error initializing categories: $e');
    }
  }

  static void initializeSubCategories(String jsonResponse) {
    try {
      print('Initializing subcategories with response: $jsonResponse');
      final Map<String, dynamic> data = json.decode(jsonResponse);
      print('Decoded JSON data: $data');
      
      if (data['success'] == true && data['data'] != null) {
        var subCategoriesData;
        
        // Try different possible response structures
        if (data['data'] is List) {
          // If data is directly a list of subcategories
          subCategoriesData = data['data'];
          print('Found direct list of subcategories');
        } else if (data['data'] is Map) {
          final categoryData = data['data'] as Map<String, dynamic>;
          print('Category data structure: ${categoryData.keys}');
          
          // Try different possible keys
          if (categoryData['subCategories'] != null) {
            subCategoriesData = categoryData['subCategories'];
          } else if (categoryData['sub_categories'] != null) {
            subCategoriesData = categoryData['sub_categories'];
          } else if (categoryData['items'] != null) {
            subCategoriesData = categoryData['items'];
          }
        }
        
        if (subCategoriesData != null) {
          print('Processing subcategories data: $subCategoriesData');
          final List<dynamic> subCategories = subCategoriesData as List<dynamic>;
          print('Found ${subCategories.length} subcategories');
          
          for (var subCategoryData in subCategories) {
            print('Processing subcategory: $subCategoryData');
            try {
              final subCategory = SubCategory.fromJson(subCategoryData as Map<String, dynamic>);
              _subCategories[subCategory.id] = subCategory;
              print('Successfully added subcategory: ${subCategory.nameEn} (ID: ${subCategory.id})');
            } catch (e) {
              print('Error processing individual subcategory: $e');
              print('Problematic data: $subCategoryData');
            }
          }
        } else {
          print('Could not find subcategories in response structure');
          print('Available data structure: ${data['data']}');
        }
      } else {
        print('Invalid response format: success=${data['success']}, data=${data['data']}');
      }
    } catch (e, stackTrace) {
      print('Error initializing subcategories: $e');
      print('Stack trace: $stackTrace');
    }
  }

  static String getCategoryName(int categoryId) {
    final category = _categories[categoryId];
    print('Getting category name for ID $categoryId: ${category?.nameEn ?? 'not found'}');
    return category?.nameEn ?? '';
  }

  static String getSubCategoryName(int subCategoryId) {
    final subCategory = _subCategories[subCategoryId];
    print('Getting subcategory name for ID $subCategoryId: ${subCategory?.nameEn ?? 'not found'}');
    print('Current subcategories in memory: ${_subCategories.keys}'); // Added to check cache state
    return subCategory?.nameEn ?? '';
  }

  static Category? getCategory(int categoryId) {
    return _categories[categoryId];
  }

  static SubCategory? getSubCategory(int subCategoryId) {
    return _subCategories[subCategoryId];
  }
}
