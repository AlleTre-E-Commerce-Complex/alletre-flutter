// ignore_for_file: avoid_print

class CustomField {
  final int id;
  final int subCategoryId;
  final String key;
  final String resKey;
  String type;
  final String labelAr;
  final String labelEn;
  bool isArray;
  bool isRequired;
  String? unit;
  String? validation;

  CustomField({
    required this.id,
    required this.subCategoryId,
    required this.key,
    required this.resKey,
    required this.type,
    required this.labelAr,
    required this.labelEn,
    this.isArray = false,
    this.isRequired = false,
    this.unit,
    this.validation,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'];
      final subCategoryId = json['subCategoryId'];
      final type = json['type'] as String? ?? 'text';
      
      // Convert array type to boolean flag
      final isArrayType = type.toLowerCase() == 'array';
      
      return CustomField(
        id: id is int ? id : int.tryParse(id.toString()) ?? 0,
        subCategoryId: subCategoryId is int ? subCategoryId : int.tryParse(subCategoryId.toString()) ?? 0,
        key: json['key'] as String? ?? '',
        resKey: json['resKey'] as String? ?? json['key'] as String? ?? '',
        type: isArrayType ? 'text' : type, // Store base type if array
        labelAr: json['labelAr'] as String? ?? '',
        labelEn: json['labelEn'] as String? ?? '',
        isArray: isArrayType,
        isRequired: json['required'] as bool? ?? false,
        unit: _determineUnit(json['key'] as String? ?? '', json['labelEn'] as String? ?? ''),
        validation: _determineValidation(json['key'] as String? ?? '', json['labelEn'] as String? ?? '', type),
      );
    } catch (e, stackTrace) {
      print('Error parsing CustomField JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static String? _determineUnit(String key, String label) {
    final fieldName = '${key.toLowerCase()} ${label.toLowerCase()}';
    if (fieldName.contains('screen size')) return 'inches';
    if (fieldName.contains('ram')) return 'GB';
    if (fieldName.contains('area')) return 'sq ft';
    return null;
  }

  static String? _determineValidation(String key, String label, String type) {
    final fieldName = '${key.toLowerCase()} ${label.toLowerCase()}';
    if (type == 'number') {
      if (fieldName.contains('year')) return 'year';
      if (fieldName.contains('screen size')) return 'positive';
      if (fieldName.contains('ram')) return 'positive';
    }
    return null;
  }

  String get name => labelEn;
}

class CategoryFields {
  final List<CustomField> _fields;

  CategoryFields({required List<CustomField> fields}) : _fields = fields;

  List<CustomField> get fields => _fields;

  void addField(CustomField field) {
    _fields.add(field);
  }

  factory CategoryFields.fromJson(Map<String, dynamic> json) {
    print('Creating CategoryFields from JSON: $json');
    try {
      final List<CustomField> allFields = [];

      // Handle both direct list and wrapped formats
      List<dynamic> fieldsData;
      if (json['data'] != null) {
        if (json['data'] is List) {
          fieldsData = json['data'] as List<dynamic>;
        } else if (json['data'] is Map<String, dynamic>) {
          final data = json['data'] as Map<String, dynamic>;
          if (data['customFields'] != null) {
            fieldsData = data['customFields'] as List<dynamic>;
          } else {
            fieldsData = [];
          }
        } else {
          fieldsData = [];
        }
      } else if (json['customFields'] != null) {
        fieldsData = json['customFields'] as List<dynamic>;
      } else {
        fieldsData = [];
      }

      // Convert all fields
      allFields.addAll(
        fieldsData.map((e) => CustomField.fromJson(e as Map<String, dynamic>)).toList(),
      );

      // Ensure required fields for Electronics category
      if (allFields.any((f) => f.key.toLowerCase().contains('screen size'))) {
        // This is likely an Electronics subcategory
        if (!allFields.any((f) => f.key.toLowerCase() == 'brand')) {
          final subCategoryId = allFields.isNotEmpty ? allFields.first.subCategoryId : 0;
          allFields.add(CustomField(
            id: 0,
            subCategoryId: subCategoryId,
            key: 'brand',
            resKey: 'brand',
            type: 'text',
            labelAr: 'العلامة التجارية',
            labelEn: 'Brand',
            isArray: false,
            isRequired: true,
          ));
        }

        if (!allFields.any((f) => f.key.toLowerCase() == 'model')) {
          final subCategoryId = allFields.isNotEmpty ? allFields.first.subCategoryId : 0;
          allFields.add(CustomField(
            id: 0,
            subCategoryId: subCategoryId,
            key: 'model',
            resKey: 'model',
            type: 'text',
            labelAr: 'الموديل',
            labelEn: 'Model',
            isArray: false,
            isRequired: true,
          ));
        }
      }

      return CategoryFields(fields: allFields);
    } catch (e, stackTrace) {
      print('Error parsing CategoryFields JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }
}
