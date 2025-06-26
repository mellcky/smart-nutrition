// lib/utils/nutrition_calculator.dart
import '../models/food_item.dart';
import '../models/progress_model.dart';
import '../providers/fooditem_provider.dart';

class HealthRiskAnalyzer {
  static const double maxDailySugar = 36; // WHO recommendation (9 tsp)
  static const double maxDailySodium = 2300; // mg
  static const double maxDailySatFat = 22; // g (10% of 2000 cal diet)

  static List<HealthInsight> analyzeRisks(List<FoodItem> items) {
    final insights = <HealthInsight>[];
    final totalSugar = items.fold(0.0, (sum, item) => sum + item.sugar);
    final totalSodium = items.fold(0.0, (sum, item) => sum + item.sodium);
    final totalSatFat = items.fold(0.0, (sum, item) => sum + item.saturatedFat);

    if (totalSugar > maxDailySugar * 7) {
      insights.add(
        HealthInsight(
          "⚠️ You've consumed ${totalSugar.toStringAsFixed(0)}g of sugar this week - "
          "exceeds WHO recommendations by ${(totalSugar / (maxDailySugar * 7) * 100).toStringAsFixed(0)}%",
          AlertLevel.warning,
        ),
      );
    }

    if (totalSodium > maxDailySodium * 7) {
      insights.add(
        HealthInsight(
          "🧂 High sodium: ${totalSodium.toStringAsFixed(0)}mg this week. "
          "May increase hypertension risk",
          AlertLevel.critical,
        ),
      );
    }

    if (insights.isEmpty) {
      insights.add(
        HealthInsight(
          "✅ Great job! Your nutrition is within healthy ranges",
          AlertLevel.info,
        ),
      );
    }

    return insights;
  }
}

class NutritionAggregator {
  static List<NutritionSummary> aggregateWeekly(
    FoodItemProvider provider,
    DateTime startDate,
  ) {
    final summaries = <NutritionSummary>[];
    final endDate = startDate.add(const Duration(days: 6));

    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      summaries.add(
        NutritionSummary(
          date: date,
          calories: provider.getTotalCalories(date),
          protein: provider.getTotalProtein(date),
          carbs: provider.getTotalCarbs(date),
          fats: provider.getTotalFats(date),
          sugar: provider.getTotalSugar(date),
          sodium: provider.getTotalSodium(date),
          saturatedFat: provider.getTotalSaturatedFat(date),
        ),
      );
    }

    return summaries;
  }
}
