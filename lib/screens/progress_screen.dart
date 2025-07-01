import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/fooditem_provider.dart';
import '../utils/progress_analyzer.dart';
import '../utils/nutrition_calculator.dart';
import '../models/food_item.dart';
import '../models/water_log.dart';
import '../db/user_database_helper.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isWeeklyView = true;
  String _selectedNutrient = 'calories';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  final List<String> _nutrients = [
    'calories',
    'protein',
    'carbs',
    'fats',
    'sugar',
    'fiber',
    'sodium',
    'saturatedFat',
    'water',
  ];

  final Map<String, String> _nutrientLabels = {
    'calories': 'Calories (kcal)',
    'protein': 'Protein (g)',
    'carbs': 'Carbs (g)',
    'fats': 'Fats (g)',
    'sugar': 'Sugar (g)',
    'fiber': 'Fiber (g)',
    'sodium': 'Sodium (mg)',
    'saturatedFat': 'Saturated Fat (g)',
    'water': 'Water (ml)',
  };

  final Map<String, Color> _nutrientColors = {
    'calories': Colors.red,
    'protein': Colors.blue,
    'carbs': Colors.green,
    'fats': Colors.orange,
    'sugar': Colors.purple,
    'fiber': Colors.brown,
    'sodium': Colors.teal,
    'saturatedFat': Colors.pink,
    'water': Colors.blue.shade400,
  };

  // Water tracking
  double waterGoal = 0; // will be calculated based on calorie goal
  Map<DateTime, double> waterData = {};

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final db = UserDatabaseHelper();
    final waterLogs = await db.getWaterLogsByDateRange(_startDate, _endDate);

    // Group water logs by date and sum the amounts
    Map<DateTime, double> newWaterData = {};
    for (var log in waterLogs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (newWaterData.containsKey(date)) {
        newWaterData[date] = newWaterData[date]! + log.amount;
      } else {
        newWaterData[date] = log.amount;
      }
    }

    setState(() {
      waterData = newWaterData;
    });
  }

  void _toggleView() {
    setState(() {
      _isWeeklyView = !_isWeeklyView;
      if (_isWeeklyView) {
        _startDate = DateTime.now().subtract(const Duration(days: 7));
      } else {
        _startDate = DateTime.now().subtract(const Duration(days: 30));
      }
      _endDate = DateTime.now();
    });
    _loadWaterData();
  }

  void _selectNutrient(String nutrient) {
    setState(() {
      _selectedNutrient = nutrient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isWeeklyView ? 'Weekly Progress' : 'Monthly Progress'),
        actions: [
          TextButton.icon(
            onPressed: _toggleView,
            icon: Icon(_isWeeklyView ? Icons.calendar_month : Icons.calendar_view_week),
            label: Text(_isWeeklyView ? 'Monthly' : 'Weekly'),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
      ),
      body: Consumer<FoodItemProvider>(
        builder: (context, foodItemProvider, child) {
          // Get food items for the selected date range
          List<FoodItem> foodItems = foodItemProvider.getFoodItemsForDateRange(_startDate, _endDate);

          if (foodItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_food, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No food data available for this period',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start logging your meals to see your progress',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Calculate nutrition data for charts
          List<Map<String, dynamic>> chartData;
          if (_selectedNutrient == 'water') {
            chartData = _getWaterDataForChart();
          } else {
            chartData = NutritionCalculator.getNutritionDataForChart(
              foodItems, 
              _selectedNutrient
            );
          }

          // Calculate average daily nutrition
          Map<String, double> avgNutrition = NutritionCalculator.calculateAverageDailyNutrition(foodItems);

          // Calculate water goal based on average calorie intake
          waterGoal = NutritionCalculator.calculateWaterIntake(avgNutrition['calories'] ?? 0);

          // Calculate macro percentages
          Map<String, double> macroPercentages = NutritionCalculator.calculateMacroPercentages(
            avgNutrition['protein'] ?? 0,
            avgNutrition['carbs'] ?? 0,
            avgNutrition['fats'] ?? 0,
          );

          // Get health insights
          List<HealthInsight> healthInsights = ProgressAnalyzer.analyzeWeeklyData(foodItems);

          // Calculate health score
          int healthScore = ProgressAnalyzer.calculateHealthScore(foodItems);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Health Score Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Health Score',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CircularPercentIndicator(
                          radius: 80.0,
                          lineWidth: 12.0,
                          percent: healthScore / 100,
                          center: Text(
                            '$healthScore',
                            style: const TextStyle(
                              fontSize: 36.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          progressColor: _getHealthScoreColor(healthScore),
                          backgroundColor: Colors.grey.shade200,
                          circularStrokeCap: CircularStrokeCap.round,
                          animation: true,
                          animationDuration: 1200,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _getHealthScoreMessage(healthScore),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Nutrition Chart
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nutrition Trends',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              value: _selectedNutrient,
                              onChanged: (value) {
                                if (value != null) {
                                  _selectNutrient(value);
                                }
                              },
                              items: _nutrients.map((nutrient) {
                                return DropdownMenuItem<String>(
                                  value: nutrient,
                                  child: Text(_nutrientLabels[nutrient] ?? nutrient),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: chartData.isEmpty
                              ? const Center(child: Text('No data available for chart'))
                              : LineChart(
                                  _createLineChartData(chartData),
                                ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Daily ${_nutrientLabels[_selectedNutrient]} over time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Macronutrient Distribution
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Macronutrient Distribution',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMacroProgressBar(
                          'Protein', 
                          macroPercentages['protein'] ?? 0, 
                          Colors.blue,
                          avgNutrition['protein'] ?? 0,
                        ),
                        const SizedBox(height: 8),
                        _buildMacroProgressBar(
                          'Carbs', 
                          macroPercentages['carbs'] ?? 0, 
                          Colors.green,
                          avgNutrition['carbs'] ?? 0,
                        ),
                        const SizedBox(height: 8),
                        _buildMacroProgressBar(
                          'Fats', 
                          macroPercentages['fats'] ?? 0, 
                          Colors.orange,
                          avgNutrition['fats'] ?? 0,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Daily Average Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Average (${_isWeeklyView ? 'Weekly' : 'Monthly'})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildNutrientRow('Calories', avgNutrition['calories']?.toStringAsFixed(1) ?? '0', 'kcal'),
                        _buildNutrientRow('Protein', avgNutrition['protein']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Carbs', avgNutrition['carbs']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Fats', avgNutrition['fats']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Sugar', avgNutrition['sugar']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Fiber', avgNutrition['fiber']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Sodium', avgNutrition['sodium']?.toStringAsFixed(1) ?? '0', 'mg'),
                        _buildNutrientRow('Saturated Fat', avgNutrition['saturatedFat']?.toStringAsFixed(1) ?? '0', 'g'),
                        _buildNutrientRow('Water', _calculateAverageWaterIntake().toStringAsFixed(1), 'ml'),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Health Insights
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Health Insights & Recommendations',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...healthInsights.map((insight) => _buildInsightCard(insight)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMacroProgressBar(String label, double percentage, Color color, double grams) {
    // Ensure percentage is a valid number
    final displayPercentage = percentage.isNaN ? 0.0 : percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('${displayPercentage.toStringAsFixed(1)}% (${grams.toStringAsFixed(1)}g)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearPercentIndicator(
          lineHeight: 16.0,
          percent: (displayPercentage / 100).clamp(0.0, 1.0),
          backgroundColor: Colors.grey.shade200,
          progressColor: color,
          animation: true,
          animationDuration: 1000,
          barRadius: const Radius.circular(8),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInsightCard(HealthInsight insight) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: insight.severityColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: insight.severityColor.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(insight.severityIcon, color: insight.severityColor),
                const SizedBox(width: 8),
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: insight.severityColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(insight.description),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight.recommendation,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _createLineChartData(List<Map<String, dynamic>> data) {
    List<FlSpot> spots = [];

    // Create spots for the line chart
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]['value'].toDouble()));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _getYAxisInterval(data),
        verticalInterval: 1,
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < data.length) {
                final date = data[value.toInt()]['date'] as DateTime;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _getYAxisInterval(data),
            reservedSize: 42,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: data.length - 1.0,
      minY: 0,
      maxY: _getMaxY(data),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: _nutrientColors[_selectedNutrient] ?? Colors.blue,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: _nutrientColors[_selectedNutrient] ?? Colors.blue,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: false,
            color: (_nutrientColors[_selectedNutrient] ?? Colors.blue).withOpacity(0.2),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          // backgroundColor: (_nutrientColors[_selectedNutrient] ?? Colors.blue).withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.x.toInt();
              if (index >= 0 && index < data.length) {
                final value = data[index]['value'];
                final date = data[index]['date'] as DateTime;
                return LineTooltipItem(
                  '${DateFormat('MM/dd').format(date)}: ${value.toStringAsFixed(1)}',
                  const TextStyle(color: Colors.white),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  double _getMaxY(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 100;
    double maxValue = 0;
    for (var point in data) {
      if (point['value'] > maxValue) {
        maxValue = point['value'];
      }
    }
    return maxValue * 1.2; // Add 20% padding
  }

  double _getYAxisInterval(List<Map<String, dynamic>> data) {
    double maxY = _getMaxY(data);
    if (maxY <= 50) return 10;
    if (maxY <= 100) return 20;
    if (maxY <= 500) return 100;
    if (maxY <= 1000) return 200;
    return 500;
  }

  Color _getHealthScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.lightGreen;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getHealthScoreMessage(int score) {
    if (score >= 80) {
      return 'Excellent! Your diet is well-balanced and nutritious.';
    } else if (score >= 60) {
      return 'Good job! Your diet is generally healthy with some room for improvement.';
    } else if (score >= 40) {
      return 'Your diet needs attention. Check the insights below for recommendations.';
    } else {
      return 'Your diet requires significant improvement. Review the insights and recommendations below.';
    }
  }

  List<Map<String, dynamic>> _getWaterDataForChart() {
    List<Map<String, dynamic>> result = [];

    // Generate a list of dates in the range
    final int daysDifference = _endDate.difference(_startDate).inDays + 1;
    for (int i = 0; i < daysDifference; i++) {
      final date = _startDate.add(Duration(days: i));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Get water intake for this date, or 0 if not available
      final waterAmount = waterData[dateKey] ?? 0.0;

      result.add({
        'date': dateKey,
        'value': waterAmount,
      });
    }

    return result;
  }

  double _calculateAverageWaterIntake() {
    if (waterData.isEmpty) return 0;

    double totalWater = 0;
    for (var amount in waterData.values) {
      totalWater += amount;
    }

    // Calculate based on the total number of days in the date range
    final int daysDifference = _endDate.difference(_startDate).inDays + 1;
    return totalWater / daysDifference;
  }
}
