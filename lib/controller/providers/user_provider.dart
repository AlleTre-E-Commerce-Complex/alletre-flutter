import 'package:alletre_app/model/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  final UserModel _user = UserModel();
  bool _agreeToTerms = false;
  bool _rememberPassword = false;

  // Getter for user
  UserModel get user => _user;

  // Getter for individual fields
  String get password => _user.password; // Added getter for password
  bool get agreeToTerms => _agreeToTerms;
  bool get rememberPassword => _rememberPassword;

  // Setters for user fields
  void setName(String value) {
    _user.name = value;
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

  // Setters for login fields (Login data)
  void setLoginEmail(String value) {
    _user.email = value;
    notifyListeners();
  }

  void setLoginPassword(String value) {
    _user.password = value;
    notifyListeners();
  }

  // Validation for login credentials (Checks if login email and password matches the stored data)
  bool validateLoginCredentials() {
    return _user.email == _user.email && _user.password == _user.password;
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
