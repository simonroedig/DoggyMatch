import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/pages/settings_page.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_widget.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

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
      body: Column(
        children: [
          CustomAppBar(
            showFilterIcon: false,
            onSettingsPressed: () => _navigateToSettings(context),
          ),
          Expanded(
            child: ProfileWidget(
                profile: profile, clickedOnOtherUser: false, distance: 0.0),
          ),
        ],
      ),
    );
  }
}
