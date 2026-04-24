// ignore_for_file: avoid_print
import 'package:flutter/material.dart';

class TabIndexProvider extends ChangeNotifier {
  int _selectedIndex = 0;  // Initially, the first tab is selected
  static const int maxIndex = 3;  // We have 4 tabs (0-3)

  int get selectedIndex => _selectedIndex;

  void updateIndex(int index) {
    print('Updating tab index to: $index');
    // Validate index is within bounds
    if (index < 0 || index > maxIndex) {
      print('Invalid tab index: $index. Must be between 0 and $maxIndex');
      return;
    }
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();
    }
  }
}
