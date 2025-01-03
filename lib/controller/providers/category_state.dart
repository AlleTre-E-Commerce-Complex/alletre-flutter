import 'package:flutter/material.dart';

class CategoryState extends ChangeNotifier {
  final Map<int, bool> _showTitleMap = {};

  bool isTitleVisible(int index) {
    return _showTitleMap[index] ?? false; // Default to false if not initialized
  }

  void toggleTitle(int index) {
    if (_showTitleMap[index] == null) {
      _showTitleMap[index] = true; // Initialize with true if not already set
    } else {
      _showTitleMap[index] = !_showTitleMap[index]!; // Toggle the value
    }
    notifyListeners(); // Notify listeners about the change
  }
}
