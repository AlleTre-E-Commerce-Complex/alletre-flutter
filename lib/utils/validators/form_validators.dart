// utils/validators/form_validators.dart
import 'package:alletre_app/controller/providers/user_provider.dart';
import 'package:alletre_app/utils/validators/string_validators.dart';

class FormValidators {

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!StringValidators.nameRegex.hasMatch(value)) {
      return 'Name can only contain alphabets';
    }
    if (!StringValidators.isWithinLength(value, 3, 20)) {
      return 'Name must be 3 to 20 characters long';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!StringValidators.emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!StringValidators.phoneRegex.hasMatch(value)) {
      return 'Phone number can contain only digits';
    }
    if (!StringValidators.isWithinLength(value, 10, 15)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!StringValidators.isWithinLength(value, 8, 30)) {
      return 'Password must be at least 8 characters long';
    }
    if (!StringValidators.containsSpecialCharacter(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password cannot be empty';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateLoginEmail(String? value, UserProvider userProvider) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (value != userProvider.user.email) {
      return 'Email does not match any registered user';
    }
    return null;
  }

  static String? validateLoginPassword(String? value, UserProvider userProvider) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value != userProvider.user.password) {
      return 'Invalid password';
    }
    return null;
  }
}
