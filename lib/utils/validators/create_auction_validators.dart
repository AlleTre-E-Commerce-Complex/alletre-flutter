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
    if (mediaList.isEmpty && mediaList.length < 3) {
      return "Please upload at least 3 image";
    }
    return null;
  }

  static String? validatePrice(String? value) {
    return value!.isEmpty ? "Enter start price" : null;
  }
}
