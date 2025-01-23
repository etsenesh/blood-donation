import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:flutter/material.dart'; // Flutter material design

import '../../common/colors.dart'; // Custom colors
import '../../utils/tools.dart'; // Utility functions (e.g., date formatting)
import '../../widgets/news_tile.dart'; // Custom widget for displaying news items

class NewsScreen extends StatelessWidget {
  static const route = 'news'; // Route name for navigation
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference to the 'news' collection in Firestore
    final news = FirebaseFirestore.instance.collection('news');

    return Scaffold(
      appBar: AppBar(title: const Text('News and Tips')), // App bar with title
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          // Stream to listen for real-time updates from Firestore
          stream: news
              .orderBy('date', descending: true) // Order by date (newest first)
              .limit(20) // Limit to 20 items
              .snapshots(),
          builder: (context, snapshot) {
            // Handle errors
            if (snapshot.hasError) {
              final error = snapshot.error;
              debugPrint('Error fetching news: $error');
              debugPrint('Stack trace: ${snapshot.stackTrace}');
              
              String errorMessage = 'Something went wrong';
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

              return Center(child: Text(errorMessage));
            }

            // Show loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MainColors.primary),
                ),
              );
            }

            // If data is available, display it in a list
            return ListView(
              children: snapshot.data?.docs.map((doc) {
                return NewsTile(
                  key: Key(doc.id), // Unique key for each news item
                  title: doc.data()['title'] as String, // News title
                  body: doc.data()['body'] as String, // News body
                  date: Tools.formatDate(
                    (doc.data()['date'] as Timestamp).toDate(), // Format date
                  ),
                );
              }).toList() ?? [], // Handle empty list case
            );
          },
        ),
      ),
    );
  }
}