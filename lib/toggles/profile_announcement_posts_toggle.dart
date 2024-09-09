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
    setState(() {
      selectedIndex = index;
    });
    widget.onToggle(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(0),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedIndex == 0 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
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
                child: Text(
                  selectedIndex == 0 ? '🐶 Profiles' : 'Profiles',
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
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
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
                child: Text(
                  selectedIndex == 1 ? '📣 Shouts' : 'Shouts',
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
              ),
            ),
          ),
          Container(
            width: 2,
            color: AppColors.customBlack,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => toggleSwitch(2),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      selectedIndex == 2 ? AppColors.customBlack : AppColors.bg,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(25),
                    bottomRight: Radius.circular(25),
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
                child: Text(
                  selectedIndex == 2 ? '📝 Posts' : 'Posts',
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
