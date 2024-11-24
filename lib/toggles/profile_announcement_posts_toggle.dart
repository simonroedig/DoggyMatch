import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class ProfileAnnouncementPostsToggle extends StatefulWidget {
  final Function(int) onToggle; // Callback for when the toggle is changed

  const ProfileAnnouncementPostsToggle({super.key, required this.onToggle});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileAnnouncementPostsToggleState createState() =>
      _ProfileAnnouncementPostsToggleState();
}

class _ProfileAnnouncementPostsToggleState
    extends State<ProfileAnnouncementPostsToggle> {
  int selectedIndex = 0; // 0 - Profiles, 1 - Announcements (Shouts), 2 - Posts

  void toggleSwitch(int index) {
    if (mounted) {
      setState(() {
        selectedIndex = index;
      });
    }
    widget.onToggle(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 1,
      // add margin left and right
      margin:
          const EdgeInsets.only(top: 0.0, left: 16.0, right: 16.0, bottom: 0.0),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(UIConstants.outerRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Profiles toggle
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedIndex == 0 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(UIConstants.outerRadius),
                    bottomLeft: Radius.circular(UIConstants.outerRadius),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: selectedIndex != 0
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    top: BorderSide(
                      color: selectedIndex != 0
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide.none,
                    bottom: BorderSide(
                      color: selectedIndex != 0
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
                      Icons.people_outline_rounded,
                      color: selectedIndex == 0
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Profiles',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedIndex == 0
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
          // Shouts toggle
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(1),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedIndex == 1 ? AppColors.customBlack : AppColors.bg,
                  border: Border(
                    top: BorderSide(
                      color: selectedIndex != 1
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide.none,
                    bottom: BorderSide(
                      color: selectedIndex != 1
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
                      Icons.campaign,
                      color: selectedIndex == 1
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Shouts',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedIndex == 1
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
          // Posts toggle
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(2),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedIndex == 2 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(UIConstants.outerRadius),
                    bottomRight: Radius.circular(UIConstants.outerRadius),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: selectedIndex != 2
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    right: BorderSide(
                      color: selectedIndex != 2
                          ? AppColors.customBlack
                          : Colors.transparent,
                      width: 3,
                    ),
                    bottom: BorderSide(
                      color: selectedIndex != 2
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
                      Icons.photo_library,
                      color: selectedIndex == 2
                          ? AppColors.bg
                          : AppColors.customBlack,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Posts',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: selectedIndex == 2
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selectedIndex == 2
                            ? AppColors.bg
                            : AppColors.customBlack,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
