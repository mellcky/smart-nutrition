import 'package:diet_app/screens/summarize_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/userprofile_provider.dart';
import '../providers/auth_provider.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});
  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _isSignUp = true; // Toggle between sign up and sign in
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Animation controller
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

    // Add focus listeners for better UX
    _nameFocus.addListener(() {
      setState(() {});
    });

    _emailFocus.addListener(() {
      setState(() {});
    });

    _passwordFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle email/password authentication
  Future<void> _handleEmailPasswordAuth() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validate inputs
    if (_isSignUp && name.isEmpty) {
      _showError("Please enter your name");
      return;
    }

    if (email.isEmpty) {
      _showError("Please enter your email");
      return;
    }

    if (password.isEmpty) {
      _showError("Please enter your password");
      return;
    }

    // Clear any previous errors
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      bool success;

      if (_isSignUp) {
        // Register new user
        print("Registering new user with email: $email and name: $name");
        success = await authProvider.registerWithEmailPassword(
          email,
          password,
          name,
        );
        print("Registration result: $success");
      } else {
        // Sign in existing user
        print("Signing in existing user with email: $email");
        success = await authProvider.signInWithEmailPassword(email, password);
        print("Sign in result: $success");
      }

      if (success) {
        // Save name to profile if signing up
        if (_isSignUp) {
          print("Updating UserProfileProvider with name: $name");
          Provider.of<UserProfileProvider>(
            context,
            listen: false,
          ).updateName(name);
          print("UserProfileProvider updated successfully");
        }

        setState(() {
          _isLoading = false;
        });

        _navigateToSummary();
      } else {
        setState(() {
          _errorMessage = authProvider.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Authentication error: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Handle Google Sign-In (now shows a message that it's not available)
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );
      print("Starting Google Sign-In process...");
      final success = await authProvider.signInWithGoogle();
      print("Google Sign-In result: $success");

      // This will always be false with our SQLite implementation
      setState(() {
        _errorMessage = authProvider.error;
        _isLoading = false;
      });
    } catch (e) {
      print("Google Sign-In error: $e");
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Show error message
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  // Navigate to summary screen
  void _navigateToSummary() {
    // Move to the next page with transition
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const SummaryScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  // Helper method to build consistent input fields
  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    TextInputType textInputType = TextInputType.text,
    bool isPassword = false,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasValue = controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isFocused ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isFocused
                  ? Colors.green.shade400
                  : hasValue
                  ? Colors.green.shade200
                  : Colors.grey.shade300,
          width: isFocused ? 2 : 1,
        ),
        boxShadow:
            isFocused
                ? [
                   BoxShadow(
                    color: Colors.green.shade100.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                : [],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isPassword && _obscurePassword,
        keyboardType: textInputType,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(
            icon,
            color: isFocused ? Colors.green.shade600 : Colors.grey.shade500,
            size: 20,
          ),
          suffixIcon:
              isPassword
                  ? IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (_) {
          // Trigger haptic feedback on input
          HapticFeedback.selectionClick();
        },
      ),
    );
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
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Progress indicator
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: LinearProgressIndicator(
                            value: 0.98, // Almost complete
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green.shade300,
                            ),
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
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // Title with improved styling
                        Text(
                          _isSignUp ? "Create Your Account" : "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          _isSignUp
                              ? "Sign up to track your nutrition journey"
                              : "Sign in to continue your journey",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 30),

                        // Error message if any
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade400,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Name field (only for sign up)
                        if (_isSignUp)
                          _buildInputField(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            hintText: "Your name",
                            icon: Icons.person_outline,
                            textInputType: TextInputType.name,
                          ),

                        const SizedBox(height: 16),

                        // Email field
                        _buildInputField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          hintText: "Email address",
                          icon: Icons.email_outlined,
                          textInputType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        _buildInputField(
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          hintText: "Password",
                          icon: Icons.lock_outline,
                          isPassword: true,
                          textInputType: TextInputType.visiblePassword,
                        ),

                        const SizedBox(height: 30),

                        // Sign in/up button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _handleEmailPasswordAuth,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                              shadowColor: Colors.green.shade200,
                            ),
                            child:
                                _isLoading
                                    ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                    : Text(
                                      _isSignUp ? "Sign Up" : "Sign In",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Toggle between sign in and sign up
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isSignUp
                                  ? "Already have an account? "
                                  : "Don't have an account? ",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isSignUp = !_isSignUp;
                                  _errorMessage = null;
                                });
                                HapticFeedback.selectionClick();
                              },
                              child: Text(
                                _isSignUp ? "Sign In" : "Sign Up",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Fixed Back Arrow with child parameter
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
