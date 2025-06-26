// lib/widgets/insights_card.dart
import 'package:flutter/material.dart';
import '/models/progress_model.dart';

class InsightsCard extends StatelessWidget {
  final HealthInsight insight;

  const InsightsCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getCardColor(),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            _getIcon(),
            const SizedBox(width: 12),
            Expanded(child: Text(insight.message)),
          ],
        ),
      ),
    );
  }

  Color _getCardColor() {
    switch (insight.level) {
      case AlertLevel.critical:
        return Colors.red[50]!;
      case AlertLevel.warning:
        return Colors.orange[50]!;
      case AlertLevel.info:
        return Colors.green[50]!;
    }
  }

  Icon _getIcon() {
    switch (insight.level) {
      case AlertLevel.critical:
        return const Icon(Icons.warning, color: Colors.red);
      case AlertLevel.warning:
        return const Icon(Icons.info_outline, color: Colors.orange);
      case AlertLevel.info:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}
