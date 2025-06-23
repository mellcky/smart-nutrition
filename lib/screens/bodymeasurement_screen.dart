import 'package:diet_app/screens/activity_screen.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  BodyMeasurementScreenState createState() => BodyMeasurementScreenState();
}

class BodyMeasurementScreenState extends State<BodyMeasurementScreen> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _bmi = "Auto-calculated 📊";
  String _bmiCategory = "";
  String _bmiEmoji = "";

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateBMI);
    _weightController.addListener(_calculateBMI);
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateBMI);
    _weightController.removeListener(_calculateBMI);
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      double heightInMeters = height / 100;
      double bmi = weight / (heightInMeters * heightInMeters);
      setState(() {
        _bmi = bmi.toStringAsFixed(1);
        _bmiCategory = _getBMICategory(bmi);
        _bmiEmoji = _getBMIEmoji(bmi);
      });
    } else {
      setState(() {
        _bmi = "Auto-calculated 📊";
        _bmiCategory = "";
        _bmiEmoji = "";
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    if (bmi < 35) return "Obese";
    return "Extremely Obese";
  }

  String _getBMIEmoji(double bmi) {
    if (bmi < 18.5) return "😟";
    if (bmi < 25) return "😊";
    if (bmi < 30) return "⚖️";
    if (bmi < 35) return "😓";
    return "🚨";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // Custom back arrow (not in AppBar)
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
                        "What's your height and weight?",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // HEIGHT input
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.height, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Your height:",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 220,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _heightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hintText: "Enter height (cm)",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // WEIGHT input
                      Center(
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "⚖️   Your weight: ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 220,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _weightController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade100,
                                  hintText: "Enter weight (kg)",
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // BMI display
                      Column(
                        children: [
                          const Text(
                            "YOUR BODY MASS INDEX (BMI) IS",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bmi,
                            style:
                                _bmi == "Auto-calculated 📊"
                                    ? const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.blue,
                                    )
                                    : const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                            textAlign: TextAlign.center,
                          ),
                          if (_bmiCategory.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              "$_bmiCategory $_bmiEmoji",
                              style: const TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),

                      const Spacer(),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              final heightText = _heightController.text.trim();
                              final weightText = _weightController.text.trim();

                              final height = double.tryParse(heightText);
                              final weight = double.tryParse(weightText);

                              if (height != null &&
                                  weight != null &&
                                  height > 0 &&
                                  weight > 0) {
                                final profileProvider =
                                    Provider.of<UserProfileProvider>(
                                      context,
                                      listen: false,
                                    );

                                profileProvider.updateHeight(height);
                                profileProvider.updateWeight(weight);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ActivityLevelScreen(),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please enter valid height and weight",
                                    ),
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
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
