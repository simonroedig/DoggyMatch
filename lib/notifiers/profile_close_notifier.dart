import 'dart:developer';

import 'package:flutter/material.dart';

class ProfileCloseNotifier extends ChangeNotifier {
  bool _shouldCloseProfile = false;

  bool get shouldCloseProfile => _shouldCloseProfile;

  void triggerCloseProfile() {
    log('ProfileCloseNotifier: triggerCloseProfile called');

    _shouldCloseProfile = true;
    notifyListeners();
  }

  void reset() {
    _shouldCloseProfile = false;
  }
}
