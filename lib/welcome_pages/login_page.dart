import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/main_screen.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/welcome_pages/welcome_page.dart';
import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:flutter_svg/svg.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _buildBackgroundImage(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.deepPurple,
                      size: 60.0,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WelcomePage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: AppColors.deepPurple,
                      height: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 90),
                const Center(
                  child: Text(
                    'Welcome back!',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: AppColors.deepPurple,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: _buildInputField(
                    label: 'Email..',
                    controller: _emailController,
                    obscureText: false,
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: _buildInputField(
                    label: 'Password..',
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.customBlack,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: _buildLoginButton(screenWidth),
                ),
              ],
            ),
          ),
          // Add this Positioned widget for the image
          Positioned(
            bottom: 10, // Position it slightly above the bottom of the screen
            left: 0, // Position it on the left side of the screen
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.asset(
                'assets/icons/doggymatch_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Background image widget
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: SvgPicture.asset(
        'assets/icons/login.svg',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: AppColors.grey),
        filled: true,
        fillColor: AppColors.bg.withOpacity(0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          borderSide: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          borderSide: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          borderSide: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(
        color: AppColors.customBlack,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLoginButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.4,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          // Access the text input
          final email = _emailController.text;
          final password = _passwordController.text;

          // Handle login logic
          _signin(email, password);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppColors.customBlack, // Match the logout button color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                UIConstants.innerRadius), // Match logout button radius
          ),
          side: const BorderSide(
            color: AppColors.customBlack, // Match border color
            width: 3, // Match border width
          ),
          elevation: 0, // Consistent shadow
        ),
        child: const Text(
          'Login >',
          style: TextStyle(
            color: AppColors.bg, // Match text color
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold, // Match text weight
            fontSize: 16, // Match text size
          ),
        ),
      ),
    );
  }

  goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
    );
  }

  _signin(String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        goToHome(); // Navigate to the main screen if login is successful
      }
    } on FirebaseAuthException catch (e) {
      // Debug logs to see the error code in the terminal
      debugPrint('FirebaseAuthException: ${e.code}');

      String errorMessage;
      // Handle different error codes from FirebaseAuthException
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Wrong email or password. Please try again.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please check and try again.';
          break;
        case 'invalid-credential':
          errorMessage = 'Invalid credentials. Please check and try again.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Contact support.';
          break;
        default:
          errorMessage = 'Some error occurred. Please try again later.';
          break;
      }
      _showErrorDialog(errorMessage); // Display the error message in a dialog
    } catch (e) {
      // Handle other unforeseen errors
      debugPrint('Unexpected error: $e');
      _showErrorDialog('Some error occurred. Please try again later.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.popUpRadius),
            side: const BorderSide(
              color: AppColors.customBlack,
              width: 3.0,
            ),
          ),
          title: const Center(
            child: Text(
              'Login Error',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.customBlack,
              ),
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.customBlack,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.customBlack,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: AppColors.bg,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
