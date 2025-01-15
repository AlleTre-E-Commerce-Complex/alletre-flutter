import 'package:flutter/material.dart';

class FocusStateNotifier extends ChangeNotifier {
  final FocusNode _focusNode = FocusNode();

  FocusNode get focusNode => _focusNode;

  void unfocus() {
    _focusNode.unfocus();
    notifyListeners();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
