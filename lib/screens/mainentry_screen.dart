import 'package:diet_app/screens/progress_screen.dart';
import 'package:flutter/material.dart';
import 'package:diet_app/screens/profile_screen.dart';
import 'tracker_screen.dart';
import 'logging_screen.dart';
import 'mealplan_screen.dart';
import 'connect_screen.dart';
import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

class MainEntryScreen extends StatefulWidget {
  const MainEntryScreen({super.key});
  @override
  State<MainEntryScreen> createState() => _MainEntryScreenState();
}

class _MainEntryScreenState extends State<MainEntryScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TrackerScreen(),
    LoggingScreen(),
    ProgressScreen(), // New screen added here
    MealPlanScreen(),
    ConnectScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getTimeBasedGreeting(String name) {
    final now = DateTime.now();
    final hour = now.hour;

    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning☀️';
    } else if (hour < 18) {
      greeting = 'Good Afternoon☀️';
    } else {
      greeting = 'Good Evening🌙';
    }

    return '$greeting, $name!';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProfileProvider>(context);
    final name = userProvider.name ?? 'User';
    final greeting = _getTimeBasedGreeting(name);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        
        title: Text(
          greeting,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              );
            },
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ),
        // backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Logging',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.apple), label: 'Meal plan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Connect',
          ),
        ],
      ),
    );
  }
}
