// import 'package:diet_app/screens/foodinput_screen.dart';
// import 'package:diet_app/screens/foodrecognition_screen.dart';
import 'package:diet_app/screens/foodrecognition_screen_fixed.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';
import 'package:diet_app/models/food_item.dart';
import '/db/user_database_helper.dart';

class LoggingScreen extends StatefulWidget {
  const LoggingScreen({super.key});

  @override
  State<LoggingScreen> createState() => _LoggingScreenState();
}

class _LoggingScreenState extends State<LoggingScreen> {
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

  void _showWaterLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const WaterLogDialog();
      },
    );
  }

  Widget _buildDailyTotal() {
    final foodProvider = Provider.of<FoodItemProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.grey[150],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NutrientItem(
              'Calories',
              '${foodProvider.totalCalories.toStringAsFixed(0)}kcal',
              Colors.red,
              Icons.whatshot,
            ),
            _NutrientItem(
              'Protein',
              '${foodProvider.totalProtein.toStringAsFixed(0)}g',
              Colors.blue,
              Icons.restaurant_menu,
            ),
            _NutrientItem(
              'Fat',
              '${foodProvider.totalFats.toStringAsFixed(0)}g',
              Colors.orange,
              Icons.water_drop,
            ),
            _NutrientItem(
              'Carbs',
              '${foodProvider.totalCarbs.toStringAsFixed(0)}g',
              Colors.green,
              Icons.eco,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealEntry({
    required String recommendation,
    required ImageProvider image,
    required VoidCallback onLogPressed,
    required String mealType,
    IconData icon = Icons.restaurant,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.grey[150],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.shade100,
                ),
                child: Center(
                  child: Icon(icon, color: Colors.green.shade800, size: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text('Recommended: $recommendation')),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Log'),
                onPressed: onLogPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.blue.shade400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String mealType) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 1.0, right: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showMealHistory(context, mealType),
          ),
        ],
      ),
    );
  }

  Future<void> _showMealHistory(BuildContext context, String mealType) async {
    final dbHelper = UserDatabaseHelper();
    List<FoodItem> foodItems = await dbHelper.getFoodItemsByMealType(mealType);

    // Sort by timestamp descending (newest first)
    foodItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                '$mealType History',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    foodItems.isEmpty
                        ? const Center(
                          child: Text(
                            'No history found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: foodItems.length,
                          itemBuilder: (context, index) {
                            final item = foodItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: const Icon(Icons.fastfood),
                                title: Text(
                                  item.foodItem,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat(
                                    'MMM d, yyyy - h:mm a',
                                  ).format(item.timestamp),
                                ),
                                trailing: Text(
                                  '${item.calories.toStringAsFixed(0)} kcal',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                              padding: const EdgeInsets.symmetric(vertical: 6),
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
                    () =>
                        _selectDate(selectedDate.add(const Duration(days: 7))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(Icons.menu),
                SizedBox(width: 8),
                Text('Daily Total', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          _buildDailyTotal(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSectionHeader(Icons.local_drink, 'Water', 'water'),
                  _buildMealEntry(
                    recommendation: '',
                    image: const AssetImage('assets/images/water.jpg'),
                    icon: Icons.water_drop,
                    mealType: 'water',
                    onLogPressed: () => _showWaterLogDialog(context),
                  ),
                  _buildSectionHeader(Icons.wb_sunny, 'Breakfast', 'breakfast'),
                  _buildMealEntry(
                    recommendation: '',
                    image: const AssetImage('assets/images/breakfast.jpg'),
                    icon: Icons.free_breakfast,
                    mealType: 'breakfast',
                    onLogPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FoodRecognitionScreen2(mealType: 'breakfast'),
                        ),
                      );
                    },
                  ),
                  _buildSectionHeader(Icons.cloud, 'Lunch', 'lunch'),
                  _buildMealEntry(
                    recommendation: '',
                    image: const AssetImage('assets/images/lunch.jpg'),
                    icon: Icons.lunch_dining,
                    mealType: 'lunch',
                    onLogPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FoodRecognitionScreen2(mealType: 'lunch'),
                        ),
                      );
                    },
                  ),
                  _buildSectionHeader(
                    Icons.nightlight_round,
                    'Dinner',
                    'dinner',
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: const AssetImage('assets/images/dinner.jpg'),
                    icon: Icons.dinner_dining,
                    mealType: 'dinner',
                    onLogPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FoodRecognitionScreen2(mealType: 'dinner'),
                        ),
                      );
                    },
                  ),
                  _buildSectionHeader(Icons.timer, 'Snacks', 'snacks'),
                  _buildMealEntry(
                    recommendation: '',
                    image: const AssetImage('assets/images/snacks.jpg'),
                    icon: Icons.cookie,
                    mealType: 'snacks',
                    onLogPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  FoodRecognitionScreen2(mealType: 'snacks'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _NutrientItem(
    this.label,
    this.value,
    this.color,
    this.icon, {
    super.key,
  });

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

class WaterLogDialog extends StatefulWidget {
  const WaterLogDialog({super.key});

  @override
  _WaterLogDialogState createState() => _WaterLogDialogState();
}

class _WaterLogDialogState extends State<WaterLogDialog> {
  String _unit = 'glass';
  int _value = 1;
  final List<int> _glassValues = [1, 2, 3, 4, 5];
  final List<int> _mlValues = [250, 500, 750, 1000, 1250];

  void _switchUnit(String unit) {
    setState(() {
      if (unit == _unit) return;
      if (unit == 'glass') {
        _value = _glassValues[_mlValues.indexOf(_value) ~/ 250];
      } else {
        _value = _value * 250;
      }
      _unit = unit;
    });
  }

  void _incrementValue() {
    setState(() {
      final values = _unit == 'glass' ? _glassValues : _mlValues;
      final currentIndex = values.indexOf(_value);
      if (currentIndex < values.length - 1) {
        _value = values[currentIndex + 1];
      }
    });
  }

  void _decrementValue() {
    setState(() {
      final values = _unit == 'glass' ? _glassValues : _mlValues;
      final currentIndex = values.indexOf(_value);
      if (currentIndex > 0) {
        _value = values[currentIndex - 1];
      }
    });
  }

  void _logWater() {
    // Implement logging logic here
    print('Logged $_value $_unit of water');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu, color: Colors.grey),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.local_drink, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Water',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.blue),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '💧 Log the water you drink to keep track of your hydration. 1 glass is 250mL! Fill up, stay refreshed, and crush your hydration goals! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.blue),
                  onPressed: _decrementValue,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '$_value',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _unit,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.blue),
                  onPressed: _incrementValue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _switchUnit('glass'),
                  child: Text(
                    'glass',
                    style: TextStyle(
                      fontSize: 16,
                      color: _unit == 'glass' ? Colors.blue : Colors.grey,
                      decoration:
                          _unit == 'glass'
                              ? TextDecoration.underline
                              : TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => _switchUnit('mL'),
                  child: Text(
                    'mL',
                    style: TextStyle(
                      fontSize: 16,
                      color: _unit == 'mL' ? Colors.blue : Colors.grey,
                      decoration:
                          _unit == 'mL'
                              ? TextDecoration.underline
                              : TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _logWater,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '+ Log Water',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
