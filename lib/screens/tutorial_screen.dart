import 'package:dots_indicator/dots_indicator.dart'; // Dots indicator for page view
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/flutter_svg.dart'; // SVG support
import 'package:shared_preferences/shared_preferences.dart'; // Local storage

import '../../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../../common/colors.dart'; // Custom colors
import 'login_screen.dart'; // Login screen for navigation

class TutorialScreen extends StatefulWidget {
  static const route = 'tutorial'; // Route name for navigation
  const TutorialScreen({super.key});

  @override
  _TutorialScreenState createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with SingleTickerProviderStateMixin {
  final _controller = PageController(); // Page controller for the tutorial panels
  int _currentIndex = 0; // Current page index

  @override
  void initState() {
    super.initState();
    // Add a listener to update the current page index
    _controller.addListener(() {
      if (_controller.page?.round() != _currentIndex) {
        setState(() => _currentIndex = _controller.page!.round());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the page controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // PageView for tutorial panels
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const BouncingScrollPhysics(), // Bounce effect for scrolling
                children: const [
                  _TutorialPanel(
                    asset: IconAssets.bloodHand,
                    title: 'Request Blood',
                    body: 'Submit a blood request and let the donors know!',
                  ),
                  _TutorialPanel(
                    asset: IconAssets.bloodBagHand,
                    title: 'Donate Blood',
                    body: 'Browse the requests and check if you can help by '
                        'donating blood to those who need it',
                  ),
                  _TutorialPanel(
                    asset: IconAssets.clipboard,
                    title: 'Health Information',
                    body: 'Stay updated with the latest health tips and '
                        'information',
                  ),
                ],
              ),
            ),

            // Dots indicator to show current page
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: DotsIndicator(
                dotsCount: 3, // Number of dots
                decorator: const DotsDecorator(
                  activeColor: MainColors.primary, // Active dot color
                  size: Size.square(12), // Dot size
                  activeSize: Size.square(12), // Active dot size
                ),
                position: _currentIndex, // Current page index
              ),
            ),

            // Next/Let's go button
            InkWell(
              onTap: () {
                if (_currentIndex == 2) {
                  // On the last page, mark the tutorial as completed
                  _markTutorialCompleted();
                  Navigator.of(context).pushReplacementNamed(LoginScreen.route); // Navigate to login screen
                } else {
                  // Go to the next page
                  _controller.animateToPage(
                    _currentIndex + 1,
                    duration: const Duration(milliseconds: 300), // Animation duration
                    curve: Curves.decelerate, // Animation curve
                  );
                }
              },
              child: Ink(
                color: MainColors.primary, // Button background color
                padding: const EdgeInsets.all(16), // Button padding
                width: double.infinity, // Full-width button
                child: Text(
                  _currentIndex == 2 ? "Let's go!" : 'Next', // Button text
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16), // Button text style
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mark the tutorial as completed in SharedPreferences
  Future<void> _markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false); // Update first launch status
  }
}

// Tutorial panel widget
class _TutorialPanel extends StatelessWidget {
  final String asset; // SVG asset path
  final String title; // Panel title
  final String body; // Panel body text

  const _TutorialPanel({
    required this.asset,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(24), // Padding for the panel
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SVG image
          Container(
            padding: const EdgeInsets.symmetric(vertical: 42),
            child: SvgPicture.asset(
              asset,
              fit: BoxFit.fitWidth,
              width: MediaQuery.of(context).size.width * 0.5, // Set image width
            ),
          ),

          // Title
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              color: MainColors.primary, // Title text color
            ),
          ),

          const SizedBox(height: 18), // Spacer

          // Body text
          Text(
            body,
            textAlign: TextAlign.center,
            style: textTheme.displaySmall?.copyWith(fontSize: 18, height: 1.2), // Body text style
          ),
        ],
      ),
    );
  }
}