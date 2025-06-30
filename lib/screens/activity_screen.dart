import 'package:diet_app/screens/restrictions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/providers/userprofile_provider.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  ActivityLevelScreenState createState() => ActivityLevelScreenState();
}

class ActivityLevelScreenState extends State<ActivityLevelScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: ActivityLevelContent()),
    );
  }
}

class ActivityLevelContent extends StatefulWidget {
  const ActivityLevelContent({super.key});

  @override
  State<ActivityLevelContent> createState() => _ActivityLevelContentState();
}

class _ActivityLevelContentState extends State<ActivityLevelContent> with SingleTickerProviderStateMixin {
  String? _selectedActivityLevel;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with animations
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            );
          },
          child: Column(
            children: [
              // Progress indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: LinearProgressIndicator(
                  value: 0.67, // 3/4 of the onboarding process
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // App logo/icon with gradient - smaller size
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade300,
                        Colors.green.shade600,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.shade100,
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.directions_run,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Title with improved styling
              Text(
                "Activity Level",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                "How active are you?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),

              // Activity options with improved styling - more compact
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActivityOption(
                      title: "Sedentary 🧘",
                      description: "Little to no exercise. Spend most of the day seated.",
                    ),
                    _buildActivityOption(
                      title: "Lightly Active 🚶",
                      description:
                          "Light exercise for 30 minutes per day, 3 to 5 times a week.",
                    ),
                    _buildActivityOption(
                      title: "Moderately Active 🏃",
                      description:
                          "Moderate exercise for 1 hour per day, 3 to 5 times a week.",
                    ),
                    _buildActivityOption(
                      title: "Very Active 🏋️",
                      description:
                          "Intense exercise for 1 hour per day, 5 to 7 times a week.",
                    ),
                    _buildActivityOption(
                      title: "Super Active 💪",
                      description: "Intense exercise for at least 2 hours every day.",
                    ),
                  ],
                ),
              ),

              // Spacer to push button to bottom
              const Spacer(),

              // Enhanced continue button
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedActivityLevel != null) {
                      // Add haptic feedback
                      HapticFeedback.mediumImpact();

                      Provider.of<UserProfileProvider>(
                        context,
                        listen: false,
                      ).updateActivityLevel(_selectedActivityLevel!);

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => 
                            const RestrictionsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(1.0, 0.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutQuart;

                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select an activity level."),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.shade200,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Positioned Back Arrow with improved styling
        Positioned(
          top: 20,
          left: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.green.shade700, size: 20),
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityOption({
    required String title,
    required String description,
  }) {
    final activityValue = title.split(" ")[0];
    final bool isSelected = _selectedActivityLevel == activityValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green.shade400 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.shade100.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: RadioListTile<String>(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade800,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              color: isSelected ? Colors.green.shade600 : Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          value: activityValue,
          groupValue: _selectedActivityLevel,
          activeColor: Colors.green.shade600,
          onChanged: (String? value) {
            HapticFeedback.selectionClick();
            setState(() {
              _selectedActivityLevel = value;
            });
          },
        ),
      ),
    );
  }
}
