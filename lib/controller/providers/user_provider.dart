import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UserProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final UserModel _user = UserModel();
  String? selectedAddress;
  final List<String> _addresses = []; // List of stored addresses
  String? _defaultAddress;
  bool _agreeToTerms = false;
  bool _rememberPassword = false;
  String _isoCode = 'AE';  // Store country ISO code

  final UserService _userService = UserService();

  // Getters
  UserModel get user => _user;
  String get name => _user.name;
  String get email => _user.email;
  String get password => _user.password;
  bool get agreeToTerms => _agreeToTerms;
  bool get rememberPassword => _rememberPassword;
  String get phoneNumber => _user.phoneNumber;
  String get isoCode => _isoCode;
  List<String> get addresses => _addresses;
  String? get defaultAddress => _defaultAddress;

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
    return emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
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
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // Add a new address
  void addAddress(String address) {
    _addresses.add(address);
    _defaultAddress ??= address;
    notifyListeners();
  }

  // Set default address
  void setDefaultAddress(String address) {
    if (_addresses.contains(address)) {
      _defaultAddress = address;
      notifyListeners();
    }
  }

  // Edit an address
  void editAddress(String oldAddress, String newAddress) {
    final index = _addresses.indexOf(oldAddress);
    if (index != -1) {
      _addresses[index] = newAddress;
      if (_defaultAddress == oldAddress) {
        _defaultAddress = newAddress; // Update default address if edited
      }
      notifyListeners();
    }
  }

  // Remove an address
  void removeAddress(String address) {
    _addresses.remove(address);
    if (_defaultAddress == address) {
      _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }

  // Signup method
  Future<void> signup() async {
    try {
      final success = await _userService.signup(
        _user.name,
        _user.email,
        _user.phoneNumber,
        _user.password,
      );

      if (success) {
        // Reset form fields after successful signup
        resetCheckboxes();
      }
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }

  // Login method
  Future<void> login() async {
    try {
      final success = await _userService.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        // Reset form fields after successful login
        resetCheckboxes();
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
