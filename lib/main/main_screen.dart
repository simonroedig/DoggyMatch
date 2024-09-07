import 'dart:developer';
import 'package:doggymatch_flutter/notifiers/filter_close_notifier.dart';
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

  final ProfileCloseNotifier profileCloseNotifier = ProfileCloseNotifier();
  final FilterMenuNotifier filterMenuNotifier =
      FilterMenuNotifier(); // Add FilterMenuNotifier

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final userProfileState = context.read<UserProfileState>();

        if (userProfileState.isProfileOpen) {
          userProfileState.closeProfile();
          profileCloseNotifier.triggerCloseProfile(); // Signal to close profile
          return false; // Prevent the default back button action
        }

        if (userProfileState.isFilterMenuOpen) {
          userProfileState.closeFilterMenu();
          filterMenuNotifier
              .triggerCloseFilterMenu(); // Signal to close filter menu
          return false; // Prevent the default back button action
        }

        return true; // Allow the default back button action
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Consumer<UserProfileState>(
          builder: (context, userProfileState, child) {
            final profile = userProfileState.userProfile;

            if (fromRegister) {
              return RegisterPage2(profile: profile);
            }

            List<Widget> pages = [
              SearchPage(profileCloseNotifier: profileCloseNotifier),
              ChatPage(profileCloseNotifier: profileCloseNotifier),
              ProfilePage(profile: profile),
              CommunityPage(profileCloseNotifier: profileCloseNotifier),
            ];

            return Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: pages[userProfileState.currentIndex],
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: fromRegister
            ? null
            : Consumer<UserProfileState>(
                builder: (context, userProfileState, child) {
                  return CustomBottomNavigationBar(
                    activeIndex: userProfileState.currentIndex,
                    onTabTapped: (index) {
                      if (userProfileState.isProfileOpen) {
                        userProfileState.closeProfile();
                        profileCloseNotifier
                            .triggerCloseProfile(); // Signal to close profile
                      } else {
                        userProfileState.updateCurrentIndex(index);
                      }
                    },
                    showCloseButton: userProfileState
                        .isCloseButtonVisible, // Show close button when either profile or filter menu is open
                    onCloseButtonTapped: () {
                      log("Close button callback triggered in MainScreen");
                      if (userProfileState.isProfileOpen) {
                        userProfileState.closeProfile();
                        profileCloseNotifier
                            .triggerCloseProfile(); // Signal to close profile
                      } else if (userProfileState.isFilterMenuOpen) {
                        userProfileState.closeFilterMenu();
                        filterMenuNotifier
                            .triggerCloseFilterMenu(); // Signal to close filter menu
                      }
                    },
                  );
                },
              ),
      ),
    );
  }
}
