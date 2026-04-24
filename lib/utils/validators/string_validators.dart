// utils/validators/string_validators.dart

class StringValidators {
  // Regex for validating email
  static final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // Regex for validating names (alphabets only)
  static final RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');

  // List of special characters for password validation
  static const List<String> specialCharacters = [
    '!', '@', '#', '\$', '%', '^', '&', '*', '(', ')', '-', '_', '+', '='
  ];

  // Checks if a string contains at least one special character
  static bool containsSpecialCharacter(String value) {
    for (var character in specialCharacters) {
      if (value.contains(character)) {
        return true;
      }
    }
    return false;
  }

  // General length validation
  static bool isWithinLength(String value, int min, int max) {
    return value.length >= min && value.length <= max;
  }
}
