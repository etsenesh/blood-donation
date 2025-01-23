import 'package:flutter/material.dart'; // Flutter material design

import '../common/colors.dart'; // Custom colors

class ActionButton extends StatelessWidget {
  final VoidCallback? callback; // Callback function for button press
  final String text; // Button text
  final Color backgroundColor; // Background color of the button
  final bool isLoading; // Loading state for the button
  final double radius; // Border radius of the button

  const ActionButton({
    required Key key,
    required this.text,
    this.callback,
    this.backgroundColor = MainColors.primary, // Default background color
    this.isLoading = false, // Default loading state
    this.radius = 5.0, // Default border radius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Full-width button
      height: 50, // Fixed height for the button
      child: isLoading
          ? const Center(
              // Show loading indicator if isLoading is true
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MainColors.primary),
              ),
            )
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor, // Button background color
                foregroundColor: Colors.white, // Button text color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(radius), // Button border radius
                ),
              ),
              onPressed: callback, // Callback function for button press
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18, // Button text size
                  fontWeight: FontWeight.w500, // Medium weight for better appearance
                ),
              ),
            ),
    );
  }
}
