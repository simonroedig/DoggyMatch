import 'package:flutter/material.dart';

class FilterMenuNotifier extends ChangeNotifier {
  bool _shouldCloseFilterMenu = false;

  bool get shouldCloseFilterMenu => _shouldCloseFilterMenu;

  void triggerCloseFilterMenu() {
    _shouldCloseFilterMenu = true;
    notifyListeners();
  }

  void reset() {
    _shouldCloseFilterMenu = false;
  }
}
