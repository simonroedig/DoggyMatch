import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int activeIndex;
  final ValueChanged<int> onTabTapped;
  final bool showCloseButton;
  final VoidCallback? onCloseButtonTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.activeIndex,
    required this.onTabTapped,
    this.showCloseButton = false,
    this.onCloseButtonTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: BottomAppBar(
        color: AppColors.bg,
        shape: const CircularNotchedRectangle(),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 80.0,
            decoration: BoxDecoration(
              color: AppColors.brownLightest,
              borderRadius: BorderRadius.circular(80.0),
              border: Border.all(
                color: Colors.black,
                width: 3.0,
              ),
            ),
            child:
                showCloseButton ? _buildCloseButton() : _buildNavigationIcons(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildIcon(0, Icons.search_rounded),
        _buildIcon(1, Icons.chat_rounded),
        _buildIcon(2, Icons.person_rounded),
      ],
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

  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () {
        log("Close button tapped in nav bar");
        if (onCloseButtonTapped != null) {
          onCloseButtonTapped!();
        }
      },
      child: Center(
        child: Container(
          color: Colors
              .transparent, // Ensure the area around the icon is tappable without changing the visual appearance
          padding: const EdgeInsets.symmetric(
              horizontal: 20.0), // Increase hitbox horizontally
          child: Container(
            width: double.infinity,
            height: 60.0,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close_rounded,
              color: AppColors.customBlack,
              size: 35.0,
            ),
          ),
        ),
      ),
    );
  }

  Color _getHighlightColor(int index) {
    return AppColors.customBlack;
  }
}
