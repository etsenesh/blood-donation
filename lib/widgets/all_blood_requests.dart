import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:flutter/material.dart'; // Flutter material design
import 'package:flutter_svg/flutter_svg.dart'; // SVG support

import '../common/assets.dart'; // Custom assets (e.g., SVG icons)
import '../common/styles.dart'; // Custom styles (e.g., fonts)
import '../data/blood_request.dart'; // BloodRequest model
import 'blood_request_tile.dart'; // Custom widget for displaying blood requests

class AllBloodRequests extends StatefulWidget {
  const AllBloodRequests({super.key});

  @override
  _AllBloodRequestsState createState() => _AllBloodRequestsState();
}

class _AllBloodRequestsState extends State<AllBloodRequests> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _query; // Firestore query stream

  @override
  void initState() {
    super.initState();
    // Initialize Firestore query
    _query = FirebaseFirestore.instance
        .collection('blood_requests') // Firestore collection
        .where('isFulfilled', isEqualTo: false) // Filter unfulfilled requests
        .orderBy('requestDate') // Order by request date
        .limit(30) // Limit to 30 requests
        .snapshots(); // Stream for real-time updates
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _query, // Firestore query stream
      builder: (context, snapshot) {
        // Handle errors
        if (snapshot.hasError) {
          final error = snapshot.error;
          debugPrint('Error fetching blood requests: $error');
          debugPrint('Stack trace: ${snapshot.stackTrace}');
          
          String errorMessage = 'Could not fetch blood requests';
          if (error is FirebaseException) {
            switch (error.code) {
              case 'permission-denied':
                errorMessage = 'Permission denied. Please check your Firestore rules.';
                break;
              // Handle other error codes as needed
              default:
                errorMessage = 'An error occurred: ${error.message}';
                break;
            }
          }

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          );
        }

        // Handle active connection state
        if (snapshot.connectionState == ConnectionState.active) {
          // If no requests are found
          if (snapshot.data!.docs.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(IconAssets.bloodBag, height: 140), // Blood bag icon
                    const SizedBox(height: 16), // Spacer
                    const Text(
                      'No requests yet!',
                      style: TextStyle(fontFamily: Fonts.logo, fontSize: 20), // Custom font
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Display list of blood requests
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  // Convert Firestore document to BloodRequest object
                  final request = BloodRequest.fromJson(
                    snapshot.data!.docs[i].data(),
                    id: snapshot.data!.docs[i].id,
                  );
                  return BloodRequestTile(request: request); // Display request in a tile
                },
                childCount: snapshot.data!.size, // Number of requests
              ),
            );
          }
        }

        // Show loading indicator while waiting for data
        return const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}