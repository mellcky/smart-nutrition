import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';
import 'package:diet_app/providers/userprofile_provider.dart';
import 'package:diet_app/utils/calorie_calculator.dart';
import 'package:diet_app/models/food_item.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  @override
  Widget build(BuildContext context) {
    final foodItemProvider = Provider.of<FoodItemProvider>(context);
    final foodItem = foodItemProvider.loggedFood; // Recently logged item

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

    return Scaffold(
      body: SafeArea(
        child: Transform.translate(
          offset: const Offset(
            0.0,
            -35.0,
          ), // Move up by 200 logical pixels (approx 20cm)
          child: Container(
            margin: const EdgeInsets.only(
              top: 16.0,
            ), // This margin will still apply relative to its original position
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (foodItem != null) ...[
                  _buildRecentFoodNotification(foodItem),
                  const SizedBox(height: 10),
                ],
                _buildTotalCaloriesCard(
                  consumed: foodItemProvider.totalCalories,
                  goal: totalCaloriesGoal,
                  protein: foodItemProvider.totalProtein / 100,
                  carbs: foodItemProvider.totalCarbs / 100,
                  fats: foodItemProvider.totalFats / 100,
                ),
                const SizedBox(height: 20),
                MicronutrientCards(foodItem: foodItem),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoodNotification(FoodItem foodItem) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // "Recently Logged" header

            // Food item indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Food name text
                  Text.rich(
                    TextSpan(
                      text: 'Logged: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      children: [
                        TextSpan(
                          text: foodItem.foodItem,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Green dot indicator
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  _buildMacroBar('Protein', protein, Colors.blue),
                  _buildMacroBar('Carbs', carbs, Colors.orange),
                  _buildMacroBar('Fats', fats, Colors.purple),
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
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
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
  final FoodItem? foodItem;

  const MicronutrientCards({super.key, required this.foodItem});

  Widget _buildCategoryCard(String title, Map<String, String> nutrients) {
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
                    Text(entry.value, style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryCard("Vital Minerals", {
          "Potassium": "${foodItem?.k ?? 0} mg",
          "Calcium": "${foodItem?.ca ?? 0} mg",
          "Magnesium": "${foodItem?.mg ?? 0} mg",
          "Iron": "${foodItem?.fe ?? 0} mg",
          "Zinc": "${foodItem?.zn ?? 0} mg",
        }),
        _buildCategoryCard("Key Vitamins", {
          "Vitamin A": "${foodItem?.vitaminA ?? 0} µg",
          "Vitamin C": "${foodItem?.vitaminC ?? 0} mg",
          "Vitamin D": "${foodItem?.vitaminD ?? 0} µg",
          "Vitamin E": "${foodItem?.vitaminE ?? 0} mg",
          "Vitamin B6": "${foodItem?.vitaminB6 ?? 0} mg",
          "Vitamin B12": "${foodItem?.vitaminB12 ?? 0} µg",
        }),
        _buildCategoryCard("Heart Health", {
          "Cholesterol": "${foodItem?.chorestrol ?? 0} mg",
          "Saturated Fat": "${foodItem?.saturatedFat ?? 0} g",
          "Fiber": "${foodItem?.fiber ?? 0} g",
          "Sugar": "${foodItem?.sugar ?? 0} g",
        }),
      ],
    );
  }
}
