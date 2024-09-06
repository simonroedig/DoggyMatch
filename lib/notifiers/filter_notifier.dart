import 'package:flutter/material.dart';

class FilterNotifier extends ChangeNotifier {
  void notifyFilterChanged() {
    notifyListeners();
  }
}
