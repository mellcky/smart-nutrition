import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/providers/progress_provider.dart';

class TopProgressBar extends StatelessWidget {
  const TopProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>().progress;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20.0,
        left: 16.0,
        right: 16.0,
      ), // space at top + sides
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // rounded corners
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          minHeight: 7, // slightly thicker
        ),
      ),
    );
  }
}
