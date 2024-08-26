import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/pages/main_screen.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/welcome_page.dart';
import 'package:doggymatch_flutter/pages/register_page.dart';
import 'package:doggymatch_flutter/services/auth.dart';
import 'package:doggymatch_flutter/profile/profile.dart';

class LoginPage extends StatefulWidget {
  final UserProfile profile;

  const LoginPage({super.key, required this.profile});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                          onPressed: () {
                            _openWelcomePage(context);
                          }),
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
                    const SizedBox(height: 40),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 0),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Implement password recovery logic here
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.deepPurple,
                            fontFamily: 'Poppins',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Center(
                            child: _buildLoginButton(screenWidth),
                          ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _openRegisterPage(context);
                        },
                        child: const Text(
                          "Don't have an account? Register instead!",
                          style: TextStyle(
                            color: AppColors.deepPurple,
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Background image widget
  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.asset(
        'assets/icons/login_register_bg.png',
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
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: AppColors.customBlack,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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
        onPressed: _isLoading
            ? null
            : () {
                // Access the text input
                final email = _emailController.text;
                final password = _passwordController.text;

                // Handle login logic
                _signin(email, password);
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
          elevation: 0, // Remove shadow
        ),
        child: const Text(
          'Login >',
          style: TextStyle(
            color: AppColors.bg,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  void goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  Future<void> _signin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    final user = await _auth.signInWithEmailAndPassword(email, password);
    if (user != null) {
      goToHome();
    } else {
      // Handle login error
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _openRegisterPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          profile: widget.profile,
        ),
      ),
    );
  }

  void _openWelcomePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WelcomePage(
          profile: widget.profile,
        ),
      ),
    );
  }
}
