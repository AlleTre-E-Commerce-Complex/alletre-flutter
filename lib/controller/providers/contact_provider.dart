import 'package:flutter/foundation.dart';

class ContactButtonProvider extends ChangeNotifier {
  final Map<int, bool> _showContactButtons = {};

  bool isShowingContactButtons(int itemId) {
    return _showContactButtons[itemId] ?? false;
  }

  void toggleContactButtons(int itemId) {
    _showContactButtons[itemId] = true;
    notifyListeners();
  }
}
