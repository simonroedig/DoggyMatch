import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/main/custom_app_bar.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/settings_page.dart';
import 'package:doggymatch_flutter/root_pages/profile_page_widgets/profile_widget.dart';
import 'package:doggymatch_flutter/classes/profile.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/states/user_profile_state.dart';

class ProfilePage extends StatelessWidget {
  final UserProfile profile;

  const ProfilePage({super.key, required this.profile});

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
      body: Column(
        children: [
          Expanded(
            child: ProfileWidget(
              profile: profile,
              clickedOnOtherUser: false,
              distance: 0.0,
              lastOnline: '',
              isProfileSaved: false,
            ),
          ),
        ],
      ),
    );
  }
}
