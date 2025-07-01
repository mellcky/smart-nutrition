import '../models/food_item.dart';
import 'package:intl/intl.dart';

class NutritionCalculator {
  // Calculate daily nutrition summary for a list of food items
  static Map<String, double> calculateDailyNutrition(List<FoodItem> foodItems) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    double totalSugar = 0;
    double totalFiber = 0;
    double totalSodium = 0;
    double totalSaturatedFat = 0;

    for (var item in foodItems) {
      totalCalories += item.calories;
      totalProtein += item.protein;
      totalCarbs += item.carbs;
      totalFats += item.fats;
      totalSugar += item.sugar;
      totalFiber += item.fiber;
      totalSodium += item.sodium;
      totalSaturatedFat += item.saturatedFat;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fats': totalFats,
      'sugar': totalSugar,
      'fiber': totalFiber,
      'sodium': totalSodium,
      'saturatedFat': totalSaturatedFat,
    };
  }

  // Calculate weekly nutrition summary
  static Map<String, Map<String, double>> calculateWeeklySummary(List<FoodItem> foodItems) {
    // Group food items by day
    Map<String, List<FoodItem>> foodItemsByDay = {};

    for (var item in foodItems) {
      String dateKey = DateFormat('yyyy-MM-dd').format(item.timestamp);
      if (!foodItemsByDay.containsKey(dateKey)) {
        foodItemsByDay[dateKey] = [];
      }
      foodItemsByDay[dateKey]!.add(item);
    }

    // Calculate daily nutrition for each day
    Map<String, Map<String, double>> weeklySummary = {};

    foodItemsByDay.forEach((dateKey, items) {
      weeklySummary[dateKey] = calculateDailyNutrition(items);
    });

    return weeklySummary;
  }

  // Calculate monthly nutrition summary
  static Map<String, Map<String, double>> calculateMonthlySummary(List<FoodItem> foodItems) {
    // Group food items by week
    Map<String, List<FoodItem>> foodItemsByWeek = {};

    for (var item in foodItems) {
      // Get the week number (1-5) within the month
      int weekOfMonth = ((item.timestamp.day - 1) ~/ 7) + 1;
      String weekKey = '${item.timestamp.year}-${item.timestamp.month}-W$weekOfMonth';

      if (!foodItemsByWeek.containsKey(weekKey)) {
        foodItemsByWeek[weekKey] = [];
      }
      foodItemsByWeek[weekKey]!.add(item);
    }

    // Calculate nutrition for each week
    Map<String, Map<String, double>> monthlySummary = {};

    foodItemsByWeek.forEach((weekKey, items) {
      monthlySummary[weekKey] = calculateDailyNutrition(items);
    });

    return monthlySummary;
  }

  // Get macronutrient percentages (protein, carbs, fats)
  static Map<String, double> calculateMacroPercentages(double protein, double carbs, double fats) {
    double total = protein + carbs + fats;

    if (total == 0) {
      return {
        'protein': 0,
        'carbs': 0,
        'fats': 0,
      };
    }

    return {
      'protein': (protein / total) * 100,
      'carbs': (carbs / total) * 100,
      'fats': (fats / total) * 100,
    };
  }

  // Calculate average daily nutrition for a period
  static Map<String, double> calculateAverageDailyNutrition(List<FoodItem> foodItems) {
    if (foodItems.isEmpty) {
      return {
        'calories': 0,
        'protein': 0,
        'carbs': 0,
        'fats': 0,
        'sugar': 0,
        'fiber': 0,
        'sodium': 0,
        'saturatedFat': 0,
      };
    }

    // Get unique days
    Set<String> uniqueDays = foodItems.map((item) => 
      DateFormat('yyyy-MM-dd').format(item.timestamp)
    ).toSet();

    int daysCount = uniqueDays.length;

    // Calculate total nutrition
    Map<String, double> totalNutrition = calculateDailyNutrition(foodItems);

    // Calculate average
    Map<String, double> averageNutrition = {};

    totalNutrition.forEach((nutrient, value) {
      averageNutrition[nutrient] = value / daysCount;
    });

    return averageNutrition;
  }

  // Get nutrition data for charting (returns data points for each day)
  static List<Map<String, dynamic>> getNutritionDataForChart(
    List<FoodItem> foodItems, 
    String nutrientType
  ) {
    // Find the date range from the food items
    DateTime? startDate;
    DateTime? endDate;

    if (foodItems.isNotEmpty) {
      startDate = foodItems.map((item) => item.timestamp).reduce((a, b) => a.isBefore(b) ? a : b);
      endDate = foodItems.map((item) => item.timestamp).reduce((a, b) => a.isAfter(b) ? a : b);

      // Normalize to start of day
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      endDate = DateTime(endDate.year, endDate.month, endDate.day);
    } else {
      // If no food items, use current date
      final now = DateTime.now();
      startDate = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 7));
      endDate = DateTime(now.year, now.month, now.day);
    }

    // Group food items by day
    Map<DateTime, List<FoodItem>> foodItemsByDay = {};

    // Initialize all days in the range with empty lists
    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      foodItemsByDay[DateTime(currentDate.year, currentDate.month, currentDate.day)] = [];
      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Add food items to their respective days
    for (var item in foodItems) {
      DateTime dateKey = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      foodItemsByDay[dateKey]!.add(item);
    }

    // Calculate daily nutrition for each day
    List<Map<String, dynamic>> chartData = [];

    foodItemsByDay.forEach((date, items) {
      Map<String, double> dailyNutrition = calculateDailyNutrition(items);

      // Add data point
      chartData.add({
        'date': date,
        'value': dailyNutrition[nutrientType] ?? 0,
      });
    });

    // Sort by date
    chartData.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    return chartData;
  }
  // Calculate recommended water intake based on calorie goal
  static double calculateWaterIntake(double calorieGoal) {
    // Formula: 1 ml of water per calorie
    return calorieGoal;
  }

  // Convert milliliters to glasses (1 glass = 250 ml)
  static int mlToGlasses(double milliliters) {
    return (milliliters / 250).round();
  }
}
