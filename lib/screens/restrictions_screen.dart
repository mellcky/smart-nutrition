import 'package:diet_app/screens/healthconditions_screen.dart';

import '/widgets/back_button_wrapper.dart';
import '/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class DietaryRestrictionsScreen extends StatefulWidget {
  const DietaryRestrictionsScreen({super.key});

  @override
  State<DietaryRestrictionsScreen> createState() =>
      _DietaryRestrictionsScreenState();
}

class _DietaryRestrictionsScreenState extends State<DietaryRestrictionsScreen> {
  final List<Map<String, String>> _options = [
    {"emoji": "🚫", "label": "None"},
    {"emoji": "🥜", "label": "Nuts"},
    {"emoji": "🥚", "label": "Eggs"},
    {"emoji": "🦐", "label": "Seafood"},
    {"emoji": "🥗", "label": "Vegetarian"},
    {"emoji": "🥛", "label": "Diary"},
    {"emoji": "🌱", "label": "Beans and Legumes"},
    {"emoji": "🍞", "label": "Gluten"},
    {"emoji": "🌿", "label": "Vegan"},
    {"emoji": "🥩", "label": "Red meat"},
  ];

  final Set<String> _selectedOptions = {};
  final TextEditingController _otherAllergiesController =
      TextEditingController();

  void _toggleSelection(String option) {
    setState(() {
      if (option == "None") {
        _selectedOptions.clear();
        _selectedOptions.add("None");
      } else {
        _selectedOptions.remove("None");
        if (_selectedOptions.contains(option)) {
          _selectedOptions.remove(option);
        } else {
          _selectedOptions.add(option);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopProgressBar(),
            BackIconWrapper(),
            SizedBox(
              width: double.infinity,
              height: 95,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -50,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/app_logo.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: 60,
                    child: const Text(
                      "Do you have any diet restrictions and allergies?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._options.map(
                    (option) => CheckboxListTile(
                      dense: true, // Reduce spacing
                      visualDensity:
                          VisualDensity.compact, // Even tighter spacing
                      title: Text("${option['emoji']} ${option['label']}"),
                      value: _selectedOptions.contains(option['label']),
                      onChanged: (_) => _toggleSelection(option['label']!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "🧾 Other Allergies",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otherAllergiesController,
                    decoration: InputDecoration(
                      hintText: "Enter any other allergies here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Save or pass selected data
                    // Prepare combined restrictions list
                    List<String> restrictions = _selectedOptions.toList();
                    String other = _otherAllergiesController.text.trim();
                    if (other.isNotEmpty) {
                      restrictions.add(other);
                    }

                    // Save to provider
                    final profileProvider = Provider.of<UserProfileProvider>(
                      context,
                      listen: false,
                    );
                    profileProvider.updateDietRestrictions(restrictions);
                    // move to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthConditionsScreen(),
                      ),
                    );
                    print("Selected: $_selectedOptions");
                    print("Other: ${_otherAllergiesController.text}");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
