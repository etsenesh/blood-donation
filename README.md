Blood Donation App

This Flutter-based mobile app connects blood donors and recipients. It allows users to add, view, and manage blood requests, with Firebase integration for secure and real-time data handling.

Features

Firebase Integration:

  Firebase Authentication for user login.
  Firestore for storing blood requests.
  Firebase Storage for profile picture uploads.
  Blood Request Management:
  Add and view detailed blood requests.
  User-Friendly Interface:
  Clean and responsive UI with intuitive navigation.
lib/
├── common/          # Styles and constants
├── data/            # Models (e.g., BloodRequest)
├── screens/         # App screens
├── widgets/         # Custom widgets (e.g., BloodRequestTile)
└── main.dart        # Entry point
Example Firestore Document
json
{
  "patientName": "John Doe",
  "bloodType": "A+",
  "medicalCenter": {
    "name": "City Hospital",
    "location": "New York"
  },
  "requestDate": "2025-01-22"
}
Acknowledgments
Built with Flutter and Firebase to simplify blood donation management.








