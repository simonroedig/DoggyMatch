// community_page.dart
// ignore_for_file: library_private_types_in_public_api

import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:doggymatch_flutter/shared_helper/shared_and_helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/toggles/friends_saved_toggle.dart';
import 'package:doggymatch_flutter/toggles/friends_receivedreq_sentreq_toggle.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/root_pages/search_page_widgets/other_persons.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'dart:developer' as developer;

class CommunityPage extends StatefulWidget {
  final Function(UserProfile, String, String, bool) onProfileSelected;

  const CommunityPage({Key? key, required this.onProfileSelected})
      : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with AutomaticKeepAliveClientMixin {
  bool isFriendsSelected = true;
  int selectedFriendsOption = 0; // 0 = Friends, 1 = Received, 2 = Sent

  bool _hasOpenedProfileFromUserId = false;

  @override
  bool get wantKeepAlive => true; // Tell Flutter to keep this widget alive

  @override
  void initState() {
    super.initState();
    developer.log('CommunityPage initialized');
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

  // Toggle between Friends and Saved
  void handleToggle(bool isFriends) {
    setState(() {
      isFriendsSelected = isFriends;
      selectedFriendsOption = 0; // Reset to Friends on toggle switch
    });
  }

  // Toggle between Friends, Received, and Sent requests
  void handleFriendsOptionToggle(int option) {
    setState(() {
      selectedFriendsOption = option;
    });
  }

  void _openProfile(
      UserProfile profile, String distance, String lastOnline, bool isSaved) {
    widget.onProfileSelected(profile, distance, lastOnline, isSaved);
  }

  @override
  Widget build(BuildContext context) {
    super.build(
        context); // Important: call super.build when using AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const CustomAppBar(
        showSearchIcon: true,
        showFilterIcon: false,
        onSettingsPressed: null,
      ),
      body: Column(
        children: [
          const SizedBox(height: 5),
          FriendsSavedToggle(onToggle: handleToggle),
          if (isFriendsSelected) ...[
            const SizedBox(height: 15),
            FriendsReceivedReqSentReqToggle(
                onToggle: handleFriendsOptionToggle),
          ],
          const SizedBox(height: 15),
          Expanded(
            // Use ValueKey to force rebuild based on the toggle state
            child: isFriendsSelected
                ? selectedFriendsOption == 0
                    ? OtherPersons(
                        key:
                            const ValueKey("friends"), // Unique key for Friends
                        onProfileSelected: _openProfile,
                        showAllProfiles: false,
                        showFriendProfiles: true,
                      )
                    : selectedFriendsOption == 1
                        ? OtherPersons(
                            key: const ValueKey("received_requests"),
                            onProfileSelected: _openProfile,
                            showAllProfiles: false,
                            showReceivedFriendRequestProfiles: true,
                          )
                        : OtherPersons(
                            key: const ValueKey("sent_requests"),
                            onProfileSelected: _openProfile,
                            showAllProfiles: false,
                            showSentFriendRequestProfiles: true,
                          )
                : OtherPersons(
                    key: const ValueKey("saved_profiles"),
                    onProfileSelected: _openProfile,
                    showAllProfiles: false,
                    showSavedProfiles: true,
                  ),
          ),
        ],
      ),
    );
  }
}
