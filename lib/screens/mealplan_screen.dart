import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_plan.dart';
import '../models/user_profile.dart';
import '../providers/userprofile_provider.dart';
import '../services/gemini_service.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool isWeeklyView = false;
  DateTime today = DateTime.now();
  bool isLoading = false;
  String? errorMessage;
  bool _needsRefresh = false;

  // Meal plan data
  DailyMealPlan? dailyMealPlan;
  WeeklyMealPlan? weeklyMealPlan;

  // Initialize the start of the current week (Monday)
  late DateTime weekStart = today.subtract(Duration(days: today.weekday - 1));

  @override
  void initState() {
    super.initState();
    // Listen for profile changes
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    provider.addListener(_handleProfileUpdate);

    // Load initial data
    _loadMealPlan();
  }

  @override
  void dispose() {
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    provider.removeListener(_handleProfileUpdate);
    super.dispose();
  }

  void _handleProfileUpdate() {
    setState(() {
      _needsRefresh = true;
    });
  }

  void shiftWeek(int offset) {
    setState(() {
      weekStart = weekStart.add(Duration(days: offset * 7));
    });
  }

  List<DateTime> getCurrentWeekDates() {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  // Load meal plan data based on user profile
  Future<void> _loadMealPlan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      _needsRefresh = false;
    });

    try {
      final userProfileProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      // Make sure user profile is loaded
      if (!userProfileProvider.isLoaded) {
        await userProfileProvider.loadUserProfile();
      }

      final UserProfile? profile = userProfileProvider.profile;

      if (profile == null) {
        throw Exception('User profile not found');
      }

      // Generate meal plan using Gemini
      final response = await GeminiService.generateMealPlan(
        profile,
        isWeekly: isWeeklyView,
      );

      // Parse the response
      try {
        if (isWeeklyView) {
          final result = GeminiService.parseMealPlanResponse(response, true);
          if (result is WeeklyMealPlan) {
            weeklyMealPlan = result;
          } else {
            throw Exception('Invalid weekly meal plan format');
          }
        } else {
          final result = GeminiService.parseMealPlanResponse(response, false);
          if (result is DailyMealPlan) {
            dailyMealPlan = result;
          } else {
            throw Exception('Invalid daily meal plan format');
          }
        }
      } catch (e) {
        throw Exception('Failed to parse meal plan: $e');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load meal plan: ${e.toString()}';
      });
      print(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getCurrentWeekDates();

    return Scaffold(
      floatingActionButton:
          _needsRefresh
              ? FloatingActionButton(
                onPressed: _loadMealPlan,
                backgroundColor: Colors.blue,
                child: const Icon(Icons.refresh),
              )
              : null,
      body: Column(
        children: [
          // Refresh banner
          if (_needsRefresh)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text('Profile updated!'),
                  const Spacer(),
                  TextButton(
                    onPressed: _loadMealPlan,
                    child: const Text('REFRESH MEAL PLAN'),
                  ),
                ],
              ),
            ),

          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (isWeeklyView) {
                        setState(() {
                          isWeeklyView = false;
                          _loadMealPlan();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            !isWeeklyView
                                ? Colors.grey.shade300
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            const Text("Daily Plan"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!isWeeklyView) {
                        setState(() {
                          isWeeklyView = true;
                          _loadMealPlan();
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isWeeklyView
                                ? Colors.grey.shade300
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.view_list, size: 18),
                            const SizedBox(width: 8),
                            const Text("Weekly Plan"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error message if any
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Error: ${errorMessage!}',
                style: const TextStyle(color: Colors.red),
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Fixed width day display with today highlighted (only in Daily Plan)
          if (!isWeeklyView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children:
                    weekDates.map((date) {
                      bool isToday =
                          DateFormat('yyyy-MM-dd').format(date) ==
                          DateFormat('yyyy-MM-dd').format(today);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              today = date;
                              isWeeklyView =
                                  false; // Ensure it stays in Daily Plan
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  isToday
                                      ? Colors.blue.shade100
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  DateFormat(
                                    'EEE',
                                  ).format(date), // Mon, Tue, ...
                                  style: TextStyle(
                                    color: isToday ? Colors.blue : Colors.black,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('d').format(date), // 20, 21, ...
                                  style: TextStyle(
                                    color: isToday ? Colors.blue : Colors.black,
                                    fontSize: 12,
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

          // Daily Plan Content
          if (!isWeeklyView)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMealPlan,
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null && dailyMealPlan == null
                        ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Could not load meal plan',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadMealPlan,
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : dailyMealPlan == null
                        ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No meal plan available',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadMealPlan,
                                    child: const Text('Generate Meal Plan'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : ListView(
                          padding: const EdgeInsets.all(8.0),
                          children: [
                            // Daily Totals
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: Colors.grey[150],
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _NutrientItem(
                                      'Calories',
                                      '${dailyMealPlan!.totalCalories.toInt()}kcal',
                                      Colors.red,
                                      Icons.local_fire_department,
                                    ),
                                    _NutrientItem(
                                      'Protein',
                                      '${dailyMealPlan!.totalProtein.toInt()}g',
                                      Colors.blue,
                                      Icons.fastfood,
                                    ),
                                    _NutrientItem(
                                      'Fat',
                                      '${dailyMealPlan!.totalFats.toInt()}g',
                                      Colors.orange,
                                      Icons.opacity,
                                    ),
                                    _NutrientItem(
                                      'Carbs',
                                      '${dailyMealPlan!.totalCarbs.toInt()}g',
                                      Colors.green,
                                      Icons.local_florist,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Meals
                            ...dailyMealPlan!.meals.map((meal) {
                              // Determine icon based on meal type
                              IconData mealIcon;
                              switch (meal.mealType.toLowerCase()) {
                                case 'breakfast':
                                  mealIcon = Icons.wb_sunny;
                                  break;
                                case 'lunch':
                                  mealIcon = Icons.cloud;
                                  break;
                                case 'snack':
                                case 'snacks':
                                  mealIcon = Icons.timer;
                                  break;
                                case 'dinner':
                                  mealIcon = Icons.nightlight_round;
                                  break;
                                default:
                                  mealIcon = Icons.restaurant;
                              }

                              return _buildMealSectionFromData(
                                meal: meal,
                                icon: mealIcon,
                              );
                            }),
                          ],
                        ),
              ),
            ),

          // Weekly Plan Content
          if (isWeeklyView)
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadMealPlan,
                child:
                    isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null && weeklyMealPlan == null
                        ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Could not load weekly meal plan',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadMealPlan,
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : weeklyMealPlan == null
                        ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.restaurant_menu,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No weekly meal plan available',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: _loadMealPlan,
                                    child: const Text(
                                      'Generate Weekly Meal Plan',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                        : ListView(
                          padding: const EdgeInsets.all(8.0),
                          children: [
                            // Weekly Summary Card
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              color: Colors.grey[150],
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Weekly Summary',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        // Average Calories
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.local_fire_department,
                                              size: 24,
                                              color: Colors.red,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${(weeklyMealPlan!.dailyPlans.isEmpty ? 0 : weeklyMealPlan!.dailyPlans.fold(0.0, (sum, plan) => sum + plan.totalCalories) / weeklyMealPlan!.dailyPlans.length).round()}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.red,
                                              ),
                                            ),
                                            Text(
                                              'Avg. Calories',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),

                                        // Total Meals
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.restaurant,
                                              size: 24,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${weeklyMealPlan!.dailyPlans.fold(0, (sum, plan) => sum + plan.meals.where((meal) => meal.foodItems.isNotEmpty).length)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Text(
                                              'Total Meals',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),

                                        // Food Items
                                        Column(
                                          children: [
                                            Icon(
                                              Icons.fastfood,
                                              size: 24,
                                              color: Colors.green,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${weeklyMealPlan!.dailyPlans.fold(0, (sum, plan) => sum + plan.meals.fold(0, (mealSum, meal) => mealSum + meal.foodItems.length))}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              'Food Items',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Day-by-day meal summary
                            ...weeklyMealPlan!.dailyPlans.map((dailyPlan) {
                              String dayName = DateFormat(
                                'EEEE',
                              ).format(dailyPlan.date);
                              String dateStr = DateFormat(
                                'MMM d',
                              ).format(dailyPlan.date);

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Day header
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '$dayName, $dateStr',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${dailyPlan.totalCalories.toInt()} kcal',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(),

                                      // Meal summaries
                                      ...dailyPlan.meals.map((meal) {
                                        // Skip empty meals
                                        if (meal.foodItems.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        // Determine icon based on meal type
                                        IconData mealIcon;
                                        switch (meal.mealType.toLowerCase()) {
                                          case 'breakfast':
                                            mealIcon = Icons.wb_sunny;
                                            break;
                                          case 'lunch':
                                            mealIcon = Icons.cloud;
                                            break;
                                          case 'snack':
                                          case 'snacks':
                                            mealIcon = Icons.timer;
                                            break;
                                          case 'dinner':
                                            mealIcon = Icons.nightlight_round;
                                            break;
                                          default:
                                            mealIcon = Icons.restaurant;
                                        }

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8.0,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Meal type icon
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 2.0,
                                                  right: 8.0,
                                                ),
                                                child: Icon(
                                                  mealIcon,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                              ),

                                              // Meal content
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Meal type and calories
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          meal.mealType,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        Text(
                                                          '${meal.totalCalories.toInt()} kcal',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    // Food items (limited to first 2 with "more" indicator)
                                                    ...meal.foodItems
                                                        .take(2)
                                                        .map(
                                                          (food) => Text(
                                                            '• ${food.foodItem}',
                                                            style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                    if (meal.foodItems.length >
                                                        2)
                                                      Text(
                                                        '+ ${meal.foodItems.length - 2} more items',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryTab(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  // Build a cell for the weekly meal plan table
  Widget _buildWeeklyMealCell(Meal meal) {
    // If there are no food items, show a placeholder
    if (meal.foodItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Text(
          '-',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
      );
    }

    // Otherwise, show a summary of the meal
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the first food item as the main meal
          Text(
            meal.foodItems.first.foodItem,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Show calories
          Text(
            '${meal.totalCalories.toInt()} kcal',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Show additional food items if any
          if (meal.foodItems.length > 1)
            Text(
              '+${meal.foodItems.length - 1} more',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  // New method to build meal section from real data
  Widget _buildMealSectionFromData({
    required Meal meal,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Meal type header outside the container
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                meal.mealType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Food items container
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: Colors.grey[150],
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food items
                ...meal.foodItems.map((foodItem) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ${foodItem.foodItem}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                    ],
                  );
                }),

                const SizedBox(height: 8),

                // Preparation instructions
                if (meal.instructions != null &&
                    meal.instructions!.isNotEmpty) ...[
                  const Text(
                    '✨ How to prepare',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(meal.instructions!),
                  const SizedBox(height: 8),
                ],

                // Health benefits
                if (meal.healthBenefits != null &&
                    meal.healthBenefits!.isNotEmpty) ...[
                  const Text(
                    '❤️ Health benefits',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(meal.healthBenefits!),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _NutrientItem(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}
