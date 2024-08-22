import 'package:doggymatch_flutter/colors.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/pages/settings_page.dart';
import 'package:doggymatch_flutter/widgets/profile_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          const Expanded(
            child: ProfileWidget(),
          ),
        ],
      ),
    );
  }
}
