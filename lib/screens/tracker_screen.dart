import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';
import 'package:diet_app/providers/userprofile_provider.dart';
import 'package:diet_app/utils/calorie_calculator.dart';
import 'package:diet_app/models/food_item.dart';
import 'package:intl/intl.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  late DateTime selectedDate;
  late List<DateTime> weekDates;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _generateWeekDates(selectedDate);
  }

  void _generateWeekDates(DateTime fromDate) {
    int currentWeekday = fromDate.weekday;
    DateTime monday = fromDate.subtract(Duration(days: currentWeekday - 1));
    weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
      _generateWeekDates(date);
    });
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final foodItemProvider = Provider.of<FoodItemProvider>(context);
    final foodItems = foodItemProvider.getFoodItemsForDate(selectedDate);

    // Get user profile data
    final userProfile = Provider.of<UserProfileProvider>(context);
    final gender = userProfile.gender;
    final age = userProfile.age;
    final height = userProfile.height;
    final weight = userProfile.weight;
    final activityLevel = userProfile.activityLevel;

    // Calculate total calorie goal
    final totalCaloriesGoal = calculateTotalCalories(
      gender: gender ?? 'male',
      age: age ?? 18,
      heightCm: height ?? 170,
      weightKg: weight ?? 70,
      activityLevel: activityLevel ?? 'moderate',
    );

    // Calculate micronutrient totals for the selected date
    final Map<String, double> micronutrients = {
      'Potassium': foodItemProvider.getTotalPotassium(selectedDate),
      'Calcium': foodItemProvider.getTotalCalcium(selectedDate),
      'Magnesium': foodItemProvider.getTotalMagnesium(selectedDate),
      'Iron': foodItemProvider.getTotalIron(selectedDate),
      'Zinc': foodItemProvider.getTotalZinc(selectedDate),
      'Vitamin A': foodItemProvider.getTotalVitaminA(selectedDate),
      'Vitamin C': foodItemProvider.getTotalVitaminC(selectedDate),
      'Vitamin D': foodItemProvider.getTotalVitaminD(selectedDate),
      'Vitamin E': foodItemProvider.getTotalVitaminE(selectedDate),
      'Vitamin B6': foodItemProvider.getTotalVitaminB6(selectedDate),
      'Vitamin B12': foodItemProvider.getTotalVitaminB12(selectedDate),
      'Cholesterol': foodItemProvider.getTotalCholesterol(selectedDate),
      'Saturated Fat': foodItemProvider.getTotalSaturatedFat(selectedDate),
      'Fiber': foodItemProvider.getTotalFiber(selectedDate),
      'Sugar': foodItemProvider.getTotalSugar(selectedDate),
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Date navigation header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed:
                      () => _selectDate(
                        selectedDate.subtract(const Duration(days: 7)),
                      ),
                ),
                const SizedBox(width: 1),
                Expanded(
                  child: Row(
                    children:
                        weekDates.map((date) {
                          final isSelected = isSameDate(date, selectedDate);
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => _selectDate(date),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? Colors.blue.shade100
                                          : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('E').format(date),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            isSelected
                                                ? Colors.blue
                                                : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(width: 1),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed:
                      () => _selectDate(
                        selectedDate.add(const Duration(days: 7)),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Main content
            Expanded(
              child: Transform.translate(
                offset: const Offset(0.0, -15.0),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // if (foodItems.isNotEmpty) ...[
                    //   _buildRecentFoods(foodItems),
                    //   const SizedBox(height: 10),
                    // ],
                    _buildTotalCaloriesCard(
                      consumed: foodItemProvider.getTotalCalories(selectedDate),
                      goal: totalCaloriesGoal,
                      protein: foodItemProvider.getTotalProtein(selectedDate),
                      carbs: foodItemProvider.getTotalCarbs(selectedDate),
                      fats: foodItemProvider.getTotalFats(selectedDate),
                    ),
                    const SizedBox(height: 20),
                    MicronutrientCards(micronutrients: micronutrients),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildRecentFoods(List<FoodItem> foodItems) {
  //   // Get the 3 most recent food items
  //   final recentItems =
  //       foodItems.length > 3
  //           ? foodItems.sublist(foodItems.length - 3)
  //           : foodItems;

  //   // Sort by timestamp descending (newest first)
  //   recentItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Padding(
  //         padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
  //         child: Text(
  //           'Recent Foods',
  //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  //         ),
  //       ),
  //       ...recentItems.map((foodItem) => _buildFoodItemCard(foodItem)),
  //     ],
  //   );
  // }

  Widget _buildFoodItemCard(FoodItem foodItem) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.fastfood, color: Colors.green),
        ),
        title: Text(
          foodItem.foodItem,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${foodItem.calories.toStringAsFixed(0)} kcal',
          style: const TextStyle(fontSize: 14),
        ),
        trailing: Text(
          DateFormat('h:mm a').format(foodItem.timestamp),
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildTotalCaloriesCard({
    required double consumed,
    required double goal,
    required double protein,
    required double carbs,
    required double fats,
  }) {
    double progress = consumed / goal;
    double remaining = goal - consumed;

    // Calculate macro percentages
    final double proteinPercentage = protein / (protein + carbs + fats);
    final double carbsPercentage = carbs / (protein + carbs + fats);
    final double fatsPercentage = fats / (protein + carbs + fats);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[150],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey[300]!,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 10,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      consumed.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      '/ ${goal.toStringAsFixed(0)} kcal',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Totals',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${remaining.toStringAsFixed(0)} kcal remaining',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _buildMacroBar('Protein', proteinPercentage, Colors.blue),
                  _buildMacroBar('Carbs', carbsPercentage, Colors.orange),
                  _buildMacroBar('Fats', fatsPercentage, Colors.purple),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class MicronutrientCards extends StatelessWidget {
  final Map<String, double> micronutrients;

  const MicronutrientCards({super.key, required this.micronutrients});

  Widget _buildCategoryCard(String title, Map<String, double> nutrients) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      color: Colors.grey[150],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(thickness: 1.2, height: 20),
            ...nutrients.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    Text(
                      _formatNutrientValue(entry.key, entry.value),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNutrientValue(String name, double value) {
    if (name == 'Cholesterol' ||
        name == 'Potassium' ||
        name == 'Calcium' ||
        name == 'Magnesium' ||
        name == 'Iron' ||
        name == 'Zinc') {
      return '${value.toStringAsFixed(0)} mg';
    } else if (name == 'Vitamin A' ||
        name == 'Vitamin D' ||
        name == 'Vitamin B12') {
      return '${value.toStringAsFixed(0)} µg';
    } else if (name == 'Vitamin C' ||
        name == 'Vitamin E' ||
        name == 'Vitamin B6') {
      return '${value.toStringAsFixed(0)} mg';
    } else if (name == 'Saturated Fat' || name == 'Fiber' || name == 'Sugar') {
      return '${value.toStringAsFixed(1)} g';
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    // Group micronutrients by category
    final vitalMinerals = {
      'Potassium': micronutrients['Potassium'] ?? 0,
      'Calcium': micronutrients['Calcium'] ?? 0,
      'Magnesium': micronutrients['Magnesium'] ?? 0,
      'Iron': micronutrients['Iron'] ?? 0,
      'Zinc': micronutrients['Zinc'] ?? 0,
    };

    final keyVitamins = {
      'Vitamin A': micronutrients['Vitamin A'] ?? 0,
      'Vitamin C': micronutrients['Vitamin C'] ?? 0,
      'Vitamin D': micronutrients['Vitamin D'] ?? 0,
      'Vitamin E': micronutrients['Vitamin E'] ?? 0,
      'Vitamin B6': micronutrients['Vitamin B6'] ?? 0,
      'Vitamin B12': micronutrients['Vitamin B12'] ?? 0,
    };

    final heartHealth = {
      'Cholesterol': micronutrients['Cholesterol'] ?? 0,
      'Saturated Fat': micronutrients['Saturated Fat'] ?? 0,
      'Fiber': micronutrients['Fiber'] ?? 0,
      'Sugar': micronutrients['Sugar'] ?? 0,
    };

    return Column(
      children: [
        _buildCategoryCard("Vital Minerals", vitalMinerals),
        _buildCategoryCard("Key Vitamins", keyVitamins),
        _buildCategoryCard("Heart Health", heartHealth),
      ],
    );
  }
}
