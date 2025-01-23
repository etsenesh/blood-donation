import 'package:flutter/material.dart'; // Flutter material design

import '../common/colors.dart'; // Custom colors
import '../data/blood_request.dart'; // BloodRequest model
import '../screens/single_request_screen.dart'; // Screen for detailed request view
import '../utils/tools.dart'; // Utility functions (e.g., date formatting)

const kBorderRadius = 12.0; // Border radius for the card

class BloodRequestTile extends StatelessWidget {
  final BloodRequest request; // Blood request data

  const BloodRequestTile({Key? key, required this.request}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Text theme for consistent styling

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Card margin
      elevation: 2, // Card elevation for shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kBorderRadius), // Rounded corners
      ),
      child: Column(
        children: [
          // Main content of the card
          Padding(
            padding: const EdgeInsets.all(16), // Padding for the content
            child: Row(
              children: [
                // Left column: Patient name and location
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Patient Name', style: textTheme.bodySmall), // Label
                      Text(request.patientName), // Patient name
                      const SizedBox(height: 12), // Spacer
                      Text('Location', style: textTheme.bodySmall), // Label
                      Text(
                        '${request.medicalCenter.name} - ${request.medicalCenter.location}', // Location
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12), // Spacer between columns
                // Right column: Needed by date and blood type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Needed By', style: textTheme.bodySmall), // Label
                    Text(Tools.formatDate(request.requestDate)), // Formatted date
                    const SizedBox(height: 12), // Spacer
                    Text('Blood Type', style: textTheme.bodySmall), // Label
                    Text(request.bloodType.name), // Blood type
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8), // Spacer

          // Details button at the bottom of the card
          InkWell(
            onTap: () {
              // Navigate to the detailed request screen
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SingleRequestScreen(request: request),
              ));
            },
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(kBorderRadius),
              bottomLeft: Radius.circular(kBorderRadius),
            ),
            child: Ink(
              padding: const EdgeInsets.all(12), // Button padding
              width: double.infinity, // Full-width button
              decoration: const BoxDecoration(
                color: MainColors.primary, // Button background color
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(kBorderRadius),
                  bottomLeft: Radius.circular(kBorderRadius),
                ),
              ),
              child: Center(
                child: Text(
                  'Details', // Button text
                  style: textTheme.labelLarge?.copyWith(color: Colors.white), // Button text style
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}