import 'package:intl/intl.dart';
import '../models/food_item.dart';
import '../providers/fooditem_provider.dart';

enum TimePeriod { weekly, monthly }

class NutritionSummary {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double sugar;
  final double sodium;
  final double saturatedFat;
  final DateTime date;

  NutritionSummary({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.sugar,
    required this.sodium,
    required this.saturatedFat,
    required this.date,
  });

  factory NutritionSummary.empty(DateTime date) => NutritionSummary(
    calories: 0,
    protein: 0,
    carbs: 0,
    fats: 0,
    sugar: 0,
    sodium: 0,
    saturatedFat: 0,
    date: date,
  );
}

class HealthRiskAnalyzer {
  static const double maxDailySugar = 36; // WHO recommendation (9 tsp = 36g)
  static const double maxDailySodium = 2300; // mg (WHO)
  static const double maxDailySaturatedFat = 22; // g (10% of 2000 cal diet)

  static List<String> analyzeRisks(List<FoodItem> items) {
    final insights = <String>[];

    final totalSugar = items.fold(0.0, (sum, item) => sum + item.sugar);
    final totalSodium = items.fold(0.0, (sum, item) => sum + item.sodium);
    final totalSatFat = items.fold(0.0, (sum, item) => sum + item.saturatedFat);

    final sugarLimit = maxDailySugar * 7;
    final sodiumLimit = maxDailySodium * 7;
    final satFatLimit = maxDailySaturatedFat * 7;

    if (totalSugar > sugarLimit) {
      final percentage = (totalSugar / sugarLimit * 100).toStringAsFixed(0);
      insights.add(
        "⚠️ High sugar: ${totalSugar.toStringAsFixed(0)}g this week "
        "(exceeds WHO limit by $percentage%)",
      );
    }

    if (totalSodium > sodiumLimit) {
      final percentage = (totalSodium / sodiumLimit * 100).toStringAsFixed(0);
      insights.add(
        "🧂 High sodium: ${totalSodium.toStringAsFixed(0)}mg this week "
        "(exceeds WHO limit by $percentage%)",
      );
    }

    if (totalSatFat > satFatLimit) {
      final percentage = (totalSatFat / satFatLimit * 100).toStringAsFixed(0);
      insights.add(
        "🍔 High saturated fat: ${totalSatFat.toStringAsFixed(0)}g this week "
        "(exceeds WHO limit by $percentage%)",
      );
    }

    // Positive reinforcement
    if (insights.isEmpty) {
      insights.add("✅ Great job! Your nutrition is within healthy ranges");
    } else {
      insights.add(
        "💡 Tip: Focus on whole foods like fruits, vegetables and lean proteins",
      );
    }

    return insights;
  }

  static double calculateHealthScore(List<FoodItem> items) {
    if (items.isEmpty) return 7.0; // Neutral score for no data

    final maxSugar = maxDailySugar * 7;
    final maxSodium = maxDailySodium * 7;
    final maxSatFat = maxDailySaturatedFat * 7;

    final sugarScore =
        1 - (items.fold(0.0, (s, i) => s + i.sugar) / maxSugar).clamp(0, 1);
    final sodiumScore =
        1 - (items.fold(0.0, (s, i) => s + i.sodium) / maxSodium).clamp(0, 1);
    final proteinScore = (items.fold(0.0, (s, i) => s + i.protein) / 350).clamp(
      0,
      1,
    );

    return ((sugarScore * 0.4) + (sodiumScore * 0.3) + (proteinScore * 0.3)) *
        10;
  }
}

class NutritionDataAggregator {
  static List<NutritionSummary> aggregateData(
    FoodItemProvider provider,
    TimePeriod period,
  ) {
    final now = DateTime.now();
    final summaries = <NutritionSummary>[];

    if (period == TimePeriod.weekly) {
      // Get Monday of current week
      DateTime monday = _getStartOfWeek(now);

      // Generate data for Monday to Sunday
      for (int i = 0; i < 7; i++) {
        final date = monday.add(Duration(days: i));
        final items = provider.getFoodItemsForDate(date);

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
    } else {
      // Monthly aggregation (group by week)
      final startDate = now.subtract(const Duration(days: 30));
      final weeks = <DateTime, List<FoodItem>>{};

      for (int i = 0; i <= 30; i++) {
        final date = startDate.add(Duration(days: i));
        final weekStart = _getStartOfWeek(date);
        weeks.putIfAbsent(weekStart, () => []);
        weeks[weekStart]!.addAll(provider.getFoodItemsForDate(date));
      }

      weeks.forEach((weekStart, items) {
        summaries.add(
          NutritionSummary(
            date: weekStart,
            calories: items.fold(0, (s, i) => s + i.calories),
            protein: items.fold(0, (s, i) => s + i.protein),
            carbs: items.fold(0, (s, i) => s + i.carbs),
            fats: items.fold(0, (s, i) => s + i.fats),
            sugar: items.fold(0, (s, i) => s + i.sugar),
            sodium: items.fold(0, (s, i) => s + i.sodium),
            saturatedFat: items.fold(0, (s, i) => s + i.saturatedFat),
          ),
        );
      });

      // Sort by date
      summaries.sort((a, b) => a.date.compareTo(b.date));
    }

    return summaries;
  }

  static DateTime _getStartOfWeek(DateTime date) {
    // Adjust to get Monday (1 = Monday, 7 = Sunday)
    int daysFromMonday = date.weekday - 1;
    return date.subtract(Duration(days: daysFromMonday));
  }

  static List<NutritionSummary> getEmptyData(TimePeriod period) {
    final now = DateTime.now();
    final summaries = <NutritionSummary>[];

    if (period == TimePeriod.weekly) {
      final monday = _getStartOfWeek(now);
      for (int i = 0; i < 7; i++) {
        summaries.add(NutritionSummary.empty(monday.add(Duration(days: i))));
      }
    } else {
      final startDate = now.subtract(const Duration(days: 30));
      for (int i = 0; i < 5; i++) {
        // 5 weeks
        final weekStart = startDate.add(Duration(days: i * 7));
        summaries.add(NutritionSummary.empty(weekStart));
      }
    }

    return summaries;
  }
}
