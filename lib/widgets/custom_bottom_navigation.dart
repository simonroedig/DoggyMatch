import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BottomAppBar(
        color: AppColors.bg,
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 80.0,
          decoration: BoxDecoration(
            color: AppColors.brownLightest,
            borderRadius: BorderRadius.circular(80.0),
            border: Border.all(
              color: Colors.black,
              width: 3.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIcon(0, Icons.search_rounded),
              _buildIcon(1, Icons.chat_rounded),
              _buildIcon(2, Icons.person_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(int index, IconData icon) {
    bool isActive = activeIndex == index;
    Color highlightColor = _getHighlightColor(index);

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

  Color _getHighlightColor(int index) {
    return AppColors.customBlack;
    /*
    switch (index) {
      case 0:
        return AppColors.accent1;
      case 1:
        return AppColors.accent2;
      case 2:
        return AppColors.accent3;
      default:
        return AppColors.customBlack;
    }
    */
  }
}
