import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/app_config.dart';
import '../common/assets.dart';
import '../common/colors.dart';
import '../screens/add_blood_request_screen.dart';
import '../screens/add_news_item.dart';
import '../screens/login_screen.dart';
import '../screens/news_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/who_can_donate_screen.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _showAdmin = false; // Toggle admin screens visibility

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            // Drawer header with user info
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Blood Donation'), // User's name
              accountEmail: Text(user?.email ?? AppConfig.email), // User's email
              otherAccountsPictures: [
                // Admin icon (visible if user is admin)
                FutureBuilder<bool>(
                  future: _isAdmin(), // Check if user is admin
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(); // Show loading indicator
                    }
                    if (snapshot.hasError) {
                      return const Icon(Icons.error); // Show error icon
                    }
                    if (snapshot.data == true) {
                      return InkWell(
                        onTap: () {
                          setState(() => _showAdmin = !_showAdmin); // Toggle admin screens
                        },
                        child: const Tooltip(
                          message: 'Admin Screens',
                          child: CircleAvatar(child: Icon(Icons.admin_panel_settings)),
                        ),
                      );
                    }
                    return const SizedBox(); // Hide admin icon if not admin
                  },
                ),
                // Logout icon
                InkWell(
                  onTap: () {
                    // Show confirmation dialog for logout
                    AwesomeDialog(
                      context: context,
                      headerAnimationLoop: false,
                      dialogType: DialogType.warning,
                      title: 'Logout',
                      desc: 'Are you sure you want to logout?',
                      btnCancelText: 'NO',
                      btnCancelOnPress: () {},
                      btnOkText: 'YES',
                      btnOkOnPress: () {
                        FirebaseAuth.instance.signOut(); // Sign out user
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.route,
                          (route) => false, // Navigate to login screen
                        );
                      },
                    ).show();
                  },
                  child: const Tooltip(
                    message: 'Logout',
                    child: CircleAvatar(child: Icon(Icons.lock_open)),
                  ),
                ),
              ],
              // User's profile picture
              currentAccountPicture: Hero(
                tag: 'profilePicHero',
                child: Container(
                  decoration: const BoxDecoration(
                    color: MainColors.accent,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: user?.photoURL != null
                      ? CachedNetworkImage(
                          imageUrl: user?.photoURL ?? '', // User's profile photo
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                            ),
                          ),
                        )
                      : SvgPicture.asset(IconAssets.donor), // Default icon if no photo
                ),
              ),
              margin: EdgeInsets.zero,
            ),
            // List of drawer items
            Expanded(
              child: Column(
                children: _screens, // Drawer tiles
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Check if the user is an admin using Firestore
  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        debugPrint('User document data: $data'); // Debug log for user data
        bool isAdmin = data?['admin'] == true;
        debugPrint('Is user admin? $isAdmin');  // Debug log for admin status
        return isAdmin;
      } else {
        debugPrint('User document does not exist');
      }
    } else {
      debugPrint('No user is currently signed in');
    }
    return false;
  }

  // List of drawer tiles
  List<Widget> get _screens => [
        const _DrawerTile(
          title: 'Profile',
          icon: Icons.person,
          destination: ProfileScreen.route,
        ),
        const _DrawerTile(
          title: 'Request Blood',
          icon: Icons.bloodtype,
          destination: AddBloodRequestScreen.route,
        ),
        if (_showAdmin) // Show admin screens if toggled
          const _DrawerTile(
            title: 'Add News',
            icon: Icons.add,
            destination: AddNewsItem.route,
          ),
        const _DrawerTile(
          title: 'News and Tips',
          icon: Icons.notifications,
          destination: NewsScreen.route,
        ),
        const _DrawerTile(
          title: 'Can I donate blood?',
          icon: Icons.help,
          destination: WhoCanDonateScreen.route,
        ),
      ];
}

// Custom drawer tile widget
class _DrawerTile extends StatelessWidget {
  final String title; // Tile title
  final String destination; // Destination screen route
  final IconData icon; // Tile icon

  const _DrawerTile({
    required this.title,
    required this.icon,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title), // Tile title
      leading: Icon(icon), // Tile icon
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.of(context).pushNamed(destination); // Navigate to the destination screen
      },
    );
  }
}