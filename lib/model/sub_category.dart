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
  CategoryFields? _customFields;

  SubCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryId,
    this.imageLink,
    this.imagePath,
    this.createdAt,
  });

  CategoryFields? get customFields => _customFields;
  set customFields(CategoryFields? fields) => _customFields = fields;

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

        // For Electronics category (ID: 1), ensure required fields are present
        if (subCategory.categoryId == 1) {
          // Update brand field to be required
          final brandField = fields.firstWhere(
            (f) => f.resKey == 'brand' || f.key == 'brandId',
            orElse: () => CustomField(
              id: 0,
              subCategoryId: subCategory.id,
              key: 'brandId',
              resKey: 'brand',
              type: 'text',
              labelAr: 'ماركة',
              labelEn: 'Brand',
              isRequired: true,
            ),
          );
          brandField.isRequired = true;
          if (!fields.contains(brandField)) {
            fields.add(brandField);
          }

          // Update model field to be required
          final modelField = fields.firstWhere(
            (f) => f.key == 'model',
            orElse: () => CustomField(
              id: 0,
              subCategoryId: subCategory.id,
              key: 'model',
              resKey: 'model',
              type: 'text',
              labelAr: 'موديل',
              labelEn: 'Model',
              isRequired: true,
            ),
          );
          modelField.isRequired = true;
          if (!fields.contains(modelField)) {
            fields.add(modelField);
          }

          // Set validation and units based on field types
          for (var field in fields) {
            final key = field.key.toLowerCase();
            final label = field.labelEn.toLowerCase();
            
            if (field.type == 'array') {
              field.isArray = true;
              field.type = 'text';
            }

            if (key.contains('screen size') || label.contains('screen size')) {
              field.unit = 'inches';
              field.type = 'number';
              field.validation = 'positive';
            } else if (key.contains('ram') || label.contains('ram size')) {
              field.unit = 'GB';
              field.type = 'number';
              field.validation = 'positive';
            } else if (key.contains('year') || label.contains('release year')) {
              field.type = 'number';
              field.validation = 'year';
            }
          }
        }

        subCategory._customFields = CategoryFields(fields: fields);
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
