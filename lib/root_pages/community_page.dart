// ignore_for_file: library_private_types_in_public_api

import 'package:doggymatch_flutter/notifiers/profile_close_notifier.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/toggles/friends_saved_toggle.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';

class CommunityPage extends StatefulWidget {
  final ProfileCloseNotifier profileCloseNotifier;
  const CommunityPage({super.key, required this.profileCloseNotifier});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isFriendsSelected = true;
  UserProfile? _selectedProfile;
  String? _selectedDistance;
  String? _lastOnline;

  @override
  void initState() {
    super.initState();
    widget.profileCloseNotifier.addListener(_onProfileClose);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //_authService.updateLastOnline(); // Call your function here
  }

  @override
  void dispose() {
    widget.profileCloseNotifier.removeListener(_onProfileClose);
    super.dispose();
  }

  void _onProfileClose() {
    if (widget.profileCloseNotifier.shouldCloseProfile) {
      closeProfile();
      widget.profileCloseNotifier.reset();
    }
  }

  void handleToggle(bool isFriends) {
    setState(() {
      isFriendsSelected = isFriends;
    });
  }

  void _openProfile(UserProfile profile, String distance, String lastOnline) {
    setState(() {
      _selectedProfile = profile;
      _selectedDistance = distance;
      _lastOnline = lastOnline;
    });
    Provider.of<UserProfileState>(context, listen: false).openProfile();
  }

  void closeProfile() {
    setState(() {
      _selectedProfile = null;
    });
    Provider.of<UserProfileState>(context, listen: false).closeProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        showSearchIcon: true,
        showFilterIcon: false,
        onSettingsPressed: null,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 5),
              FriendsSavedToggle(onToggle: handleToggle),
              const SizedBox(height: 15),
              Expanded(
                child: isFriendsSelected
                    ? const Center(
                        child: Text(
                          'No friends available',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.customBlack,
                          ),
                        ),
                      )
                    : OtherPersons(
                        onProfileSelected: _openProfile,
                        showAllProfiles: false,
                        showSavedProfiles: true,
                      ),
              ),
            ],
          ),
          if (_selectedProfile != null)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: closeProfile,
                    child: Container(
                      color: Colors.black.withOpacity(0),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Material(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Colors.transparent,
                        child: ProfileWidget(
                          profile: _selectedProfile!,
                          clickedOnOtherUser: true,
                          distance: double.parse(_selectedDistance ?? '?'),
                          lastOnline: _lastOnline ?? '',
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
