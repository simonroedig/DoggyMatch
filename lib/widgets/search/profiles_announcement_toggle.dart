// File: profiles_announcement_toggle.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class ProfilesAnnouncementToggle extends StatefulWidget {
  final Function(bool) onToggle; // Callback for when the toggle is changed

  const ProfilesAnnouncementToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilesAnnouncementToggleState createState() =>
      _ProfilesAnnouncementToggleState();
}

class _ProfilesAnnouncementToggleState
    extends State<ProfilesAnnouncementToggle> {
  bool isProfilesSelected = true;

  void toggleSwitch() {
    setState(() {
      isProfilesSelected = !isProfilesSelected;
    });
    widget.onToggle(isProfilesSelected);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleSwitch,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isProfilesSelected ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: !isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    top: BorderSide(
                      color: !isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide.none, // No border on the right side
                    bottom: BorderSide(
                      color: !isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  isProfilesSelected ? '🐶 Profiles' : 'Profiles',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: isProfilesSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isProfilesSelected
                        ? AppColors.bg
                        : AppColors.customBlack,
                  ),
                ),
              ),
            ),
            Container(
              width: 2, // Adjusted the width to be consistent
              color: AppColors.customBlack,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isProfilesSelected
                      ? AppColors.customBlack
                      : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    bottom: BorderSide(
                      color: isProfilesSelected
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    left: BorderSide.none, // No border on the left side
                  ),
                ),
                child: Text(
                  !isProfilesSelected ? '📣 Shouts' : 'Shouts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: !isProfilesSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: !isProfilesSelected
                        ? AppColors.bg
                        : AppColors.customBlack,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
