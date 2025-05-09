import 'package:diet_app/screens/mainentry_screen.dart';
import 'package:diet_app/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/userprofile_provider.dart';
import 'providers/progress_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressProvider()),

        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
      ],

      child: MyApp(),
    ),
  );
}

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'DietAI',
//       theme: ThemeData(primarySwatch: Colors.green),
//       home: WelcomeScreen(),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DietAI',
      theme: ThemeData(
        // primarySwatch: Colors.green,
        // colorScheme: ColorScheme.fromSwatch(
        //   primarySwatch: Colors.green,
        // ).copyWith(
        //   secondary: Colors.green, // Ensure accent color is green
        // ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor:
              Colors.green, // Selected icon and label color (green)
          selectedIconTheme: const IconThemeData(color: Colors.green),
          // Unselected colors are omitted to use Flutter's default
        ),
      ),
      home: WelcomeScreen(), // Using MainEntryScreen to test the UI
    );
  }
}
