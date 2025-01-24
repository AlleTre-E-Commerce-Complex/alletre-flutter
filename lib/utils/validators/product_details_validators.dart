import 'dart:io';

class ProductDetailsValidation {
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
    if (mediaList.isEmpty) {
      return "Please upload at least one image";
    }
    if (mediaList.length < 3) {
      return "Please upload at least 3 images";
    }
    return null;
  }
}
