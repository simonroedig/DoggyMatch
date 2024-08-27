import 'dart:developer';

import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/register_page_2.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';
import 'package:doggymatch_flutter/pages/chat_page.dart';
import 'package:doggymatch_flutter/pages/profile_page.dart';
import 'package:doggymatch_flutter/widgets/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';

class MainScreen extends StatelessWidget {
  final bool fromRegister;

  const MainScreen({super.key, this.fromRegister = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<UserProfileState>(
        builder: (context, userProfileState, child) {
          final profile = userProfileState.userProfile;

          if (fromRegister) {
            return RegisterPage2(profile: profile);
          }

          List<Widget> pages = [
            const SearchPage(),
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
                      // Close the profile if it's open when tapping other tabs
                      userProfileState.closeProfile();
                    } else {
                      userProfileState.updateCurrentIndex(index);
                    }
                  },
                  showCloseButton: userProfileState.isProfileOpen,
                  onCloseButtonTapped: () {
                    log("Close button callback triggered in MainScreen");
                    userProfileState.closeProfile();
                    // Notify SearchPage to also close its profile
                    if (context.mounted) {
                      log('Closing profile in MainScreen MOUNTED');
                      final searchPageState =
                          context.findAncestorStateOfType<SearchPageState>();
                      searchPageState
                          ?.closeProfile(); // Ensure SearchPage updates too
                    }
                  },
                );
              },
            ),
    );
  }
}
