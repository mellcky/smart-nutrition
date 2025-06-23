import 'package:diet_app/models/food_item.dart';

class Meal {
  final String mealType; // breakfast, lunch, dinner, snack
  final List<FoodItem> foodItems;
  final String? instructions;
  final String? healthBenefits;

  Meal({
    required this.mealType,
    required this.foodItems,
    this.instructions,
    this.healthBenefits,
  });

  // Calculate total nutritional values for the meal
  double get totalCalories => foodItems.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => foodItems.fold(0, (sum, item) => sum + item.protein);
  double get totalFats => foodItems.fold(0, (sum, item) => sum + item.fats);
  double get totalCarbs => foodItems.fold(0, (sum, item) => sum + item.carbs);

  factory Meal.fromJson(Map<String, dynamic> json) {
    try {
      // Check if foodItems exists and is a list
      if (json['foodItems'] == null || !(json['foodItems'] is List)) {
        return Meal(
          mealType: json['mealType'] ?? 'Unknown',
          foodItems: [],
          instructions: json['instructions'],
          healthBenefits: json['healthBenefits'],
        );
      }

      // Safely convert and map the foodItems
      List<FoodItem> foodItems = [];
      for (var item in json['foodItems'] as List) {
        if (item is Map<String, dynamic>) {
          try {
            // Add a default foodItemId if not present
            if (item['foodItemId'] == null) {
              item['foodItemId'] = 0;
            }
            foodItems.add(FoodItem.fromJson(item));
          } catch (e) {
            print('Error parsing food item: $e');
            // Skip invalid food items
          }
        }
      }

      return Meal(
        mealType: json['mealType'] ?? 'Unknown',
        foodItems: foodItems,
        instructions: json['instructions'],
        healthBenefits: json['healthBenefits'],
      );
    } catch (e) {
      print('Error parsing Meal from JSON: $e');
      // Return a default meal if parsing fails
      return Meal(
        mealType: json['mealType'] ?? 'Unknown',
        foodItems: [],
        instructions: 'Could not parse instructions',
        healthBenefits: 'Could not parse health benefits',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mealType': mealType,
      'foodItems': foodItems.map((item) => item.toMap()).toList(),
      'instructions': instructions,
      'healthBenefits': healthBenefits,
    };
  }
}

class DailyMealPlan {
  final DateTime date;
  final List<Meal> meals;

  DailyMealPlan({
    required this.date,
    required this.meals,
  });

  // Calculate total nutritional values for the day
  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get totalFats => meals.fold(0, (sum, meal) => sum + meal.totalFats);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);

  factory DailyMealPlan.fromJson(Map<String, dynamic> json) {
    try {
      // Try to parse the date, or use current date if it fails
      DateTime date;
      try {
        date = DateTime.parse(json['date'] ?? '');
      } catch (e) {
        print('Error parsing date: $e');
        date = DateTime.now();
      }

      // Check if meals exists and is a list
      if (json['meals'] == null || !(json['meals'] is List)) {
        return DailyMealPlan(
          date: date,
          meals: [],
        );
      }

      // Safely convert and map the meals
      List<Meal> meals = [];
      for (var meal in json['meals'] as List) {
        if (meal is Map<String, dynamic>) {
          try {
            meals.add(Meal.fromJson(meal));
          } catch (e) {
            print('Error parsing meal: $e');
            // Skip invalid meals
          }
        }
      }

      return DailyMealPlan(
        date: date,
        meals: meals,
      );
    } catch (e) {
      print('Error parsing DailyMealPlan from JSON: $e');
      // Return a default plan if parsing fails
      return DailyMealPlan(
        date: DateTime.now(),
        meals: [],
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'meals': meals.map((meal) => meal.toJson()).toList(),
    };
  }
}

class WeeklyMealPlan {
  final List<DailyMealPlan> dailyPlans;
  final String? generatedFor; // User profile information this was generated for

  WeeklyMealPlan({
    required this.dailyPlans,
    this.generatedFor,
  });

  factory WeeklyMealPlan.fromJson(Map<String, dynamic> json) {
    try {
      // Check if dailyPlans exists and is a list
      if (json['dailyPlans'] == null || !(json['dailyPlans'] is List) || (json['dailyPlans'] as List).isEmpty) {
        // If no dailyPlans or invalid format, create a default weekly plan with current week
        final today = DateTime.now();
        final weekStart = today.subtract(Duration(days: today.weekday - 1));

        return WeeklyMealPlan(
          dailyPlans: List.generate(
            7, 
            (index) => DailyMealPlan(
              date: weekStart.add(Duration(days: index)),
              meals: [],
            )
          ),
          generatedFor: json['generatedFor'],
        );
      }

      // Safely convert and map the dailyPlans
      List<DailyMealPlan> plans = [];
      for (var plan in json['dailyPlans'] as List) {
        if (plan is Map<String, dynamic>) {
          plans.add(DailyMealPlan.fromJson(plan));
        }
      }

      // If we couldn't parse any plans, create a default
      if (plans.isEmpty) {
        final today = DateTime.now();
        final weekStart = today.subtract(Duration(days: today.weekday - 1));
        plans = List.generate(
          7, 
          (index) => DailyMealPlan(
            date: weekStart.add(Duration(days: index)),
            meals: [],
          )
        );
      }

      return WeeklyMealPlan(
        dailyPlans: plans,
        generatedFor: json['generatedFor'],
      );
    } catch (e) {
      print('Error parsing WeeklyMealPlan from JSON: $e');
      // Return a default weekly plan if parsing fails
      final today = DateTime.now();
      final weekStart = today.subtract(Duration(days: today.weekday - 1));

      return WeeklyMealPlan(
        dailyPlans: List.generate(
          7, 
          (index) => DailyMealPlan(
            date: weekStart.add(Duration(days: index)),
            meals: [],
          )
        ),
        generatedFor: 'Error parsing meal plan',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyPlans': dailyPlans.map((plan) => plan.toJson()).toList(),
      'generatedFor': generatedFor,
    };
  }
}
