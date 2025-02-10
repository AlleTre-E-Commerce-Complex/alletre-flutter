import 'package:flutter/material.dart';

class TabIndexProvider extends ChangeNotifier {
  int _selectedIndex = 0;  // Initially, the first tab is selected

  int get selectedIndex => _selectedIndex;

  void updateIndex(int index) {
     print('Updating tab index to: $index'); 
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners();  // Notify listeners to rebuild UI
    }
  }
}
