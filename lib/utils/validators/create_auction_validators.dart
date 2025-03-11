import 'dart:io';

class CreateAuctionValidation {
  static String? validateItemName(String? value) {
    return value!.isEmpty ? "Enter item name" : null;
  }

  static String? validateCategory(String? value) {
    return value == null ? "Select a category" : null;
  }

  static String? validateSubCategory(String? value) {
    return value == null ? "Select a sub category" : null;
  }

  static String? validateDescription(String? value) {
    return value!.isEmpty ? "Enter item description" : null;
  }

  static String? validateItemCondition(String? value) {
    return value == null ? "Select item condition" : null;
  }

  static String? validateMediaSection(List<File> mediaList) {
    if (mediaList.isEmpty || mediaList.length < 3) {
      return "Please upload atleast 3 images";
    }
    return null;
  }

  static String? validatePrice(String? value) {
    return value!.isEmpty ? "Enter start price" : null;
  }

  // Custom field validation methods
  static String? validateCustomField(
      String fieldName, String? value, String type,
      {bool isRequired = false}) {
    if (isRequired && (value == null || value.isEmpty)) {
      return "$fieldName is required";
    }

    if (value != null && value.isNotEmpty) {
      switch (type.toLowerCase()) {
        case 'number':
          if (double.tryParse(value) == null) {
            return "$fieldName must be a valid number";
          }
          break;
        case 'text':
          // Basic text validation - could add more specific rules if needed
          break;
        case 'select':
          // Selection validation handled by dropdown widget
          break;
      }
    }

    return null;
  }

  // static String? validateColor(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Color is required';
  //   }
  //   return null;
  // }

  // static String? validateModel(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Model is required';
  //   }
  //   return null;
  // }

  static Map<String, bool> getRequiredFields(String? subcategory) {
    return {
      'Color': true,
      'Model': true,
      'Screen Size': false,
      'Operating System': false,
      'Release Year': false,
      'Region of Manufacture': false,
      'RAM Size': false,
      'Processor': false,
      'Brand': false,
      'Graphics Card': false,
      'Camera Type': true,
      'Memory': true,
      'Material': true,
      'Type': false,
      'Age': false,
      'Number of Rooms': false,
      'Total Area (Sq Ft)': false,
      'Number of Floors': false,
      'Land Type': false
    };
  }
}
