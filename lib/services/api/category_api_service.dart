// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;
import 'package:alletre_app/services/category_service.dart';
import 'package:alletre_app/utils/constants/api_endpoints.dart';

class CategoryApiService {
  static Future<void> initializeCategories() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.categories}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Categories Response Status: ${response.statusCode}');
      print('Categories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        CategoryService.initializeCategories(response.body);
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  static Future<void> initializeSubCategories(int categoryId) async {
    try {
      final url = '${ApiEndpoints.baseUrl}${ApiEndpoints.getSubCategoriesUrl(categoryId)}';
      print('Fetching subcategories from URL: $url');
      print('Category ID: $categoryId'); // Added to verify categoryId

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Subcategories Response Status: ${response.statusCode}');
      print('Subcategories Response Body: ${response.body}');

      if (response.statusCode == 200) {
        CategoryService.initializeSubCategories(response.body);
      } else {
        throw Exception('Failed to load subcategories');
      }
    } catch (e) {
      print('Error loading subcategories: $e');
    }
  }
}
