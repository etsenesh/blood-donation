import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/flutter_svg.dart'; // SVG support
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications

import '../../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../../common/colors.dart'; // Custom colors
import '../../utils/tools.dart'; // Utility functions
import '../../utils/validators.dart'; // Validation functions
import '../../widgets/action_button.dart'; // Custom button widget
import 'home_screen.dart'; // Home screen for navigation
import 'registration_screen.dart'; // Registration screen for navigation

class LoginScreen extends StatefulWidget {
  static const route = 'login'; // Route name for navigation
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(); // Controller for email field
  final _passController = TextEditingController(); // Controller for password field
  String? _emailError; // Error message for email field
  String? _passError; // Error message for password field
  bool _isLoading = false; // Loading state for login and password reset

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MainColors.primary, // Set background color
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // Bounce effect for scrolling
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Login card
                  Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(IconAssets.logo), // App logo
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Login',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _emailField(), // Email input field
                          const SizedBox(height: 18),
                          _passField(), // Password input field
                          const SizedBox(height: 32),
                          ActionButton(
                            key: const Key('login_button'),
                            text: 'Login',
                            callback: _login, // Login callback
                            isLoading: _isLoading, // Loading state
                          ),
                          const SizedBox(height: 16),
                          // Reset password link
                          GestureDetector(
                            onTap: _resetPassword,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                'Reset Password',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: MainColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Registration link
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, RegistrationScreen.route);
                    },
                    child: RichText(
                      text: const TextSpan(
                        text: 'New user? ',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        children: [
                          TextSpan(
                            text: 'Create Account',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Email input field
  Widget _emailField() => TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        onTap: () => setState(() => _emailError = null), // Clear error on tap
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Email',
          prefixIcon: const Icon(Icons.email),
          errorText: _emailError, // Display error message
        ),
      );

  // Password input field
  Widget _passField() => TextField(
        controller: _passController,
        onTap: () => setState(() => _passError = null), // Clear error on tap
        obscureText: true, // Hide password text
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          errorText: _passError, // Display error message
        ),
      );

  // Handle login
  Future<void> _login() async {
    if (_validateFields()) { // Validate fields before proceeding
      setState(() {
        _emailError = null;
        _passError = null;
        _isLoading = true; // Show loading indicator
      });
      try {
        // Sign in with Firebase
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );
        // Navigate to home screen and remove all previous routes
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.route,
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase-specific errors
        if (e.code == 'user-not-found') {
          _emailError = 'No user found for that email';
        } else if (e.code == 'wrong-password') {
          _passError = 'Wrong password provided for that user';
        } else {
          Fluttertoast.showToast(msg: e.message ?? 'An error occurred');
        }
      } catch (e) {
        // Handle generic errors
        Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again',
        );
      }
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Handle password reset
  Future<void> _resetPassword() async {
    if (Tools.isNullOrEmpty(_emailController.text)) {
      // Validate email field
      setState(() {
        _emailError = '* Please specify your email';
      });
    } else {
      setState(() {
        _emailError = null;
        _passError = null;
        _isLoading = true; // Show loading indicator
      });
      try {
        // Send password reset email
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailController.text);
        Fluttertoast.showToast(
          msg: 'Password reset email has been sent. Please check your email',
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase-specific errors
        Fluttertoast.showToast(msg: e.message ?? 'An error occurred');
      } catch (e) {
        // Handle generic errors
        Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again',
        );
      }
      setState(() => _isLoading = false); // Hide loading indicator
    }
  }

  // Validate email and password fields
  bool _validateFields() {
    setState(() {
      _emailError = Validators.required(_emailController.text, 'Email');
      _passError = Validators.required(_passController.text, 'Password');
    });

    return _emailError == null && _passError == null; // Return true if no errors
  }
}