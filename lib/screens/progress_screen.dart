import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[100], // Removed as per your code
      appBar: AppBar(
        // backgroundColor: Colors.white, // Commented out as per your code
        elevation: 0,
        toolbarHeight: 0, // Added as per your code
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blueAccent,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(),
          tabs: const [Tab(text: "Insights"), Tab(text: "Alerts")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [InsightsTab(), AlertsTab()],
      ),
    );
  }
}

class InsightsTab extends StatefulWidget {
  const InsightsTab({super.key});

  @override
  State<InsightsTab> createState() => _InsightsTabState();
}

class _InsightsTabState extends State<InsightsTab> {
  bool isWeekly = true;

  Widget _buildInsightCard(String title, Widget child) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(height: 200, child: child),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isWeekly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isWeekly ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Daily",
                    style: GoogleFonts.poppins(
                      color: !isWeekly ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isWeekly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isWeekly ? Colors.blueAccent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Weekly",
                    style: GoogleFonts.poppins(
                      color: isWeekly ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        _buildSegmentedControl(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildInsightCard(
                "Macronutrient Distribution",
                MacroPieChart(isWeekly: isWeekly),
              ),
              _buildInsightCard(
                "Micronutrient Levels",
                MicroRadarChart(isWeekly: isWeekly),
              ),
              _buildInsightCard(
                "Hydration Tracker",
                HydrationLineChart(isWeekly: isWeekly),
              ),
              _buildInsightCard(
                "Total Calories",
                TotalCaloriesCircular(isWeekly: isWeekly),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AlertsTab extends StatelessWidget {
  const AlertsTab({super.key});

  Widget _buildAlertCard({required String description, required Color color}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2, end: 0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAlertCard(
          description:
              "High sodium intake detected this week. Consider reducing salt.",
          color: Colors.redAccent,
        ),
        _buildAlertCard(
          description: "Your hydration level was below average on 3 days.",
          color: Colors.orange,
        ),
        _buildAlertCard(
          description: "Balanced macronutrient intake maintained daily!",
          color: Colors.green,
        ),
      ],
    );
  }
}

// ----------- Chart Widgets ------------

class MacroPieChart extends StatelessWidget {
  final bool isWeekly;
  const MacroPieChart({super.key, required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final carbs = isWeekly ? 40.0 : 35.0;
    final fats = isWeekly ? 30.0 : 25.0;
    final proteins = isWeekly ? 30.0 : 40.0;
    final total = carbs + fats + proteins;

    final carbsPercentage = ((carbs / total) * 100).toStringAsFixed(1);
    final fatsPercentage = ((fats / total) * 100).toStringAsFixed(1);
    final proteinsPercentage = ((proteins / total) * 100).toStringAsFixed(1);

    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            value: carbs,
            color: Colors.orangeAccent,
            title: "Carbs: $carbsPercentage%",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          PieChartSectionData(
            value: fats,
            color: Colors.greenAccent,
            title: "Fats: $fatsPercentage%",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          PieChartSectionData(
            value: proteins,
            color: Colors.blueAccent,
            title: "Proteins: $proteinsPercentage%",
            radius: 60,
            titleStyle: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack);
  }
}

class MicroRadarChart extends StatelessWidget {
  final bool isWeekly;
  const MicroRadarChart({super.key, required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final dailyData = [7.0, 5.0, 6.0, 4.0, 8.0];
    final weeklyData = [40.0, 35.0, 38.0, 30.0, 42.0];
    final data = isWeekly ? weeklyData : dailyData;
    final maxValue = (isWeekly ? weeklyData : dailyData).reduce(
      (a, b) => a > b ? a : b,
    );

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            fillColor: Colors.teal.withOpacity(0.2),
            borderColor: Colors.teal,
            entryRadius: 2,
            dataEntries:
                data
                    .asMap()
                    .entries
                    .map((e) => RadarEntry(value: e.value))
                    .toList(),
          ),
        ],
        tickCount: 5,
        ticksTextStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.black87,
        ),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, _) {
          const labels = ["Iron", "Zinc", "Mg", "Ca", "K"];
          return RadarChartTitle(text: labels[index], angle: 0);
        },
        radarBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      swapAnimationDuration: const Duration(milliseconds: 400),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class HydrationLineChart extends StatelessWidget {
  final bool isWeekly;
  const HydrationLineChart({super.key, required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final daily = [2.0, 2.5, 1.8, 3.0, 2.2, 2.9, 2.0];
    final weekly = [14.0];
    final data = isWeekly ? weekly : daily;

    return LineChart(
      LineChartData(
        maxY: isWeekly ? 20 : 3.5,
        minY: 0,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (isWeekly) {
                  return Text(
                    "This Week",
                    style: GoogleFonts.poppins(fontSize: 10),
                  );
                }
                const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                return Text(
                  value.toInt() < days.length ? days[value.toInt()] : "",
                  style: GoogleFonts.poppins(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget:
                  (value, meta) => Text(
                    value.toStringAsFixed(1),
                    style: GoogleFonts.poppins(fontSize: 10),
                  ),
            ),
          ),
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
        ),
        lineBarsData: [
          LineChartBarData(
            spots:
                isWeekly
                    ? [const FlSpot(0, 14.0)]
                    : daily
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value))
                        .toList(),
            isCurved: true,
            color: Colors.blueAccent,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blueAccent.withOpacity(0.1),
            ),
          ),
        ],
        borderData: FlBorderData(show: false),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class TotalCaloriesCircular extends StatelessWidget {
  final bool isWeekly;
  const TotalCaloriesCircular({super.key, required this.isWeekly});

  @override
  Widget build(BuildContext context) {
    final dailyCalories = [1800, 2000, 2200, 2100, 1900, 2500, 2300];
    final weeklyCalories = [13000];
    final data = isWeekly ? weeklyCalories : dailyCalories;
    final maxCalories = isWeekly ? 14000.0 : 2500.0;
    final currentCalories =
        isWeekly
            ? data[0].toDouble()
            : (data.reduce((a, b) => a + b) / data.length).toDouble();

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: CircularProgressIndicator(
              value: currentCalories / maxCalories,
              strokeWidth: 12,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                currentCalories < (isWeekly ? 12000 : 2000)
                    ? Colors.redAccent
                    : Colors.greenAccent,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentCalories.toInt().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                "kcal",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.easeOut);
  }
}
