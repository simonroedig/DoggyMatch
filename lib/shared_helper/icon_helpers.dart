// File: icon_helpers.dart
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/services/friends_service.dart';

class IconHelpers {
  final FriendsService _friendsService = FriendsService();

  /// Determines the friend status for a given profile UID.
  Future<String> determineFriendStatus(String profileUid) async {
    if (await _friendsService.areFriends(profileUid)) {
      return 'friends';
    } else if (await _friendsService.isFriendRequestReceived(profileUid)) {
      return 'received';
    } else if (await _friendsService.isFriendRequestSent(profileUid)) {
      return 'sent';
    }
    return 'none';
  }

  /// Builds the friend status icon based on the status and profile color.
  Widget buildFriendStatusIcon(
      String status, Color profileColor, double strokeWidth) {
    Widget buildIconWithBackground(Widget icon) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Outer circle with profile color and customBlack stroke
          Container(
            width: 32, // Width of the rectangle
            height: 24, // Height of the rectangle
            decoration: BoxDecoration(
              color: profileColor, // Background color of the rectangle
              borderRadius: BorderRadius.circular(
                  UIConstants.innerInnerRadius), // Add border radius here
              border: Border.all(
                color: AppColors.customBlack, // Stroke color
                width: strokeWidth, // Stroke width
              ),
            ),
          ),
          // Inner combined icon
          icon,
        ],
      );
    }

    switch (status) {
      case 'friends':
        return buildIconWithBackground(
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-2, 0),
                child: const Icon(
                  Icons.people_alt_rounded,
                  size: 12,
                  color: AppColors.customBlack,
                ),
              ),
              Transform.translate(
                offset: const Offset(6, -3),
                child: const Icon(
                  Icons.check_rounded,
                  size: 8,
                  color: AppColors.customBlack,
                ),
              ),
            ],
          ),
        );
      case 'received':
        return buildIconWithBackground(
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-2, 0),
                child: const Opacity(
                  opacity: 0.5, // Set the opacity for the main icon
                  child: Icon(
                    Icons.people_alt_rounded,
                    size: 12,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(6, -3),
                child: const Opacity(
                  opacity: 0.5, // Set the opacity for the smaller icon
                  child: Icon(
                    Icons.call_received_rounded,
                    size: 8,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
            ],
          ),
        );
      case 'sent':
        return buildIconWithBackground(
          Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: const Offset(-2, 0),
                child: const Opacity(
                  opacity: 0.5, // Set the opacity for the main icon
                  child: Icon(
                    Icons.people_alt_rounded,
                    size: 12,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(6, -3),
                child: const Opacity(
                  opacity: 0.5, // Set the opacity for the smaller icon
                  child: Icon(
                    Icons.call_made_rounded,
                    size: 8,
                    color: AppColors.customBlack,
                  ),
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink(); // Return nothing for no status
    }
  }

  /// Builds the save icon based on the saved status and profile color.
  Widget buildSaveIcon(
      bool isSaved, Color profileColor, double strokeWidth, double? size) {
    if (!isSaved) {
      return const SizedBox.shrink(); // Return nothing if not saved
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer rectangle with profile color and customBlack stroke
        Container(
          width: size, // Width of the rectangle
          height: size, // Height of the rectangle
          decoration: BoxDecoration(
            color: profileColor, // Background color of the rectangle
            borderRadius: BorderRadius.circular(
                UIConstants.innerInnerRadius), // Add border radius
            border: Border.all(
              color: AppColors.customBlack, // Stroke color
              width: strokeWidth, // Stroke width
            ),
          ),
        ),
        // Save icon in customBlack
        Icon(
          Icons.bookmark_rounded,
          size: size! / 2,
          color: AppColors.customBlack, // Icon color
        ),
      ],
    );
  }
}
