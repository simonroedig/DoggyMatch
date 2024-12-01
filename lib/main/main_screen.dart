// main_screen.dart

import 'package:doggymatch_flutter/root_pages/profile_page_widgets/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_bottom_navigation.dart';
import 'package:doggymatch_flutter/root_pages/chat_page.dart';
import 'package:doggymatch_flutter/root_pages/community_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:doggymatch_flutter/root_pages/search_page.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';
import 'package:doggymatch_flutter/welcome_pages/register_page_2.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';

class MainScreen extends StatefulWidget {
  final bool fromRegister;

  MainScreen({Key? key, this.fromRegister = false}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: CustomAppBar(
          // You may need to adjust parameters or make the app bar dynamic
          showFilterIcon: false,
          showSearchIcon: false,
          onSettingsPressed: _navigateToSettings,
        ),
        body: Consumer<UserProfileState>(
          builder: (context, userProfileState, child) {
            final profile = userProfileState.userProfile;

            if (profile.uid.isEmpty) {
              // Profile is not ready, show a loading indicator
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.fromRegister) {
              return RegisterPage2(profile: profile);
            }

            List<Widget> pages = [
              SearchPage(onProfileSelected: _openProfile),
              ChatPage(onProfileSelected: _openProfile),
              ProfilePage(
                profile: profile,
                onProfileSelected: _openProfile,
              ),
              CommunityPage(onProfileSelected: _openProfile),
            ];

            return Stack(
              children: [
                IndexedStack(
                  index: userProfileState.currentIndex,
                  children: pages,
                ),
                if (userProfileState.isProfileOpen &&
                    userProfileState.selectedProfile != null)
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      color: Colors.black.withOpacity(0),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: MediaQuery.of(context).size.height -
                                  kToolbarHeight -
                                  MediaQuery.of(context).padding.top -
                                  kBottomNavigationBarHeight,
                            ),
                            child: ProfileWidget(
                              profile: userProfileState.selectedProfile!,
                              clickedOnOtherUser: true,
                              distance:
                                  userProfileState.selectedDistance ?? 0.0,
                              lastOnline: userProfileState.lastOnline ?? '',
                              isProfileSaved:
                                  userProfileState.isProfileSaved ?? false,
                              startInChat: userProfileState.startInChat,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        bottomNavigationBar: widget.fromRegister
            ? null
            : Consumer<UserProfileState>(
                builder: (context, userProfileState, child) {
                  return CustomBottomNavigationBar(
                    activeIndex: userProfileState.currentIndex,
                    onTabTapped: (index) {
                      if (userProfileState.isProfileOpen) {
                        userProfileState.closeProfile();
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
                      userProfileState.closeProfile();
                    },
                  );
                },
              ),
      ),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _openProfile(
    UserProfile profile,
    String distance,
    String lastOnline,
    bool isSaved, {
    bool startInChat = false,
  }) {
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);
    userProfileState.openProfile(
      profile,
      double.parse(distance),
      lastOnline,
      isSaved,
      startInChat: startInChat,
    );
  }

  Future<bool> _onWillPop() async {
    final userProfileState =
        Provider.of<UserProfileState>(context, listen: false);

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
      return false; // Prevent the default back button action
    }

    return true; // Allow the default back button action
  }
}
