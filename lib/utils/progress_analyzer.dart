import 'package:flutter/material.dart';
import '../models/food_item.dart';

class ProgressAnalyzer {
  // WHO recommended daily limits
  static const double _maxDailySugarGrams = 50.0; // WHO recommends less than 50g per day
  static const double _maxDailySodiumMg = 2000.0; // WHO recommends less than 2000mg per day
  static const double _maxDailySaturatedFatGrams = 22.0; // Based on 2000 calorie diet (10% of calories)
  static const double _maxDailyCholesterolMg = 300.0; // General recommendation

  // Minimum recommended daily values
  static const double _minDailyFiberGrams = 25.0; // General recommendation
  static const double _minDailyProteinGrams = 50.0; // General recommendation for average adult

  // Analyze weekly food data and return insights
  static List<HealthInsight> analyzeWeeklyData(List<FoodItem> foodItems) {
    List<HealthInsight> insights = [];
    
    if (foodItems.isEmpty) {
      return [
        HealthInsight(
          title: 'No Data Available',
          description: 'Start logging your meals to get health insights.',
          severity: InsightSeverity.info,
          recommendation: 'Log your meals regularly to track your nutrition patterns.',
        )
      ];
    }

    // Calculate total nutrients
    double totalSugar = 0;
    double totalSodium = 0;
    double totalSaturatedFat = 0;
    double totalCholesterol = 0;
    double totalFiber = 0;
    double totalProtein = 0;
    double totalCalories = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    
    for (var item in foodItems) {
      totalSugar += item.sugar;
      totalSodium += item.sodium;
      totalSaturatedFat += item.saturatedFat;
      totalCholesterol += item.chorestrol;
      totalFiber += item.fiber;
      totalProtein += item.protein;
      totalCalories += item.calories;
      totalCarbs += item.carbs;
      totalFats += item.fats;
    }

    // Number of days in the data
    final Set<DateTime> uniqueDays = foodItems.map((item) => 
      DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day)
    ).toSet();
    final int daysCount = uniqueDays.length;
    
    // Calculate daily averages
    final double avgDailySugar = daysCount > 0 ? totalSugar / daysCount : 0;
    final double avgDailySodium = daysCount > 0 ? totalSodium / daysCount : 0;
    final double avgDailySaturatedFat = daysCount > 0 ? totalSaturatedFat / daysCount : 0;
    final double avgDailyCholesterol = daysCount > 0 ? totalCholesterol / daysCount : 0;
    final double avgDailyFiber = daysCount > 0 ? totalFiber / daysCount : 0;
    final double avgDailyProtein = daysCount > 0 ? totalProtein / daysCount : 0;
    
    // Generate insights based on averages
    
    // Sugar insight
    if (avgDailySugar > _maxDailySugarGrams) {
      insights.add(
        HealthInsight(
          title: 'High Sugar Intake',
          description: 'You\'ve consumed an average of ${avgDailySugar.toStringAsFixed(1)}g of sugar daily, which exceeds the recommended limit of ${_maxDailySugarGrams}g.',
          severity: InsightSeverity.high,
          recommendation: 'Consider reducing sugary snacks and drinks. Opt for fruits when craving something sweet.',
        )
      );
    }
    
    // Sodium insight
    if (avgDailySodium > _maxDailySodiumMg) {
      insights.add(
        HealthInsight(
          title: 'High Sodium Intake',
          description: 'Your average daily sodium intake of ${avgDailySodium.toStringAsFixed(1)}mg exceeds the recommended limit of ${_maxDailySodiumMg}mg.',
          severity: InsightSeverity.high,
          recommendation: 'Reduce consumption of processed foods and add less salt to your meals.',
        )
      );
    }
    
    // Saturated fat insight
    if (avgDailySaturatedFat > _maxDailySaturatedFatGrams) {
      insights.add(
        HealthInsight(
          title: 'High Saturated Fat Intake',
          description: 'Your average daily saturated fat intake of ${avgDailySaturatedFat.toStringAsFixed(1)}g exceeds the recommended limit of ${_maxDailySaturatedFatGrams}g.',
          severity: InsightSeverity.medium,
          recommendation: 'Choose leaner meats and low-fat dairy products. Use olive oil instead of butter when possible.',
        )
      );
    }
    
    // Cholesterol insight
    if (avgDailyCholesterol > _maxDailyCholesterolMg) {
      insights.add(
        HealthInsight(
          title: 'High Cholesterol Intake',
          description: 'Your average daily cholesterol intake of ${avgDailyCholesterol.toStringAsFixed(1)}mg exceeds the recommended limit of ${_maxDailyCholesterolMg}mg.',
          severity: InsightSeverity.medium,
          recommendation: 'Limit consumption of egg yolks, fatty meats, and full-fat dairy products.',
        )
      );
    }
    
    // Fiber insight
    if (avgDailyFiber < _minDailyFiberGrams) {
      insights.add(
        HealthInsight(
          title: 'Low Fiber Intake',
          description: 'Your average daily fiber intake of ${avgDailyFiber.toStringAsFixed(1)}g is below the recommended minimum of ${_minDailyFiberGrams}g.',
          severity: InsightSeverity.medium,
          recommendation: 'Include more whole grains, fruits, vegetables, and legumes in your diet.',
        )
      );
    }
    
