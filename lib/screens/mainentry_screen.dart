import 'package:flutter/material.dart';
import 'package:diet_app/screens/profile_screen.dart';
import 'tracker_screen.dart';
import 'logging_screen.dart';
import 'mealplan_screen.dart';
import 'connect_screen.dart';

class MainEntryScreen extends StatefulWidget {
  @override
  _MainEntryScreenState createState() => _MainEntryScreenState();
}

class _MainEntryScreenState extends State<MainEntryScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    TrackerScreen(),
    LoggingScreen(),
    MealPlanScreen(),
    ConnectScreen(),
  ];

  void _onItemTapped(int index) {
    if (index < 2) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index > 2) {
      setState(() {
        _selectedIndex = index - 1;
      });
    }
  }

  void _onFabPressed() {
    print("FAB pressed!");
  }

  String _getTimeBasedGreeting() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour < 12) {
      return 'Good Morning☀️, User!';
    } else if (hour < 18) {
      return 'Good Afternoon☀️, User!';
    } else {
      return 'Good Evening🌙, User!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    // Determine if current screen is ConnectScreen (last screen in _screens)
    final isOnConnectScreen = _selectedIndex == 3;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTimeBasedGreeting(),
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
              backgroundColor: Colors.green,
              backgroundImage: const AssetImage('assets/images/profile.jpg'),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < 2 ? _selectedIndex : _selectedIndex + 1,
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
          BottomNavigationBarItem(icon: SizedBox.shrink(), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.apple), label: 'Meal plan'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Connect',
          ),
        ],
      ),
      floatingActionButton:
          isOnConnectScreen && isKeyboardVisible
              ? null
              : FloatingActionButton(
                onPressed: _onFabPressed,
                backgroundColor: Colors.green,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
