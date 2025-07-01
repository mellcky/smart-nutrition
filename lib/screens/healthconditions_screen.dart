import 'package:diet_app/screens/name_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/providers/userprofile_provider.dart';
import 'package:provider/provider.dart';

class HealthConditionsScreen extends StatefulWidget {
  const HealthConditionsScreen({super.key});

  @override
  _HealthConditionsScreenState createState() => _HealthConditionsScreenState();
}

class _HealthConditionsScreenState extends State<HealthConditionsScreen> with SingleTickerProviderStateMixin {
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
    _otherConditionsController.dispose();
    _otherConditionsFocusNode.dispose();
    super.dispose();
  }
  final List<String> _selectedConditions = [];
  final TextEditingController _otherConditionsController = TextEditingController();
  final List<String> _customConditions = [];
  final FocusNode _otherConditionsFocusNode = FocusNode();

  final List<Map<String, String>> _conditions = [
    {'emoji': '✅', 'label': 'No health conditions'},
    {'emoji': '🩸', 'label': 'Diabetes'},
    {'emoji': '💓', 'label': 'Hypertension'},
    {'emoji': '🧈', 'label': 'High cholesterol'},
    {'emoji': '🫁', 'label': 'Asthma'},
    {'emoji': '🦴', 'label': 'Arthritis'},
  ];

  void _toggleSelection(String label) {
    setState(() {
      if (_selectedConditions.contains(label)) {
        _selectedConditions.remove(label);
      } else {
        _selectedConditions.add(label);
      }
    });
  }

  void _addCustomCondition() {
    final text = _otherConditionsController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _customConditions.add(text);
        _otherConditionsController.clear();
      });
      // Add haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  void _removeCustomCondition(String condition) {
    setState(() {
      _customConditions.remove(condition);
    });
    // Add haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
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
                      value: 0.9, // Almost complete
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
                      minHeight: 5,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // App logo/icon with gradient
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      width: 90,
                      height: 90,
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
                          Icons.health_and_safety,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Title with improved styling
                  Text(
                    "Health Conditions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Do you have any health conditions?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Checkbox list + text input
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        ..._conditions.map(
                          (condition) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: _selectedConditions.contains(condition['label']) 
                                  ? Colors.green.shade50 
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _selectedConditions.contains(condition['label'])
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              title: Text(
                                "${condition['emoji']} ${condition['label']}",
                                style: TextStyle(
                                  fontWeight: _selectedConditions.contains(condition['label'])
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedConditions.contains(condition['label'])
                                      ? Colors.green.shade700
                                      : Colors.black87,
                                ),
                              ),
                              value: _selectedConditions.contains(condition['label']),
                              onChanged: (_) {
                                HapticFeedback.selectionClick();
                                _toggleSelection(condition['label']!);
                              },
                              activeColor: Colors.green.shade600,
                              checkColor: Colors.white,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,  // Darker background for better visibility
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade400, width: 2),  // Add border for emphasis
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade200,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "🧾 Other Conditions - Add Your Own",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,  // Larger font size
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Display custom conditions as chips
                              if (_customConditions.isNotEmpty) ...[
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _customConditions.map((condition) {
                                    return TweenAnimationBuilder<double>(
                                      duration: const Duration(milliseconds: 300),
                                      tween: Tween<double>(begin: 0.0, end: 1.0),
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: Opacity(
                                            opacity: value,
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Chip(
                                        label: Text(condition),
                                        backgroundColor: Colors.green.shade100,
                                        deleteIconColor: Colors.green.shade700,
                                        onDeleted: () => _removeCustomCondition(condition),
                                        elevation: 2,
                                        shadowColor: Colors.green.shade200,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Input field with add button
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _otherConditionsController,
                                      focusNode: _otherConditionsFocusNode,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Enter any other health conditions",
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(10),
                                          borderSide: BorderSide(color: Colors.green.shade600, width: 3),
                                        ),
                                        prefixIcon: Icon(Icons.add_circle_outline, color: Colors.green.shade600),
                                      ),
                                      onChanged: (_) {
                                        // Trigger haptic feedback on input
                                        HapticFeedback.selectionClick();
                                      },
                                      onSubmitted: (_) => _addCustomCondition(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 56, // Match TextField height
                                    width: 80, // Wider button for better visibility
                                    child: ElevatedButton(
                                      onPressed: _addCustomCondition,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        elevation: 4, // Add elevation for better visibility
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 20),
                                          SizedBox(width: 4),
                                          Text("Add", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Helper text with arrow indicator
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.keyboard_double_arrow_up,
                                      color: Colors.green.shade600,
                                      size: 20,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Type here to add your own health conditions! Press Enter or the Add button.",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Add a "Text Input Available" label
                              Container(
                                margin: EdgeInsets.only(top: 8),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "TEXT INPUT AVAILABLE HERE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Spacer to push button to bottom
                  const Spacer(),

                  // Enhanced continue button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add haptic feedback
                        HapticFeedback.mediumImpact();

                        final userProfile = Provider.of<UserProfileProvider>(
                          context,
                          listen: false,
                        );

                        // Create a copy of the selected conditions
                        List<String> conditions = List.from(_selectedConditions);

                        // Add any custom conditions from the chips
                        if (_customConditions.isNotEmpty) {
                          conditions.addAll(_customConditions);
                        }

                        // Add any text currently in the input field
                        String other = _otherConditionsController.text.trim();
                        if (other.isNotEmpty) {
                          conditions.add(other);
                        }

                        userProfile.updateHealthConditions(conditions);

                        // Move to the next page with transition
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => 
                              const NameScreen(),
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
        ),
      ),
    );
  }
}
