// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:doggymatch_flutter/pages/notifiers/profile_close_notifier.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/register_page_2.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';
import 'package:doggymatch_flutter/pages/chat_page.dart';
import 'package:doggymatch_flutter/pages/profile_page.dart';
import 'package:doggymatch_flutter/widgets/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  final bool fromRegister;

  MainScreen({super.key, this.fromRegister = false});

  final ProfileCloseNotifier profileCloseNotifier = ProfileCloseNotifier();

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
              const ChatPage(),
              ProfilePage(profile: profile),
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
                    showCloseButton: userProfileState.isProfileOpen,
                    onCloseButtonTapped: () {
                      log("Close button callback triggered in MainScreen");
                      userProfileState.closeProfile();
                      profileCloseNotifier
                          .triggerCloseProfile(); // Signal to close profile
                    },
                  );
                },
              ),
      ),
    );
  }
}
