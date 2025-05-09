import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealPlanScreen extends StatefulWidget {
  @override
  _MealPlanScreenState createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  bool isWeeklyView = false;
  DateTime today = DateTime.now();

  // Initialize the start of the current week (Monday)
  late DateTime weekStart = today.subtract(Duration(days: today.weekday - 1));

  void shiftWeek(int offset) {
    setState(() {
      weekStart = weekStart.add(Duration(days: offset * 7));
    });
  }

  List<DateTime> getCurrentWeekDates() {
    return List.generate(7, (index) => weekStart.add(Duration(days: index)));
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = getCurrentWeekDates();

    return Scaffold(
      // appBar: AppBar(title: Text("Meal Plan")),
      body: Column(
        children: [
          // Toggle Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isWeeklyView = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            !isWeeklyView ? Colors.grey.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 18),
                            SizedBox(width: 8),
                            Text("Daily Plan"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => isWeeklyView = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color:
                            isWeeklyView ? Colors.grey.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.view_list, size: 18),
                            SizedBox(width: 8),
                            Text("Weekly Plan"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Fixed width day display with today highlighted
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children:
                  weekDates.map((date) {
                    bool isToday =
                        DateFormat('yyyy-MM-dd').format(date) ==
                        DateFormat('yyyy-MM-dd').format(today);

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.symmetric(vertical: 10),
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
                              DateFormat('EEE').format(date), // Mon, Tue, ...
                              style: TextStyle(
                                color: isToday ? Colors.blue : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
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
                    );
                  }).toList(),
            ),
          ),

          // Placeholder for meal plan content
          Expanded(
            child: Center(
              child: Text(
                isWeeklyView
                    ? "Weekly Meal Plan Content"
                    : "Daily Meal Plan Content",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
