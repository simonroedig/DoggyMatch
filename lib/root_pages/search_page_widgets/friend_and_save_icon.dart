// ignore_for_file: use_super_parameters

import 'package:doggymatch_flutter/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/shared_helper/icon_helpers.dart';

// FriendIconWidget
class FriendIconWidget extends StatelessWidget {
  final String userId;
  final Color profileColor;

  const FriendIconWidget({
    Key? key,
    required this.userId,
    required this.profileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: IconHelpers().determineFriendStatus(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Show a loading indicator or placeholder
          return const SizedBox(
            width: 20, // Adjust the size as needed
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.customBlack),
              strokeWidth: 2,
            ),
          );
        } else {
          String friendStatus = snapshot.data!;
          if (friendStatus != 'none') {
            return IconHelpers().buildFriendStatusIcon(
              friendStatus,
              profileColor,
              2,
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}

// SaveIconWidget
class SaveIconWidget extends StatelessWidget {
  final String userId;
  final Color profileColor;

  const SaveIconWidget({
    Key? key,
    required this.userId,
    required this.profileColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ProfileService().isProfileSaved(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Show a loading indicator or placeholder
          return const SizedBox(
            width: 20, // Adjust the size as needed
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.customBlack),
              strokeWidth: 2,
            ),
          );
        } else {
          bool isSaved = snapshot.data!;
          if (isSaved) {
            return IconHelpers().buildSaveIcon(
              true,
              profileColor,
              2,
              20,
            );
          } else {
            return const SizedBox.shrink();
          }
        }
      },
    );
  }
}
