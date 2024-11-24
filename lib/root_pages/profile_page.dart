// ignore_for_file: use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/settings_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/notifiers/profile_close_notifier.dart';
import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'dart:developer' as developer;

class ProfilePage extends StatefulWidget {
  final UserProfile profile;
  final ProfileCloseNotifier profileCloseNotifier;

  const ProfilePage({
    Key? key,
    required this.profile,
    required this.profileCloseNotifier,
  }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _hasOpenedProfileFromUserId = false;
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;
  bool? _isSaved;

  @override
  void initState() {
    super.initState();
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    userProfileState.closeProfile();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      _closeProfile();
      widget.profileCloseNotifier.reset();
    }
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

          // Open profile automatically
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
    setState(() {
      _selectedProfile = profile;
      _selectedDistance = distance;
      _lastOnline = lastOnline;
      _isSaved = isSaved;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  void _closeProfile() {
    setState(() {
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false).closeProfile();
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
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: CustomAppBar(
        showFilterIcon: false,
        showSearchIcon: false,
        onSettingsPressed: () => _navigateToSettings(context),
        isProfileOpen: Provider.of<UserProfileState>(context).isProfileOpen,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ProfileWidget(
                  profile: widget.profile,
                  clickedOnOtherUser: false,
                  distance: 0.0,
                  lastOnline: '',
                  isProfileSaved: false,
                ),
              ),
            ],
          ),
          if (_selectedProfile != null)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _closeProfile,
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Material(
                        borderRadius:
                            BorderRadius.circular(UIConstants.popUpRadius),
                        color: Colors.transparent,
                        child: ProfileWidget(
                          profile: _selectedProfile!,
                          clickedOnOtherUser: true,
                          distance: double.parse(_selectedDistance ?? '0'),
                          lastOnline: _lastOnline ?? '',
                          isProfileSaved: _isSaved ?? false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