    // Protein insight
    if (avgDailyProtein < _minDailyProteinGrams) {
      insights.add(
        HealthInsight(
          title: 'Low Protein Intake',
          description: 'Your average daily protein intake of ${avgDailyProtein.toStringAsFixed(1)}g is below the recommended minimum of ${_minDailyProteinGrams}g.',
          severity: InsightSeverity.medium,
          recommendation: 'Include more lean meats, fish, eggs, dairy, or plant-based protein sources like beans and tofu.',
        )
      );
    }
    
    // If no issues found, add a positive insight
    if (insights.isEmpty) {
      insights.add(
        HealthInsight(
          title: 'Balanced Diet',
          description: 'Your diet appears to be well-balanced based on the logged meals.',
          severity: InsightSeverity.good,
          recommendation: 'Keep up the good work! Continue to maintain a varied and balanced diet.',
        )
      );
    }
    
    return insights;
  }
  
  // Calculate health score based on food data (0-100)
  static int calculateHealthScore(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) return 0;
    
    // Number of days in the data
    final Set<DateTime> uniqueDays = foodItems.map((item) => 
      DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day)
    ).toSet();
    final int daysCount = uniqueDays.length;
    if (daysCount == 0) return 0;
    
    // Calculate daily averages
    double totalSugar = 0;
    double totalSodium = 0;
    double totalSaturatedFat = 0;
    double totalFiber = 0;
    double totalProtein = 0;
    double totalFruits = 0;
    double totalVegetables = 0;
    
    for (var item in foodItems) {
      totalSugar += item.sugar;
      totalSodium += item.sodium;
      totalSaturatedFat += item.saturatedFat;
      totalFiber += item.fiber;
      totalProtein += item.protein;
      
      // Simple heuristic for fruits and vegetables based on vitamins
      if (item.vitaminC > 10 || item.vitaminA > 100) {
        if (item.fiber > 2 && item.sugar > 5) {
          totalFruits += 1; // Likely a fruit
        } else if (item.fiber > 2) {
          totalVegetables += 1; // Likely a vegetable
        }
      }
    }
    
    final double avgDailySugar = totalSugar / daysCount;
    final double avgDailySodium = totalSodium / daysCount;
    final double avgDailySaturatedFat = totalSaturatedFat / daysCount;
    final double avgDailyFiber = totalFiber / daysCount;
    final double avgDailyProtein = totalProtein / daysCount;
    final double avgDailyFruits = totalFruits / daysCount;
    final double avgDailyVegetables = totalVegetables / daysCount;
    
    // Calculate scores for each component (0-20)
    int sugarScore = avgDailySugar <= _maxDailySugarGrams 
        ? 20 
        : (20 - ((avgDailySugar - _maxDailySugarGrams) / _maxDailySugarGrams * 20).clamp(0, 20)).toInt();
    
    int sodiumScore = avgDailySodium <= _maxDailySodiumMg 
        ? 20 
        : (20 - ((avgDailySodium - _maxDailySodiumMg) / _maxDailySodiumMg * 20).clamp(0, 20)).toInt();
    
    int saturatedFatScore = avgDailySaturatedFat <= _maxDailySaturatedFatGrams 
        ? 20 
        : (20 - ((avgDailySaturatedFat - _maxDailySaturatedFatGrams) / _maxDailySaturatedFatGrams * 20).clamp(0, 20)).toInt();
    
    int fiberScore = avgDailyFiber >= _minDailyFiberGrams 
        ? 20 
        : (avgDailyFiber / _minDailyFiberGrams * 20).toInt();
    
    int proteinScore = avgDailyProtein >= _minDailyProteinGrams 
        ? 20 
        : (avgDailyProtein / _minDailyProteinGrams * 20).toInt();
    
    // Calculate overall score (0-100)
    int overallScore = sugarScore + sodiumScore + saturatedFatScore + fiberScore + proteinScore;
    
    // Bonus points for fruits and vegetables (up to 10 points)
    int fruitVegBonus = ((avgDailyFruits + avgDailyVegetables) * 2).clamp(0, 10).toInt();
    overallScore = (overallScore + fruitVegBonus).clamp(0, 100);
    
    return overallScore;
  }
}

// Health insight model
class HealthInsight {
  final String title;
  final String description;
  final InsightSeverity severity;
  final String recommendation;
  
  HealthInsight({
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendation,
  });
  
  Color get severityColor {
    switch (severity) {
      case InsightSeverity.high:
        return Colors.red;
      case InsightSeverity.medium:
        return Colors.orange;
      case InsightSeverity.low:
        return Colors.yellow;
      case InsightSeverity.good:
        return Colors.green;
      case InsightSeverity.info:
        return Colors.blue;
    }
  }
  
  IconData get severityIcon {
    switch (severity) {
      case InsightSeverity.high:
        return Icons.warning_rounded;
      case InsightSeverity.medium:
        return Icons.warning_amber_rounded;
      case InsightSeverity.low:
        return Icons.info_outline;
      case InsightSeverity.good:
        return Icons.check_circle;
      case InsightSeverity.info:
        return Icons.info;
    }
  }
}

enum InsightSeverity {
  high,
  medium,
  low,
  good,
  info,
}