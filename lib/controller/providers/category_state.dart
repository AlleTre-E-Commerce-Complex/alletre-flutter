import 'package:flutter/material.dart';

class CategoryState extends ChangeNotifier {
  final Map<int, bool> _showTitleMap = {};

  bool isTitleVisible(int index) {
    return _showTitleMap[index] ?? false;
  }

  void toggleTitle(int index) {
    if (_showTitleMap[index] == null) {
      _showTitleMap[index] = true;
    } else {
      _showTitleMap[index] = !_showTitleMap[index]!;
    }
    notifyListeners();
  }

  // Add method to reset all titles
  void resetAllTitles() {
    _showTitleMap.clear();
    notifyListeners();
  }
}
