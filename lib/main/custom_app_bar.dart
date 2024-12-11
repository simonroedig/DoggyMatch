// File: custom_app_bar.dart

import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool isFilterOpen;
  final VoidCallback? toggleFilter;
  final bool showFilterIcon;
  final VoidCallback? onSettingsPressed;
  final bool isProfileOpen;
  final bool showSearchIcon;

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
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  final AssetImage _logoImage = const AssetImage('assets/icons/logo.png');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache the logo image here
    precacheImage(_logoImage, context);
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double additionalPadding = 8.0;

    return AppBar(
      backgroundColor: AppColors.bg,
      elevation: 0,
      scrolledUnderElevation: 0.0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: Padding(
        padding: EdgeInsets.only(
          top: statusBarHeight + additionalPadding,
          left: 16.0,
          right: 16.0,
          bottom: 10.0,
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                height: 60.0,
                decoration: BoxDecoration(
                  color: AppColors.brownLightest,
                  borderRadius: BorderRadius.circular(UIConstants.outerRadius),
                  border: Border.all(
                    color: AppColors.customBlack,
                    width: 3.0,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Use the precached AssetImage
                        Image(
                          image: _logoImage,
                          height: 60,
                          gaplessPlayback: true,
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
                    if (widget.showSearchIcon)
                      IconButton(
                        icon: const Icon(Icons.search_rounded, size: 30.0),
                        onPressed: () {},
                        color: const Color.fromARGB(0, 34, 34, 34),
                      )
                    else if (widget.showFilterIcon)
                      IconButton(
                        icon: Icon(
                          widget.isFilterOpen
                              ? Icons.close_rounded
                              : Icons.filter_list_rounded,
                          size: 30.0,
                        ),
                        onPressed:
                            widget.isProfileOpen ? null : widget.toggleFilter,
                        color: AppColors.customBlack,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.settings_rounded, size: 30.0),
                        onPressed: widget.isProfileOpen
                            ? null
                            : widget.onSettingsPressed,
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
