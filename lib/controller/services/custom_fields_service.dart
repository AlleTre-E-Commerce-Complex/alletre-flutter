// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'package:http/http.dart' as http;
// import '../../model/custom_field_model.dart';

// class CustomFieldsService {
//   static const String baseUrl = 'https://www.alletre.com/api';

//   static Future<CategoryFields> getCustomFieldsByCategory(String categoryId) async {
//     try {
//       developer.log('Fetching custom fields for category: $categoryId');
//       final response = await http.get(
//         Uri.parse('$baseUrl/categories/custom-fields?categoryId=$categoryId'),
//       );

//       if (response.statusCode == 200) {
//         developer.log('Successfully fetched category fields');
//         return CategoryFields.fromJson(jsonDecode(response.body));
//       } else {
//         final error = 'Failed to fetch category fields: ${response.statusCode}';
//         developer.log(error);
//         throw Exception(error);
//       }
//     } catch (e) {
//       developer.log('Error fetching category fields', error: e);
//       rethrow;
//     }
//   }

//   static Future<CategoryFields> getCustomFieldsBySubcategory(String subcategoryId) async {
//     try {
//       developer.log('Fetching custom fields for subcategory: $subcategoryId');
//       final response = await http.get(
//         Uri.parse('$baseUrl/categories/custom-fields?subCategoryId=$subcategoryId'),
//       );

//       if (response.statusCode == 200) {
//         developer.log('Successfully fetched subcategory fields');
//         return CategoryFields.fromJson(jsonDecode(response.body));
//       } else {
//         final error = 'Failed to fetch subcategory fields: ${response.statusCode}';
//         developer.log(error);
//         throw Exception(error);
//       }
//     } catch (e) {
//       developer.log('Error fetching subcategory fields', error: e);
//       rethrow;
//     }
//   }
// }
