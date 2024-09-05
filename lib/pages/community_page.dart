import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/widgets/custom_app_bar.dart';
import 'package:doggymatch_flutter/pages/community/friends_saved_toggle.dart';
import 'package:doggymatch_flutter/colors.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isFriendsSelected = true;

  void handleToggle(bool isFriends) {
    setState(() {
      isFriendsSelected = isFriends;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          const SizedBox(height: 15),
          Expanded(
            child: isFriendsSelected
                ? const Center(
                    child: Text(
                      'No friends available',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      'No saved profiles',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.customBlack,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
