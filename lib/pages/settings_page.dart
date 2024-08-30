// ignore_for_file: use_build_context_synchronously

import 'package:doggymatch_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/welcome_page.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:doggymatch_flutter/state/user_profile_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final userProfileState = Provider.of<UserProfileState>(context);
    bool isDogOwner = userProfileState.userProfile.isDogOwner;
    Color selectedColor = userProfileState.userProfile.profileColor;

    // Calculate the available width minus padding for each color option
    int colorOptionCount = 6;
    double availableWidth = screenWidth - 32.0; // 16px padding on both sides
    double totalSpacing =
        (colorOptionCount - 1) * 8.0; // 8px spacing between circles
    double maxCircleDiameter =
        (availableWidth - totalSpacing) / colorOptionCount - 4;

    return Scaffold(
      backgroundColor: AppColors.greyLightest,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.customBlack,
          ),
        ),
        backgroundColor: AppColors.greyLightest,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greyLightest,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_circle_left_rounded),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.customBlack,
              iconSize: 30.0,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        diameter: maxCircleDiameter,
                      ),
                      const SizedBox(width: 8.0),
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
                        diameter: maxCircleDiameter,
                      ),
                      const SizedBox(width: 8.0),
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
                        diameter: maxCircleDiameter,
                      ),
                      const SizedBox(width: 8.0),
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
                        diameter: maxCircleDiameter,
                      ),
                      const SizedBox(width: 8.0),
                      _buildColorOption(
                        color: AppColors.accent4,
                        isSelected: selectedColor == AppColors.accent4,
                        onTap: () {
                          setState(() {
                            selectedColor = AppColors.accent4;
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
                Center(
                  child: SizedBox(
                    width: screenWidth * 0.4,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _auth.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
                          (Route<dynamic> route) =>
                              false, // Removes all previous routes
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.customBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(
                          color: AppColors.customBlack,
                          width: 3,
                        ),
                        //elevation: 0, // Remove shadow
                      ),
                      child: const Text(
                        '< Logout',
                        style: TextStyle(
                          color: AppColors.bg,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            left: 16.0,
            right: 16.0,
            child: SizedBox(
              width: screenWidth * 0.8,
              height: 50.0,
              child: ElevatedButton(
                onPressed: () async {
                  final firstConfirmation = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text(
                          'Are you sure you want to delete your account?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );

                  if (firstConfirmation == true) {
                    final secondConfirmation = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Are You Absolutely Sure?'),
                        content: const Text(
                            'This action is irreversible. Do you really want to delete your account?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Yes, Delete'),
                          ),
                        ],
                      ),
                    );

                    if (secondConfirmation == true) {
                      // Call the new method to delete account and user data
                      final success = await _auth.deleteAccountAndData();
                      if (!mounted) {
                        return; // Ensure the widget is still mounted before continuing
                      }

                      if (success) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
                          (Route<dynamic> route) =>
                              false, // Removes all previous routes
                        );
                      } else {
                        // Handle deletion failure
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to delete account.'),
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.customRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(
                    color: AppColors.customBlack,
                    width: 3,
                  ),
                  //elevation: 0, // Remove shadow
                ),
                child: const Text(
                  'Delete Account? 😢',
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

  void goToWelcome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const WelcomePage(),
      ),
      (route) => false,
    );
  }
}
