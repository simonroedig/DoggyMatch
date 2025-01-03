// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'package:doggymatch_flutter/notifiers/profile_close_notifier.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/welcome_pages/register_page_2.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/root_pages/search_page.dart';
import 'package:doggymatch_flutter/root_pages/chat_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page.dart';
import 'package:doggymatch_flutter/main/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/root_pages/community_page.dart';

class MainScreen extends StatelessWidget {
  final bool fromRegister;

  MainScreen({super.key, this.fromRegister = false});

  final ProfileCloseNotifier profileCloseNotifier1 = ProfileCloseNotifier();
  final ProfileCloseNotifier profileCloseNotifier2 = ProfileCloseNotifier();
  final ProfileCloseNotifier profileCloseNotifier3 = ProfileCloseNotifier();
  final ProfileCloseNotifier profileCloseNotifier4 = ProfileCloseNotifier();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final userProfileState = context.read<UserProfileState>();

        if (userProfileState.openedProfileViaSubpageBool) {
          Navigator.pop(context);
          userProfileState.resetOpenedProfileViaSubpage();
          if (userProfileState.currentIndex == 2) {
            userProfileState.closeProfile();
          }

          return true; // Allow the default back button action
        }

        if (userProfileState.isProfileOpen) {
          userProfileState.closeProfile();
          profileCloseNotifier1.triggerCloseProfile();
          profileCloseNotifier2.triggerCloseProfile();
          profileCloseNotifier3.triggerCloseProfile();
          profileCloseNotifier4.triggerCloseProfile();
          return false; // Prevent the default back button action
        }

        return true; // Allow the default back button action
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Consumer<UserProfileState>(
          builder: (context, userProfileState, child) {
            final profile = userProfileState.userProfile;

            if (profile.uid.isEmpty) {
              // Profile is not ready, show a loading indicator
              return const Center(child: CircularProgressIndicator());
            }

            // Check if only uid and email exist in the profile
            if (profile.uid.isNotEmpty &&
                profile.email.isNotEmpty &&
                profile.userName.isEmpty &&
                profile.aboutText.isEmpty &&
                profile.location.isEmpty) {
              return RegisterPage2(profile: profile);
            }

            // Redirect to RegisterPage2 if profile is incomplete
            if (fromRegister) {
              return RegisterPage2(profile: profile);
            }

            List<Widget> pages = [
              SearchPage(profileCloseNotifier: profileCloseNotifier1),
              ChatPage(profileCloseNotifier: profileCloseNotifier2),
              ProfilePage(
                  profile: profile,
                  profileCloseNotifier: profileCloseNotifier3),
              CommunityPage(profileCloseNotifier: profileCloseNotifier4),
            ];

            // Use IndexedStack instead of AnimatedSwitcher HERE (XXX)

            return IndexedStack(
              index: userProfileState.currentIndex,
              children: pages,
            );
            /*
            return Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  // Provide a unique key to each page so the AnimatedSwitcher
                  // knows when the child changes
                  child: pages[userProfileState.currentIndex],
                ),
              ],
            );
            */
          },
        ),
        bottomNavigationBar: Consumer<UserProfileState>(
          builder: (context, userProfileState, child) {
            final profile = userProfileState.userProfile;

            // Check if the profile is incomplete
            if (profile.uid.isNotEmpty &&
                profile.email.isNotEmpty &&
                profile.userName.isEmpty &&
                profile.aboutText.isEmpty &&
                profile.location.isEmpty) {
              // log debug message
              log('Profile is incomplete');
              // this means the suer did not go through the registration process
              return const SizedBox.shrink();
            }

            return CustomBottomNavigationBar(
              activeIndex: userProfileState.currentIndex,
              onTabTapped: (index) {
                if (userProfileState.isProfileOpen) {
                  userProfileState.closeProfile();
                  profileCloseNotifier1.triggerCloseProfile();
                  profileCloseNotifier2.triggerCloseProfile();
                  profileCloseNotifier3.triggerCloseProfile();
                  profileCloseNotifier4.triggerCloseProfile();
                } else {
                  userProfileState.updateCurrentIndex(index);
                }
              },
              showCloseButton: userProfileState.isProfileOpen,
              onCloseButtonTapped: () {
                if (userProfileState.openedProfileViaSubpageBool) {
                  Navigator.pop(context);
                  userProfileState.resetOpenedProfileViaSubpage();

                  if (userProfileState.currentIndex == 2) {
                    userProfileState.closeProfile();
                  }
                  return;
                }
                log('HHHHHHHHHHHHHHHHHHHHH');

                userProfileState.closeProfile();
                profileCloseNotifier1.triggerCloseProfile();
                profileCloseNotifier2.triggerCloseProfile();
                profileCloseNotifier3.triggerCloseProfile();
                profileCloseNotifier4.triggerCloseProfile();
              },
            );
          },
        ),
      ),
    );
  }
}
