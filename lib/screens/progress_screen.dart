import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/fooditem_provider.dart';
import '../utils/progress_analyzer.dart';
import '../widgets/charts/health_score_gauge.dart';
import '../widgets/charts/nutrition_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  TimePeriod _timePeriod = TimePeriod.weekly;
  String _selectedMetric = 'calories';
  final List<String> _metrics = [
    'calories',
    'protein',
    'carbs',
    'fats',
    'sugar',
    'sodium',
    'saturatedFat',
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FoodItemProvider>(context);
    final data = NutritionDataAggregator.aggregateData(provider, _timePeriod);

    // Get items for the current period (7 days for weekly, 30 for monthly)
    final periodItems = provider.getFoodItemsForDateRange(
      _timePeriod == TimePeriod.weekly
          ? DateTime.now().subtract(const Duration(days: 7))
          : DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    final insights = HealthRiskAnalyzer.analyzeRisks(periodItems);
    final healthScore = HealthRiskAnalyzer.calculateHealthScore(periodItems);

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Nutrition Progress'),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.info_outline),
      //       onPressed: () => _showHealthStandards(context),
      //     ),
      //   ],
      // ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Period Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text('Weekly'),
                        selected: _timePeriod == TimePeriod.weekly,
                        onSelected:
                            (_) =>
                                setState(() => _timePeriod = TimePeriod.weekly),
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color:
                              _timePeriod == TimePeriod.weekly
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ChoiceChip(
                        label: const Text('Monthly'),
                        selected: _timePeriod == TimePeriod.monthly,
                        onSelected:
                            (_) => setState(
                              () => _timePeriod = TimePeriod.monthly,
                            ),
                        selectedColor: Theme.of(context).primaryColor,
                        labelStyle: TextStyle(
                          color:
                              _timePeriod == TimePeriod.monthly
                                  ? Colors.white
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),

                  // const SizedBox(height: 1),

                  // Health Score
                  Center(
                    child: Column(
                      children: [
                        HealthScoreGauge(score: healthScore),
                        const SizedBox(height: 8),
                        Text(
                          healthScore > 8
                              ? 'Excellent! 🎉'
                              : healthScore > 6
                              ? 'Good Job! 👍'
                              : 'Needs Improvement 💪',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Metric Selector
                  Text(
                    'Select Metric:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _metrics.map((metric) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                  metric == 'saturatedFat'
                                      ? 'Sat. Fat'
                                      : metric,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        _selectedMetric == metric
                                            ? Colors.white
                                            : Theme.of(
                                              context,
                                            ).colorScheme.onBackground,
                                  ),
                                ),
                                selected: _selectedMetric == metric,
                                onSelected:
                                    (_) => setState(
                                      () => _selectedMetric = metric,
                                    ),
                                selectedColor: Theme.of(context).primaryColor,
                                backgroundColor: Colors.grey[200],
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chart Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nutrition Trends',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Chart
                  SizedBox(
                    height: 300,
                    child: NutritionChart(
                      data: data,
                      selectedMetric: _selectedMetric,
                      period: _timePeriod,
                      onBarTapped: (date) {
                        _showDailyDetails(context, provider, date);
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Health Insights
                  Text(
                    'Health Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ListView(
                      shrinkWrap: true,
                      children:
                          insights
                              .map(
                                (insight) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: _getInsightColor(
                                            insight,
                                          ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getInsightIcon(insight),
                                          size: 20,
                                          color: _getInsightColor(insight),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          insight,
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                  ),

                  // Add bottom padding for iOS safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getInsightColor(String insight) {
    if (insight.contains('⚠️') || insight.contains('may increase'))
      return Colors.orange;
    if (insight.contains('🧂') || insight.contains('High sodium'))
      return Colors.red;
    if (insight.contains('🍔') || insight.contains('saturated fat'))
      return Colors.deepOrange;
    return Colors.green;
  }

  IconData _getInsightIcon(String insight) {
    if (insight.contains('⚠️') || insight.contains('may increase'))
      return Icons.warning;
    if (insight.contains('🧂') || insight.contains('High sodium'))
      return Icons.bloodtype;
    if (insight.contains('🍔') || insight.contains('saturated fat'))
      return Icons.fastfood;
    return Icons.check_circle;
  }

  void _showDailyDetails(
    BuildContext context,
    FoodItemProvider provider,
    DateTime date,
  ) {
    final items = provider.getFoodItemsForDate(date);
    final dateFormatted = DateFormat.yMMMMd().format(date);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(dateFormatted),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No food logged this day'),
                  )
                else
                  ...items
                      .map(
                        (item) => ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getMealIcon(item.mealType),
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            item.foodItem,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${item.calories.toStringAsFixed(0)} kcal',
                          ),
                          trailing: Text(
                            item.mealType,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                const SizedBox(height: 16),
                if (items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daily Total:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${provider.getTotalCalories(date).toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie;
      default:
        return Icons.restaurant;
    }
  }

  void _showHealthStandards(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Health Standards'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStandardRow('Sugar', '≤36g/day', Colors.pink),
                _buildStandardRow('Sodium', '≤2300mg/day', Colors.blueGrey),
                _buildStandardRow(
                  'Saturated Fat',
                  '≤22g/day',
                  Colors.deepOrange,
                ),
                _buildStandardRow('Protein', '50-175g/day', Colors.blue),
                const SizedBox(height: 16),
                Text(
                  'Based on WHO recommendations for average adults',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildStandardRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
