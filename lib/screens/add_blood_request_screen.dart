import '../../data/medical_center.dart'; // Import MedicalCenter class
import '../../utils/blood_types.dart'; // Import BloodType utilities
import '../../utils/tools.dart'; // Import utility functions (e.g., date formatting)
import '../../utils/validators.dart'; // Import validation functions
import '../../widgets/action_button.dart'; // Custom button widget
import '../../widgets/medical_center_picker.dart'; // Medical center picker widget
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth package
import 'package:flutter/material.dart'; // Flutter material design package
import 'package:fluttertoast/fluttertoast.dart'; // Toast notifications

class AddBloodRequestScreen extends StatefulWidget {
  static const route = 'add-request'; // Route name for navigation
  const AddBloodRequestScreen({super.key});

  @override
  _AddBloodRequestScreenState createState() => _AddBloodRequestScreenState();
}

class _AddBloodRequestScreenState extends State<AddBloodRequestScreen> {
  final _formKey = GlobalKey<FormState>(); // Form key for validation
  final _patientNameController = TextEditingController(); // Controller for patient name
  final _contactNumberController = TextEditingController(); // Controller for contact number
  final _noteController = TextEditingController(); // Controller for notes
  String _bloodType = 'A+'; // Selected blood type (default: A+)
  MedicalCenter? _medicalCenter; // Selected medical center
  DateTime _requestDate = DateTime.now(); // Selected request date (default: today)
  bool _isLoading = false; // Loading state for submission

  @override
  void dispose() {
    // Dispose controllers to free up resources
    _patientNameController.dispose();
    _contactNumberController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Blood Request')), // App bar with title
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24), // Padding for the form
          child: Form(
            key: _formKey, // Form key for validation
            child: Column(
              children: [
                _patientNameField(), // Patient name input field
                const SizedBox(height: 16), // Spacer
                _contactNumberField(), // Contact number input field
                const SizedBox(height: 16), // Spacer
                _bloodTypeSelector(), // Blood type dropdown
                const SizedBox(height: 16), // Spacer
                _medicalCenterSelector(), // Medical center picker
                const SizedBox(height: 16), // Spacer
                _requestDatePicker(), // Request date picker
                const SizedBox(height: 16), // Spacer
                _noteField(), // Notes input field
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: ActionButton(
                    key: const Key('submit_button'),
                    callback: _submit, // Submit callback
                    text: 'Submit',
                    isLoading: _isLoading, // Loading state
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Submit the blood request to Firestore
  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) { // Validate form
      setState(() => _isLoading = true); // Show loading indicator
      try {
        final user = FirebaseAuth.instance.currentUser; // Get current user
        final requests = FirebaseFirestore.instance.collection('blood_requests'); // Firestore collection

        // Add request data to Firestore
        await requests.add({
          'uid': user?.uid ?? '', // User ID
          'submittedBy': user?.displayName, // User's display name
          'patientName': _patientNameController.text, // Patient name
          'bloodType': _bloodType, // Selected blood type
          'contactNumber': _contactNumberController.text, // Contact number
          'note': _noteController.text, // Notes
          'submittedAt': DateTime.now(), // Submission timestamp
          'requestDate': _requestDate, // Request date
          'isFulfilled': false, // Request status
          'medicalCenter': _medicalCenter?.toJson(), // Medical center details
        });

        _resetFields(); // Reset form fields
        Fluttertoast.showToast(msg: 'Request successfully submitted'); // Success toast
        Navigator.pop(context); // Navigate back
      } catch (e) {
        Fluttertoast.showToast(msg: 'Something went wrong. Please try again'); // Error toast
      } finally {
        setState(() => _isLoading = false); // Hide loading indicator
      }
    }
  }

  // Patient name input field
  Widget _patientNameField() => TextFormField(
        controller: _patientNameController,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        validator: (v) => Validators.required(v ?? '', 'Patient name'), // Validation
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Patient Name',
        ),
      );

  // Contact number input field
  Widget _contactNumberField() => TextFormField(
        controller: _contactNumberController,
        keyboardType: TextInputType.phone,
        validator: (v) => Validators.required(v ?? '', 'Contact number') ?? Validators.phone(v ?? ''), // Validation
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Contact number',
          prefixText: '+251 ', // Prefix for phone number
        ),
      );

  // Notes input field
  Widget _noteField() => TextFormField(
        controller: _noteController,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Notes (Optional)',
          alignLabelWithHint: true,
        ),
      );

  // Blood type dropdown selector
  Widget _bloodTypeSelector() => DropdownButtonFormField<String>(
        value: _bloodType,
        onChanged: (v) => setState(() => _bloodType = v!), // Update selected blood type
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Blood Type',
        ),
        items: BloodTypeUtils.bloodTypes
            .map((v) => DropdownMenuItem(value: v, child: Text(v))) // Blood type options
            .toList(),
      );

  // Medical center picker
  Widget _medicalCenterSelector() => GestureDetector(
        onTap: () async {
          final picked = await showModalBottomSheet<MedicalCenter>(
            context: context,
            builder: (_) => const MedicalCenterPicker(), // Show medical center picker
            isScrollControlled: true,
          );
          if (picked != null) {
            setState(() => _medicalCenter = picked); // Update selected medical center
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            key: ValueKey<String>(_medicalCenter?.name ?? 'none'),
            initialValue: _medicalCenter?.name,
            validator: (_) => _medicalCenter == null ? '* Please select a medical center' : null, // Validation
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Medical Center',
            ),
          ),
        ),
      );

  // Request date picker
  Widget _requestDatePicker() => GestureDetector(
        onTap: () async {
          final today = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: today,
            firstDate: today,
            lastDate: today.add(const Duration(days: 365)), // Allow dates up to 1 year from today
          );
          if (picked != null) {
            setState(() => _requestDate = picked); // Update selected date
          }
        },
        child: AbsorbPointer(
          child: TextFormField(
            key: ValueKey<DateTime>(_requestDate),
            initialValue: Tools.formatDate(_requestDate), // Format date for display
            validator: (_) => null, // Validation
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Request date',
              helperText: 'The date on which you need the blood to be ready',
            ),
          ),
        ),
      );

  // Reset form fields
  void _resetFields() {
    _patientNameController.clear();
    _contactNumberController.clear();
    _noteController.clear();
    setState(() {
      _requestDate = DateTime.now(); // Reset to today
      _medicalCenter = null; // Clear medical center
    });
  }
}