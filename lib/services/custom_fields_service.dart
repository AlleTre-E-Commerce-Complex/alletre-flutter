// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alletre_app/model/custom_field_model.dart';

class CustomFieldsService {
  static const String baseUrl = 'https://www.alletre.com/api';

  // Get system fields
  static Future<CategoryFields> getSystemFields() async {
    print('🔄 Fetching system fields');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/system-fields'),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final fields = CategoryFields.fromJson(data);
          print('✅ Successfully parsed system fields');
          return fields;
        }
      }
      
      print('❌ Failed to fetch system fields');
      throw Exception('Failed to fetch system fields');
    } catch (e) {
      print('❌ Error fetching system fields: $e');
      rethrow;
    }
  }

  // Get custom fields by subcategory
  static Future<CategoryFields> getCustomFieldsBySubcategory(String subcategoryId) async {
    print('🔄 Fetching custom fields for subcategory: $subcategoryId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/custom-fields?subCategoryId=$subcategoryId'),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final Map<String, dynamic> fieldsData = data['data'];
          final List<Map<String, dynamic>> fields = [];

          // Process array custom fields
          if (fieldsData['arrayCustomFields'] != null) {
            final arrayFields = fieldsData['arrayCustomFields'] as List<dynamic>;
            print('DEBUG: Processing ${arrayFields.length} array fields');
            for (var field in arrayFields) {
              final fieldMap = field as Map<String, dynamic>;
              print('DEBUG: Processing array field: ${fieldMap['key']} (${fieldMap['labelEn']})');
              fields.add({
                ...fieldMap,
                'type': 'array',
                'isArray': true,
              });
            }
          }

          // Process regular custom fields
          if (fieldsData['regularCustomFields'] != null) {
            final regularFields = fieldsData['regularCustomFields'] as List<dynamic>;
            print('DEBUG: Processing ${regularFields.length} regular fields');
            for (var field in regularFields) {
              final fieldMap = field as Map<String, dynamic>;
              String type = fieldMap['type'] ?? 'text';
              final key = fieldMap['key'] as String;
              
              print('DEBUG: Processing regular field: $key (${fieldMap['labelEn']})');
              print('DEBUG: Original type: $type');
              
              // Determine correct type based on field key
              switch (key) {
                case 'screenSize':
                case 'memory':
                case 'releaseYear':
                  type = 'number';
                  print('DEBUG: Changed type to number for $key');
                  break;
                case 'operatingSystem':
                case 'regionOfManufacture':
                case 'brandId':
                case 'model':
                  type = 'text';
                  print('DEBUG: Kept text type for $key');
                  break;
              }

              fields.add({
                ...fieldMap,
                'type': type,
                'isArray': false,
              });
              print('DEBUG: Added field $key with type $type');
            }
          }

          print('DEBUG: Total fields to process: ${fields.length}');
          final categoryFields = CategoryFields.fromJson({'data': fields});
          print('✅ Successfully created CategoryFields');
          print('DEBUG: Final fields count: ${categoryFields.fields.length}');
          return categoryFields;
        }
      }
      
      print('❌ Failed to fetch custom fields');
      throw Exception('Failed to fetch custom fields');
    } catch (e) {
      print('❌ Error fetching custom fields: $e');
      rethrow;
    }
  }

  // Get auction details
  static Future<Map<String, dynamic>?> getAuctionDetails(String auctionId) async {
    print('🔄 Fetching auction details: $auctionId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('✅ Successfully fetched auction details');
          return data['data'];
        }
      }
      
      print('❌ API returned no data or success: false');
      return null;
    } catch (e) {
      print('❌ Error fetching auction details: $e');
      return null;
    }
  }

  // Get listed product details
  static Future<Map<String, dynamic>?> getListedProductDetails(String productId) async {
    print('🔄 Fetching listed product details: $productId');
    try {
      // Don't try to fetch details if productId is 0 or null
      if (productId == '0' || productId.isEmpty) {
        print('⚠️ Invalid product ID: $productId');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auctions/listedProducts/$productId/details'),
      );

      print('📥 Response status code: ${response.statusCode}');
      print('📦 Response data: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Response data type: ${data.runtimeType}');
        print('DEBUG: Success: ${data['success']}, Has data: ${data['data'] != null}');
        
        if (data['success'] == true && data['data'] != null) {
          final responseData = data['data'] as Map<String, dynamic>;
          print('DEBUG: Response data fields: ${responseData.keys.toList()}');
          
          if (responseData['customFields'] != null) {
            final customFields = responseData['customFields'] as Map<String, dynamic>;
            print('DEBUG: Custom fields type: ${customFields.runtimeType}');
            print('DEBUG: Custom fields keys: ${customFields.keys.toList()}');
            print('DEBUG: Custom fields values: ${customFields.values.toList()}');
          }
          
          print('✅ Successfully fetched listed product details');
          return responseData;
        }
      }
      
      print('❌ API returned no data or success: false');
      return null;
    } catch (e) {
      print('❌ Error fetching listed product details: $e');
      return null;
    }
  }
}
