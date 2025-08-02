// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alletre_app/model/custom_field_model.dart';
import 'package:flutter/foundation.dart';

class CustomFieldsService {
  static const String baseUrl = 'http://10.120.234.182:3001/api';

  // Get all system fields
  static Future<CategoryFields> getSystemFields() async {
    print('🔄 Fetching all system fields');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/system-fields'),
      );

      print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Creating CategoryFields from JSON: $data');
        if (data['success'] == true && data['data'] != null) {
          final List<Map<String, dynamic>> fields = [];
          if (data['data'] is List) {
            print(
                'DEBUG: Processing direct list of ${data['data'].length} fields');
            fields.addAll(List<Map<String, dynamic>>.from(data['data']));
          } else if (data['data'] is Map) {
            print('DEBUG: Processing map of fields');
            final Map<String, dynamic> fieldsMap = data['data'];
            fields.addAll(fieldsMap.entries.map((entry) => {
                  'name': entry.key,
                  'type': entry.value['type'] ?? 'text',
                  'options': entry.value['options'],
                  'isArray': entry.value['isArray'] ?? false,
                }));
          }
          print('DEBUG: Total fields processed: ${fields.length}');
          final categoryFields = CategoryFields.fromJson({'data': fields});
          print('✅ Successfully created CategoryFields');
          return categoryFields;
        }
      }

      print('❌ Failed to fetch system fields');
      throw Exception('Failed to fetch system fields');
    } catch (e) {
      print('❌ Error fetching system fields: $e');
      rethrow;
    }
  }

  // Get custom fields by category ID
  static Future<CategoryFields> getCustomFieldsByCategory(
      String categoryId) async {
    print('🔄 Fetching custom fields for category: $categoryId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories/custom-fields?categoryId=$categoryId'),
      );

      print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final Map<String, dynamic> fieldsData = data['data'];
          final List<Map<String, dynamic>> fields = [];

          // Process array custom fields
          if (fieldsData['arrayCustomFields'] != null) {
            final arrayFields =
                fieldsData['arrayCustomFields'] as List<dynamic>;
            for (var field in arrayFields) {
              final fieldMap = field as Map<String, dynamic>;
              fields.add({
                ...fieldMap,
                'type': 'array',
                'isArray': true,
              });
            }
          }

          // Process regular custom fields
          if (fieldsData['regularCustomFields'] != null) {
            final regularFields =
                fieldsData['regularCustomFields'] as List<dynamic>;
            for (var field in regularFields) {
              final fieldMap = field as Map<String, dynamic>;
              String type = fieldMap['type'] ?? 'text';
              final key = fieldMap['key'] as String;
              // Determine correct type based on field key
              switch (key) {
                case 'screenSize':
                case 'memory':
                case 'releaseYear':
                  type = 'number';
                  break;
                case 'operatingSystem':
                case 'regionOfManufacture':
                case 'brandId':
                case 'model':
                  type = 'text';
                  break;
              }
              fields.add({
                ...fieldMap,
                'type': type,
                'isArray': false,
              });
            }
          }

          // Always add 'model' field if present in response (not in arrays or regulars)
          if (fieldsData['model'] != null) {
            final modelField = fieldsData['model'] as Map<String, dynamic>;
            fields.add({
              ...modelField,
              'type': modelField['type'] ?? 'text',
              'isArray': false,
            });
          }

          final categoryFields = CategoryFields.fromJson({'data': fields});
          print('✅ Successfully created CategoryFields');
          return categoryFields;
        }
      }

      print('❌ Failed to fetch category custom fields');
      throw Exception('Failed to fetch category custom fields');
    } catch (e) {
      print('❌ Error fetching category custom fields: $e');
      rethrow;
    }
  }

  // Get custom fields by subcategory ID
  static Future<CategoryFields> getCustomFieldsBySubcategory(
      String subCategoryId) async {
    print('🔄 Fetching custom fields for subcategory: $subCategoryId');
    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/categories/custom-fields?subCategoryId=$subCategoryId'),
      );

      print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final Map<String, dynamic> fieldsData = data['data'];
          final List<Map<String, dynamic>> fields = [];

          // Process array custom fields
          if (fieldsData['arrayCustomFields'] != null) {
            final arrayFields =
                fieldsData['arrayCustomFields'] as List<dynamic>;
            for (var field in arrayFields) {
              final fieldMap = field as Map<String, dynamic>;
              fields.add({
                ...fieldMap,
                'type': 'array',
                'isArray': true,
              });
            }
          }

          // Process regular custom fields
          if (fieldsData['regularCustomFields'] != null) {
            final regularFields =
                fieldsData['regularCustomFields'] as List<dynamic>;
            for (var field in regularFields) {
              final fieldMap = field as Map<String, dynamic>;
              String type = fieldMap['type'] ?? 'text';
              final key = fieldMap['key'] as String;
              // Determine correct type based on field key
              switch (key) {
                case 'screenSize':
                case 'memory':
                case 'releaseYear':
                  type = 'number';
                  break;
                case 'operatingSystem':
                case 'regionOfManufacture':
                case 'brandId':
                case 'model':
                  type = 'text';
                  break;
              }
              fields.add({
                ...fieldMap,
                'type': type,
                'isArray': false,
              });
            }
          }

          // Always add 'model' field if present in response (not in arrays or regulars)
          if (fieldsData['model'] != null) {
            final modelField = fieldsData['model'] as Map<String, dynamic>;
            fields.add({
              ...modelField,
              'type': modelField['type'] ?? 'text',
              'isArray': false,
            });
          }

          // Always add 'brand' field for Home Appliances (subCategoryId == 1 or 16-20) if not present
          final brandSubcategoryIds = ['1', '16', '17', '18', '19', '20'];
          if (brandSubcategoryIds.contains(subCategoryId) &&
              !fields.any(
                  (f) => (f['key'] == 'brand' || f['resKey'] == 'brand'))) {
            fields.add({
              'id': -1,
              'subCategoryId': int.tryParse(subCategoryId) ?? -1,
              'key': 'brand',
              'resKey': 'brand',
              'type': 'text',
              'labelAr': 'ماركة',
              'labelEn': 'Brand',
              'isArray': false,
              'isRequired': true
            });
          }

          final categoryFields = CategoryFields.fromJson({'data': fields});
          print('✅ Successfully created CategoryFields');
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
  static Future<Map<String, dynamic>?> getAuctionDetails(
      String auctionId) async {
    // print('🔄 Fetching auction details: $auctionId');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auctions/user/$auctionId/details'),
      );

      // print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // print('✅ Successfully fetched auction details');
          return data['data'] as Map<String, dynamic>;
        }
      }

      print('❌ Failed to fetch auction details');
      return null;
    } catch (e) {
      // Suppress error message
      debugPrint('Error fetching auction details: $e');
      return null;
    }
  }

  // Get listed product details
  static Future<Map<String, dynamic>?> getListedProductDetails(
      String productId) async {
    // print('🔄 Fetching listed product details: $productId');
    try {
      // Don't try to fetch details if productId is 0 or null
      if (productId == '0' || productId.isEmpty) {
        print('⚠️ Invalid product ID: $productId');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/auctions/listedProducts/$productId/details'),
      );

      // print('📥 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // print('✅ Successfully fetched listed product details');
          return data['data'] as Map<String, dynamic>;
        }
      }

      print('❌ Failed to fetch listed product details');
      return null;
    } catch (e) {
      print('❌ Error fetching listed product details: $e');
      return null;
    }
  }
}
