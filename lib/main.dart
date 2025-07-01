import 'package:diet_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:diet_app/providers/userprofile_provider.dart';
import 'package:diet_app/providers/progress_provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';
import 'package:diet_app/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite database (this happens automatically when UserDatabaseHelper is used)
  print("Using SQLite for local authentication");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // Add AuthProvider
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DietAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          selectedIconTheme: IconThemeData(color: Colors.green),
        ),
      ),
      home: WelcomeScreen(),
    );
  }
}
