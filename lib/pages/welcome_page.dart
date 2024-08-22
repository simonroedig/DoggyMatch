import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/register_page.dart';
import 'package:doggymatch_flutter/pages/login_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildContent(context, screenWidth),
        ],
      ),
    );
  }

  // Extract background image into a separate function
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/icons/WelcomeBG.png',
        fit: BoxFit.cover,
      ),
    );
  }

  // Extract foreground content into a separate function
  Widget _buildContent(BuildContext context, double screenWidth) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 60.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildWelcomeText(),
            _buildActionButtons(context, screenWidth),
          ],
        ),
      ),
    );
  }

  // Extract welcome text into a separate function
  Widget _buildWelcomeText() {
    return const Column(
      children: [
        Text(
          'Welcome to',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: AppColors.deepPurple,
            height: 0.9,
          ),
        ),
        SizedBox(height: 0),
        Text(
          'DoggyMatch',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
            color: AppColors.deepPurple,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  // Extract action buttons into a separate function
  Widget _buildActionButtons(BuildContext context, double screenWidth) {
    return Column(
      children: [
        _buildButton(
          context: context,
          label: 'Register',
          onPressed: () => _navigateToPage(context, const RegisterPage()),
          backgroundColor: AppColors.brownLightest,
        ),
        const SizedBox(height: 8),
        _buildButton(
          context: context,
          label: 'Login',
          onPressed: () => _navigateToPage(context, const LoginPage()),
          backgroundColor: AppColors.bg,
        ),
      ],
    );
  }

  // General button creation function to avoid repetition
  Widget _buildButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.8,
      height: 50.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          side: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
          elevation: 0, // Remove shadow
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.customBlack,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // Navigation function to abstract page routing logic
  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
