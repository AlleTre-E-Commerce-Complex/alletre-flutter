// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class StorageService {
//   static final StorageService _instance = StorageService._internal();
//   factory StorageService() => _instance;
//   StorageService._internal();

//   final _secureStorage = const FlutterSecureStorage();
//   SharedPreferences? _prefs;

//   // Initialize shared preferences
//   Future<void> init() async {
//     _prefs = await SharedPreferences.getInstance();
//   }

//   // Secure Storage Methods (for sensitive data like tokens)
//   Future<void> setSecureItem(String key, String value) async {
//     await _secureStorage.write(key: key, value: value);
//   }

//   Future<String?> getSecureItem(String key) async {
//     return await _secureStorage.read(key: key);
//   }

//   Future<void> removeSecureItem(String key) async {
//     await _secureStorage.delete(key: key);
//   }

//   // Regular Storage Methods (for non-sensitive data)
//   Future<void> setItem(String key, String value) async {
//     await _prefs?.setString(key, value);
//   }

//   Future<String?> getItem(String key) async {
//     return _prefs?.getString(key);
//   }

//   Future<void> removeItem(String key) async {
//     await _prefs?.remove(key);
//   }

//   // Clear all storage
//   Future<void> clearAll() async {
//     await _secureStorage.deleteAll();
//     await _prefs?.clear();
//   }
// }
