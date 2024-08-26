import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/widgets/profile/profile_edit_all.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class RegisterPage2 extends StatefulWidget {
  final UserProfile profile;

  const RegisterPage2({super.key, required this.profile});

  @override
  State<RegisterPage2> createState() => _RegisterPage2State();
}

class _RegisterPage2State extends State<RegisterPage2> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final userProfileState = Provider.of<UserProfileState>(context);
    bool isDogOwner = userProfileState.userProfile.isDogOwner;
    Color selectedColor = userProfileState.userProfile.profileColor;

    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40.0),
                const Center(
                  child: Text(
                    "I am a",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildSelectionMenu(
                  icon: Icons.pets_rounded,
                  text: "Dog Owner",
                  isSelected: isDogOwner,
                  onTap: () {
                    setState(() {
                      isDogOwner = true;
                    });
                    userProfileState.updateDogOwnerStatus(true);
                  },
                ),
                const SizedBox(height: 10.0),
                _buildSelectionMenu(
                  icon: Icons.person_rounded,
                  text: "Dog Sitter",
                  isSelected: !isDogOwner,
                  onTap: () {
                    setState(() {
                      isDogOwner = false;
                    });
                    userProfileState.updateDogOwnerStatus(false);
                  },
                ),
                const SizedBox(height: 30.0),
                const Center(
                  child: Text(
                    "Profile Color",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorOption(
                        color: AppColors.accent1,
                        isSelected: selectedColor == AppColors.accent1,
                        onTap: () {
                          setState(() {
                            selectedColor = AppColors.accent1;
                          });
                          userProfileState
                              .updateProfileColor(AppColors.accent1);
                        },
                      ),
                      const SizedBox(width: 20.0),
                      _buildColorOption(
                        color: AppColors.accent2,
                        isSelected: selectedColor == AppColors.accent2,
                        onTap: () {
                          setState(() {
                            selectedColor = AppColors.accent2;
                          });
                          userProfileState
                              .updateProfileColor(AppColors.accent2);
                        },
                      ),
                      const SizedBox(width: 20.0),
                      _buildColorOption(
                        color: AppColors.accent3,
                        isSelected: selectedColor == AppColors.accent3,
                        onTap: () {
                          setState(() {
                            selectedColor = AppColors.accent3;
                          });
                          userProfileState
                              .updateProfileColor(AppColors.accent3);
                        },
                      ),
                      const SizedBox(width: 20.0),
                      _buildColorOption(
                        color: AppColors.brownLightest,
                        isSelected: selectedColor == AppColors.brownLightest,
                        onTap: () {
                          setState(() {
                            selectedColor = AppColors.brownLightest;
                          });
                          userProfileState
                              .updateProfileColor(AppColors.brownLightest);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: SizedBox(
              width: screenWidth * 0.4,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () {
                  _openEditProfileDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  side: const BorderSide(
                    color: AppColors.customBlack,
                    width: 3,
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue >',
                  style: TextStyle(
                    color: AppColors.bg,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionMenu({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.greyLightest,
          borderRadius: BorderRadius.circular(50.0),
          border: Border.all(
            color: isSelected ? AppColors.customBlack : AppColors.grey,
            width: 3.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.customBlack : AppColors.grey,
            ),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? AppColors.customBlack : AppColors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.customBlack,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? AppColors.customBlack
                : const Color.fromARGB(113, 34, 34, 34),
            width: 3.0,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check_rounded,
                color: AppColors.customBlack,
              )
            : null,
      ),
    );
  }

  void _openEditProfileDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProfileImageEdit(
          profile: widget.profile,
        ),
      ),
    );
  }
}
