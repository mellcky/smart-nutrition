import 'package:diet_app/screens/summarize_screen.dart';

import '/widgets/back_button_wrapper.dart';
import '/widgets/progress_bar.dart';
import 'package:flutter/material.dart';
import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

class HealthConditionsScreen extends StatefulWidget {
  @override
  _HealthConditionsScreenState createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> {
  List<String> _selectedConditions = [];
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopProgressBar(),
            BackIconWrapper(),
            SizedBox(
              width: double.infinity,
              height: 100,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: -40,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/app_logo.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  Positioned(
                    top: 50,
                    child: const Text(
                      "Do you have any health conditions?",
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
                      MaterialPageRoute(builder: (context) => SummaryScreen()),
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
