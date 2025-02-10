import 'package:flutter/material.dart';

class TabIndexProvider extends ChangeNotifier {
  int _selectedIndex = 0;  // Initially, the first tab is selected

  int get selectedIndex => _selectedIndex;

  void updateIndex(int index) {
     // ignore: avoid_print
     print('Updating tab index to: $index'); 
    if (_selectedIndex != index) {
      _selectedIndex = index;
      notifyListeners(); 
    }
  }
}
