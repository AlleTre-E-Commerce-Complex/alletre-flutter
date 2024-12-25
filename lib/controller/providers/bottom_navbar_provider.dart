// bottom_navbar_provider.dart
import 'package:flutter/material.dart';

class BottomNavBarProvider with ChangeNotifier {
  int _selectedIndex = 0;  // Default selected index (Home)

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
