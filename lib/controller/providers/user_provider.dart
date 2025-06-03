import 'dart:io';
import 'package:alletre_app/controller/helpers/user_services.dart';
import 'package:alletre_app/controller/services/auth_services.dart';
import 'package:alletre_app/model/user_model.dart';
import 'package:alletre_app/utils/validators/form_validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class UserProvider with ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final UserModel _user = UserModel();
  final List<Map<String, dynamic>> _addresses = []; // List of stored addresses as Maps
  Map<String, dynamic>? _defaultAddress;
  bool _agreeToTerms = false;
  bool _rememberPassword = false;
  String _isoCode = 'AE'; // Store country ISO code
  bool _isLoading = false;
  String _lastValidationMessage = '';
  String _authMethod = 'custom'; // 'custom', 'google', or 'apple'
  String? _displayName;
  String? _displayNumber;
  String? _displayEmail;
  String? _photoUrl;
  bool? _emailVerified;

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
  List<Map<String, dynamic>> get addresses => _addresses;
  Map<String, dynamic>? get defaultAddress => _defaultAddress;
  bool get isLoading => _isLoading;
  String get lastValidationMessage => _lastValidationMessage;
  String get authMethod => _authMethod;
  String get displayName => _displayName ?? _user.name;
  String get displayNumber {
    if (_displayNumber != null && _displayNumber!.isNotEmpty) {
      return _displayNumber!;
    }
    return _user.phoneNumber.isNotEmpty
        ? _user.phoneNumber
        : 'Add Phone Number';
  }

  String get displayEmail {
    if (_displayEmail != null && _displayEmail!.isNotEmpty) {
      return _displayEmail!;
    }
    return _user.email.isNotEmpty ? _user.email : 'Add Email';
  }

  String? get photoUrl => _photoUrl;
  bool? get emailVerified => _emailVerified;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  // Get the current access token
  Future<String?> get token async {
    final tokens = await getTokens();
    return tokens['access_token'];
  }

  // Update profile photo
  Future<void> updateProfilePhoto(File photo) async {
    try {
      setLoading(true);
      // Upload photo to Firebase Storage
      // For now, just update the local state
      _photoUrl = photo.path;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile photo: $e');
    } finally {
      setLoading(false);
    }
  }

  PhoneNumber get currentPhoneNumber => PhoneNumber(
        // phoneNumber: _user.phoneNumber,
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
    return emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
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
    // passwordController.clear();
    notifyListeners();
  }

  // Add a new address
  void addAddress(Map<String, dynamic> address) {
    // Add a unique id if not present
    if (!address.containsKey('id')) {
      address['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    }
    _addresses.add(address);
    _defaultAddress ??= address;
    notifyListeners();
  }

  // Set addresses from backend
  void setAddresses(List<Map<String, dynamic>> addresses) {
    _addresses.clear();
    _addresses.addAll(addresses);
    notifyListeners();
  }

  // Set default address
  void setDefaultAddress(Map<String, dynamic> address) {
    if (_addresses.contains(address)) {
      _defaultAddress = address;
      notifyListeners();
    }
  }

  // Edit an address
  void editAddress(Map<String, dynamic> oldAddress, Map<String, dynamic> newAddress) {
    final id = oldAddress['id'];
    debugPrint('[UserProvider] editAddress called with id: $id');
    debugPrint('[UserProvider] Current addresses: $_addresses');
    final index = _addresses.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      // Preserve the id in the new address
      newAddress['id'] = id;
      _addresses[index] = newAddress;
      if (_defaultAddress?['id'] == id) {
        _defaultAddress = newAddress;
      }
      notifyListeners();
    } else {
      debugPrint('[UserProvider] No address found with id: $id');
    }
  }

  // Remove an address
  void removeAddress(Map<String, dynamic> address) {
    final id = address['id'];
    _addresses.removeWhere((a) => a['id'] == id);
    if (_defaultAddress?['id'] == id) {
      _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
    }
    notifyListeners();
  }

  // Clear all addresses
  void clearAddresses() {
    _addresses.clear();
    _defaultAddress = null;
    notifyListeners();
  }

  // Toggle loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool validateSignupForm() {
    bool isValid = _user.name.isNotEmpty &&
        _user.email.isNotEmpty &&
        _user.phoneNumber.isNotEmpty &&
        _user.password.isNotEmpty &&
        _agreeToTerms;

    if (!isValid) {
      String emptyFieldsMessage = FormValidators.getEmptyFieldsMessage(
          _user.name, _user.email, _user.phoneNumber, _user.password);

      if (!_agreeToTerms) {
        if (emptyFieldsMessage.isNotEmpty) {
          emptyFieldsMessage += ' and accept the Terms & Conditions';
        } else {
          emptyFieldsMessage = 'Please accept the Terms & Conditions';
        }
      }

      _lastValidationMessage = emptyFieldsMessage;
    }

    return isValid;
  }

  Future<Map<String, dynamic>> signup() async {
    if (!validateSignupForm()) {
      return {
        'success': false,
        'message': 'Please fill in all required fields and agree to terms'
      };
    }

    setLoading(true);
    try {
      final result = await _userService.signupService(
        _user.name,
        _user.email,
        _user.phoneNumber,
        _user.password,
      );

      if (result['success']) {
        resetSignupForm();
      }

      return result;
    } finally {
      setLoading(false);
    }
  }

  // bool validateLoginForm() {
  //   return emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
  // }

  bool validateLoginForm() {
    if (emailController.text.isEmpty && passwordController.text.isEmpty) {
      _lastValidationMessage = 'Please enter your email and password';
      return false;
    }
    if (emailController.text.isEmpty) {
      _lastValidationMessage = 'Email is required';
      return false;
    }
    if (passwordController.text.isEmpty) {
      _lastValidationMessage = 'Password is required';
      return false;
    }
    return true;
  }

