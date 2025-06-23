import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/providers/userprofile_provider.dart';

import '/screens/bodymeasurement_screen.dart';

class AgeInputPage extends StatefulWidget {
  const AgeInputPage({super.key});

  @override
  State<AgeInputPage> createState() => _AgeInputPageState();
}

class _AgeInputPageState extends State<AgeInputPage> {
  final int minAge = 12;
  final int maxAge = 100;
  int _selectedAge = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
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
                const SizedBox(height: 40),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cake),
                    SizedBox(width: 8),
                    Text(
                      "What's your age?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Show selected age
                Text(
                  "Age: $_selectedAge",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Center(
                  child: Container(
                    width: 150,
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedAge - minAge,
                      ),
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedAge = index + minAge;
                        });
                      },
                      children: List.generate(
                        maxAge - minAge + 1,
                        (index) => Center(
                          child: Text(
                            "${index + minAge}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<UserProfileProvider>(
                        context,
                        listen: false,
                      ).updateAge(_selectedAge);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BodyMeasurementScreen(),
                        ),
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
              ],
            ),
            // Positioned Back Arrow
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
          ],
        ),
      ),
    );
  }
}
