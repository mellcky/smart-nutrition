import 'dart:async';
import 'package:flutter/material.dart';

/// Unified food database with nutrition data and aliases
final Map<String, Map<String, dynamic>> foodDatabase = {
  'banana': {
    'aliases': {'bananas'},
    'calories': 90,
    'protein': 1.1,
    'carbs': 23,
    'fat': 0.3,
  },
  'egg': {
    'aliases': {'eggs'},
    'calories': 70,
    'protein': 6.0,
    'carbs': 0.6,
    'fat': 5.0,
  },
  'apple juice': {
    'aliases': {'apples juice', 'apple juices'},
    'calories': 120,
    'protein': 0.1,
    'carbs': 28,
    'fat': 0.1,
  },
  'bread': {
    'aliases': {'breads'},
    'calories': 80,
    'protein': 3.0,
    'carbs': 15,
    'fat': 1.0,
  },
};

/// Precomputed regex pattern for efficient extraction
final RegExp _foodExtractionRegex = _createFoodExtractionRegex();

RegExp _createFoodExtractionRegex() {
  // Create pattern with all canonical names and aliases
  final allTerms =
      foodDatabase.entries
          .expand(
            (entry) => [
              entry.key,
              ...entry.value['aliases'] as Iterable<String>,
            ],
          )
          .toSet()
          .toList();

  // Sort by length descending to prioritize longer matches
  allTerms.sort((a, b) => b.length.compareTo(a.length));

  final pattern = allTerms.map((term) => RegExp.escape(term)).join('|');

  return RegExp(
    r'(\b\d+\b)\s*(' + pattern + r')\b|\b(' + pattern + r')\b',
    caseSensitive: false,
  );
}

/// Extract food items in single regex pass
List<Map<String, dynamic>> extractFoodItems(String input) {
  final matches = _foodExtractionRegex.allMatches(input);
  final extracted = <Map<String, dynamic>>[];
  final usedPositions = <int, int>{};

  for (final match in matches) {
    final start = match.start;
    final end = match.end;

    // Check for overlapping matches
    bool isOverlapping = false;
    for (final pos in usedPositions.entries) {
      if (start < pos.value && end > pos.key) {
        isOverlapping = true;
        break;
      }
    }
    if (isOverlapping) continue;

    int quantity = 1;
    String? rawName;

    if (match.group(1) != null) {
      quantity = int.parse(match.group(1)!);
      rawName = match.group(2);
    } else if (match.group(3) != null) {
      rawName = match.group(3);
    }

    if (rawName != null) {
      // Find canonical name
      String? canonical;
      for (final key in foodDatabase.keys) {
        final aliases = foodDatabase[key]!['aliases'] as Set<String>;
        if (key == rawName || aliases.contains(rawName)) {
          canonical = key;
          break;
        }
      }

      if (canonical != null) {
        extracted.add({'name': canonical, 'quantity': quantity});
        usedPositions[start] = end;
      }
    }
  }

  return extracted;
}

/// Get multiplied nutrition data
Map<String, dynamic> getMultipliedNutrition(String foodName, int quantity) {
  final data = foodDatabase[foodName]!;
  return {
    'name': foodName,
    'quantity': quantity,
    'total_calories': (data['calories'] * quantity).toDouble(),
    'total_protein': (data['protein'] * quantity).toDouble(),
    'total_carbs': (data['carbs'] * quantity).toDouble(),
    'total_fat': (data['fat'] * quantity).toDouble(),
  };
}

class FoodInputScreen extends StatefulWidget {
  const FoodInputScreen({super.key});

  @override
  _FoodInputScreenState createState() => _FoodInputScreenState();
}

class _FoodInputScreenState extends State<FoodInputScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _analyzeAndFetch();
    });
  }

  void _analyzeAndFetch() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      setState(() {
        _results = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    Future.microtask(() {
      try {
        final detectedFoods = extractFoodItems(text);
        final enriched =
            detectedFoods
                .map(
                  (item) =>
                      getMultipliedNutrition(item['name'], item['quantity']),
                )
                .toList();

        setState(() {
          _results = enriched;
          _loading = false;
        });
      } catch (e) {
        print('Error processing: $e');
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Your Meal'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              setState(() => _results = []);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Food input section
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Describe your meal',
                hintText: 'e.g. 2 eggs, 1 banana, apple juice',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fastfood),
                suffixIcon:
                    _controller.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _results = []);
                          },
                        )
                        : null,
              ),
            ),
            SizedBox(height: 16),

            // Nutrition analysis section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Nutrition Analysis',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _loading
                            ? Center(child: CircularProgressIndicator())
                            : _results.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.food_bank,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    _controller.text.isEmpty
                                        ? 'Start typing your meal to see nutrition info\n\nExamples:\n• "2 eggs and 1 banana"\n• "apple juice and bread"'
                                        : 'No foods detected. Try:\n• "2 eggs"\n• "banana"',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, i) {
                                final item = _results[i];
                                return NutritionCard(item: item);
                              },
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
}

/// Reusable nutrition card widget
class NutritionCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const NutritionCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item['quantity']}x',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item['name'].toString().toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutrientColumn(
                    'Calories',
                    item['total_calories'],
                    Colors.orange,
                  ),
                  VerticalDivider(width: 1, thickness: 1.5),
                  _buildNutrientColumn(
                    'Protein',
                    item['total_protein'],
                    Colors.green,
                    unit: 'g',
                  ),
                  VerticalDivider(width: 1, thickness: 1.5),
                  _buildNutrientColumn(
                    'Carbs',
                    item['total_carbs'],
                    Colors.blue,
                    unit: 'g',
                  ),
                  VerticalDivider(width: 1, thickness: 1.5),
                  _buildNutrientColumn(
                    'Fat',
                    item['total_fat'],
                    Colors.amber,
                    unit: 'g',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientColumn(
    String label,
    dynamic value,
    Color color, {
    String unit = '',
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value is double ? '${value.toStringAsFixed(1)}$unit' : '$value$unit',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}
