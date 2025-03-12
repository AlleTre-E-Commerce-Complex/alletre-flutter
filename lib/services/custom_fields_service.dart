import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:alletre_app/model/custom_field_model.dart';

class CustomFieldsService {
  static const String baseUrl = 'https://www.alletre.com/api';

  static Future<CategoryFields> getCustomFieldsBySubcategory(String subcategoryId) async {
    try {
      debugPrint('🔄 Fetching custom fields for subcategory: $subcategoryId');
      final response = await http.get(
        Uri.parse('$baseUrl/categories/custom-fields?subCategoryId=$subcategoryId'),
      );

      debugPrint('📥 Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        debugPrint('📦 Response data: $jsonResponse');
        
        if (jsonResponse['success'] == true) {
          return CategoryFields.fromJson(jsonResponse);
        } else {
          const error = '❌ API returned success: false';
          debugPrint(error);
          throw Exception(error);
        }
      } else {
        final error = '❌ Failed to fetch custom fields: ${response.statusCode}';
        debugPrint(error);
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching custom fields: $e');
      rethrow;
    }
  }
}
