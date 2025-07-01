import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'name_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();

  bool _isLogin = true;
  bool _obscurePassword = true;

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

    // Add focus listeners for better UX
    _emailFocus.addListener(() {
      setState(() {});
    });
    _passwordFocus.addListener(() {
      setState(() {});
    });
    _nameFocus.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _nameFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    // If in login mode and user clicks "Sign Up", navigate back to welcome screen
    if (_isLogin) {
      // Add haptic feedback
      HapticFeedback.mediumImpact();
      // Navigate back to welcome screen
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      // If in sign up mode, toggle to login mode
      setState(() {
        _isLogin = !_isLogin;
      });
      // Add haptic feedback
      HapticFeedback.mediumImpact();
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
    // Add haptic feedback
    HapticFeedback.selectionClick();
  }

  Future<void> _authenticate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Validate inputs
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    // Add haptic feedback
    HapticFeedback.mediumImpact();

    bool success;
    if (_isLogin) {
      success = await authProvider.signInWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    } else {
      success = await authProvider.registerWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );
    }

    if (success && mounted) {
      // Navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NameScreen(),
        ),
      );
    } else if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.error ?? "Authentication failed")),
      );
    }
  }

  // Show the forgot password dialog
  void _showForgotPasswordDialog(BuildContext context, AuthProvider authProvider) {
    final resetEmailController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isEmailVerified = false;
    bool isLoading = false;
    bool isSuccess = false;
    bool isError = false;
    String errorMessage = '';

    // Password strength variables
    int passwordStrength = 0;
    String passwordStrengthText = 'Weak';
    Color passwordStrengthColor = Colors.red;

    // Function to calculate password strength
    void calculatePasswordStrength(String password) {
      passwordStrength = 0;
      if (password.length >= 8) passwordStrength++;
      if (password.contains(RegExp(r'[A-Z]'))) passwordStrength++;
      if (password.contains(RegExp(r'[0-9]'))) passwordStrength++;
      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) passwordStrength++;

      switch (passwordStrength) {
        case 0:
        case 1:
          passwordStrengthText = 'Weak';
          passwordStrengthColor = Colors.red;
          break;
        case 2:
          passwordStrengthText = 'Medium';
          passwordStrengthColor = Colors.orange;
          break;
        case 3:
          passwordStrengthText = 'Strong';
          passwordStrengthColor = Colors.yellow.shade800;
          break;
        case 4:
          passwordStrengthText = 'Very Strong';
          passwordStrengthColor = Colors.green;
          break;
      }
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container(); // This is not used but required
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.all(0),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  constraints: BoxConstraints(
                    maxWidth: 400,
                    maxHeight: isEmailVerified ? 400 : 300,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with gradient
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade300, Colors.green.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                isEmailVerified ? Icons.lock_reset : Icons.email,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                isEmailVerified ? "Reset Your Password" : "Verify Your Email",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (!isEmailVerified)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0, left: 20, right: 20),
                                  child: Text(
                                    "Enter your email to reset your password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Content
                      Flexible(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: isSuccess
                              ? _buildSuccessContent()
                              : isError
                                  ? _buildErrorContent(errorMessage)
                                  : isEmailVerified
                                      ? _buildPasswordResetContent(
                                          newPasswordController,
                                          confirmPasswordController,
                                          passwordStrength,
                                          passwordStrengthText,
                                          passwordStrengthColor,
                                          (password) {
                                            setState(() {
                                              calculatePasswordStrength(password);
                                            });
                                          },
                                        )
                                      : _buildEmailVerificationContent(resetEmailController),
                        ),
                      ),

                      // Actions
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: isLoading ? null : () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                              ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: isLoading || isSuccess ? null : () async {
                                if (isEmailVerified) {
                                  // Reset password
                                  final newPassword = newPasswordController.text.trim();
                                  final confirmPassword = confirmPasswordController.text.trim();

                                  if (newPassword.isEmpty) {
                                    setState(() {
                                      isError = true;
                                      errorMessage = "Please enter a new password";
                                    });
                                    return;
                                  }

                                  if (newPassword != confirmPassword) {
                                    setState(() {
                                      isError = true;
                                      errorMessage = "Passwords do not match";
                                    });
                                    return;
                                  }

                                  if (passwordStrength < 2) {
                                    setState(() {
                                      isError = true;
                                      errorMessage = "Password is too weak. Include uppercase, numbers, and special characters.";
                                    });
                                    return;
                                  }

                                  setState(() {
                                    isLoading = true;
                                    isError = false;
                                  });

                                  final email = resetEmailController.text.trim();
                                  final success = await authProvider.resetPassword(email, newPassword);

                                  setState(() {
                                    isLoading = false;
                                    isSuccess = success;
                                    if (!success) {
                                      isError = true;
                                      errorMessage = authProvider.error ?? "Failed to reset password";
                                    }
                                  });

                                  if (success) {
                                    Future.delayed(const Duration(seconds: 2), () {
                                      Navigator.pop(context);
                                    });
                                  }
                                } else {
                                  // Verify email
                                  final email = resetEmailController.text.trim();
                                  if (email.isEmpty) {
                                    setState(() {
                                      isError = true;
                                      errorMessage = "Please enter your email";
                                    });
                                    return;
                                  }

                                  setState(() {
                                    isLoading = true;
                                    isError = false;
                                  });

                                  final exists = await authProvider.resetPassword(email);

                                  setState(() {
                                    isLoading = false;
                                    if (exists) {
                                      isEmailVerified = true;
                                    } else {
                                      isError = true;
                                      errorMessage = authProvider.error ?? "Email not found";
                                    }
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 3,
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isEmailVerified ? "Reset Password" : "Verify Email",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Build success content for the dialog
  Widget _buildSuccessContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: Colors.green.shade700,
            size: 50,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Password Reset Successfully!",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          "You can now sign in with your new password.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build error content for the dialog
  Widget _buildErrorContent(String errorMessage) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error,
            color: Colors.red.shade700,
            size: 50,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Error",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          errorMessage,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build email verification content for the dialog
  Widget _buildEmailVerificationContent(TextEditingController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: "Enter your email",
            prefixIcon: Icon(Icons.email, color: Colors.green.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "We'll verify if this email exists in our system.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  // Build password reset content for the dialog
  Widget _buildPasswordResetContent(
    TextEditingController newPasswordController,
    TextEditingController confirmPasswordController,
    int passwordStrength,
    String passwordStrengthText,
    Color passwordStrengthColor,
    Function(String) onPasswordChanged,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Create a new password for your account",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: newPasswordController,
          obscureText: true,
          onChanged: onPasswordChanged,
          decoration: InputDecoration(
            hintText: "New Password",
            prefixIcon: Icon(Icons.lock, color: Colors.green.shade600),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.green.shade400, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Password strength indicator
        Row(
          children: [
            Text(
              "Password Strength: ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
            Text(
              passwordStrengthText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: passwordStrengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        // Password strength bar
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Flexible(
                flex: passwordStrength,
                child: Container(
                  decoration: BoxDecoration(
                    color: passwordStrengthColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Flexible(
                flex: 4 - passwordStrength,
                child: Container(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Include uppercase, numbers, and special characters for a stronger password.",
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        // Confirm password field with clear label
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Confirm Password",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Re-enter your password",
                prefixIcon: Icon(Icons.lock_outline, color: Colors.green.shade600),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Both passwords must match exactly.",
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool isFocused = focusNode.hasFocus;
    final bool hasValue = controller.text.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: TweenAnimationBuilder<double>(
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
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword ? _obscurePassword : false,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIcon: Icon(
                prefixIcon,
                color: isFocused ? Colors.green.shade600 : Colors.grey.shade500,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: _togglePasswordVisibility,
                    )
                  : null,
            ),
            onChanged: (_) {
              // Trigger haptic feedback on input
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                child: Column(
                  children: [
                    // App logo/icon with gradient
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Container(
                        width: 100,
                        height: 100,
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
                            Icons.restaurant_menu,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // Title with improved styling
                    Text(
                      _isLogin ? "Welcome Back" : "Create Account",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      _isLogin 
                          ? "Sign in to continue your nutrition journey" 
                          : "Join us for a healthier lifestyle",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Name field (only for registration)
                    if (!_isLogin)
                      _buildTextField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        hintText: 'Your Name',
                        prefixIcon: Icons.person,
                      ),

                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: 'Email Address',
                      prefixIcon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                    ),

                    // Forgot password (only for login)
                    if (_isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 32, top: 8),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.95, end: 1.0),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.elasticOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: InkWell(
                              onTap: () {
                                // Handle forgot password
                                HapticFeedback.lightImpact();
                                _showForgotPasswordDialog(context, authProvider);
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade50, Colors.green.shade100],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.shade100.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.lock_reset,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Forgot Password?",
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Sign in/Register button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _authenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                          elevation: 5,
                          shadowColor: Colors.green.shade200,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLogin ? "Sign In" : "Create Account",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Toggle between login and register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        GestureDetector(
                          onTap: _toggleAuthMode,
                          child: Text(
                            _isLogin ? "Sign Up" : "Sign In",
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

            // Back button
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

            // Loading overlay
            if (authProvider.isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
