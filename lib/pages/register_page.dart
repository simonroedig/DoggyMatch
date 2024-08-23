import 'package:doggymatch_flutter/pages/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:doggymatch_flutter/colors.dart';
import 'package:doggymatch_flutter/pages/welcome_page.dart';
import 'package:doggymatch_flutter/services/auth.dart';

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
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Sign Up\nto get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
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
                const SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.customBlack,
            width: 3,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: borderColor ?? AppColors.customBlack,
            width: 3,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
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
    return password == confirmPassword ? Colors.green : Colors.red;
  }

  Widget _buildRegisterButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.4,
      height: 50.0,
      child: ElevatedButton(
        onPressed: () {
          // Access the text input
          final email = _emailController.text;
          final password = _passwordController.text;
          final confirmPassword = _confirmPasswordController.text;

          // Handle register logic
          _signup(email, password, confirmPassword);
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
          'Register >',
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

  goToHome() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
  }

  _signup(String email, String password, String confirmPassword) async {
    if (password != confirmPassword) {
      return;
    }

    final user = await _auth.createUserWithEmailAndPassword(email, password);
    if (user != null) {
      goToHome();
    } else {}
  }
}
