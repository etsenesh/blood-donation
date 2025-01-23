import 'package:flutter/foundation.dart';

@immutable
class MedicalCenter {
  final String name;
  final List<String> phoneNumbers;
  final String location;
  final String latitude;
  final String longitude;

  const MedicalCenter({
    required this.name,
    required this.phoneNumbers,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  /// Deserialize JSON into a `MedicalCenter` object
  factory MedicalCenter.fromJson(Map<String, dynamic> json) {
    return MedicalCenter(
      name: json['name'] as String,
      phoneNumbers: List<String>.from(json['phoneNumbers'] ?? []), // Safe deserialization
      location: json['location'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
    );
  }

  /// Serialize a `MedicalCenter` object into JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumbers': phoneNumbers,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

