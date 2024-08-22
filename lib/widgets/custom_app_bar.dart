import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isFilterOpen;
  final VoidCallback toggleFilter;

  const CustomAppBar({
    super.key,
    required this.isFilterOpen,
    required this.toggleFilter,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  IconButton(
                    icon: Icon(isFilterOpen ? Icons.close : Icons.filter_list,
                        size: 30.0),
                    onPressed: toggleFilter,
                    color: AppColors.customBlack,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
