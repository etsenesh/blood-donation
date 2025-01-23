import 'package:bloodyapp/common/colors.dart'; // Custom color definitions
import 'package:bloodyapp/common/styles.dart'; // Custom font and style definitions
import 'package:bloodyapp/screens/add_blood_request_screen.dart'; // Screen for adding blood requests
import 'package:bloodyapp/screens/add_news_item.dart'; // Screen for adding news items
import 'package:bloodyapp/screens/edit_profile_screen.dart'; // Screen for editing user profile
import 'package:bloodyapp/screens/home_screen.dart'; // Home screen
import 'package:bloodyapp/screens/login_screen.dart'; // Login screen
import 'package:bloodyapp/screens/news_screen.dart'; // News screen
import 'package:bloodyapp/screens/profile_screen.dart'; // Profile screen
import 'package:bloodyapp/screens/registration_screen.dart'; // Registration screen
import 'package:bloodyapp/screens/splash_screen.dart'; // Splash screen
import 'package:bloodyapp/screens/tutorial_screen.dart'; // Tutorial screen
import 'package:bloodyapp/screens/who_can_donate_screen.dart'; // Screen for donation eligibility info
import 'package:firebase_core/firebase_core.dart'; // Firebase core package
import 'firebase_options.dart';
import 'package:flutter/material.dart'; // Flutter material design package

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Run the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hide debug banner
      title: 'Blood Donation', // App title
      theme: ThemeData(
        primarySwatch: MainColors.swatch, // Custom primary color swatch
        visualDensity: VisualDensity.adaptivePlatformDensity, // Adaptive visual density
        fontFamily: Fonts.text, // Custom font family
      ),
      initialRoute: SplashScreen.route, // Initial route (Splash Screen)
      routes: {
        // Define all routes for the app
        HomeScreen.route: (_) => const HomeScreen(),
        TutorialScreen.route: (_) => const TutorialScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        RegistrationScreen.route: (_) => const RegistrationScreen(),
        SplashScreen.route: (_) => const SplashScreen(),
        ProfileScreen.route: (_) => const ProfileScreen(),
        WhoCanDonateScreen.route: (_) => const WhoCanDonateScreen(),
        AddBloodRequestScreen.route: (_) => const AddBloodRequestScreen(),
        NewsScreen.route: (_) => const NewsScreen(),
        AddNewsItem.route: (_) => const AddNewsItem(),
        EditProfileScreen.route: (_) => const EditProfileScreen(),
      },
    );
  }
}