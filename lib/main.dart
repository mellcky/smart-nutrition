// import 'package:diet_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'package:showcaseview/showcaseview.dart';

import 'package:diet_app/screens/mainentry_screen.dart';
import 'package:diet_app/providers/userprofile_provider.dart';
import 'package:diet_app/providers/progress_provider.dart';
import 'package:diet_app/providers/fooditem_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => FoodItemProvider()),
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
      home: MainEntryScreen(),
    );
  }
}