// Method to update user info after Firebase authentication
  void setFirebaseUserInfo(User? firebaseUser, String method) async {
    if (firebaseUser != null) {
      _authMethod = method;
      _displayName = firebaseUser.displayName;
      _displayNumber = firebaseUser.phoneNumber;
      _displayEmail = firebaseUser.email;
      // OAuth providers (Google, Apple) have pre-verified emails
      _emailVerified = (method == 'google' || method == 'apple')
          ? true
          : firebaseUser.emailVerified;
      _photoUrl = firebaseUser.photoURL;

      // Debug: Print tokens
      final idToken = await firebaseUser.getIdToken();
      debugPrint('Firebase ID Token: $idToken');
      
      // Get refresh token from secure storage
      final refreshToken = await _storage.read(key: 'refresh_token');
      debugPrint('Current refresh token: $refreshToken');

      // Save auth method
      final userAuthService = UserAuthService();
      await userAuthService.setAuthMethod(method);

      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login() async {
    if (!validateLoginForm()) {
      return {
        'success': false,
        'message': 'Please enter both email and password'
      };
    }

    setLoading(true);
    try {
      // Trim whitespace from email
      final email = emailController.text.trim();
      final password = passwordController.text;

      debugPrint('Attempting login for email: $email');

      final result = await _userService.loginService(email, password);

      // final result = await _userService.login(
      //   emailController.text,
      //   passwordController.text,
      // );

      if (result['success']) {
        _authMethod = 'custom';

        // Save auth method
        final userAuthService = UserAuthService();
        await userAuthService.setAuthMethod('custom');

        if (_rememberPassword) {
          // Save credentials if remember password is checked
          await _storage.write(key: 'saved_email', value: email);
          await _storage.write(key: 'saved_password', value: password);
        }

        // Validate tokens after successful login
        final hasValidTokens = await _userService.validateTokens();
        if (!hasValidTokens) {
          return {
            'success': false,
            'message': 'Login failed: Unable to store authentication tokens'
          };
        }

        resetLoginForm(); // form reset on successful login
      }

      return result;
    } catch (e) {
      debugPrint('Error in login process: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred during login'
      };
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Clear secure storage and sign out from services
      await _userService.logout();
      
      // Reset all user-related state by creating a new empty instance
      _user.name = '';
      _user.email = '';
      _user.phoneNumber = '';
      _user.password = '';
      _user.profileImagePath = null;
      
      _addresses.clear();
      _defaultAddress = null;
      _displayName = null;
      _displayNumber = null;
      _displayEmail = null;
      _photoUrl = null;
      _emailVerified = null;
      _authMethod = 'custom';
      _agreeToTerms = false;
      _rememberPassword = false;
      _lastValidationMessage = '';
      
      // Clear controllers
      emailController.clear();
      passwordController.clear();
      
      // Also handle Firebase logout if needed
      await logoutFirebase();
      
      debugPrint('User provider state cleared after logout');
    } catch (e) {
      debugPrint('Error during user provider logout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutFirebase() async {
    if (_authMethod == 'google' || _authMethod == 'apple') {
      await FirebaseAuth.instance.signOut();
    }

    resetLoginForm();
    resetSignupForm();
    _displayName = null;
    _displayNumber = null;
    _displayEmail = null;
    _emailVerified = null;
    _photoUrl = null;
    notifyListeners();
  }

  Future<Map<String, String?>> getTokens() async {
    return await _userService
        .getTokens(); // Added getTokens to match UserService
  }

  void resetLoginForm() {
    emailController.clear();
    passwordController.clear();
    _rememberPassword = false;
    notifyListeners();
  }

  void resetSignupForm() {
    _user.name = '';
    _user.email = '';
    _user.phoneNumber = '';
    _user.password = '';
    _agreeToTerms = false;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // Login method
  // Future<void> login() async {
  //   try {
  //     final success = await _userService.login(
  //       emailController.text,
  //       passwordController.text,
  //     );

  //     if (success) {
  //       // Reset form fields after successful login
  //       resetCheckboxes();
  //     }
  //   } catch (e) {
  //     throw Exception('Login failed: $e');
  //   }
  // }

  // Make address default (backend + frontend)
  Future<Map<String, dynamic>> makeDefaultAddress(String locationId, Map<String, dynamic> address) async {
    setLoading(true);
    try {
      final result = await _userService.makeDefaultAddress(locationId);
      if (result['success']) {
        _defaultAddress = address;
        notifyListeners();
      }
      return result;
    } catch (e) {
      return {'success': false, 'message': 'Failed to make address default'};
    } finally {
      setLoading(false);
    }
  }

  // Mark an address as default locally
  void markAddressAsDefault(dynamic locationId) {
    for (var addr in _addresses) {
      addr['isDefault'] = (addr['id'] == locationId);
    }
    notifyListeners();
  }
}
