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
  bool? isDogOwner;
  Color? selectedColor;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final userProfileState = Provider.of<UserProfileState>(context);

    // Calculate the appropriate size for the color circles to prevent overflow
    int colorOptionCount = 6; // Number of color options
    double availableWidth = screenWidth - 32.0; // 16px padding on both sides
    double totalSpacing =
        (colorOptionCount - 1) * 8.0; // 8px spacing between circles
    double maxCircleDiameter =
        (availableWidth - totalSpacing) / colorOptionCount - 4;

    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              // Center the whole content
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Center content vertically
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center content horizontally
                children: [
                  const SizedBox(height: 40.0),
                  const Text(
                    "Select your profile type.\nYou can always change it later! 😃",
                    textAlign:
                        TextAlign.center, // Center text within the Text widget
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  const Text(
                    "I am a",
                    textAlign:
                        TextAlign.center, // Center text within the Text widget
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _buildSelectionMenu(
                    icon: Icons.pets_rounded,
                    text: "Dog Owner",
                    isSelected: isDogOwner == true,
                    onTap: () {
                      setState(() {
                        isDogOwner = true;
                        errorMessage = null; // Clear error message
                      });
                      userProfileState.updateDogOwnerStatus(true);
                    },
                  ),
                  const SizedBox(height: 10.0),
                  _buildSelectionMenu(
                    icon: Icons.person_rounded,
                    text: "Dog Sitter",
                    isSelected: isDogOwner == false,
                    onTap: () {
                      setState(() {
                        isDogOwner = false;
                        errorMessage = null; // Clear error message
                      });
                      userProfileState.updateDogOwnerStatus(false);
                    },
                  ),
                  const SizedBox(height: 30.0),
                  const Text(
                    "Profile Color",
                    textAlign:
                        TextAlign.center, // Center text within the Text widget
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.customBlack,
                      fontFamily: 'Poppins',
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
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.accent1);
                          },
                          diameter: maxCircleDiameter,
                        ),
                        const SizedBox(width: 8.0),
                        _buildColorOption(
                          color: AppColors.accent2,
                          isSelected: selectedColor == AppColors.accent2,
                          onTap: () {
                            setState(() {
                              selectedColor = AppColors.accent2;
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.accent2);
                          },
                          diameter: maxCircleDiameter,
                        ),
                        const SizedBox(width: 8.0),
                        _buildColorOption(
                          color: AppColors.accent3,
                          isSelected: selectedColor == AppColors.accent3,
                          onTap: () {
                            setState(() {
                              selectedColor = AppColors.accent3;
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.accent3);
                          },
                          diameter: maxCircleDiameter,
                        ),
                        const SizedBox(width: 8.0),
                        _buildColorOption(
                          color: AppColors.brownLightest,
                          isSelected: selectedColor == AppColors.brownLightest,
                          onTap: () {
                            setState(() {
                              selectedColor = AppColors.brownLightest;
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.brownLightest);
                          },
                          diameter: maxCircleDiameter,
                        ),
                        const SizedBox(width: 8.0),
                        _buildColorOption(
                          color: AppColors.accent4,
                          isSelected: selectedColor == AppColors.accent4,
                          onTap: () {
                            setState(() {
                              selectedColor = AppColors.accent4;
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.accent4);
                          },
                          diameter: maxCircleDiameter,
                        ),
                        const SizedBox(width: 8.0),
                        _buildColorOption(
                          color: AppColors.accent5,
                          isSelected: selectedColor == AppColors.accent5,
                          onTap: () {
                            setState(() {
                              selectedColor = AppColors.accent5;
                              errorMessage = null; // Clear error message
                            });
                            userProfileState
                                .updateProfileColor(AppColors.accent5);
                          },
                          diameter: maxCircleDiameter,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppColors.customRed,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
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
                  if (isDogOwner == null || selectedColor == null) {
                    setState(() {
                      errorMessage =
                          "Please select whether you're a Dog Owner or Dog Sitter and choose a profile color. You can change these later anytime.";
                    });
                  } else {
                    _openEditProfileDialog(context);
                  }
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
                  '>',
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
    required double diameter,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: diameter,
        height: diameter,
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
          fromRegister: true,
        ),
      ),
    );
  }
}
