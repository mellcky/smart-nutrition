import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/progress_provider.dart'; // Make sure to import your ProgressProvider

class TopProgressBar extends StatelessWidget {
  const TopProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = Provider.of<ProgressProvider>(context).progress;
    final totalSteps =
        7; // Total steps in the process (you can change this based on your flow)

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Step ${progress + 1}/$totalSteps', // Displaying current step
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          LinearProgressIndicator(
            value: (progress + 1) / totalSteps,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.green,
            ), // Green progress color
            minHeight: 8,
          ),
        ],
      ),
    );
  }
}
