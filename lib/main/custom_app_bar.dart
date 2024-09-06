// File: custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFilterOpen;
  final VoidCallback? toggleFilter;
  final bool showFilterIcon;
  final VoidCallback? onSettingsPressed;
  final bool isProfileOpen;
  final bool showSearchIcon; // New parameter for search icon

  const CustomAppBar({
    super.key,
    this.isFilterOpen = false,
    this.toggleFilter,
    this.showFilterIcon = true,
    this.onSettingsPressed,
    this.isProfileOpen = false,
    this.showSearchIcon = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(
            top: 40.0, left: 16.0, right: 16.0, bottom: 10.0),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 60.0,
                decoration: BoxDecoration(
                  color: AppColors.brownLightest,
                  borderRadius: BorderRadius.circular(80.0),
                  border: Border.all(
                    color: AppColors.customBlack,
                    width: 3.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/logo.png',
                          height: 60,
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Doggy',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                                color: AppColors.customBlack,
                                height: 0.9,
                              ),
                            ),
                            Text(
                              'Match',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Poppins',
                                color: AppColors.customBlack,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (showSearchIcon)
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 30.0),
                        onPressed: () {}, // Add action if needed
                        color: const Color.fromARGB(0, 34, 34, 34),
                      )
                    else if (showFilterIcon)
                      IconButton(
                        icon: Icon(
                          isFilterOpen
                              ? Icons.close_rounded
                              : Icons.filter_list_rounded,
                          size: 30.0,
                        ),
                        onPressed: isProfileOpen
                            ? null
                            : toggleFilter, // Disable if profile is open
                        color: AppColors.customBlack,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, size: 30.0),
                        onPressed: isProfileOpen
                            ? null
                            : onSettingsPressed, // Disable if profile is open
                        color: AppColors.customBlack,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
