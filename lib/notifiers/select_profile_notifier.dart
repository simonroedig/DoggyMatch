import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/classes/profile.dart';

class SelectedProfileNotifier extends ChangeNotifier {
  UserProfile? _selectedProfile;
  String? _distance;
  String? _lastOnline;
  bool? _isSaved;

  UserProfile? get selectedProfile => _selectedProfile;
  String? get distance => _distance;
  String? get lastOnline => _lastOnline;
  bool? get isSaved => _isSaved;

  void setSelectedProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved) {
    _selectedProfile = profile;
    _distance = distance;
    _lastOnline = lastOnline;
    _isSaved = isSaved;
    notifyListeners();
  }

  void clearSelectedProfile() {
    _selectedProfile = null;
    _distance = null;
    _lastOnline = null;
    _isSaved = null;
    notifyListeners();
  }
}
