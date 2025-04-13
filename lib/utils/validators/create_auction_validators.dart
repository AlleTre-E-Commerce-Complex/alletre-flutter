import 'dart:io';

class CreateAuctionValidation {
  static String? validateTitle(String? value) {
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

  static String? validateItemCondition(String? condition, String category) {
    if (category == "Properties") {
      return null; // No validation needed for Properties category
    }
    if (condition == null || condition.isEmpty) {
      return 'Please select an item condition';
    }
    return null;
  }

  static String? validateMediaSection(List<File> mediaList) {
    if (mediaList.isEmpty || mediaList.length < 3) {
      return "Please upload atleast 3 images or videos";
    }
    if (mediaList.length > 5) {
      return "You can upload maximum 5 images or videos";
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter start price";
    }
    final price = double.tryParse(value);
    if (price == null || price <= 0) {
      return "Enter a valid price";
    }
    return null;
  }

  static String? validatePurchasePrice(String? value, String startPrice) {
    if (value == null || value.isEmpty) {
      return "Enter purchase price";
    }

    final purchasePrice = double.tryParse(value);
    final startingPrice = double.tryParse(startPrice);

    if (purchasePrice == null || purchasePrice <= 0) {
      return "Enter a valid price";
    }

    if (startingPrice == null || startingPrice <= 0) {
      return "Invalid start price";
    }

    if (purchasePrice < startingPrice * 1.3) {
      return "Purchase price must be at least 30% more than\nstart price";
    }

    return null;
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

  // static String? validateTitle(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return 'Title is required';
  //   }
  //   if (value.length < 3) {
  //     return 'Title must be at least 3 characters';
  //   }
  //   return null;
  // }

  static String? validateAuctionDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description is required';
    }
    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }
    return null;
  }

  static String? validateAuctionCategory(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Category is required';
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
