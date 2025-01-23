import 'package:cached_network_image/cached_network_image.dart'; // For cached network images
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/flutter_svg.dart'; // SVG support
import 'package:shared_preferences/shared_preferences.dart'; // Local storage

import '../../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../../common/colors.dart'; // Custom colors
import '../../utils/blood_types.dart'; // Blood type utilities
import '../../widgets/submitted_blood_requests.dart'; // Widget for submitted blood requests
import 'edit_profile_screen.dart'; // Edit profile screen for navigation

class ProfileScreen extends StatelessWidget {
  static const route = 'profile'; // Route name for navigation
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // App bar title
        actions: [
          // Edit profile button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacementNamed(context, EditProfileScreen.route);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerImage(user?.photoURL ?? ''), // Profile header image
            _infoRow(context, user!), // User info row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 24, 12),
              child: Text(
                'Active Blood Requests:',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: MainColors.primary),
              ),
            ),
            const Expanded(child: SubmittedBloodRequests()), // List of active requests
          ],
        ),
      ),
    );
  }

  // User info row with blood type icons
  Widget _infoRow(BuildContext context, User user) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _bloodIcon(), // Blood type icon on the left
            Expanded(
              child: Column(
                children: [
                  Text(
                    user.displayName ?? 'No Name', // Display user's name
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email ?? 'No Email', textAlign: TextAlign.center), // Display user's email
                ],
              ),
            ),
            _bloodIcon(), // Blood type icon on the right
          ],
        ),
      );

  // Blood type icon widget
  Widget _bloodIcon() {
    return FutureBuilder<String>(
      future: _getBloodType(), // Fetch blood type from SharedPreferences
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator
        }
        final bloodType = snapshot.data ?? BloodType.aPos.name; // Default to A+
        return SvgPicture.asset(
          BloodTypeUtils.fromName(bloodType).icon, // Blood type icon
          height: 50,
        );
      },
    );
  }

  // Fetch blood type from SharedPreferences
  Future<String> _getBloodType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('bloodType') ?? BloodType.aPos.name; // Default to A+
  }

  // Profile header image with curved background
  Widget _headerImage(String url) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            height: curveHeight,
            child: CustomPaint(painter: _MyPainter()), // Custom curved background
          ),
          Hero(
            tag: 'profilePicHero', // Hero animation tag
            child: Container(
              width: avatarDiameter,
              height: avatarDiameter,
              decoration: const BoxDecoration(
                color: MainColors.accent,
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: url.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: url, // User's profile photo
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white70,
                        ),
                      ),
                    )
                  : SvgPicture.asset(IconAssets.donor), // Default icon if no photo
            ),
          ),
        ],
      );
}

// Constants for UI dimensions
const avatarRadius = 60.0;
const avatarDiameter = avatarRadius * 2;
const curveHeight = avatarRadius * 2.5;

/// Custom painter for the curved background
/// Source: https://gist.github.com/tarek360/c94a82f9554caf8f6b62c4fcf140272f
class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true
      ..color = MainColors.primary;

    const topLeft = Offset(0, 0);
    final bottomLeft = Offset(0, size.height * 0.25);
    final topRight = Offset(size.width, 0);
    final bottomRight = Offset(size.width, size.height * 0.25);

    final leftCurveControlPoint =
        Offset(size.width * 0.2, size.height - avatarRadius * 0.8);
    final rightCurveControlPoint = Offset(size.width - leftCurveControlPoint.dx,
        size.height - avatarRadius * 0.8,);

    final avatarLeftPoint =
        Offset(size.width * 0.5 - avatarRadius + 5, size.height * 0.5);
    final avatarRightPoint =
        Offset(size.width * 0.5 + avatarRadius - 5, avatarLeftPoint.dy);

    final avatarTopPoint =
        Offset(size.width / 2, size.height / 2 - avatarRadius);

    final path = Path()
      ..moveTo(topLeft.dx, topLeft.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..quadraticBezierTo(leftCurveControlPoint.dx, leftCurveControlPoint.dy,
          avatarLeftPoint.dx, avatarLeftPoint.dy,)
      ..arcToPoint(avatarTopPoint, radius: const Radius.circular(avatarRadius))
      ..lineTo(size.width / 2, 0)
      ..close();

    final path2 = Path()
      ..moveTo(topRight.dx, topRight.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..quadraticBezierTo(rightCurveControlPoint.dx, rightCurveControlPoint.dy,
          avatarRightPoint.dx, avatarRightPoint.dy,)
      ..arcToPoint(avatarTopPoint,
          radius: const Radius.circular(avatarRadius), clockwise: false,)
      ..lineTo(size.width / 2, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}