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

  // Cache for meal plans to improve loading speed
  final Map<String, dynamic> _mealPlanCache = {};

  // Initialize the start of the current week (Monday)
  late DateTime weekStart = today.subtract(Duration(days: today.weekday - 1));

  // For navigation between weeks/months
  void navigateToPreviousDay() {
    setState(() {
      today = today.subtract(const Duration(days: 1));
      _loadMealPlan();
    });
  }

  void navigateToNextDay() {
    setState(() {
      today = today.add(const Duration(days: 1));
      _loadMealPlan();
    });
  }

  void navigateToPreviousWeek() {
    setState(() {
      weekStart = weekStart.subtract(const Duration(days: 7));
      if (!isWeeklyView) {
        today = today.subtract(const Duration(days: 7));
      }
      _loadMealPlan();
    });
  }

  void navigateToNextWeek() {
    setState(() {
      weekStart = weekStart.add(const Duration(days: 7));
      if (!isWeeklyView) {
        today = today.add(const Duration(days: 7));
      }
      _loadMealPlan();
    });
  }

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
    // Check if the profile was updated
    final provider = Provider.of<UserProfileProvider>(context, listen: false);
    if (provider.profileUpdated) {
      // Automatically refresh the meal plan when the profile changes
      _loadMealPlan();

      // Also set the flag in case the automatic refresh fails
      setState(() {
        _needsRefresh = true;
      });
    }
  }

  void shiftWeek(int offset) {
    setState(() {
      weekStart = weekStart.add(Duration(days: offset * 7));
    });
  }

  List<DateTime> getCurrentWeekDates() {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  // Generate a unique cache key based on profile data and view type
  String _generateCacheKey(UserProfile profile, bool isWeekly) {
    // Include relevant profile data that would affect meal plan generation
    final StringBuilder = StringBuffer();

    // Add view type
    StringBuilder.write(isWeekly ? 'weekly' : 'daily');

    // Add basic profile information
    if (profile.gender != null) StringBuilder.write('_${profile.gender}');
    if (profile.age != null) StringBuilder.write('_${profile.age}');
    if (profile.weight != null) StringBuilder.write('_w${profile.weight!.round()}');
    if (profile.height != null) StringBuilder.write('_h${profile.height!.round()}');

    // Add health conditions and dietary restrictions (sorted to ensure consistent key)
    if (profile.healthConditions != null && profile.healthConditions!.isNotEmpty) {
      final sortedConditions = List<String>.from(profile.healthConditions!)..sort();
      StringBuilder.write('_hc${sortedConditions.join('')}');
    }

    if (profile.dietaryRestrictions != null && profile.dietaryRestrictions!.isNotEmpty) {
      final sortedRestrictions = List<String>.from(profile.dietaryRestrictions!)..sort();
      StringBuilder.write('_dr${sortedRestrictions.join('')}');
    }

    // Add date for daily view
    if (!isWeekly) {
      StringBuilder.write('_${DateFormat('yyyy-MM-dd').format(today)}');
    } else {
      // For weekly view, add the start of the week
      StringBuilder.write('_${DateFormat('yyyy-MM-dd').format(weekStart)}');
    }

    return StringBuilder.toString();
  }

  // Load meal plan data based on user profile
  Future<void> _loadMealPlan() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      _needsRefresh = false;
    });

    try {
      // Get the user profile provider
      final userProfileProvider = Provider.of<UserProfileProvider>(
        context,
        listen: false,
      );

      // Reset the profile updated flag in the provider
      userProfileProvider.resetUpdateFlag();

      // Make sure user profile is loaded
      if (!userProfileProvider.isLoaded) {
        await userProfileProvider.loadUserProfile();
      }

      final UserProfile? profile = userProfileProvider.profile;

      if (profile == null) {
        throw Exception('User profile not found');
      }

      // Create a cache key based on profile data and view type
      final String cacheKey = _generateCacheKey(profile, isWeeklyView);

      // Check if we have a cached meal plan
      if (_mealPlanCache.containsKey(cacheKey) && !_needsRefresh) {
        // Use cached data
        if (isWeeklyView) {
          weeklyMealPlan = _mealPlanCache[cacheKey] as WeeklyMealPlan;
        } else {
          dailyMealPlan = _mealPlanCache[cacheKey] as DailyMealPlan;
        }
        print('Using cached meal plan');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Generate meal plan using Gemini
      final response = await GeminiService.generateMealPlan(
        profile,
        isWeekly: isWeeklyView,
        date: isWeeklyView ? weekStart : today,
      );

      // Parse the response
      try {
        if (isWeeklyView) {
          final result = GeminiService.parseMealPlanResponse(response, true, profile);
          if (result is WeeklyMealPlan) {
            weeklyMealPlan = result;
            // Cache the result
            _mealPlanCache[cacheKey] = result;
          } else {
            throw Exception('Invalid weekly meal plan format');
          }
        } else {
          final result = GeminiService.parseMealPlanResponse(response, false, profile);
          if (result is DailyMealPlan) {
            dailyMealPlan = result;
            // Cache the result
            _mealPlanCache[cacheKey] = result;
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

          // Navigation and Toggle Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [


                const SizedBox(height: 8),

                // Toggle buttons row
                Row(
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
                              isWeeklyView = false; // Ensure it stays in Daily Plan
                              _loadMealPlan(); // Reload meal plan for the selected date
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

                            // Tabular Weekly Meal Plan
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
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
                                      'Weekly Meal Plan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Tabular layout
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        columnSpacing: 12,
                                        headingRowHeight: 40,
                                        dataRowHeight: 100,
                                        border: TableBorder.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        headingRowColor: WidgetStateProperty.all(
                                          Colors.grey.shade100,
                                        ),
                                        columns: [
                                          // Day column
                                          DataColumn(
                                            label: SizedBox(
                                              width: 80,
                                              child: Center(
                                                child: Text(
                                                  'Day',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Meal type columns
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: _buildCategoryTab(
                                                  Icons.wb_sunny,
                                                  'Breakfast',
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: _buildCategoryTab(
                                                  Icons.cloud,
                                                  'Lunch',
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: _buildCategoryTab(
                                                  Icons.nightlight_round,
                                                  'Dinner',
                                                ),
                                              ),
                                            ),
                                          ),
                                          DataColumn(
                                            label: SizedBox(
                                              width: 120,
                                              child: Center(
                                                child: _buildCategoryTab(
                                                  Icons.timer,
                                                  'Snacks',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                        rows: weeklyMealPlan!.dailyPlans.map((dailyPlan) {
                                          // Get day name and format date
                                          String dayName = DateFormat('EEEE').format(dailyPlan.date);
                                          String dateStr = DateFormat('MM/dd').format(dailyPlan.date);

                                          // Find meals by type
                                          Meal? breakfast = dailyPlan.meals.firstWhere(
                                            (meal) => meal.mealType.toLowerCase() == 'breakfast',
                                            orElse: () => Meal(mealType: 'Breakfast', foodItems: []),
                                          );

                                          Meal? lunch = dailyPlan.meals.firstWhere(
                                            (meal) => meal.mealType.toLowerCase() == 'lunch',
                                            orElse: () => Meal(mealType: 'Lunch', foodItems: []),
                                          );

                                          Meal? dinner = dailyPlan.meals.firstWhere(
                                            (meal) => meal.mealType.toLowerCase() == 'dinner',
                                            orElse: () => Meal(mealType: 'Dinner', foodItems: []),
                                          );

                                          Meal? snack = dailyPlan.meals.firstWhere(
                                            (meal) => meal.mealType.toLowerCase() == 'snack' || 
                                                     meal.mealType.toLowerCase() == 'snacks',
                                            orElse: () => Meal(mealType: 'Snacks', foodItems: []),
                                          );

                                          return DataRow(
                                            cells: [
                                              // Day cell
                                              DataCell(
                                                SizedBox(
                                                  width: 80,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        dayName,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        dateStr,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              // Meal cells
                                              DataCell(_buildWeeklyMealCell(breakfast)),
                                              DataCell(_buildWeeklyMealCell(lunch)),
                                              DataCell(_buildWeeklyMealCell(dinner)),
                                              DataCell(_buildWeeklyMealCell(snack)),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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

    // Otherwise, show a summary of the meal with just food items (no instructions or health benefits)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show the first food item as the main meal
          Text(
            meal.foodItems.isNotEmpty && meal.foodItems.first.foodItem.isNotEmpty 
                ? meal.foodItems.first.foodItem 
                : meal.mealType,
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
          // List all food items without showing more/less
          ...meal.foodItems.skip(1).map((foodItem) {
            if (foodItem.foodItem.isEmpty) return const SizedBox.shrink();
            return Text(
              foodItem.foodItem,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
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
