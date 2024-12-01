// profile_page.dart
// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/settings_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'dart:developer' as developer;

class ProfilePage extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const ProfilePage({
    Key? key,
    required this.profile,
    required this.onProfileSelected,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasOpenedProfileFromUserId = false;

  @override
  void initState() {
    super.initState();
    developer.log('ProfilePage initialized');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasOpenedProfileFromUserId) {
      final userProfileState =
          Provider.of<UserProfileState>(context, listen: false);
      final userId = userProfileState.userIdToOpen;
      if (userId != null) {
        developer.log('Opening profile from user id: $userId');
        _openProfileById(userId);
        _hasOpenedProfileFromUserId = true;
        userProfileState.resetUserIdToOpen();
      }
    }
  }

  void _openProfileById(String userId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        final profileData =
            await ProfileService().fetchOtherUserProfile(userId);
        if (profileData != null && mounted) {
          final userProfile = profileData;
          final userProfileState =
              Provider.of<UserProfileState>(context, listen: false);
          final distance = calculateDistance(
            userProfileState.userProfile.latitude,
            userProfileState.userProfile.longitude,
            userProfile.latitude,
            userProfile.longitude,
          ).toStringAsFixed(1);
          final lastOnline = calculateLastOnlineLong(userProfile.lastOnline);
          final isSaved = await ProfileService().isProfileSaved(userId);

          // Open profile using the callback
          _openProfile(userProfile, distance, lastOnline, isSaved);
        }
      } catch (e) {
        if (mounted) {
          developer.log('Error loading profile: $e');
        }
      }
    });
  }

  void _openProfile(
    UserProfile profile,
    String distance,
    String lastOnline,
    bool isSaved,
  ) {
    widget.onProfileSelected(profile, distance, lastOnline, isSaved);
  }

  void _navigateToSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isProfileOpen = Provider.of<UserProfileState>(context).isProfileOpen;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomAppBar(
        showFilterIcon: false,
        showSearchIcon: false,
        onSettingsPressed: () => _navigateToSettings(context),
        isProfileOpen: isProfileOpen,
      ),
      body: ProfileWidget(
        profile: widget.profile,
        clickedOnOtherUser: false,
        distance: 0.0,
        lastOnline: '',
        isProfileSaved: false,
      ),
    );
  }
}
