// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:alletre_app/model/category.dart';
import 'package:alletre_app/model/sub_category.dart';

/// Service responsible for managing the in-memory cache of categories and subcategories.
/// This service handles data storage, validation, and provides access methods for the UI.
/// It works in conjunction with CategoryApiService, which handles the API communication.
class CategoryService {
  /// In-memory cache of categories indexed by ID
  static final Map<int, Category> _categories = {};
  
  /// In-memory cache of subcategories indexed by ID
  static final Map<int, SubCategory> _subCategories = {};

  /// Get all categories
  static List<Category> getAllCategories() {
    return _categories.values.toList();
  }

  /// Get subcategories for a specific category
  static List<SubCategory> getSubCategoriesForCategory(int categoryId) {
    return _subCategories.values
        .where((subcat) => subcat.categoryId == categoryId)
        .toList();
  }

  /// Initialize categories from API response
  /// Called by CategoryApiService after fetching data
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

  /// Initialize subcategories from API response
  /// Called by CategoryApiService after fetching data
  /// For Electronics category (ID: 1), ensures all required custom fields are present
  static void initializeSubCategories(String jsonResponse) {
    try {
      // print('Initializing subcategories with response: $jsonResponse');
      final Map<String, dynamic> data = json.decode(jsonResponse);
      // print('Decoded JSON data: $data');
      
      if (data['success'] == true && data['data'] != null) {
        var subCategoriesData;
        
        // Handle different API response structures
        if (data['data'] is List) {
          subCategoriesData = data['data'];
          print('Found direct list of subcategories');
        } else if (data['data'] is Map) {
          final categoryData = data['data'] as Map<String, dynamic>;
          print('Category data structure: ${categoryData.keys}');
          
          // Try different possible keys based on API response
          if (categoryData['subCategories'] != null) {
            subCategoriesData = categoryData['subCategories'];
          } else if (categoryData['sub_categories'] != null) {
            subCategoriesData = categoryData['sub_categories'];
          } else if (categoryData['items'] != null) {
            subCategoriesData = categoryData['items'];
          }
        }
        
        if (subCategoriesData != null) {
          // print('Processing subcategories data: $subCategoriesData');
          final List<dynamic> subCategories = subCategoriesData as List<dynamic>;
          print('Found ${subCategories.length} subcategories');
          
          for (var subCategoryData in subCategories) {
            // print('Processing subcategory: $subCategoryData');
            try {
              final subCategory = SubCategory.fromJson(subCategoryData as Map<String, dynamic>);
              _subCategories[subCategory.id] = subCategory;
              // print('🏆 Successfully added subcategory: ${subCategory.nameEn} (ID: ${subCategory.id})');
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

  /// Get category name by ID
  /// Returns empty string if category not found
  static String getCategoryName(int categoryId) {
    final category = _categories[categoryId];
    // print('Getting category name for ID $categoryId: ${category?.nameEn ?? 'not found'}');
    return category?.nameEn ?? '';
  }

  /// Get subcategory name by ID
  /// Returns empty string if subcategory not found
  static String getSubCategoryName(int subCategoryId) {
    final subCategory = _subCategories[subCategoryId];
    // print('🎁 Getting subcategory name for ID $subCategoryId: ${subCategory?.nameEn ?? 'not found'}');
    // print('Current subcategories in memory: ${_subCategories.keys}');
    return subCategory?.nameEn ?? '';
  }

  /// Get category by ID
  /// Returns null if not found
  static Category? getCategory(int categoryId) {
    return _categories[categoryId];
  }

  /// Get subcategory by ID
  /// Returns null if not found
  static SubCategory? getSubCategory(int subCategoryId) {
    return _subCategories[subCategoryId];
  }

  /// Get seller deposit amount for a category
  /// Returns null if category not found
  static String getSellerDepositAmount(int categoryId) {
    final category = _categories[categoryId];
    return category!.sellerDepositFixedAmount;
  }
}