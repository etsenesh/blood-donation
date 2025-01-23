import '../../utils/validators.dart'; // Import validation utilities
import '../../widgets/action_button.dart'; // Custom button widget
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:flutter/material.dart'; // Flutter material design package
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications

class AddNewsItem extends StatefulWidget {
  static const route = 'add-news'; // Route name for navigation
  const AddNewsItem({super.key});

  @override
  _AddNewsItemState createState() => _AddNewsItemState();
}

class _AddNewsItemState extends State<AddNewsItem> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _titleController = TextEditingController(); // Controller for news title
  final _bodyController = TextEditingController(); // Controller for news body
  bool _isLoading = false; // Loading state for submission

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add News Item')), // App bar with title
      body: SafeArea(
        child: Form(
          key: _formKey, // Form key for validation
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24), // Padding for the form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title input field
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => Validators.required(v ?? '', 'Title'), // Validation
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Title',
                  ),
                ),
                const SizedBox(height: 24), // Spacer
                // Body input field
                TextFormField(
                  controller: _bodyController,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 3, // Minimum lines for the text field
                  maxLines: 5, // Maximum lines for the text field
                  validator: (v) => Validators.required(v ?? '', 'Body'), // Validation
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Body',
                  ),
                ),
                const SizedBox(height: 36), // Spacer
                // Submit button
                ActionButton(
                  key: const Key('submit_button'),
                  callback: _submit, // Submit callback
                  text: 'Submit',
                  isLoading: _isLoading, // Loading state
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit the news item to Firestore
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) { // Validate form
      setState(() => _isLoading = true); // Show loading indicator
      try {
        final news = FirebaseFirestore.instance.collection('news'); // Firestore collection

        // Add news item data to Firestore
        await news.add({
          'title': _titleController.text, // News title
          'body': _bodyController.text, // News body
          'date': DateTime.now(), // Submission timestamp
        });

        _titleController.clear(); // Clear title field
        _bodyController.clear(); // Clear body field
        Fluttertoast.showToast(msg: 'News item successfully added'); // Success toast
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Something went wrong. Please try again', // Error toast
        );
      } finally {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }
}