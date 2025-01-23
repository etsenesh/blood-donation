import '../../common/assets.dart'; // Import custom assets (e.g., SVG icons)
import '../../common/colors.dart'; // Import custom colors
import '../../widgets/all_blood_requests.dart'; // Widget to display all blood requests
import '../../widgets/custom_drawer.dart'; // Custom drawer widget
import 'package:flutter/material.dart'; // Flutter material design package
import 'package:flutter_svg/flutter_svg.dart'; // SVG support for Flutter

class HomeScreen extends StatelessWidget {
  static const route = 'home'; // Route name for navigation
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(), // Custom drawer for navigation
      appBar: AppBar(title: const Text('Blood Requests')), // App bar with title
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(), // Bounce effect for scrolling
          slivers: [
            // Header card with motivational message
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 3, // Card elevation for shadow
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Blood bag icon
                        SvgPicture.asset(
                          IconAssets.bloodBagHand,
                          height: 80,
                          width: 80,
                        ),
                        const SizedBox(width: 12), // Spacer
                        // Motivational text
                        Expanded(
                          child: Center(
                            child: Text(
                              'Donate Blood,\nSave Lives',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(color: MainColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Sliver app bar for "Current Requests" section
            SliverAppBar(
              title: Text(
                'Current Requests',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(color: MainColors.primary),
              ),
              primary: false, // Not a primary app bar
              pinned: true, // Pinned to the top
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              automaticallyImplyLeading: false, // Hide the back button
            ),
            // List of all blood requests
            const AllBloodRequests(),
          ],
        ),
      ),
    );
  }
}