import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTapped;
  final bool isProfileOpen;

  const CustomBottomNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onTabTapped,
    this.isProfileOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BottomAppBar(
        color: AppColors.bg,
        shape: const CircularNotchedRectangle(),
        child: Center(
          child: isProfileOpen
              ? _buildCloseButton(context)
              : _buildIconRow(context),
        ),
      ),
    );
  }

  Widget _buildIconRow(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80.0,
      decoration: BoxDecoration(
        color: AppColors.brownLightest,
        borderRadius: BorderRadius.circular(80.0),
        border: Border.all(color: Colors.black, width: 3.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIcon(context, 0, Icons.search_rounded),
          _buildIcon(context, 1, Icons.chat_rounded),
          _buildIcon(context, 2, Icons.person_rounded),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context, int index, IconData icon) {
    bool isActive = activeIndex == index;
    Color highlightColor = isActive ? AppColors.grey : AppColors.grey;
    return GestureDetector(
      onTap: () => onTabTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 30.0,
            color: isActive ? highlightColor : AppColors.customBlack,
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Container(
                width: 30.0,
                height: 3.0,
                decoration: BoxDecoration(
                  color: highlightColor,
                  shape: BoxShape.rectangle,
                  borderRadius: const BorderRadius.all(Radius.circular(40.0)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close, size: 30.0, color: AppColors.customBlack),
      onPressed: () {
        Provider.of<UserProfileState>(context, listen: false)
            .toggleProfileOpen(false);
      },
    );
  }
}
