// File: friends_saved_toggle.dart

// ignore_for_file: library_private_types_in_public_api

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class FriendsSavedToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed

  const FriendsSavedToggle({super.key, required this.onToggle});

  @override
  _FriendsSavedToggleState createState() => _FriendsSavedToggleState();
}

class _FriendsSavedToggleState extends State<FriendsSavedToggle> {
  bool isFriendsSelected = true;

  void toggleSwitch() {
    if (mounted) {
      setState(() {
        isFriendsSelected = !isFriendsSelected;
      });
    }

    widget.onToggle(isFriendsSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 1,
        margin: const EdgeInsets.only(
            top: 0.0, left: 16.0, right: 16.0, bottom: 0.0),
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Friends toggle
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isFriendsSelected ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UIConstants.outerRadius),
                    bottomLeft: Radius.circular(UIConstants.outerRadius),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: !isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    top: BorderSide(
                      color: !isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide.none,
                    bottom: BorderSide(
                      color: !isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_alt_rounded,
                      color: isFriendsSelected
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Friends',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: isFriendsSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isFriendsSelected
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 2, // Divider between the toggles
              color: AppColors.customBlack,
            ),
            // Saved toggle
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      !isFriendsSelected ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(UIConstants.outerRadius),
                    bottomRight: Radius.circular(UIConstants.outerRadius),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    bottom: BorderSide(
                      color: isFriendsSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    left: BorderSide.none,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: !isFriendsSelected
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: !isFriendsSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !isFriendsSelected
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
