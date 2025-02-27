class SubCategory {
  final int id;
  final String nameEn;
  final String nameAr;
  final int categoryId;
  final String? imageLink;
  final List<CustomField> customFields;

  SubCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.categoryId,
    this.imageLink,
    required this.customFields,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    print('Creating SubCategory from JSON: $json');
    try {
      return SubCategory(
        id: json['id'] as int? ?? json['subcategoryId'] as int? ?? 0,
        nameEn: json['nameEn'] as String? ?? 
               json['name_en'] as String? ?? 
               json['name'] as String? ?? 
               '',
        nameAr: json['nameAr'] as String? ?? 
               json['name_ar'] as String? ?? 
               json['arabic_name'] as String? ?? 
               '',
        categoryId: json['categoryId'] as int? ?? 
                   json['category_id'] as int? ?? 
                   0,
        imageLink: json['imageLink'] as String? ?? 
                   json['image_link'] as String? ?? 
                   json['image'] as String?,
        customFields: _parseCustomFields(json),
      );
    } catch (e, stackTrace) {
      print('Error parsing SubCategory JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static List<CustomField> _parseCustomFields(Map<String, dynamic> json) {
    try {
      final fields = json['customFields'] ?? 
                     json['custom_fields'] ?? 
                     json['fields'] ?? 
                     [];
      
      if (fields is List) {
        return fields
            .whereType<Map<String, dynamic>>()
            .map((e) => CustomField.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error parsing custom fields: $e');
      return [];
    }
  }
}

class CustomField {
  final int id;
  final int subCategoryId;
  final String key;
  final String resKey;
  final String type;
  final String labelAr;
  final String labelEn;

  CustomField({
    required this.id,
    required this.subCategoryId,
    required this.key,
    required this.resKey,
    required this.type,
    required this.labelAr,
    required this.labelEn,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    return CustomField(
      id: json['id'] as int,
      subCategoryId: json['subCategoryId'] as int,
      key: json['key'] as String,
      resKey: json['resKey'] as String,
      type: json['type'] as String,
      labelAr: json['labelAr'] as String,
      labelEn: json['labelEn'] as String,
    );
  }
}
