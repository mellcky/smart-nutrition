import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  Widget _buildDailyTotal() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNutrientItem('Calories', '0kcal', Colors.red, Icons.whatshot),
          _buildNutrientItem(
            'Protein',
            '0g',
            Colors.blue,
            Icons.restaurant_menu,
          ),
          _buildNutrientItem('Fat', '0g', Colors.orange, Icons.water_drop),
          _buildNutrientItem('Carbs', '0g', Colors.green, Icons.eco),
        ],
      ),
    );
  }

  Widget _buildNutrientItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
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
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealEntry({
    required String recommendation,
    required ImageProvider image,
    required VoidCallback onLogPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Dynamic circular image
              CircleAvatar(
                radius: 24,
                backgroundImage: image,
                backgroundColor: Colors.grey.shade300,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Recommended: $recommendation',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Log Food")),
      body: Column(
        children: [
          // const SizedBox(height: 10),
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
          // Placeholder for food logging content
          // hamburger icon and "Daily Total" text
          Padding(
            padding: EdgeInsets.only(left: 16.0), // Adjust the value as needed
            child: Row(
              children: [
                Icon(Icons.menu), // Hamburger icon
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
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ), // Adjust the value as needed
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_drink,
                          color: Colors.grey,
                        ), // Hamburger icon
                        SizedBox(width: 8),
                        Text('Water', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: AssetImage(
                      'assets/images/water.jpg',
                    ), // or NetworkImage(...)
                    onLogPressed: () {
                      // Your logic here
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ), // Adjust the value as needed
                    child: Row(
                      children: [
                        Icon(Icons.wb_sunny, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Breakfast', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: AssetImage(
                      'assets/images/breakfast.jpg',
                    ), // or NetworkImage(...)
                    onLogPressed: () {
                      // Your logic here
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ), // Adjust the value as needed
                    child: Row(
                      children: [
                        Icon(Icons.cloud, color: Colors.grey), // Hamburger icon
                        SizedBox(width: 8),
                        Text('Lunch', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: AssetImage(
                      'assets/images/lunch.jpg',
                    ), // or NetworkImage(...)
                    onLogPressed: () {
                      // Your logic here
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ), // Adjust the value as needed
                    child: Row(
                      children: [
                        Icon(
                          Icons.nightlight_round,
                          color: Colors.grey,
                        ), // Hamburger icon
                        SizedBox(width: 8),
                        Text('Dinner', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: AssetImage(
                      'assets/images/dinner.jpg',
                    ), // or NetworkImage(...)
                    onLogPressed: () {
                      // Your logic here
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.0,
                    ), // Adjust the value as needed
                    child: Row(
                      children: [
                        Icon(Icons.timer, color: Colors.grey), // Hamburger icon
                        SizedBox(width: 8),
                        Text('Snacks', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                  _buildMealEntry(
                    recommendation: '',
                    image: AssetImage(
                      'assets/images/snacks.jpg',
                    ), // or NetworkImage(...)
                    onLogPressed: () {
                      // Your logic here
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

// New widget to display daily nutritional totals
