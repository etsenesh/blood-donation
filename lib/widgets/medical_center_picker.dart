import 'package:flutter/material.dart'; // Flutter material design

import '../data/lists/blood_banks.dart'; // List of blood banks
import '../data/lists/hospitals.dart'; // List of hospitals
import '../data/lists/lrc_centers.dart'; // List of Red Cross centers
import '../data/lists/medical_centers.dart'; // List of medical centers
import '../data/medical_center.dart'; // MedicalCenter model

class MedicalCenterPicker extends StatefulWidget {
  const MedicalCenterPicker({super.key});

  @override
  _MedicalCenterPickerState createState() => _MedicalCenterPickerState();
}

class _MedicalCenterPickerState extends State<MedicalCenterPicker> {
  final _searchController = TextEditingController(); // Controller for search field
  MedicalCenterCategory _category = MedicalCenterCategory.hospitals; // Selected category
  late List<MedicalCenter> _centers; // List of medical centers for the selected category

  @override
  void initState() {
    super.initState();
    _centers = hospitals; // Initialize with hospitals
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme; // Text theme for consistent styling

    // Filter medical centers based on search query
    final filtered = _centers
        .where(
          (c) =>
              c.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
              c.location.toLowerCase().contains(_searchController.text.toLowerCase()),
        )
        .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8, // Initial size of the sheet
      minChildSize: 0.4, // Minimum size of the sheet
      maxChildSize: 0.9, // Maximum size of the sheet
      builder: (BuildContext context, ScrollController scrollController) {
        return Column(
          children: [
            // Search bar and category dropdown
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Search field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search), // Search icon
                        hintText: 'Search', // Placeholder text
                        isDense: true, // Reduce vertical padding
                      ),
                      onChanged: (val) => setState(() {}), // Update UI on text change
                    ),
                  ),
                  const SizedBox(width: 12), // Spacer
                  // Category dropdown
                  DropdownButtonHideUnderline(
                    child: DropdownButton<MedicalCenterCategory>(
                      value: _category, // Selected category
                      items: MedicalCenterCategory.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c,
                              child: Text(c.name), // Display category name
                            ),
                          )
                          .toList(),
                      onChanged: (cat) {
                        if (cat == _category) return; // Skip if category hasn't changed

                        // Update the list of centers based on the selected category
                        switch (cat) {
                          case MedicalCenterCategory.hospitals:
                            _centers = hospitals;
                            break;
                          case MedicalCenterCategory.lrcCenters:
                            _centers = lrcCenters;
                            break;
                          case MedicalCenterCategory.bloodBanks:
                            _centers = bloodBanks;
                            break;
                          case MedicalCenterCategory.medicalCenters:
                            _centers = medicalCenters;
                            break;
                          case null:
                            // TODO: Handle this case.
                            throw UnimplementedError();
                        }
                        setState(() => _category = cat!); // Update UI
                      },
                    ),
                  ),
                ],
              ),
            ),
            // List of filtered medical centers
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filtered.length,
                itemBuilder: (context, i) => ListTile(
                  dense: true, // Reduce vertical padding
                  title: Text(
                    filtered[i].name, // Center name
                    style: textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    filtered[i].location, // Center location
                    style: textTheme.bodyMedium?.copyWith(
                      color: textTheme.bodySmall?.color,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, filtered[i]); // Return selected center
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Enum for medical center categories
enum MedicalCenterCategory {
  hospitals,
  lrcCenters,
  bloodBanks,
  medicalCenters,
}

// Extension to get the display name for each category
extension on MedicalCenterCategory {
  String get name {
    switch (this) {
      case MedicalCenterCategory.hospitals:
        return 'Hospitals';
      case MedicalCenterCategory.lrcCenters:
        return 'Red Cross';
      case MedicalCenterCategory.bloodBanks:
        return 'Blood Banks';
      case MedicalCenterCategory.medicalCenters:
        return 'Others';
    }
  }
}