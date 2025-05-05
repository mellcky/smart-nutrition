import 'package:diet_app/screens/age_screen.dart';
import 'package:flutter/material.dart';
import '/widgets/back_button_wrapper.dart';
import '/widgets/progress_bar.dart';
import 'package:diet_app/models/user_profile.dart';
import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

import '/providers/progress_provider.dart';

class GenderSelectionScreen extends StatefulWidget {
  final UserProfile userProfile;

  GenderSelectionScreen({Key? key, required this.userProfile})
    : super(key: key);

  @override
  _GenderSelectionScreenState createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgressProvider>(context, listen: false).setProgress(0.6);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopProgressBar(),
            BackIconWrapper(),
            // const SizedBox(height: 16),
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
                    top: 60, // Logo top (-50) + radius (50) + 10px space = ~60
                    child: const Text(
                      "Basic Information",
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

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.transgender, color: Colors.black, size: 24),
                SizedBox(width: 8),
                Text(
                  "What is your gender?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _genderCard("Male", "assets/images/male.jpg"),
                SizedBox(width: 20),
                _genderCard("Female", "assets/images/female.jpg"),
              ],
            ),

            Spacer(),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 50,
              ), // Padding from the bottom of the screen
              child: ElevatedButton(
                onPressed: () {
                  // ✅ Update gender in provider
                  final profileProvider = Provider.of<UserProfileProvider>(
                    context,
                    listen: false,
                  );
                  profileProvider.updateGender(selectedGender!);

                  if (selectedGender != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AgeInputPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please select a gender")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Green button
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
          ],
        ),
      ),
    );
  }

  Widget _genderCard(String gender, String imagePath) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap:
          () => setState(() {
            selectedGender = gender;
          }),
      child: Container(
        width: 130,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 250, fit: BoxFit.contain),
            SizedBox(height: 8),
            Text(gender, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
