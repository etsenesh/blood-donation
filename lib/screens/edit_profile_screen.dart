import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/colors.dart';
import '../../utils/blood_types.dart';
import '../../widgets/action_button.dart';

class EditProfileScreen extends StatefulWidget {
  static const route = 'edit-profile';
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

const kProfileDiameter = 120.0;

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _nameController = TextEditingController(); // Controller for name field
  final _emailController = TextEditingController(); // Controller for email field
  late String _bloodType; // Selected blood type
  late User _oldUser; // Current user
  bool _isLoading = false; // Loading state for submission

  File? _image; // Selected profile image
  final picker = ImagePicker(); // Image picker instance

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  // Load user data from Firebase and SharedPreferences
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    _nameController.text = user?.displayName ?? ''; // Set name from Firebase
    _emailController.text = user?.email ?? ''; // Set email from Firebase
    _oldUser = user!; // Store the current user

    // Load blood type from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _bloodType = prefs.getString('bloodType') ?? BloodType.aPos.name; // Default to A+
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')), // App bar with title
      body: SafeArea(
        child: Form(
          key: _formKey, // Form key for validation
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24), // Padding for the form
            child: Column(
              children: [
                const SizedBox(height: 12),
                _imageRow(), // Profile image row
                const SizedBox(height: 36),
                _nameField(), // Name input field
                const SizedBox(height: 18),
                _emailField(), // Email input field
                const SizedBox(height: 18),
                _bloodTypeSelector(), // Blood type dropdown
                const SizedBox(height: 36),
                ActionButton(
                  key: const Key('save_button'),
                  text: 'Save',
                  callback: _save, // Save callback
                  isLoading: _isLoading, // Loading state
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Profile image row with upload functionality
  Widget _imageRow() => InkWell(
        onTap: _getImage, // Open image picker on tap
        borderRadius: BorderRadius.circular(90),
        child: Container(
          width: kProfileDiameter,
          height: kProfileDiameter,
          decoration: const BoxDecoration(
            color: MainColors.accent,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (_image != null)
                Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  height: kProfileDiameter,
                  width: kProfileDiameter,
                ),
              Container(
                height: 30,
                width: kProfileDiameter,
                color: MainColors.primary,
                child: const Icon(Icons.upload, color: Colors.white, size: 16),
              ),
            ],
          ),
        ),
      );

  // Name input field
  Widget _nameField() => TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Name',
          prefixIcon: Icon(Icons.person),
        ),
      );

  // Email input field
  Widget _emailField() => TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
          prefixIcon: Icon(Icons.email),
        ),
      );

  // Blood type dropdown selector
  Widget _bloodTypeSelector() => DropdownButtonFormField<String>(
        value: _bloodType,
        onChanged: (v) => setState(() => _bloodType = v!), // Update selected blood type
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Blood Type',
          prefixIcon: Icon(Icons.bloodtype),
        ),
        items: BloodTypeUtils.bloodTypes
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Text(v),
                ))
            .toList(),
      );

  // Open image picker to select a profile image
  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path)); // Update selected image
    }
  }

  // Save profile changes
  Future<void> _save() async {
    if (_formKey.currentState?.validate() ?? false) { // Validate form
      setState(() => _isLoading = true); // Show loading indicator
      try {
        final user = FirebaseAuth.instance.currentUser;
        String? newProfileUrl;

        // Upload new profile image if selected
        if (_image != null) {
          Fluttertoast.showToast(msg: 'Uploading Image...');
          final snapshot = await FirebaseStorage.instance
              .ref()
              .child('avatars/${user?.uid}')
              .putFile(_image!);
          newProfileUrl = await snapshot.ref.getDownloadURL(); // Get image URL
        }

        // Update display name and photo URL if changed
        if (_nameController.text != _oldUser.displayName || newProfileUrl != null) {
          await user?.updateDisplayName(_nameController.text);
          if (newProfileUrl != null) {
            await user?.updatePhotoURL(newProfileUrl);
          }
        }

        // Update email if changed
        if (_emailController.text != _oldUser.email) {
          await user?.verifyBeforeUpdateEmail(_emailController.text);
        }

        // Update blood type in Firestore and SharedPreferences if changed
        final prefs = await SharedPreferences.getInstance();
        final initialBloodType = prefs.getString('bloodType') ?? BloodType.aPos.name;
        if (_bloodType != initialBloodType) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .update({'bloodType': _bloodType});
          await prefs.setString('bloodType', _bloodType); // Save blood type locally
        }

        Fluttertoast.showToast(msg: 'Profile updated successfully'); // Success toast
        Navigator.pop(context); // Navigate back
      } on FirebaseException catch (e) {
        Fluttertoast.showToast(msg: e.message ?? 'An error occurred'); // Firebase error
      } catch (e) {
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again'); // Generic error
      } finally {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }
}