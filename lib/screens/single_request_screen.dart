import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase authentication
import 'package:flutter/material.dart'; // Flutter material design
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications
import 'package:share_plus/share_plus.dart'; // Share functionality
import 'package:url_launcher/url_launcher.dart'; // URL launcher for maps and calls

import '../../common/colors.dart'; // Custom colors
import '../../data/blood_request.dart'; // BloodRequest model
import '../../utils/blood_types.dart'; // Blood type utilities
import '../../utils/tools.dart'; // Utility functions (e.g., date formatting)

class SingleRequestScreen extends StatelessWidget {
  final BloodRequest request; // Blood request details
  const SingleRequestScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = textTheme.bodySmall?.copyWith(fontSize: 14); // Title text style
    final bodyStyle = textTheme.bodyLarge?.copyWith(fontSize: 16); // Body text style
    const bodyWrap = EdgeInsets.only(top: 4, bottom: 16); // Padding for body text

    return Scaffold(
      appBar: AppBar(title: const Text('Blood Request Details')), // App bar with title
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24), // Padding for the screen
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Submitted By
              Text('Submitted By', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                  '${request.submittedBy} on ${Tools.formatDate(request.submittedAt)}',
                  style: bodyStyle,
                ),
              ),

              // Patient Name
              Text('Patient Name', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(request.patientName, style: bodyStyle),
              ),

              // Location
              Text('Location', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                  '${request.medicalCenter.name} - ${request.medicalCenter.location}',
                  style: bodyStyle,
                ),
              ),

              // Blood Type
              Text('Blood Type', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(request.bloodType.name, style: bodyStyle),
              ),

              // Possible Donors
              Text('Possible Donors', style: titleStyle),
              Padding(
                padding: bodyWrap,
                child: Text(
                  request.bloodType.possibleDonors
                      .map((e) => e.name)
                      .join('   /   '),
                  style: bodyStyle,
                ),
              ),

              // Notes (if available)
              if (!Tools.isNullOrEmpty(request.note)) ...[
                Text('Notes', style: titleStyle),
                Padding(
                  padding: bodyWrap,
                  child: Text(request.note, style: bodyStyle),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(thickness: 1), // Divider

              // Buttons for Directions and Share
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Get Directions Button
                    Expanded(
                      child: TextButton.icon(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            MainColors.primaryDark,
                          ),
                        ),
                        onPressed: () async {
                          final url =
                              'https://www.google.com/maps/search/?api=1&query='
                              '${request.medicalCenter.latitude},'
                              '${request.medicalCenter.longitude}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url)); // Open Google Maps
                          } else {
                            Fluttertoast.showToast(msg: 'Could not launch map');
                          }
                        },
                        icon: const Icon(Icons.navigation),
                        label: const Text('Get Directions'),
                      ),
                    ),
                    const VerticalDivider(thickness: 1), // Vertical divider
                    // Share Button
                    Expanded(
                      child: TextButton.icon(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(
                            MainColors.primaryDark,
                          ),
                        ),
                        onPressed: () {
                          // Share request details using share_plus
                          Share.share(
                            '${request.patientName} needs ${request.bloodType.name} '
                            'blood by ${Tools.formatDate(request.requestDate)}.\n'
                            'You can donate by visiting ${request.medicalCenter.name} located in '
                            '${request.medicalCenter.location}.\n\n'
                            'Contact +251${request.contactNumber} for more info.',
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 1), // Divider
              const SizedBox(height: 12),

              // Contact Button
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      MainColors.primary,
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.all(12),
                    ),
                    shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    )),
                  ),
                  onPressed: () async {
                    final contact = 'tel:+251${request.contactNumber}';
                    if (await canLaunchUrl(Uri.parse(contact))) {
                      await launchUrl(Uri.parse(contact)); // Open phone dialer
                    } else {
                      Fluttertoast.showToast(msg: 'Something went wrong');
                    }
                  },
                  child: Center(
                    child: Text(
                      'Contact',
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Mark as Fulfilled Button (only visible to the requester)
              if (!request.isFulfilled &&
                  request.uid == FirebaseAuth.instance.currentUser?.uid)
                _MarkFulfilledBtn(request: request),
            ],
          ),
        ),
      ),
    );
  }
}

// Mark as Fulfilled Button (Stateful Widget)
class _MarkFulfilledBtn extends StatefulWidget {
  final BloodRequest request;

  const _MarkFulfilledBtn({required this.request});

  @override
  _MarkFulfilledBtnState createState() => _MarkFulfilledBtnState();
}

class _MarkFulfilledBtnState extends State<_MarkFulfilledBtn> {
  bool _isLoading = false; // Loading state for the button

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  Colors.green[600],
                ),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.all(12),
                ),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                )),
              ),
              onPressed: () async {
                setState(() => _isLoading = true); // Show loading indicator
                try {
                  // Update the request status in Firestore
                  await FirebaseFirestore.instance
                      .collection('blood_requests')
                      .doc(widget.request.id)
                      .update({'isFulfilled': true});
                  widget.request.isFulfilled = true; // Update local state
                  Navigator.pop(context); // Navigate back
                } on FirebaseException catch (e) {
                  Fluttertoast.showToast(msg: e.message ?? 'An error occurred');
                } catch (e) {
                  Fluttertoast.showToast(
                    msg: 'Something went wrong. Please try again',
                  );
                }
                setState(() => _isLoading = false); // Hide loading indicator
              },
              child: Center(
                child: Text(
                  'Mark as Fulfilled',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ),
          );
  }
}