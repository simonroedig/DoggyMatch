import 'package:doggymatch_flutter/main/main_screen.dart';
import 'package:doggymatch_flutter/main/ui_constants.dart';
import 'package:doggymatch_flutter/welcome_pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/main/colors.dart';
import 'package:doggymatch_flutter/welcome_pages/welcome_page.dart';
import 'package:doggymatch_flutter/services/auth_service.dart';
import 'package:flutter_svg/svg.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                    'Register',
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
                    'Sign Up to get started!',
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
                const SizedBox(height: 8),
                Center(
                  child: _buildInputField(
                    label: 'Confirm Password..',
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.customBlack,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                              !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    borderColor: _getConfirmPasswordBorderColor(),
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: _buildRegisterButton(screenWidth),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
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
    Color? borderColor,
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
          borderSide: BorderSide(
            color: borderColor ?? AppColors.customBlack,
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.customBlack,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.outerRadius),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.customBlack,
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

  Color _getConfirmPasswordBorderColor() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.isEmpty && confirmPassword.isEmpty) {
      return AppColors.customBlack;
    }
    return password == confirmPassword
        ? AppColors.customGreen
        : AppColors.customRed;
  }

  Widget _buildRegisterButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.4,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          final email = _emailController.text;
          final password = _passwordController.text;
          final confirmPassword = _confirmPasswordController.text;

          _signup(email, password, confirmPassword);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.customBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.innerRadius),
          ),
          side: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
          elevation: 0,
        ),
        child: const Text(
          'Register >',
          style: TextStyle(
            color: AppColors.bg,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(fromRegister: true),
      ),
    );
  }

  _signup(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match. Please try again.');
      return;
    }

    try {
      final user = await _auth.createUserWithEmailAndPassword(email, password);
      if (user != null) {
        _auth.createUserDocument(user);
        goToHome();
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code}');
      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage =
              'This email is already in use. Please try another or LOG-IN.';
          break;
        case 'weak-password':
          errorMessage =
              'Your password is too weak. Please try a stronger one.';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format. Please check and try again.';
          break;
        default:
          errorMessage = 'Some error occurred. Please try again later.';
          break;
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
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
              'Registration Error',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.customBlack,
              ),
            ),
          ),
          content: message.contains('LOG-IN')
              ? RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.customBlack,
                    ),
                    children: [
                      const TextSpan(
                          text:
                              'This email is already in use. Please try another or '),
                      TextSpan(
                        text: 'LOGIN.',
                        style: const TextStyle(
                          color: AppColors.customBlack,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.of(context).pop(); // Close the dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                )
              : Text(
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
