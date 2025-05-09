import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:percent_indicator/percent_indicator.dart';

class TrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalorieProgress(),
            SizedBox(height: 5),

            _buildMetricSection(
              'Heart Health',
              Icons.favorite,
              Colors.redAccent,
              [
                {'label': 'Cholesterol', 'value': '170 mg'},
                {'label': 'Omega-3', 'value': '1.5 g'},
                {'label': 'Fiber', 'value': '24 g'},
                {'label': 'Water', 'value': '7/8 cups'},
              ],
            ),
            SizedBox(height: 16),
            _buildMetricSection(
              'Controlled Consumption',
              Icons.block,
              Colors.black,
              [
                {'label': 'Sugar', 'value': '44 g'},
                {'label': 'Trans Fat', 'value': '1 g'},
                {'label': 'Caffeine', 'value': '260 mg'},
              ],
            ),
            SizedBox(height: 16),
            _buildMetricSection(
              'key Vitamins',
              Icons.medication,
              Colors.redAccent,
              [
                {'label': 'Vitamin D', 'value': '3.2 µg'},
                {'label': 'Vitamin B12', 'value': '5.4 µg'},
                {'label': 'Vitamin C', 'value': '68 mg'},
                {'label': 'Vitamin B9', 'value': '320 µg'},
              ],
            ),
            SizedBox(height: 16),
            _buildMetricSection(
              'Vital Minerals',
              Icons.fitness_center,
              Colors.teal,
              [
                {'label': 'Iron', 'value': '11 mg'},
                {'label': 'Potassium', 'value': '3,400 mg'},
                {'label': 'Zinc', 'value': '9 mg'},
                {'label': 'Calcium', 'value': '950 mg'},
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieProgress() {
    return Center(
      // This centers the circular indicator in its parent
      child: CircularPercentIndicator(
        radius: 90,
        lineWidth: 16,
        percent: 1850 / 2200,
        progressColor: Colors.green,
        backgroundColor: Colors.green.shade100,
        circularStrokeCap: CircularStrokeCap.round,
        center: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min, // Keeps the column tight to its content
          children: [
            Text(
              '1,850',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'of 2,200 kcal',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSection(
    String title,
    IconData icon,
    Color iconColor,
    List<Map<String, String>> metrics,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children:
                metrics
                    .map(
                      (metric) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              metric['label']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              metric['value']!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
      ],
    );
  }
}
