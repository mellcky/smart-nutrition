// lib/models/progress_models.dart
class NutritionSummary {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double sugar;
  final double sodium;
  final double saturatedFat;

  NutritionSummary({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.sugar,
    required this.sodium,
    required this.saturatedFat,
  });
}

class HealthInsight {
  final String message;
  final AlertLevel level;

  HealthInsight(this.message, this.level);
}

enum AlertLevel { info, warning, critical }
