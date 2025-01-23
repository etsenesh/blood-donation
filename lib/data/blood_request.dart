import 'medical_center.dart'; // Import MedicalCenter class
import '../utils/blood_types.dart'; // Import BloodType utilities
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for Timestamp

class BloodRequest {
  // Properties of the BloodRequest class
  final String id; // Unique ID of the blood request
  final String uid; // User ID of the requester
  final String submittedBy; // Name of the person who submitted the request
  final String patientName; // Name of the patient needing blood
  final String contactNumber; // Contact number for the request
  final String note; // Additional notes for the request
  final BloodType bloodType; // Blood type required (using your enum)
  final DateTime submittedAt; // Timestamp when the request was submitted
  final DateTime requestDate; // Date when the blood is needed
  final MedicalCenter medicalCenter; // Medical center details
  bool isFulfilled; // Status of the request (fulfilled or not)

  // Constructor for BloodRequest
  BloodRequest({
    required this.id,
    required this.uid,
    required this.submittedBy,
    required this.patientName,
    required this.contactNumber,
    required this.bloodType,
    required this.medicalCenter,
    required this.submittedAt,
    required this.requestDate,
    required this.note,
    this.isFulfilled = false, // Default value for isFulfilled is false
  });

  // Factory constructor to create a BloodRequest object from Firestore JSON data
  factory BloodRequest.fromJson(Map<String, dynamic> json, {required String id}) {
    return BloodRequest(
      id: id,
      uid: json['uid'] as String,
      submittedBy: json['submittedBy'] as String,
      patientName: json['patientName'] as String,
      contactNumber: json['contactNumber'] as String,
      bloodType: BloodTypeUtils.fromName(json['bloodType'] as String), // Use your helper to convert string to BloodType enum
      medicalCenter: MedicalCenter.fromJson(
        json['medicalCenter'] as Map<String, dynamic>,
      ),
      submittedAt: (json['submittedAt'] as Timestamp).toDate(),
      requestDate: (json['requestDate'] as Timestamp).toDate(),
      note: json['note'] as String,
      isFulfilled: json['isFulfilled'] as bool,
    );
  }
}
