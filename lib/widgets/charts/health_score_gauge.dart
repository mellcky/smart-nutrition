import 'package:flutter/material.dart';

class HealthScoreGauge extends StatelessWidget {
  final double score;

  const HealthScoreGauge({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress indicator background
          // CircularProgressIndicator(
          //   value: 1.0, // Full circle for background
          //   strokeWidth: 12,
          //   backgroundColor: Colors.grey[200],
          //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
          // ),

          // Actual progress indicator
          // CircularProgressIndicator(
          //   value: score / 10,
          //   strokeWidth: 12,
          //   backgroundColor: Colors.transparent,
          //   valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score)),
          // ),

          // Score text overlay
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(score),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'HEALTH SCORE',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score > 8) return const Color(0xFF34A853); // Green
    if (score > 6) return const Color(0xFF90EE90); // Light Green
    if (score > 4) return const Color(0xFFFFA500); // Orange
    return const Color(0xFFFF0000); // Red
  }
}
