import 'package:diet_app/screens/dietarygoals_screen.dart';
import 'package:flutter/material.dart';
import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

class HealthConditionsScreen extends StatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  _HealthConditionsScreenState createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  final List<String> _selectedConditions = [];
  final TextEditingController _otherConditionsController =
      TextEditingController();

  final List<Map<String, String>> _conditions = [
    {'emoji': '✅', 'label': 'No health conditions'},
    {'emoji': '🩸', 'label': 'Diabetes'},
    {'emoji': '💓', 'label': 'Hypertension'},
    {'emoji': '🧈', 'label': 'High cholesterol'},
    {'emoji': '🫁', 'label': 'Asthma'},
    {'emoji': '🦴', 'label': 'Arthritis'},
  ];

  void _toggleSelection(String label) {
    setState(() {
      if (_selectedConditions.contains(label)) {
        _selectedConditions.remove(label);
      } else {
        _selectedConditions.add(label);
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
                padding: const EdgeInsets.only(top: 10, left: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back, size: 28),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
            const Text(
              "Do you have any health conditions?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._conditions.map(
                    (condition) => CheckboxListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(
                        "${condition['emoji']} ${condition['label']}",
                      ),
                      value: _selectedConditions.contains(condition['label']),
                      onChanged: (_) => _toggleSelection(condition['label']!),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "🧾 Other Conditions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otherConditionsController,
                    decoration: InputDecoration(
                      hintText: "Enter any other health conditions",
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
                    final userProfile = Provider.of<UserProfileProvider>(
                      context,
                      listen: false,
                    );
                    userProfile.updateHealthConditions(_selectedConditions);
                    // move to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DietaryGoalsScreen(),
                      ),
                    );

                    print("Selected Conditions: $_selectedConditions");
                    print("Other: ${_otherConditionsController.text}");
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
