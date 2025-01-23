import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/flutter_svg.dart'; // SVG support
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications

import '../../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../../common/colors.dart'; // Custom colors
import '../../utils/blood_types.dart'; // Blood type utilities
import '../../utils/validators.dart'; // Validation utilities
import '../../widgets/action_button.dart'; // Custom button widget
import 'home_screen.dart'; // Home screen for navigation

class RegistrationScreen extends StatefulWidget {
  static const route = 'register'; // Route name for navigation
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController(); // Controller for name field
  final _emailController = TextEditingController(); // Controller for email field
  final _passController = TextEditingController(); // Controller for password field
  String? _nameError; // Error message for name field
  String? _emailError; // Error message for email field
  String? _passError; // Error message for password field
  String _bloodType = 'A+'; // Selected blood type (default: A+)
  bool _isLoading = false; // Loading state for registration

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _nameController.dispose();
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
              child: Card(
                margin: const EdgeInsets.all(24), // Card margin
                child: Padding(
                  padding: const EdgeInsets.all(24), // Card padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(IconAssets.logo), // App logo
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'Register',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _nameField(), // Name input field
                      const SizedBox(height: 18),
                      _emailField(), // Email input field
                      const SizedBox(height: 18),
                      _passField(), // Password input field
                      const SizedBox(height: 18),
                      _bloodTypeSelector(), // Blood type dropdown
                      const SizedBox(height: 32),
                      ActionButton(
                        key: const Key('register_button'),
                        text: 'Register',
                        callback: _register, // Registration callback
                        isLoading: _isLoading, // Loading state
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Name input field
  Widget _nameField() => TextField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        onTap: () => setState(() => _nameError = null), // Clear error on tap
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: 'Name',
          prefixIcon: const Icon(Icons.person),
          errorText: _nameError, // Display error message
        ),
      );

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

  // Blood type dropdown selector
  Widget _bloodTypeSelector() => DropdownButtonFormField<String>(
        value: _bloodType,
        onChanged: (v) => setState(() => _bloodType = v!), // Update selected blood type
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Blood Type',
          prefixIcon: Icon(Icons.bloodtype),
        ),
        items: BloodTypeUtils.bloodTypes
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v),
                ))
            .toList(),
      );

  // Handle user registration
  Future<void> _register() async {
    if (_validateFields()) { // Validate fields before proceeding
      setState(() {
        _nameError = null;
        _emailError = null;
        _passError = null;
        _isLoading = true; // Show loading indicator
      });
      try {
        // Create user with Firebase authentication
        print('Creating user with Firebase authentication...');
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passController.text,
        );

        // Update user's display name
        print('Updating user display name...');
        await userCredential.user?.updateDisplayName(_nameController.text);

        // Save additional user data in Firestore
        print('Saving additional user data in Firestore...');
        final users = FirebaseFirestore.instance.collection('users');
        await users.doc(userCredential.user?.uid).set({
          'bloodType': _bloodType, // Save blood type
          'isAdmin': false, // Default admin status
        }, SetOptions(merge: true));

        // Send email verification
        print('Sending email verification...');
        await userCredential.user?.sendEmailVerification();

        // Navigate to home screen and remove all previous routes
        print('Navigating to home screen...');
        Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.route,
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        // Handle Firebase-specific errors
        print('FirebaseAuthException: ${e.code}');
        if (e.code == 'weak-password') {
          _passError = 'The password provided is too weak';
        } else if (e.code == 'email-already-in-use') {
          _emailError = 'The account already exists for that email';
        } else {
          Fluttertoast.showToast(msg: e.message ?? 'An error occurred');
        }
      } catch (e) {
        // Handle generic errors
        print('Exception: $e');
        Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again',
        );
      } finally {
        print('Setting loading state to false...');
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  // Validate name, email, and password fields
  bool _validateFields() {
    setState(() {
      _nameError = Validators.required(_nameController.text, 'Name');
      _emailError = Validators.required(_emailController.text, 'Email');
      _passError = Validators.required(_passController.text, 'Password');
    });

    return _nameError == null && _emailError == null && _passError == null; // Return true if no errors
  }
}