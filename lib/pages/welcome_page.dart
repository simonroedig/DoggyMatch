import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the screen width
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/icons/WelcomeBG.png',
              fit: BoxFit.cover, // Ensures the image covers the entire screen
            ),
          ),
          // Foreground content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 60.0,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Welcome Text
                  const Column(
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: AppColors.deepPurple,
                          height: 0.9, // Adjust this value to control the space
                        ),
                      ),
                      SizedBox(height: 0), // No space between the texts
                      Text(
                        'DoggyMatch',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                          color: AppColors.deepPurple,
                          height: 1.0, // Adjust this value if needed
                        ),
                      ),
                    ],
                  ),
                  // Buttons at the bottom
                  Column(
                    children: [
                      SizedBox(
                        width: screenWidth * 0.8, // 80% width of the screen
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle register action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.brownLightest, // Customize the color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(
                              color: AppColors.customBlack,
                              width: 3,
                            ), // Adding the border
                            elevation: 0, // Remove shadow
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: AppColors.customBlack,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Space between the buttons
                      SizedBox(
                        width: screenWidth * 0.8, // 80% width of the screen
                        height: 50.0,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle sign in action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.bg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            side: const BorderSide(
                              color: AppColors.customBlack,
                              width: 3,
                            ), // Adding the border
                            elevation: 0, // Remove shadow
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.customBlack,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
