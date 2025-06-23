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
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, left: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
              ),
            ),
            // Logo at the top
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: Center(
                  child: Text(
                    'Diet App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ),
            ),

            // Back arrow below the logo
            const SizedBox(height: 8),

            const Text(
              "Do you have any dietary restrictions?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Checkbox list + text input
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._options.map(
                    (option) => CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
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

            // Continue button
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    List<String> restrictions = _selectedOptions.toList();
                    String other = _otherAllergiesController.text.trim();
                    if (other.isNotEmpty) {
                      restrictions.add(other);
                    }

                    Provider.of<UserProfileProvider>(
                      context,
                      listen: false,
                    ).updateDietRestrictions(restrictions);

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
