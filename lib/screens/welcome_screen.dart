import '/screens/gender_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '/onboardingclass/onboardingclass.dart';
// import '/widgets/back_button_wrapper.dart';
import '/providers/progress_provider.dart';
import '/widgets/progress_bar.dart';
import 'package:diet_app/models/user_profile.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //progress provider

    // Reset progress when building this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final progressProvider = Provider.of<ProgressProvider>(
        context,
        listen: false,
      );
      // Reset progress to 0.1 on Welcome screen load
      progressProvider.setProgress(0.1);
    });
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top content with logo and text
            TopProgressBar(),
            // Small space between progress bar and logo
            SizedBox(height: 16),

            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  // CircleAvatar(
                  //   radius: 70,
                  //   backgroundImage: AssetImage(
                  //     'assets/images/app_logo.jpg',
                  //   ), // Make sure this is correctly loaded
                  // ),
                  Container(
                    width: 140,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/app_logo.jpg'),
                      ),
                    ),
                  ),

                  // Mid-size space between logo and welcome text
                  Spacer(flex: 2),
                  SizedBox(height: 30),

                  // Welcome Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          'Welcome to Your Smart\nNutrition Assistant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          '"🥗Personalized meals,\n⏲️real time tracking\nand\n ⏺️tailored recommendations for you!”',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom content with Get Started button and Sign in
            Spacer(),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GenderSelectionScreen(
                                    userProfile: UserProfile(),
                                  ),
                            ),
                          );
                          //                  // Handle get started
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            32,
                            164,
                            41,
                          ),

                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Already have an account? "),
                        GestureDetector(
                          onTap: () {
                            // Handle sign in
                          },
                          child: Text(
                            "Sign in",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
