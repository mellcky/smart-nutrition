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
  List<Map<String, dynamic>> summaryData = [];
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
        "type": "text",
      },
      {
        "label": "Age",
        "value": "${userProfile.age?.toString() ?? 'Not provided'} 🎂",
        "type": "text",
      },
      {
        "label": "Height",
        "value":
            "${userProfile.height?.toStringAsFixed(1) ?? 'Not provided'} cm 📏",
        "type": "text",
      },
      {
        "label": "Weight",
        "value":
            "${userProfile.weight?.toStringAsFixed(1) ?? 'Not provided'} kg ⚖️",
        "type": "text",
      },
      {
        "label": "Activity Level",
        "value": "${userProfile.activityLevel ?? 'Not provided'} 🏃",
        "type": "text",
      },
      {
        "label": "Dietary Restrictions",
        "value": userProfile.dietaryRestrictions ?? [],
        "type": "list",
      },
      {
        "label": "Health Conditions",
        "value": userProfile.healthConditions ?? [],
        "type": "list",
      },
      {
        "label": "Dietary Goals",
        "value": userProfile.dietaryGoals ?? [],
        "type": "list",
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
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() {
        _showTickList[i] = true;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _analysisDone = true;
    });
  }

  void _handleEdit(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Navigate to edit $label screen..."),
        duration: const Duration(seconds: 1),
      ),
    );
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
              Text(
                _analysisDone
                    ? "Confirmed ✅"
                    : _currentIndex >= 0
                    ? "Confirming ${summaryData[_currentIndex]['label']}..."
                    : "Initializing Confirmation...",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 12),

              // 🔁 Dynamic Summary List
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(summaryData.length, (index) {
                    final item = summaryData[index];
                    final isVisible = index <= _currentIndex;

                    if (!isVisible) return const SizedBox.shrink();

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Column(
                                children: [
                                  Text(
                                    item['label'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  item['type'] == 'list'
                                      ? Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        alignment: WrapAlignment.center,
                                        children:
                                            (item['value'] as List).isNotEmpty
                                                ? (item['value'] as List)
                                                    .map<Widget>((value) {
                                                      return Chip(
                                                        label: Text(
                                                          value.toString(),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                              ),
                                                        ),
                                                        backgroundColor:
                                                            Colors.purple[50],
                                                      );
                                                    })
                                                    .toList()
                                                : [
                                                  Chip(
                                                    label: Text(
                                                      'None',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                  ),
                                                ],
                                      )
                                      : Text(
                                        item['value'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                ],
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
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              color: Colors.deepPurple,
                              onPressed:
                                  () =>
                                      _analysisDone
                                          ? _handleEdit(item['label'])
                                          : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }),
                ),
              ),

              // 📊 Progress + Confirm
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: (_currentIndex + 1) / summaryData.length,
                      minHeight: 10,
                      backgroundColor: Colors.grey[300],
                      color: const Color.fromARGB(255, 126, 75, 146),
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
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const MainEntryScreen(),
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
