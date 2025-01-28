// import 'package:alletre_app/model/user_model.dart';
// import 'package:flutter/material.dart';

// class UserProvider with ChangeNotifier {
//   final UserModel _user = UserModel();
//   bool _agreeToTerms = false;
//   bool _rememberPassword = false;

//   // Getter for user
//   UserModel get user => _user;

//   // Getter for individual fields
//   String get password => _user.password; // Added getter for password
//   bool get agreeToTerms => _agreeToTerms;
//   bool get rememberPassword => _rememberPassword;

//   // Getter for phone number with country code
//   String get phoneNumber => _user.phoneNumber; 

//   // Setters for user fields
//   void setName(String value) {
//     _user.name = value;
//     notifyListeners();
//   }

//   void setEmail(String value) {
//     _user.email = value;
//     notifyListeners();
//   }

//   void setPhoneNumber(String value) {
//     _user.phoneNumber = value;
//     notifyListeners();
//   }

//   void setPassword(String value) {
//     _user.password = value;
//     notifyListeners();
//   }

//   // Setters for login fields (Login data)
//   void setLoginEmail(String value) {
//     _user.email = value;
//     notifyListeners();
//   }

//   void setLoginPassword(String value) {
//     _user.password = value;
//     notifyListeners();
//   }

//   // Validation for login credentials (Checks if login email and password match the stored data)
//   bool validateLoginCredentials() {
//     return _user.email == _user.email && _user.password == _user.password;
//   }

//   // Setters for additional fields
//   void toggleAgreeToTerms() {
//     _agreeToTerms = !_agreeToTerms;
//     notifyListeners();
//   }

//   void toggleRememberPassword() {
//     _rememberPassword = !_rememberPassword;
//     notifyListeners();
//   }

//   void resetCheckboxes() {
//     _agreeToTerms = false;
//     _rememberPassword = false;
//     notifyListeners();
//   }
// }


import 'package:alletre_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UserProvider with ChangeNotifier {
  final UserModel _user = UserModel();
  bool _agreeToTerms = false;
  bool _rememberPassword = false;
  String _isoCode = 'AE';  // Store country ISO code

  // Getters
  UserModel get user => _user;
  String get password => _user.password;
  bool get agreeToTerms => _agreeToTerms;
  bool get rememberPassword => _rememberPassword;
  String get phoneNumber => _user.phoneNumber;
  String get isoCode => _isoCode;

  PhoneNumber get currentPhoneNumber => PhoneNumber(
    phoneNumber: _user.phoneNumber,
    isoCode: _isoCode,
  );

  // Setters for user fields
  void setName(String value) {
    _user.name = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _user.email = value;
    notifyListeners();
  }

  void setPhoneNumber(PhoneNumber userPhoneNumber) {
    _user.phoneNumber = userPhoneNumber.phoneNumber ?? '';
    _isoCode = userPhoneNumber.isoCode ?? 'AE';
    notifyListeners();
  }

  void setPassword(String value) {
    _user.password = value;
    notifyListeners();
  }

  // Setters for login fields
  void setLoginEmail(String value) {
    _user.email = value;
    notifyListeners();
  }

  void setLoginPassword(String value) {
    _user.password = value;
    notifyListeners();
  }

  // Validation for login credentials
  bool validateLoginCredentials() {
    return _user.email == _user.email && _user.password == _user.password;
  }

  // Checkbox handlers
  void toggleAgreeToTerms() {
    _agreeToTerms = !_agreeToTerms;
    notifyListeners();
  }

  void toggleRememberPassword() {
    _rememberPassword = !_rememberPassword;
    notifyListeners();
  }

  void resetCheckboxes() {
    _agreeToTerms = false;
    _rememberPassword = false;
    notifyListeners();
  }
}