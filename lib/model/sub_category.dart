// ignore_for_file: avoid_print
import 'custom_field_model.dart';

class SubCategory {
  final int id;
  final String nameEn;
  final String nameAr;
  final int categoryId;
  final String? imageLink;
  final String? imagePath;
  final String? createdAt;
  CategoryFields? customFields;

  SubCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryId,
    this.imageLink,
    this.imagePath,
    this.createdAt,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    print('📦 Creating SubCategory from JSON: $json');
    try {
      final id = json['id'];
      final categoryId = json['categoryId'] ?? json['category_id'];
      final subCategory = SubCategory(
        id: id is int ? id : int.tryParse(id.toString()) ?? 0,
        nameEn: json['nameEn'] as String? ?? 
               json['name_en'] as String? ?? 
               json['name'] as String? ?? 
               '',
        nameAr: json['nameAr'] as String? ?? 
               json['name_ar'] as String? ?? 
               json['arabic_name'] as String? ?? 
               '',
        categoryId: categoryId is int ? categoryId : int.tryParse(categoryId.toString()) ?? 0,
        imageLink: json['imageLink'] as String? ?? 
                  json['image_link'] as String? ?? 
                  json['image'] as String?,
        imagePath: json['imagePath'] as String?,
        createdAt: json['createdAt'] as String?,
      );

      // Parse custom fields if present
      if (json['customFields'] != null) {
        final customFieldsList = json['customFields'] as List<dynamic>;
        final fields = customFieldsList.map((field) => CustomField.fromJson(field as Map<String, dynamic>)).toList();

        subCategory.customFields = CategoryFields(fields: fields);
      }

      print('✅ Successfully created SubCategory: ${subCategory.nameEn} (ID: ${subCategory.id})');
      return subCategory;
    } catch (e, stackTrace) {
      print('❌ Error parsing SubCategory JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }
}
