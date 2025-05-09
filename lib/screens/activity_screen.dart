// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '/providers/on_boarding_provider.dart';
// import '/widgets/back_button_wrapper.dart';
// import '/widgets/progress_bar.dart';
// // import '/screens/activity_screen.dart';
// // import '/widgets/back_button_wrapper.dart';
// // import '/widgets/gender_option.dart';

// class ActivityScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final provider = Provider.of<OnboardingProvider>(context);
//     provider.setProgress(1.0);

//     final List<Map<String, dynamic>> activityOptions = [
//       {"label": "Sedentary", "icon": Icons.hotel},
//       {"label": "Lightly active", "icon": Icons.directions_walk},
//       {"label": "Moderately active", "icon": Icons.directions_run},
//       {"label": "Very active", "icon": Icons.local_fire_department},
//     ];

//     return Scaffold(
//       appBar: AppBar(toolbarHeight: 0),
//       body: Column(
//         children: [
//           TopProgressBar(),
//           BackIconWrapper(),
//           SizedBox(height: 20),
//           Text(
//             "How active are you on a daily basis?",
//             style: TextStyle(fontSize: 20),
//           ),
//           ...activityOptions.map((option) {
//             final label = option["label"] as String;
//             final isSelected = provider.activityLevels.contains(label);

//             return ListTile(
//               leading: Icon(
//                 option["icon"] as IconData,
//                 color: isSelected ? Colors.green : null,
//               ),
//               title: Text(label),
//               tileColor: isSelected ? Colors.green.shade100 : null,
//               onTap: () => provider.toggleActivityLevel(label),
//             );
//           }).toList(),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               // Proceed or navigate based on selected options
//             },
//             child: Text('Continue'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:diet_app/screens/restrictions_screen.dart';
import 'package:diet_app/screens/restrictions_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // ✅ provider
import '/widgets/back_button_wrapper.dart';
import '/widgets/progress_bar.dart';
import '/providers/userprofile_provider.dart'; // ✅ Import your profile provider

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  ActivityLevelScreenState createState() => ActivityLevelScreenState();
}

class ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? _selectedActivityLevel;

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
              height:
                  130, // Slightly increased to fit both logo and text comfortably
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Logo moved up
                  Positioned(
                    top: -50,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/app_logo.jpg'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),

                  // Text positioned just below the logo
                  Positioned(
                    top: 60,
                    child: Column(
                      children: const [
                        Text(
                          "How active are you?",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8), // Space between the texts
                        Text(
                          "Don't worry, you can easily change your profile",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _buildActivityOption(
              "Sedentary 🧘",
              "Little to no exercise. Spend most of the day seated.",
            ),
            _buildActivityOption(
              "Lightly Active 🚶",
              "Light exercise for 30 minutes per day, 3 to 5 times a week.",
            ),
            _buildActivityOption(
              "Moderately Active 🏃",
              "Moderate exercise for 1 hour per day, 3 to 5 times a week.",
            ),
            _buildActivityOption(
              "Very Active 🏋️",
              "Intense exercise for 1 hour per day, 5 to 7 times a week.",
            ),
            _buildActivityOption(
              "Super Active 💪",
              "Intense exercise for at least 2 hours every day.",
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.only(
                bottom: 0,
              ), // Bottom padding remains
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle continue logic
                    if (_selectedActivityLevel != null) {
                      // ✅ Save to provider
                      final profileProvider = Provider.of<UserProfileProvider>(
                        context,
                        listen: false,
                      );
                      profileProvider.updateActivityLevel(
                        _selectedActivityLevel!,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DietaryRestrictionsScreen(),
                        ),
                      );
                    } else {
                      // Optional: show warning if nothing is selected
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
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
        ),
      ),
    );
  }

  Widget _buildActivityOption(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Center(
        child: SizedBox(
          width: 350, // Adjust this width as needed
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
              value: title.split(" ")[0], // Extract the activity level
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
