import 'package:diet_app/screens/mainentry_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _currentIndex = -1;
  List<bool> _showTickList = [];
  List<Map<String, String>> summaryData = [];
  bool _analysisDone = false;

  @override
  void initState() {
    super.initState();
    final userProfile = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    summaryData = [
      {
        "label": "Gender",
        "value":
            "${userProfile.gender ?? 'Not provided'} ${_getEmojiForGender(userProfile.gender ?? '')}",
      },
      {
        "label": "Age",
        "value": "${userProfile.age?.toString() ?? 'Not provided'} 🎂",
      },
      {
        "label": "Height",
        "value":
            "${userProfile.height?.toStringAsFixed(1) ?? 'Not provided'} cm 📏",
      },
      {
        "label": "Weight",
        "value":
            "${userProfile.weight?.toStringAsFixed(1) ?? 'Not provided'} kg ⚖️",
      },
      {
        "label": "Activity Level",
        "value": "${userProfile.activityLevel ?? 'Not provided'} 🏃",
      },
      {
        "label": "Dietary Restrictions",
        "value":
            (userProfile.dietaryRestrictions != null &&
                    userProfile.dietaryRestrictions!.isNotEmpty)
                ? userProfile.dietaryRestrictions!.join(", ")
                : "None 🚫",
      },
      {
        "label": "Health Conditions",
        "value":
            (userProfile.healthConditions != null &&
                    userProfile.healthConditions!.isNotEmpty)
                ? userProfile.healthConditions!.join(", ")
                : "None 💪",
      },
    ];

    _showTickList = List.generate(summaryData.length, (_) => false);
    _startDisplaySequence();
  }

  String _getEmojiForGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return '👨';
      case 'female':
        return '👩';
      case 'other':
        return '🌈';
      default:
        return '';
    }
  }

  void _startDisplaySequence() async {
    for (int i = 0; i < summaryData.length; i++) {
      setState(() {
        _currentIndex = i;
      });
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _showTickList[i] = true;
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _analysisDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final completionPercentage =
        ((_currentIndex + 1) / summaryData.length * 100).clamp(0, 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ Header Message
              Text(
                _analysisDone
                    ? "Analysis Done ✅"
                    : _currentIndex >= 0
                    ? "Analyzing ${summaryData[_currentIndex]['label']}..."
                    : "Initializing Analysis...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 12),

              // 📝 Summary values
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(summaryData.length, (index) {
                    final isVisible = index <= _currentIndex;
                    return isVisible
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "${summaryData[index]['label']}: ${summaryData[index]['value']}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _showTickList[index]
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                )
                                : const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                          ],
                        )
                        : const SizedBox.shrink();
                  }),
                ),
              ),

              // 📊 Progress bar and confirm button
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      20,
                    ), // Add rounded corners
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / summaryData.length,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: const Color.fromARGB(
                        255,
                        126,
                        75,
                        146,
                      ), // Purple color
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$completionPercentage%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: ElevatedButton(
                      onPressed:
                          _analysisDone
                              ? () {
                                // Navigate to main app interface here
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MainEntryScreen(),
                                  ),
                                );
                              }
                              : null,
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
                        "Confirm",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
