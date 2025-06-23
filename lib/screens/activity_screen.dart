import 'package:diet_app/screens/restrictions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/userprofile_provider.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  ActivityLevelScreenState createState() => ActivityLevelScreenState();
}

class ActivityLevelScreenState extends State<ActivityLevelScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: ActivityLevelContent()),
    );
  }
}

class ActivityLevelContent extends StatefulWidget {
  const ActivityLevelContent({super.key});

  @override
  State<ActivityLevelContent> createState() => _ActivityLevelContentState();
}

class _ActivityLevelContentState extends State<ActivityLevelContent> {
  String? _selectedActivityLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom back arrow
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.only(top: 12, left: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back, size: 28),
            ),
          ),
        ),

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
        const Text(
          "How active are you?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildActivityOption(
          title: "Sedentary 🧘",
          description: "Little to no exercise. Spend most of the day seated.",
        ),
        _buildActivityOption(
          title: "Lightly Active 🚶",
          description:
              "Light exercise for 30 minutes per day, 3 to 5 times a week.",
        ),
        _buildActivityOption(
          title: "Moderately Active 🏃",
          description:
              "Moderate exercise for 1 hour per day, 3 to 5 times a week.",
        ),
        _buildActivityOption(
          title: "Very Active 🏋️",
          description:
              "Intense exercise for 1 hour per day, 5 to 7 times a week.",
        ),
        _buildActivityOption(
          title: "Super Active 💪",
          description: "Intense exercise for at least 2 hours every day.",
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                if (_selectedActivityLevel != null) {
                  Provider.of<UserProfileProvider>(
                    context,
                    listen: false,
                  ).updateActivityLevel(_selectedActivityLevel!);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DietaryRestrictionsScreen(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select an activity level."),
                    ),
                  );
                }
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
    );
  }

  Widget _buildActivityOption({
    required String title,
    required String description,
  }) {
    final activityValue = title.split(" ")[0];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Center(
        child: SizedBox(
          width: 350,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RadioListTile<String>(
              title: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(description),
              value: activityValue,
              groupValue: _selectedActivityLevel,
              onChanged: (String? value) {
                setState(() {
                  _selectedActivityLevel = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
