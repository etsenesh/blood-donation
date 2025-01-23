import '../../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../../common/styles.dart'; // Custom styles (e.g., fonts)
import 'home_screen.dart'; // Home screen for navigation
import 'login_screen.dart'; // Login screen for navigation
import 'tutorial_screen.dart'; // Tutorial screen for first-time users
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:firebase_core/firebase_core.dart'; // Firebase initialization
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/svg.dart'; // SVG support
import 'package:shared_preferences/shared_preferences.dart'; // Local storage

class SplashScreen extends StatefulWidget {
  static const route = '/'; // Route name for navigation
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _destination = ''; // Destination screen after splash

  @override
  void initState() {
    super.initState();
    _initializeApp(); // Initialize Firebase and resolve destination
  }

  // Initialize Firebase and SharedPreferences
  Future<void> _initializeApp() async {
    await Firebase.initializeApp(); // Initialize Firebase
    await _resolveDestination(); // Determine the destination screen
  }

  // Determine the destination screen based on user state
  Future<void> _resolveDestination() async {
    debugPrint('Firebase initialization complete');

    // Allow the splash screen to remain for a bit longer
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance(); // Initialize SharedPreferences
    final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true; // Check if it's the first launch

    if (isFirstLaunch) {
      _destination = TutorialScreen.route; // Navigate to tutorial screen
      await prefs.setBool('isFirstLaunch', false); // Update first launch status
    } else if (FirebaseAuth.instance.currentUser != null) {
      _destination = HomeScreen.route; // Navigate to home screen if user is logged in
      await _updateCachedData(); // Update cached user data
    } else {
      _destination = LoginScreen.route; // Navigate to login screen if user is not logged in
    }

    // Navigate to the destination screen
    Navigator.of(context).pushReplacementNamed(_destination);
  }

  // Update cached user data in SharedPreferences
  Future<void> _updateCachedData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(); // Fetch user data from Firestore

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('bloodType', userDoc.data()?['bloodType'] as String? ?? 'A+'); // Save blood type
      prefs.setBool('isAdmin', userDoc.data()?['isAdmin'] as bool? ?? false); // Save admin status
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(IconAssets.logo), // App logo
              const SizedBox(height: 28),
              Flexible(
                child: Text(
                  'Blood Donation',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontFamily: Fonts.logo, // Custom font for the logo
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}