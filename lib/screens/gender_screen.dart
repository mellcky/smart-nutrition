import 'package:diet_app/screens/age_screen.dart';
import 'package:flutter/material.dart';

import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Back Button Positioned
            Positioned(
              top: 20,
              left: 16,
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context); // This pops the current screen
                },
              ),
            ),
            // Main Column Content
            Column(
              children: [
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
                  "Basic Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.transgender, color: Colors.black, size: 24),
                    SizedBox(width: 8),
                    Text(
                      "What is your gender?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _genderCard("Male", "assets/images/male.jpg"),
                    const SizedBox(width: 20),
                    _genderCard("Female", "assets/images/female.jpg"),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedGender != null) {
                        Provider.of<UserProfileProvider>(
                          context,
                          listen: false,
                        ).updateGender(selectedGender!);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AgeInputPage(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select a gender"),
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _genderCard(String gender, String imagePath) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Image.asset(
              imagePath,
              height: 200,
              width: 100,
              fit: BoxFit.cover,
              cacheHeight: 300,
              cacheWidth: 200,
            ),
            const SizedBox(height: 8),
            Text(gender, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
