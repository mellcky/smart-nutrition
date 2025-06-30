import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/providers/userprofile_provider.dart';
import '/screens/dietarygoals_screen.dart'; // Assuming this is the next screen in the flow

class RestrictionsScreen extends StatefulWidget {
  const RestrictionsScreen({super.key});

  @override
  State<RestrictionsScreen> createState() => _RestrictionsScreenState();
}

class _RestrictionsScreenState extends State<RestrictionsScreen> with SingleTickerProviderStateMixin {
  // List of common dietary restrictions
  final List<String> _commonRestrictions = [
    'Gluten',
    'Dairy',
    'Nuts',
    'Eggs',
    'Soy',
    'Shellfish',
    'Fish',
    'Pork',
    'Beef',
    'Vegetarian',
    'Vegan',
  ];

  // Selected restrictions
  final List<String> _selectedRestrictions = [];

  // Controller for custom restriction input
  final TextEditingController _customRestrictionController = TextEditingController();

  // List of custom restrictions added by the user
  final List<String> _customRestrictions = [];

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Focus node for custom input
  final FocusNode _customFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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

    // Add listener for focus changes
    _customFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customRestrictionController.dispose();
    _customFocusNode.dispose();
    super.dispose();
  }

  // Toggle a restriction selection
  void _toggleRestriction(String restriction) {
    setState(() {
      if (_selectedRestrictions.contains(restriction)) {
        _selectedRestrictions.remove(restriction);
      } else {
        _selectedRestrictions.add(restriction);
      }
    });
    // Provide haptic feedback
    HapticFeedback.selectionClick();
  }

  // Add a custom restriction
  void _addCustomRestriction() {
    final String restriction = _customRestrictionController.text.trim();
    if (restriction.isNotEmpty) {
      setState(() {
        // Add to both lists to track and display
        _customRestrictions.add(restriction);
        _selectedRestrictions.add(restriction);
        _customRestrictionController.clear();
      });
      // Provide haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  // Remove a custom restriction
  void _removeCustomRestriction(String restriction) {
    setState(() {
      _customRestrictions.remove(restriction);
      _selectedRestrictions.remove(restriction);
    });
    // Provide haptic feedback
    HapticFeedback.selectionClick();
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
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: LinearProgressIndicator(
                      value: 0.65, // Adjust based on position in onboarding flow
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
                      minHeight: 6,
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
                          Icons.no_food,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    "Dietary Restrictions",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Question
                  Text(
                    "Do you have any dietary restrictions?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Subtitle
                  Text(
                    "Select all that apply",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scrollable list of common restrictions
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Common restrictions grid
                          // Text(
                          //   "Common Restrictions",
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.w600,
                          //     color: Colors.grey.shade800,
                          //   ),
                          // ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 1.8,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: _commonRestrictions.length,
                            itemBuilder: (context, index) {
                              final restriction = _commonRestrictions[index];
                              final isSelected = _selectedRestrictions.contains(restriction);
                              return _buildRestrictionCard(restriction, isSelected);
                            },
                          ),

                          const SizedBox(height: 20),

                          // Custom restrictions section
                          Text(
                            "Other Restrictions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Custom restriction input
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _customFocusNode.hasFocus ? Colors.green.shade50 : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: _customFocusNode.hasFocus 
                                          ? Colors.green.shade400 
                                          : Colors.grey.shade300,
                                      width: _customFocusNode.hasFocus ? 1.5 : 1,
                                    ),
                                    boxShadow: _customFocusNode.hasFocus
                                        ? [
                                            BoxShadow(
                                              color: Colors.green.shade100.withOpacity(0.4),
                                              blurRadius: 4,
                                              spreadRadius: 0.5,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: TextField(
                                    controller: _customRestrictionController,
                                    focusNode: _customFocusNode,
                                    decoration: InputDecoration(
                                      hintText: "Enter a food restriction",
                                      hintStyle: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                    onSubmitted: (_) => _addCustomRestriction(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade600,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade200.withOpacity(0.4),
                                      blurRadius: 4,
                                      spreadRadius: 0.5,
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                  padding: EdgeInsets.zero,
                                  onPressed: _addCustomRestriction,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 15),

                          // Display custom restrictions
                          if (_customRestrictions.isNotEmpty) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _customRestrictions.map((restriction) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        restriction,
                                        style: TextStyle(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: 3),
                                      InkWell(
                                        onTap: () => _removeCustomRestriction(restriction),
                                        child: Icon(
                                          Icons.close,
                                          size: 14,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Continue button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        // Add haptic feedback
                        HapticFeedback.mediumImpact();

                        // Update the user profile with selected restrictions
                        final profileProvider = Provider.of<UserProfileProvider>(
                          context,
                          listen: false,
                        );
                        profileProvider.updateDietRestrictions(_selectedRestrictions);

                        // Navigate to the next screen
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => 
                              const DietaryGoalsScreen(),
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

            // Positioned Back Arrow
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

  // Helper method to build restriction selection cards
  Widget _buildRestrictionCard(String restriction, bool isSelected) {
    return GestureDetector(
      onTap: () => _toggleRestriction(restriction),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green.shade400 : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.green.shade100.withOpacity(0.4),
                    blurRadius: 4,
                    spreadRadius: 0.5,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Main content
            Center(
              child: Text(
                restriction,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.green.shade400,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
