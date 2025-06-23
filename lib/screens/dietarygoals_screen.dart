import 'package:diet_app/screens/name_screen.dart';
import 'package:diet_app/screens/summarize_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class DietaryGoalsScreen extends StatefulWidget {
  const DietaryGoalsScreen({super.key});

  @override
  State<DietaryGoalsScreen> createState() => _DietaryGoalsScreenState();
}

class _DietaryGoalsScreenState extends State<DietaryGoalsScreen> {
  // List of dietary goals with emojis
  final List<String> _goals = [
    '🏋️‍♂️ Weight Loss ',
    '💪 Improved Health ',
    '🍽️ Weight Gain ',
  ];

  List<String> _selectedGoals = [];

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
              "What are your dietary goals?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Goal selection list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    value: _selectedGoals.contains(_goals[index]),
                    title: Text(
                      _goals[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedGoals.add(_goals[index]);
                        } else {
                          _selectedGoals.remove(_goals[index]);
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
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
                    userProfile.setDietaryGoals(_selectedGoals);
                    // move to the next page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NameScreen()),
                    );
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
