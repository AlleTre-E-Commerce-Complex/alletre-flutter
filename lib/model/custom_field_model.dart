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
  dynamic value;
  List<String>? options;

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
    this.value,
    this.options,
  });

  factory CustomField.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'];
      final subCategoryId = json['subCategoryId'];
      final type = json['type'] as String? ?? 'text';
      final value = json['value'];
      final options = json['options'];
      
      // Keep array type as is, don't convert to text
      final isArrayType = type.toLowerCase() == 'array';
      
      // Handle special cases for laptop fields
      dynamic processedValue;
      if (value != null) {
        if (type == 'number') {
          processedValue = value.toString();
        } else if (isArrayType && value is List) {
          processedValue = value;  // Keep as List for array type
        } else {
          processedValue = value.toString();
        }
      }

      // Set options for dropdown and array fields
      List<String>? fieldOptions;
      if (options != null && options is List) {
        fieldOptions = options.map((e) => e.toString()).toList();
      }
      
      return CustomField(
        id: id is int ? id : int.tryParse(id.toString()) ?? 0,
        subCategoryId: subCategoryId is int ? subCategoryId : int.tryParse(subCategoryId.toString()) ?? 0,
        key: json['key'] as String? ?? '',
        resKey: json['resKey'] as String? ?? json['key'] as String? ?? '',
        type: type,  // Keep original type
        labelAr: json['labelAr'] as String? ?? '',
        labelEn: json['labelEn'] as String? ?? '',
        isArray: isArrayType,
        isRequired: json['required'] as bool? ?? false,
        value: processedValue,
        options: fieldOptions,
      );
    } catch (e, stackTrace) {
      print('Error parsing CustomField JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  // Update field value
  void updateValue(dynamic newValue) {
    if (newValue == null) {
      value = null;
      return;
    }

    // Handle different field types
    switch (type.toLowerCase()) {
      case 'number':
        if (newValue is num) {
          value = newValue;
        } else {
          value = num.tryParse(newValue.toString()) ?? newValue.toString();
        }
        break;
      case 'array':
        if (newValue is List) {
          value = newValue;  // Keep as List
        } else if (newValue is String) {
          // Handle comma-separated string
          if (newValue.contains(',')) {
            value = newValue.split(',').map((e) => e.trim()).toList();
          } else {
            value = [newValue];  // Single value as List
          }
        } else {
          value = [newValue.toString()];
        }
        break;
      default:
        value = newValue.toString();
    }
  }

  String get displayValue {
    if (value == null) return 'Not specified';
    
    if (type.toLowerCase() == 'array' && value is List) {
      return (value as List).join(', ');
    }
    
    // Format display value based on field key
    switch (key) {
      case 'screenSize':
        return '$value inches';
      case 'memory':
        return '$value GB';
      case 'releaseYear':
        return value.toString();
      case 'color':
        if (value is List) {
          return value.join(', ');
        }
        return value.toString();
      default:
        return value.toString();
    }
  }

  String get name => labelEn;

  @override
  String toString() {
    return 'CustomField{id: $id, key: $key, labelEn: $labelEn, type: $type, value: $value}';
  }
}

class CategoryFields {
  final List<CustomField> _fields;

  CategoryFields({required List<CustomField> fields}) : _fields = fields;

  List<CustomField> get fields => _fields;

  void addField(CustomField field) {
    _fields.add(field);
  }

  // Update field values from a map
  void updateFieldValues(Map<String, dynamic> values) {
    print('\nDEBUG: Starting field value updates');
    print('DEBUG: Update values received: $values');
    print('DEBUG: Current fields: ${_fields.map((f) => '${f.key}: ${f.value}').join(', ')}');

    for (var field in _fields) {
      print('\nDEBUG: Checking field: ${field.key} (${field.labelEn})');
      print('DEBUG: Current value: ${field.value}');
      print('DEBUG: Field type: ${field.type}');

      if (values.containsKey(field.key)) {
        final newValue = values[field.key];
        print('DEBUG: Found new value: $newValue (${newValue.runtimeType})');
        field.updateValue(newValue);
        print('DEBUG: Updated value is now: ${field.value}');
      } else {
        print('DEBUG: No new value found for ${field.key}');
      }
    }

    print('\nDEBUG: Field updates complete');
    print('DEBUG: Final fields: ${_fields.map((f) => '${f.key}: ${f.value}').join(', ')}');
  }

  // Merge with another CategoryFields instance
  void mergeWith(CategoryFields other) {
    print('DEBUG: Starting field merge');
    print('DEBUG: Current fields: ${_fields.map((f) => '${f.key}: ${f.value}').join(', ')}');
    print('DEBUG: Other fields: ${other.fields.map((f) => '${f.key}: ${f.value}').join(', ')}');

    for (var otherField in other.fields) {
      print('\nDEBUG: Processing field: ${otherField.key}');
      print('DEBUG: Field type: ${otherField.type}');
      print('DEBUG: Field value: ${otherField.value}');

      var existingFieldIndex = _fields.indexWhere((f) => f.key == otherField.key);
      
      if (existingFieldIndex == -1) {
        print('DEBUG: Adding new field: ${otherField.key} (${otherField.labelEn})');
        _fields.add(otherField);
      } else {
        var existingField = _fields[existingFieldIndex];
        print('DEBUG: Found existing field: ${existingField.key}');
        print('DEBUG: Existing value: ${existingField.value}');
        print('DEBUG: New value: ${otherField.value}');

        if (otherField.value != null) {
          print('DEBUG: Updating value for ${existingField.key}');
          existingField.updateValue(otherField.value);
          print('DEBUG: Updated value is now: ${existingField.value}');
        }
      }
    }

    print('\nDEBUG: Merge complete');
    print('DEBUG: Final fields: ${_fields.map((f) => '${f.key}: ${f.value}').join(', ')}');
  }

  factory CategoryFields.fromJson(Map<String, dynamic> json) {
    print('Creating CategoryFields from JSON: $json');
    try {
      final List<CustomField> allFields = [];

      // Handle the new API response structure with array and regular fields
      if (json['data'] != null) {
        final data = json['data'];
        if (data is Map<String, dynamic>) {
          // Extract array custom fields
          if (data['arrayCustomFields'] != null) {
            final arrayFields = data['arrayCustomFields'] as List<dynamic>;
            print('DEBUG: Processing ${arrayFields.length} array fields');
            allFields.addAll(
              arrayFields.map((field) => CustomField.fromJson({...field, 'type': 'array'}))
            );
          }

          // Extract regular custom fields
          if (data['regularCustomFields'] != null) {
            final regularFields = data['regularCustomFields'] as List<dynamic>;
            print('DEBUG: Processing ${regularFields.length} regular fields');
            allFields.addAll(
              regularFields.map((field) => CustomField.fromJson(field))
            );
          }
        } else if (data is List) {
          // Handle direct list format
          print('DEBUG: Processing direct list of ${data.length} fields');
          allFields.addAll(
            data.map((field) => CustomField.fromJson(field))
          );
        }
      }

      print('DEBUG: Total fields processed: ${allFields.length}');
      return CategoryFields(fields: allFields);
    } catch (e, stackTrace) {
      print('Error parsing CategoryFields JSON: $e');
      print('Stack trace: $stackTrace');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'CategoryFields{fields: $_fields}';
  }
}
