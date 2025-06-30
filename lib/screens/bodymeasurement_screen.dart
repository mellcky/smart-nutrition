import 'package:diet_app/screens/activity_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '/providers/userprofile_provider.dart';

class BodyMeasurementScreen extends StatefulWidget {
  const BodyMeasurementScreen({super.key});

  @override
  BodyMeasurementScreenState createState() => BodyMeasurementScreenState();
}

class BodyMeasurementScreenState extends State<BodyMeasurementScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _bmi = "Auto-calculated";
  String _bmiCategory = "";
  String _bmiEmoji = "";
  Color _bmiColor = Colors.grey;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Focus nodes for text fields
  final FocusNode _heightFocus = FocusNode();
  final FocusNode _weightFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_calculateBMI);
    _weightController.addListener(_calculateBMI);

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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Add focus listeners for better UX
    _heightFocus.addListener(() {
      setState(() {});
    });

    _weightFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _heightController.removeListener(_calculateBMI);
    _weightController.removeListener(_calculateBMI);
    _heightController.dispose();
    _weightController.dispose();
    _animationController.dispose();
    _heightFocus.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      double heightInMeters = height / 100;
      double bmi = weight / (heightInMeters * heightInMeters);
      setState(() {
        _bmi = bmi.toStringAsFixed(1);
        _bmiCategory = _getBMICategory(bmi);
        _bmiEmoji = _getBMIEmoji(bmi);
        _bmiColor = _getBMIColor(bmi);
      });
    } else {
      setState(() {
        _bmi = "Auto-calculated";
        _bmiCategory = "";
        _bmiEmoji = "";
        _bmiColor = Colors.grey;
      });
    }
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    if (bmi < 35) return "Obese";
    return "Extremely Obese";
  }

  String _getBMIEmoji(double bmi) {
    if (bmi < 18.5) return "😟";
    if (bmi < 25) return "😊";
    if (bmi < 30) return "⚖️";
    if (bmi < 35) return "😓";
    return "🚨";
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    if (bmi < 35) return Colors.deepOrange;
    return Colors.red;
  }


  @override
  Widget build(BuildContext context) {
    final bool isFormValid = _heightController.text.isNotEmpty && 
                            _weightController.text.isNotEmpty &&
                            double.tryParse(_heightController.text) != null &&
                            double.tryParse(_weightController.text) != null &&
                            double.tryParse(_heightController.text)! > 0 &&
                            double.tryParse(_weightController.text)! > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
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
                      value: 0.5, // 2/4 of the onboarding process
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // App logo/icon with gradient - smaller size
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
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
                            Icons.straighten,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title with improved styling
                  Text(
                    "Body Measurements",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "What's your height and weight?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Input fields in a row for more compact layout
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // HEIGHT input with improved styling
                        Expanded(
                          child: _buildMeasurementInput(
                            icon: Icons.height,
                            label: "Height",
                            controller: _heightController,
                            focusNode: _heightFocus,
                            hint: "Enter height",
                            suffix: "cm",
                          ),
                        ),

                        const SizedBox(width: 15),

                        // WEIGHT input with improved styling
                        Expanded(
                          child: _buildMeasurementInput(
                            icon: Icons.monitor_weight_outlined,
                            label: "Weight",
                            controller: _weightController,
                            focusNode: _weightFocus,
                            hint: "Enter weight",
                            suffix: "kg",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BMI display with improved styling and animations
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _bmi != "Auto-calculated" 
                            ? 1.0 
                            : _scaleAnimation.value,
                        child: child,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      width: 260,
                      decoration: BoxDecoration(
                        color: _bmi == "Auto-calculated" 
                            ? Colors.grey.shade50 
                            : _bmiColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _bmi == "Auto-calculated" 
                              ? Colors.grey.shade300 
                              : _bmiColor.withOpacity(0.5),
                          width: 2,
                        ),
                        boxShadow: _bmi == "Auto-calculated" 
                            ? [] 
                            : [
                                BoxShadow(
                                  color: _bmiColor.withOpacity(0.2),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "BODY MASS INDEX (BMI)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_bmi != "Auto-calculated") ...[
                                Text(
                                  _bmi,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: _bmiColor,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _bmiEmoji,
                                  style: const TextStyle(
                                    fontSize: 32,
                                  ),
                                ),
                              ] else ...[
                                Icon(
                                  Icons.calculate_outlined,
                                  size: 24,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _bmi,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (_bmiCategory.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _bmiColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _bmiCategory,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _bmiColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Enhanced continue button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: ElevatedButton(
                      onPressed: isFormValid ? () {
                        // Add haptic feedback
                        HapticFeedback.mediumImpact();

                        final height = double.parse(_heightController.text);
                        final weight = double.parse(_weightController.text);

                        final profileProvider = Provider.of<UserProfileProvider>(
                          context,
                          listen: false,
                        );

                        profileProvider.updateHeight(height);
                        profileProvider.updateWeight(weight);

                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => 
                              const ActivityLevelScreen(),
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
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.green.shade200,
                        disabledForegroundColor: Colors.white70,
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

  // Helper method to build consistent measurement input fields
  Widget _buildMeasurementInput({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String suffix,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasValue = controller.text.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Padding(
            padding: const EdgeInsets.only(left: 5, bottom: 5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isFocused ? Colors.green.shade700 : Colors.grey.shade700,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isFocused ? Colors.green.shade700 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          // Input field with animation
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.95, end: isFocused ? 1.05 : 1.0),
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutQuad,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 50,
              decoration: BoxDecoration(
                color: isFocused ? Colors.green.shade50 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused 
                      ? Colors.green.shade400 
                      : hasValue 
                          ? Colors.green.shade200 
                          : Colors.grey.shade300,
                  width: isFocused ? 2 : 1,
                ),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: Colors.green.shade100.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 16,
                    ),
                    suffixText: suffix,
                    suffixStyle: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (_) {
                    // Trigger haptic feedback on input
                    HapticFeedback.selectionClick();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
