// user_provider.dart
import 'package:alletre_app/model/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserModel _user = UserModel();
  bool _agreeToTerms = false;
  bool _rememberPassword = false;

  // Getter for user
  UserModel get user => _user;

  // Getter for agreement and remember password flags
  bool get agreeToTerms => _agreeToTerms;
  bool get rememberPassword => _rememberPassword;

  // Setters for user fields
  void setFullName(String value) {
    _user.fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _user.email = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _user.phoneNumber = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _user.password = value;
    notifyListeners();
  }

  void setConfirmPassword(String value) {
    _user.confirmPassword = value;
    notifyListeners();
  }

  // Setters for additional fields
  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void toggleRememberPassword() {
    _rememberPassword = !_rememberPassword;
    notifyListeners();
  }
}
