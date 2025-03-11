// import 'dart:developer' as developer;
// import 'package:flutter/material.dart';
// import '../../../model/custom_field_model.dart';
// import '../../../controller/services/custom_fields_service.dart';
// import '../../../utils/themes/app_theme.dart';

// class CustomFieldsGrid extends StatelessWidget {
//   final String? categoryId;
//   final String? subcategoryId;
//   final ValueNotifier<Map<String, dynamic>> fieldValues;

//   const CustomFieldsGrid({
//     Key? key,
//     this.categoryId,
//     this.subcategoryId,
//     required this.fieldValues,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     if (categoryId == null && subcategoryId == null) {
//       return const SizedBox.shrink();
//     }

//     return FutureBuilder<CategoryFields>(
//       future: _fetchCustomFields(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 8),
//                   Text(
//                     'Loading custom fields...',
//                     style: TextStyle(
//                       color: onSecondaryColor,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (snapshot.hasError) {
//           developer.log('Error loading custom fields: ${snapshot.error}');
//           return Center(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     color: errorColor,
//                     size: 24,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Failed to load custom fields: ${snapshot.error}',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: errorColor,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () {
//                       // Force a rebuild to retry loading
//                       (context as Element).markNeedsBuild();
//                     },
//                     child: const Text('Retry'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }

//         if (!snapshot.hasData || snapshot.data!.fields.isEmpty) {
//           developer.log('No custom fields found for category/subcategory');
//           return const SizedBox.shrink();
//         }

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Divider(thickness: 1, color: primaryColor),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 8.0),
//               child: Text(
//                 "Additional Details",
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                   color: onSecondaryColor,
//                 ),
//               ),
//             ),
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 3,
//               ),
//               itemCount: snapshot.data!.fields.length,
//               itemBuilder: (context, index) {
//                 final field = snapshot.data!.fields[index];
//                 return _buildFieldWidget(field);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<CategoryFields> _fetchCustomFields() async {
//     try {
//       if (subcategoryId != null) {
//         developer.log('Fetching subcategory fields for ID: $subcategoryId');
//         return await CustomFieldsService.getCustomFieldsBySubcategory(
//             subcategoryId!);
//       } else if (categoryId != null) {
//         developer.log('Fetching category fields for ID: $categoryId');
//         return await CustomFieldsService.getCustomFieldsByCategory(categoryId!);
//       }
//       throw Exception('No category or subcategory ID provided');
//     } catch (e) {
//       developer.log('Error fetching fields', error: e);
//       rethrow;
//     }
//   }

//   Widget _buildFieldWidget(CustomField field) {
//     switch (field.type.toLowerCase()) {
//       case 'text':
//         return _buildTextField(field);
//       case 'number':
//         return _buildNumberField(field);
//       case 'select':
//         return _buildSelectField(field);
//       default:
//         developer.log('Unknown field type: ${field.type}');
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildTextField(CustomField field) {
//     return TextFormField(
//       decoration: _getInputDecoration(field),
//       onChanged: (value) => _updateFieldValue(field.id, value),
//       validator: _getValidator(field),
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget _buildNumberField(CustomField field) {
//     return TextFormField(
//       keyboardType: TextInputType.number,
//       decoration: _getInputDecoration(field),
//       onChanged: (value) => _updateFieldValue(field.id, value),
//       validator: (value) {
//         final baseValidation = _getValidator(field)(value);
//         if (baseValidation != null) return baseValidation;

//         if (value != null && value.isNotEmpty) {
//           if (double.tryParse(value) == null) {
//             return '${field.name} must be a number';
//           }
//         }
//         return null;
//       },
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   Widget _buildSelectField(CustomField field) {
//     return DropdownButtonFormField<String>(
//       decoration: _getInputDecoration(field),
//       items: field.options?.map((option) {
//         return DropdownMenuItem(
//           value: option,
//           child: Text(
//             option,
//             style: const TextStyle(
//               color: onSecondaryColor,
//               fontSize: 12,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         );
//       }).toList(),
//       onChanged: (value) => _updateFieldValue(field.id, value),
//       validator: _getValidator(field),
//       autovalidateMode: AutovalidateMode.onUserInteraction,
//     );
//   }

//   InputDecoration _getInputDecoration(CustomField field) {
//     return InputDecoration(
//       labelText: '${field.name}${field.required ? ' *' : ''}',
//       labelStyle: const TextStyle(fontSize: 12),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: errorColor),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: errorColor),
//       ),
//       helperText: field.description,
//       helperStyle: const TextStyle(fontSize: 10),
//     );
//   }

//   FormFieldValidator<String> _getValidator(CustomField field) {
//     return (value) {
//       if (field.required && (value == null || value.isEmpty)) {
//         return '${field.name} is required';
//       }
//       return null;
//     };
//   }

//   void _updateFieldValue(String fieldId, dynamic value) {
//     final currentValues = Map<String, dynamic>.from(fieldValues.value);
//     currentValues[fieldId] = value;
//     fieldValues.value = currentValues;
//     developer.log('Updated field $fieldId with value: $value');
//   }
// }
