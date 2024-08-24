import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/constants/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFilterOpen;
  final VoidCallback? toggleFilter;
  final bool showFilterIcon;
  final VoidCallback? onSettingsPressed;

  const CustomAppBar({
    super.key,
    this.isFilterOpen = false,
    this.toggleFilter,
    this.showFilterIcon = true,
    this.onSettingsPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0, // Remove shadow
      automaticallyImplyLeading:
          false, // Remove default back button if not needed
      flexibleSpace: Padding(
        padding: const EdgeInsets.only(
            top: 40.0, left: 16.0, right: 16.0, bottom: 10.0),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 60.0,
                decoration: BoxDecoration(
                  color:
                      AppColors.brownLightest, // Container color remains as is
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
                    if (showFilterIcon)
                      IconButton(
                        icon: Icon(
                          isFilterOpen
                              ? Icons.close_rounded
                              : Icons.filter_list_rounded,
                          size: 30.0,
                        ),
                        onPressed: toggleFilter,
                        color: AppColors.customBlack,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, size: 30.0),
                        onPressed: onSettingsPressed,
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
