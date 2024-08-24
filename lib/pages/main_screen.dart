import 'package:doggymatch_flutter/constants/colors.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/search_page.dart';
import 'package:doggymatch_flutter/pages/chat_page.dart';
import 'package:doggymatch_flutter/pages/profile_page.dart';
import 'package:doggymatch_flutter/widgets/custom_bottom_navigation.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Consumer<UserProfileState>(
        builder: (context, userProfileState, child) {
          final profile = userProfileState.userProfile;

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
      bottomNavigationBar: Consumer<UserProfileState>(
        builder: (context, userProfileState, child) {
          return CustomBottomNavigationBar(
            activeIndex: userProfileState.currentIndex,
            onTabTapped: (index) {
              userProfileState.updateCurrentIndex(index);
            },
          );
        },
      ),
    );
  }
}
