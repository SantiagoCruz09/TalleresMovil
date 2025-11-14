import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _primaryColor = const Color(0xFF3F51B5); // default indigo

  Color get primaryColor => _primaryColor;

  void setColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }
}
