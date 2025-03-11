// class CustomField {
//   final String id;
//   final String name;
//   final String type;
//   final bool required;
//   final String? description;
//   final List<String>? options;

//   CustomField({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.required,
//     this.description,
//     this.options,
//   });

//   factory CustomField.fromJson(Map<String, dynamic> json) {
//     return CustomField(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       type: json['type'] as String,
//       required: json['required'] as bool? ?? false,
//       description: json['description'] as String?,
//       options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'type': type,
//       'required': required,
//       'description': description,
//       'options': options,
//     };
//   }
// }

// class CategoryFields {
//   final List<CustomField> fields;

//   CategoryFields({required this.fields});

//   factory CategoryFields.fromJson(Map<String, dynamic> json) {
//     return CategoryFields(
//       fields: (json['fields'] as List<dynamic>)
//           .map((e) => CustomField.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'fields': fields.map((e) => e.toJson()).toList(),
//     };
//   }
// }
